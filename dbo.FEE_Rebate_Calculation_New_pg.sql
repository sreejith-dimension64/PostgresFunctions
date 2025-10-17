CREATE OR REPLACE FUNCTION "dbo"."FEE_Rebate_Calculation_New"(
    p_MI_Id VARCHAR(500),
    p_ASMAY_ID VARCHAR(500),
    p_AMST_ID VARCHAR(500),
    p_FMG_ID TEXT,
    p_FMH_ID TEXT,
    p_FTI_ID TEXT,
    p_paiddate DATE,
    p_USERID BIGINT,
    INOUT p_totalrebateamount BIGINT DEFAULT 0
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMC_RebateAplicableFlg BOOLEAN;
    v_FMC_RebateAgainstFullPaymentFlg BOOLEAN;
    v_FMC_RebateAgainstPartialPaymentFlg BOOLEAN;
    v_FMA_ID BIGINT;
    v_FYREBSET_RebateTypeFlg VARCHAR(50);
    v_FYREBSET_RebateDate DATE;
    v_FYREBSET_RebateAmtOrPercentValue DECIMAL(18,2);
    v_COUNT VARCHAR(500);
    v_FYGH_RebateApplicableFlg BOOLEAN;
    v_FYGH_RebateTypeFlg VARCHAR(50);
    v_CurrentYrCharges BIGINT;
    v_FMG_IDFullpayment BIGINT;
    v_FMH_IDFullpayment BIGINT;
    v_FMI_IDFullpayment BIGINT;
    v_FTI_IDFullpayment BIGINT;
    v_rebateamount BIGINT;
    v_FMG_IDFullpaymentamt BIGINT;
    v_FMH_IDFullpaymentamt BIGINT;
    v_FMI_IDFullpaymentamt BIGINT;
    v_FTI_IDFullpaymentamt BIGINT;
    v_FYGH_PartialRebateAmtOrPercentageValue BIGINT;
    v_FMG_IDPartialpercent BIGINT;
    v_FMH_IDPartialpercent BIGINT;
    v_FMI_IDPartialpercent BIGINT;
    v_FTI_IDPartialpercent BIGINT;
    v_FMA_PartialRebateApplicableDate DATE;
    v_FMG_IDPartialamt BIGINT;
    v_FMH_IDPartialamt BIGINT;
    v_FMI_IDPartialamt BIGINT;
    v_FTI_IDPartialamt BIGINT;
    v_dynamic TEXT;
    v_dynamic1 TEXT;
    v_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS groupheadinstallment_temp;
    DROP TABLE IF EXISTS counttemp;

    SELECT "FMC_RebateAplicableFlg", "FMC_RebateAgainstFullPaymentFlg", "FMC_RebateAgainstPartialPaymentFlg"
    INTO v_FMC_RebateAplicableFlg, v_FMC_RebateAgainstFullPaymentFlg, v_FMC_RebateAgainstPartialPaymentFlg
    FROM "Fee_Master_Configuration" 
    WHERE "MI_ID" = p_MI_Id::BIGINT AND "USERID" = p_USERID AND "ASMAY_ID" != 0;

    SELECT "FYREBSET_RebateTypeFlg", "FYREBSET_RebateDate", "FYREBSET_RebateAmtOrPercentValue"
    INTO v_FYREBSET_RebateTypeFlg, v_FYREBSET_RebateDate, v_FYREBSET_RebateAmtOrPercentValue
    FROM "Fee_Yearly_RebateSetting" 
    WHERE "MI_ID" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_ID::BIGINT;

    v_rebateamount := 0;
    p_totalrebateamount := 0;

    v_dynamic := '
    CREATE TEMP TABLE groupheadinstallment_temp AS
    SELECT A."FMG_Id", A."FMH_Id", A."FMI_ID", C."FTI_Id"
    FROM "Fee_Yearly_Group_Head_Mapping" A
    INNER JOIN "FEE_MASTER_GROUP" D ON D."FMG_ID" = A."FMG_ID" AND D."MI_ID" = A."MI_ID"
    INNER JOIN "FEE_MASTER_HEAD" E ON E."FMH_ID" = A."FMH_ID" AND E."MI_ID" = A."MI_ID"
    INNER JOIN "Fee_Master_Installment" B ON B."FMI_Id" = A."FMI_Id" AND B."MI_ID" = A."MI_Id"
    INNER JOIN "Fee_T_Installment" C ON C."FMI_Id" = B."FMI_Id"
    WHERE A."MI_ID" = ' || p_MI_Id || ' AND A."ASMAY_Id" = ' || p_ASMAY_ID || ' AND D."FMG_ID" = ' || p_FMG_ID || ' 
    AND E."FMH_Id" IN (' || p_FMH_Id || ') AND C."FTI_Id" IN (' || p_FTI_ID || ')
    AND A."FYGHM_ActiveFlag" = TRUE AND B."FMI_ActiceFlag" = TRUE AND D."FMG_ActiceFlag" = TRUE AND E."FMH_ActiveFlag" = TRUE';
    
    EXECUTE v_dynamic;

    v_dynamic1 := '
    CREATE TEMP TABLE counttemp AS
    SELECT DISTINCT COUNT(*) AS count
    FROM "Fee_Yearly_Group_Head_Mapping" A
    INNER JOIN "FEE_MASTER_GROUP" D ON D."FMG_ID" = A."FMG_ID" AND D."MI_ID" = A."MI_ID"
    INNER JOIN "FEE_MASTER_HEAD" E ON E."FMH_ID" = A."FMH_ID" AND E."MI_ID" = A."MI_ID"
    INNER JOIN "Fee_Master_Installment" B ON B."FMI_Id" = A."FMI_Id" AND B."MI_ID" = A."MI_Id"
    INNER JOIN "Fee_T_Installment" C ON C."FMI_Id" = B."FMI_Id"
    WHERE A."MI_ID" = ' || p_MI_Id || ' AND A."ASMAY_Id" = ' || p_ASMAY_ID || ' AND D."FMG_ID" IN (' || p_FMG_ID || ') 
    AND E."FMH_Id" IN (' || p_FMH_Id || ') AND C."FTI_Id" IN (' || p_FTI_ID || ')
    AND A."FYGHM_ActiveFlag" = TRUE AND B."FMI_ActiceFlag" = TRUE AND D."FMG_ActiceFlag" = TRUE AND E."FMH_ActiveFlag" = TRUE';

    EXECUTE v_dynamic1;

    SELECT count INTO v_COUNT FROM counttemp;

    IF (v_FMC_RebateAplicableFlg = TRUE AND v_FMC_RebateAgainstFullPaymentFlg = TRUE AND v_FMC_RebateAgainstPartialPaymentFlg = FALSE) THEN
    
        IF (v_FYREBSET_RebateTypeFlg = 'Percentage') THEN

            FOR v_rec IN SELECT * FROM groupheadinstallment_temp LOOP
                v_FMG_IDFullpayment := v_rec."FMG_Id";
                v_FMH_IDFullpayment := v_rec."FMH_Id";
                v_FMI_IDFullpayment := v_rec."FMI_ID";
                v_FTI_IDFullpayment := v_rec."FTI_Id";

                SELECT "FYG_RebateApplicableFlg", "FYG_RebateTypeFlg"
                INTO v_FYGH_RebateApplicableFlg, v_FYGH_RebateTypeFlg
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_ID::BIGINT AND "FMG_ID" = v_FMG_IDFullpayment;

                IF (v_FYGH_RebateApplicableFlg = TRUE AND v_FYGH_RebateTypeFlg = 'Percentage') THEN

                    SELECT "FSS_CurrentYrCharges" INTO v_CurrentYrCharges 
                    FROM "Fee_Student_Status" 
                    WHERE "MI_ID" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_ID::BIGINT AND "FMG_ID" = v_FMG_IDFullpayment 
                    AND "FMH_Id" = v_FMH_IDFullpayment AND "FTI_Id" = v_FTI_IDFullpayment AND "AMST_ID" = p_AMST_ID::BIGINT;

                    IF (p_paiddate <= v_FYREBSET_RebateDate) THEN
                        v_rebateamount := ((v_CurrentYrCharges * v_FYREBSET_RebateAmtOrPercentValue) / 100);
                        p_totalrebateamount := p_totalrebateamount + v_rebateamount;
                    ELSE
                        p_totalrebateamount := 0;
                    END IF;

                END IF;

            END LOOP;

            RETURN p_totalrebateamount;

        ELSIF (v_FYREBSET_RebateTypeFlg = 'Amount') THEN

            FOR v_rec IN SELECT * FROM groupheadinstallment_temp LOOP
                v_FMG_IDFullpaymentamt := v_rec."FMG_Id";
                v_FMH_IDFullpaymentamt := v_rec."FMH_Id";
                v_FMI_IDFullpaymentamt := v_rec."FMI_ID";
                v_FTI_IDFullpaymentamt := v_rec."FTI_Id";

                SELECT "FYG_RebateApplicableFlg", "FYG_RebateTypeFlg"
                INTO v_FYGH_RebateApplicableFlg, v_FYGH_RebateTypeFlg
                FROM "Fee_Yearly_Group"
                WHERE "MI_ID" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_ID::BIGINT AND "FMG_ID" = v_FMG_IDFullpaymentamt;

                IF (v_FYGH_RebateApplicableFlg = TRUE AND v_FYGH_RebateTypeFlg = 'Amount') THEN

                    IF (p_paiddate <= v_FYREBSET_RebateDate) THEN
                        v_rebateamount := (v_FYREBSET_RebateAmtOrPercentValue / v_COUNT::NUMERIC);
                        p_totalrebateamount := p_totalrebateamount + v_rebateamount;
                    ELSE
                        p_totalrebateamount := 0;
                    END IF;

                END IF;

            END LOOP;

            RETURN p_totalrebateamount;

        END IF;

    END IF;

    RETURN p_totalrebateamount;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN 0;
END;
$$;