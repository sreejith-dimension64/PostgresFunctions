CREATE OR REPLACE FUNCTION "dbo"."FEE_RebateGroupwise_Calculation_Both"(
    p_MI_Id VARCHAR(500),
    p_ASMAY_ID VARCHAR(500),
    p_AMST_ID VARCHAR(500),
    p_FMG_ID TEXT,
    p_FTI_ID TEXT,
    p_paiddate DATE,
    p_paidamount BIGINT,
    p_USERID VARCHAR(25)
)
RETURNS TABLE("RebateAmount" BIGINT) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMC_RebateAplicableFlg BOOLEAN;
    v_FMC_RebateAgainstFullPaymentFlg BOOLEAN;
    v_FMC_RebateAgainstPartialPaymentFlg BOOLEAN;
    v_FYREBSET_RebateTypeFlg VARCHAR(50);
    v_FYREBSET_RebateDate DATE;
    v_FYREBSET_RebateAmtOrPercentValue DECIMAL(18,2);
    v_totalyrcharges BIGINT;
    v_FYGH_RebateApplicableFlg BOOLEAN;
    v_FYG_RebateTypeFlg VARCHAR(50);
    v_FYG_PartialRebateAmtOrPercentageValue DECIMAL(18,2);
    v_CurrentYrCharges BIGINT;
    v_FMG_IDFullpayment BIGINT;
    v_FMH_IDFullpayment BIGINT;
    v_FTI_IDFullpayment BIGINT;
    v_rebateamount BIGINT;
    v_FMG_IDFullpaymentamt BIGINT;
    v_FMH_IDFullpaymentamt BIGINT;
    v_FTI_IDFullpaymentamt BIGINT;
    v_FMA_PartialRebateApplicableDate DATE;
    v_FMG_IDPartialpercent BIGINT;
    v_FMH_IDPartialpercent BIGINT;
    v_FMT_IDPartialpercent BIGINT;
    v_FTI_IDPartialpercent BIGINT;
    v_count BIGINT;
    v_totalrebateamount BIGINT;
    rec RECORD;
BEGIN
    
    v_totalrebateamount := 0;
    
    DROP TABLE IF EXISTS groupheadinstallment_temp;
    
    SELECT "FMC_RebateAplicableFlg", "FMC_RebateAgainstFullPaymentFlg", "FMC_RebateAgainstPartialPaymentFlg"
    INTO v_FMC_RebateAplicableFlg, v_FMC_RebateAgainstFullPaymentFlg, v_FMC_RebateAgainstPartialPaymentFlg
    FROM "Fee_Master_Configuration" 
    WHERE "MI_ID" = p_MI_Id::BIGINT AND "userid" = p_USERID::BIGINT;
    
    SELECT "FYREBSET_RebateTypeFlg", "FYREBSET_RebateDate", "FYREBSET_RebateAmtOrPercentValue"
    INTO v_FYREBSET_RebateTypeFlg, v_FYREBSET_RebateDate, v_FYREBSET_RebateAmtOrPercentValue
    FROM "Fee_Yearly_RebateSetting" 
    WHERE "MI_ID" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;
    
    EXECUTE '
    CREATE TEMP TABLE groupheadinstallment_temp AS
    SELECT DISTINCT B."FMG_Id", B."FMH_Id", D."FTI_Id"
    FROM "Fee_Yearly_Group" A
    INNER JOIN "Fee_Yearly_Group_Head_Mapping" B ON A."FMG_Id" = B."FMG_Id" AND A."MI_Id" = B."MI_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "Fee_Master_Installment" C ON C."FMI_Id" = B."FMI_Id" AND C."MI_Id" = B."MI_Id"
    INNER JOIN "Fee_T_Installment" D ON D."FMI_Id" = C."FMI_Id" AND C."MI_Id" = D."MI_Id"
    WHERE A."MI_ID" = ' || p_MI_ID || ' AND A."ASMAY_Id" = ' || p_ASMAY_ID || ' 
    AND A."FMG_ID" IN (' || p_FMG_ID || ') AND D."FTI_ID" IN (' || p_FTI_ID || ') 
    AND A."FYG_ActiveFlag" = true AND A."FYG_RebateApplicableFlg" = true';
    
    SELECT SUM("FSS_CurrentYrCharges") INTO v_totalyrcharges
    FROM "Fee_Student_Status" 
    WHERE "MI_Id" = p_MI_ID::BIGINT 
    AND "ASMAY_Id" = p_ASMAY_ID::BIGINT 
    AND "FMG_Id" IN (SELECT DISTINCT "FMG_ID" FROM groupheadinstallment_temp) 
    AND "FMH_Id" IN (SELECT DISTINCT "FMH_Id" FROM groupheadinstallment_temp)
    AND "FTI_Id" IN (SELECT DISTINCT "FTI_Id" FROM groupheadinstallment_temp) 
    AND "AMST_ID" = p_AMST_ID::BIGINT;
    
    SELECT COUNT(*) INTO v_count FROM groupheadinstallment_temp;
    
    IF (v_FMC_RebateAplicableFlg = true AND v_FMC_RebateAgainstFullPaymentFlg = true AND v_FMC_RebateAgainstPartialPaymentFlg = true) THEN
        
        IF (p_paidamount >= v_totalyrcharges) THEN
            
            FOR rec IN SELECT * FROM groupheadinstallment_temp
            LOOP
                v_FMG_IDFullpayment := rec."FMG_Id";
                v_FMH_IDFullpayment := rec."FMH_Id";
                v_FTI_IDFullpayment := rec."FTI_Id";
                
                SELECT "FYG_RebateApplicableFlg", "FYG_RebateTypeFlg"
                INTO v_FYGH_RebateApplicableFlg, v_FYG_RebateTypeFlg
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = p_MI_Id::BIGINT 
                AND "ASMAY_Id" = p_ASMAY_ID::BIGINT 
                AND "FMG_ID" = v_FMG_IDFullpayment;
                
                IF (v_FYGH_RebateApplicableFlg = true AND v_FYG_RebateTypeFlg = 'Percentage') THEN
                    
                    IF (v_FYREBSET_RebateTypeFlg = 'Percentage') THEN
                        
                        SELECT "FSS_CurrentYrCharges" INTO v_CurrentYrCharges
                        FROM "Fee_Student_Status" 
                        WHERE "MI_ID" = p_MI_Id::BIGINT 
                        AND "ASMAY_Id" = p_ASMAY_ID::BIGINT 
                        AND "FMG_ID" = v_FMG_IDFullpayment
                        AND "FMH_Id" = v_FMH_IDFullpayment 
                        AND "FTI_Id" = v_FTI_IDFullpayment 
                        AND "AMST_ID" = p_AMST_ID::BIGINT;
                        
                        IF (p_paiddate <= v_FYREBSET_RebateDate) THEN
                            v_rebateamount := ((v_CurrentYrCharges * v_FYREBSET_RebateAmtOrPercentValue) / 100);
                            v_totalrebateamount := v_totalrebateamount + v_rebateamount;
                        ELSE
                            v_totalrebateamount := 0;
                        END IF;
                        
                    END IF;
                    
                ELSIF (v_FYGH_RebateApplicableFlg = true AND v_FYG_RebateTypeFlg = 'Amount') THEN
                    
                    IF (v_FYREBSET_RebateTypeFlg = 'Amount') THEN
                        
                        IF (p_paiddate <= v_FYREBSET_RebateDate) THEN
                            v_rebateamount := (v_FYREBSET_RebateAmtOrPercentValue / v_count);
                            v_totalrebateamount := v_rebateamount;
                        ELSE
                            v_totalrebateamount := 0;
                        END IF;
                        
                    END IF;
                    
                END IF;
                
            END LOOP;
            
        ELSIF (p_paidamount < v_totalyrcharges) THEN
            
            FOR rec IN SELECT * FROM groupheadinstallment_temp
            LOOP
                v_FMG_IDPartialpercent := rec."FMG_Id";
                v_FMH_IDPartialpercent := rec."FMH_Id";
                v_FTI_IDPartialpercent := rec."FTI_Id";
                
                SELECT "FYG_RebateApplicableFlg", "FYG_RebateTypeFlg", "FYG_PartialRebateAmtOrPercentageValue"
                INTO v_FYGH_RebateApplicableFlg, v_FYG_RebateTypeFlg, v_FYG_PartialRebateAmtOrPercentageValue
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = p_MI_Id::BIGINT 
                AND "ASMAY_Id" = p_ASMAY_ID::BIGINT 
                AND "FMG_ID" = v_FMG_IDPartialpercent;
                
                SELECT "FMA_PartialRebateApplicableDate" INTO v_FMA_PartialRebateApplicableDate
                FROM "Fee_Master_Amount" 
                WHERE "MI_ID" = p_MI_Id::BIGINT 
                AND "ASMAY_ID" = p_ASMAY_ID::BIGINT
                AND "FMG_ID" = v_FMG_IDPartialpercent 
                AND "FMH_ID" = v_FMH_IDPartialpercent 
                AND "FTI_ID" = v_FTI_IDPartialpercent;
                
                IF (v_FYGH_RebateApplicableFlg = true AND v_FYG_RebateTypeFlg = 'Percentage') THEN
                    
                    v_FMA_PartialRebateApplicableDate := '1970-01-01';
                    v_FYGH_RebateApplicableFlg := NULL;
                    v_FYG_PartialRebateAmtOrPercentageValue := 0;
                    
                    SELECT "FSS_CurrentYrCharges" INTO v_CurrentYrCharges
                    FROM "Fee_Student_Status" 
                    WHERE "MI_ID" = p_MI_Id::BIGINT 
                    AND "ASMAY_Id" = p_ASMAY_ID::BIGINT 
                    AND "FMG_ID" = v_FMG_IDPartialpercent
                    AND "FMH_Id" = v_FMH_IDPartialpercent 
                    AND "FTI_Id" = v_FTI_IDPartialpercent 
                    AND "AMST_ID" = p_AMST_ID::BIGINT;
                    
                    IF (p_paiddate <= v_FMA_PartialRebateApplicableDate) THEN
                        v_rebateamount := ((v_CurrentYrCharges * v_FYG_PartialRebateAmtOrPercentageValue) / 100);
                        v_totalrebateamount := v_totalrebateamount + v_rebateamount;
                    ELSIF (v_FMA_PartialRebateApplicableDate != '1970-01-01') THEN
                        v_totalrebateamount := 0;
                    END IF;
                    
                ELSIF (v_FYGH_RebateApplicableFlg = true AND v_FYG_RebateTypeFlg = 'Amount') THEN
                    
                    v_FMA_PartialRebateApplicableDate := '1970-01-01';
                    v_FYGH_RebateApplicableFlg := NULL;
                    v_FYG_PartialRebateAmtOrPercentageValue := 0;
                    
                    IF (p_paiddate <= v_FMA_PartialRebateApplicableDate) THEN
                        v_rebateamount := v_FYG_PartialRebateAmtOrPercentageValue;
                        v_totalrebateamount := v_totalrebateamount + v_rebateamount;
                    ELSIF (v_FMA_PartialRebateApplicableDate != '1970-01-01') THEN
                        v_totalrebateamount := 0;
                    END IF;
                    
                END IF;
                
            END LOOP;
            
        END IF;
        
    ELSE
        v_totalrebateamount := 0;
    END IF;
    
    RETURN QUERY SELECT v_totalrebateamount;
    
END;
$$;