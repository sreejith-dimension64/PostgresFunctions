CREATE OR REPLACE FUNCTION "dbo"."CandidateSalaryDetailDynamicCalculation"(
    p_MI_ID BIGINT,
    p_HRCD_Id BIGINT
)
RETURNS TABLE (
    "mi_id" BIGINT,
    "emp_id" BIGINT,
    "hrmed_id" BIGINT,
    "hrmed_amount" NUMERIC(18,2),
    "hrmed_ed_type" VARCHAR(50),
    "hrmed_ed_flag" VARCHAR(50),
    "hrmed_amount_percent_flag" VARCHAR(50),
    "hrmed_RoundOffFlag" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRMED_IdCUR1 BIGINT; v_TEMPSALCOUNT INT; v_HRMED_IdCUR3 BIGINT; v_HRMEDP_HRMED_IdCUR2 BIGINT; v_HRMEDP_HRMED_IdCUR3 BIGINT; v_CUR3HEADCOUNT INT;
    
    v_HRMED_EDTypeFlagCUR1 VARCHAR(50); v_HRMED_EarnDedFlagCUR1 VARCHAR(50); v_HRMED_AmountPercentFlagCUR1 VARCHAR(50); v_HRMED_RoundOffFlagCUR1 VARCHAR(50);
    v_HRCED_PercentageCUR2 VARCHAR(50); v_HRCED_PercentageCUR3 VARCHAR(50);
    v_HRMED_EDTypeFlagCUR3 VARCHAR(50); v_HRMED_EarnDedFlagCUR3 VARCHAR(50); v_HRMED_AmountPercentFlagCUR3 VARCHAR(50); v_HRMED_RoundOffFlagCUR3 VARCHAR(50);
    
    v_HRMED_IdCUR4 BIGINT; v_HRMEDP_HRMED_IdCUR4 BIGINT; v_hrmed_amountCUR4 NUMERIC(18,2);
    v_HRCED_PercentageCUR4 VARCHAR(50); v_HRMED_EDTypeFlagCUR4 VARCHAR(50); v_HRMED_EarnDedFlagCUR4 VARCHAR(50); v_HRMED_AmountPercentFlagCUR4 VARCHAR(50); v_HRMED_RoundOffFlagCUR4 VARCHAR(50);
    
    v_HRCED_AmountCUR1 NUMERIC(18,2); v_CALCULATEDHEADAMOUNT NUMERIC(18,2); v_hrmed_amount NUMERIC(18,2);
    
    v_HRC_PFMAXAMT NUMERIC(18,2); v_HRC_FPFPER NUMERIC(18,2); v_HRC_EPFPER NUMERIC(18,2);
    v_HRC_ACCNO2 NUMERIC(18,2); v_HRC_ACCNO21 NUMERIC(18,2); v_HRC_ACCNO22 NUMERIC(18,2);
    v_HRC_ESIMAX NUMERIC(18,2); v_HRC_ESIEMPCONT NUMERIC(18,2); v_HRES_COUNT INT; v_HRES_ID BIGINT;
    
    v_HRC_ESIMaxAmount NUMERIC(18,2); v_HRC_AC2MinAmount NUMERIC(18,2); v_HRC_AC21MinAmount NUMERIC(18,2); v_HRC_AC22MinAmount NUMERIC(18,2);
    v_HRC_AsPerEmpFlag BOOLEAN;
    
    v_PTAMOUNT NUMERIC(10,2) := 0.00;
    
    v_HRME_PFApplicableFlag BOOLEAN; v_HRME_PFDate DATE; v_HRME_PFFixedFlag BOOLEAN; v_HRME_PFMaxFlag BOOLEAN; v_HRME_ESIApplicableFlag BOOLEAN;
    v_HRME_ESIDate DATE;
    
    v_CUR5HRMED_ID BIGINT; v_CUR5HRMED_PERC VARCHAR(50); v_CUR5HRMED_EDTypeFlag VARCHAR(50); v_CUR5HRMED_EarnDedFlag VARCHAR(50); v_CUR5HRMED_AmountPercentFlag VARCHAR(50); v_CUR5HRCED_Amount NUMERIC(10,2); v_CUR5HRMED_RoundOffFlag VARCHAR(50);
    
    v_CURPTHRMED_Id BIGINT; v_CURPTHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPT NUMERIC(18,2); v_CALCAMOUNTPT NUMERIC(18,2);
    
    v_CURPFMAXHRMED_Id BIGINT; v_CURPFMAXHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPFMAX NUMERIC(18,2); v_CALCAMOUNTPFMAX NUMERIC(18,2);
    
    v_CURPFHRMED_Id BIGINT; v_CURPFHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPF NUMERIC(18,2); v_CALCAMOUNTPF NUMERIC(18,2);
    
    v_CUR6HRMED_Id BIGINT; v_CURHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNT NUMERIC(18,2); v_CALCAMOUNT NUMERIC(18,2);
    
    v_CUR7HRMED_Id BIGINT; v_CUR7HRMED_AMOUNT NUMERIC(10,2); v_CUR7HRMED_EDTypeFlag VARCHAR(50); v_CUR7HRMED_EarnDedFlag VARCHAR(50); v_CUR7HRMED_RoundOffFlag VARCHAR(50);
    
    v_result NUMERIC(10,2);
    v_result1 NUMERIC(18,2);
    v_result2 NUMERIC(18,2);
    v_result3 NUMERIC(18,2);
    
    rec RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "temp_salary_comp_detail" (
        "mi_id" BIGINT,
        "emp_id" BIGINT,
        "hrmed_id" BIGINT,
        "hrmed_amount" NUMERIC(18,2),
        "hrmed_ed_type" VARCHAR(50),
        "hrmed_ed_flag" VARCHAR(50),
        "hrmed_amount_percent_flag" VARCHAR(50),
        "hrmed_RoundOffFlag" VARCHAR(50)
    ) ON COMMIT DROP;
    
    SELECT "HRC_PFMaxAmt", "HRC_FPFPer", "HRC_EPFPer", "HRC_AsPerEmpFlag",
           "HRC_AccNo2", "HRC_AccNo21", "HRC_AccNo22", "HRC_ESIMax", "HRC_ESIEmplrCont",
           "HRC_ESIMaxAmount", "HRC_AC2MinAmount", "HRC_AC21MinAmount", "HRC_AC22MinAmount"
    INTO v_HRC_PFMAXAMT, v_HRC_FPFPER, v_HRC_EPFPER, v_HRC_AsPerEmpFlag,
         v_HRC_ACCNO2, v_HRC_ACCNO21, v_HRC_ACCNO22, v_HRC_ESIMAX, v_HRC_ESIEMPCONT,
         v_HRC_ESIMaxAmount, v_HRC_AC2MinAmount, v_HRC_AC21MinAmount, v_HRC_AC22MinAmount
    FROM "HR_Configuration"
    WHERE "MI_Id" = p_MI_ID;
    
    v_HRME_PFApplicableFlag := TRUE;
    v_HRME_PFFixedFlag := FALSE;
    v_HRME_PFMaxFlag := FALSE;
    v_HRME_ESIApplicableFlag := TRUE;
    
    FOR rec IN
        SELECT A."HRMED_Id", A."HRCED_Amount", B."HRMED_EDTypeFlag", B."HRMED_EarnDedFlag", B."HRMED_AmountPercentFlag", B."HRMED_RoundOffFlag"
        FROM "HR_Candidate_EarningsDeductions" A
        LEFT JOIN "HR_Master_EarningsDeductions" B ON B."HRMED_Id" = A."HRMED_Id"
        WHERE A."MI_Id" = p_MI_ID AND A."HRCD_Id" = p_HRCD_Id AND B."HRMED_AmountPercentFlag" = 'Amount' AND B."HRMED_ActiveFlag" = TRUE AND A."HRCED_ActiveFlag" = TRUE
        ORDER BY B."HRMED_EarnDedFlag" DESC, B."HRMED_AmountPercentFlag" ASC
    LOOP
        SELECT COUNT(*) INTO v_TEMPSALCOUNT FROM "temp_salary_comp_detail" WHERE "mi_id" = p_MI_ID AND "emp_id" = p_HRCD_Id AND "hrmed_id" = rec."HRMED_Id";
        IF v_TEMPSALCOUNT = 0 THEN
            INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, rec."HRMED_Id", rec."HRCED_Amount", rec."HRMED_EDTypeFlag", rec."HRMED_EarnDedFlag", rec."HRMED_AmountPercentFlag", rec."HRMED_RoundOffFlag");
            RAISE NOTICE 'INSERT v_HRMED_IdCUR1 >> %', rec."HRMED_Id";
        END IF;
    END LOOP;
    
    FOR rec IN
        SELECT A."HRMED_Id"
        FROM "HR_Master_EarningsDeductions" A
        LEFT JOIN "HR_Candidate_EarningsDeductions" B ON B."HRMED_Id" = A."HRMED_Id"
        WHERE A."MI_Id" = p_MI_ID AND B."HRCD_Id" = p_HRCD_Id AND B."HRCED_ActiveFlag" = TRUE AND A."HRMED_ActiveFlag" = TRUE AND
              A."HRMED_Id" NOT IN (SELECT "hrmed_id" FROM "temp_salary_comp_detail" WHERE "mi_id" = p_MI_ID AND "emp_id" = p_HRCD_Id)
              AND A."HRMED_EarnDedFlag" = 'Earning'
    LOOP
        SELECT COUNT(*) INTO v_TEMPSALCOUNT FROM "temp_salary_comp_detail" WHERE "mi_id" = p_MI_ID AND "emp_id" = p_HRCD_Id AND "hrmed_id" = rec."HRMED_Id";
        IF v_TEMPSALCOUNT = 0 THEN
            FOR rec IN
                SELECT A."HRMED_Id", A."HRMEDP_HRMED_Id", B."hrmed_amount", C."HRCED_Percentage", D."HRMED_EDTypeFlag", D."HRMED_EarnDedFlag", D."HRMED_AmountPercentFlag", D."HRMED_RoundOffFlag"
                FROM "HR_Master_EarningsDeductionsPer" A
                LEFT JOIN "temp_salary_comp_detail" B ON B."hrmed_id" = A."HRMEDP_HRMED_Id"
                LEFT JOIN "HR_Candidate_EarningsDeductions" C ON C."HRMED_Id" = A."HRMED_Id"
                LEFT JOIN "HR_Master_EarningsDeductions" D ON D."HRMED_Id" = C."HRMED_Id"
                WHERE A."HRMED_Id" = rec."HRMED_Id" AND D."HRMED_ActiveFlag" = TRUE AND C."HRCED_ActiveFlag" = TRUE AND A."MI_Id" = p_MI_ID AND C."HRCD_Id" = p_HRCD_Id
                      AND A."HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
            LOOP
                v_HRMED_IdCUR3 := rec."HRMED_Id";
                v_HRMEDP_HRMED_IdCUR3 := rec."HRMEDP_HRMED_Id";
                v_hrmed_amount := rec."hrmed_amount";
                v_HRCED_PercentageCUR3 := rec."HRCED_Percentage";
                v_HRMED_EDTypeFlagCUR3 := rec."HRMED_EDTypeFlag";
                v_HRMED_EarnDedFlagCUR3 := rec."HRMED_EarnDedFlag";
                v_HRMED_AmountPercentFlagCUR3 := rec."HRMED_AmountPercentFlag";
                v_HRMED_RoundOffFlagCUR3 := rec."HRMED_RoundOffFlag";
                
                SELECT COUNT(*) INTO v_CUR3HEADCOUNT FROM "temp_salary_comp_detail" WHERE "HRMED_Id" = v_HRMEDP_HRMED_IdCUR3;
                IF v_CUR3HEADCOUNT = 0 THEN
                    FOR rec IN
                        SELECT A."HRMED_Id", A."HRMEDP_HRMED_Id", B."hrmed_amount", C."HRCED_Percentage", D."HRMED_EDTypeFlag", D."HRMED_EarnDedFlag", D."HRMED_AmountPercentFlag", D."HRMED_RoundOffFlag"
                        FROM "HR_Master_EarningsDeductionsPer" A
                        LEFT JOIN "temp_salary_comp_detail" B ON B."hrmed_id" = A."HRMEDP_HRMED_Id"
                        LEFT JOIN "HR_Candidate_EarningsDeductions" C ON C."HRMED_Id" = A."HRMED_Id"
                        LEFT JOIN "HR_Master_EarningsDeductions" D ON D."HRMED_Id" = C."HRMED_Id"
                        WHERE A."HRMED_Id" = v_HRMEDP_HRMED_IdCUR3 AND D."HRMED_ActiveFlag" = TRUE AND C."HRCED_ActiveFlag" = TRUE AND A."MI_Id" = p_MI_ID AND C."HRCD_Id" = p_HRCD_Id
                              AND A."HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
                    LOOP
                        v_HRMED_IdCUR4 := rec."HRMED_Id";
                        v_HRMEDP_HRMED_IdCUR4 := rec."HRMEDP_HRMED_Id";
                        v_hrmed_amountCUR4 := rec."hrmed_amount";
                        v_HRCED_PercentageCUR4 := rec."HRCED_Percentage";
                        v_HRMED_EDTypeFlagCUR4 := rec."HRMED_EDTypeFlag";
                        v_HRMED_EarnDedFlagCUR4 := rec."HRMED_EarnDedFlag";
                        v_HRMED_AmountPercentFlagCUR4 := rec."HRMED_AmountPercentFlag";
                        v_HRMED_RoundOffFlagCUR4 := rec."HRMED_RoundOffFlag";
                        
                        SELECT ("hrmed_amount" * v_HRCED_PercentageCUR4::NUMERIC / 100) INTO v_CALCULATEDHEADAMOUNT FROM "temp_salary_comp_detail" WHERE "HRMED_Id" = v_HRMEDP_HRMED_IdCUR4;
                        
                        SELECT * INTO v_result3 FROM "CalculateRoundOffValue"(v_CALCULATEDHEADAMOUNT, v_HRMED_RoundOffFlagCUR4);
                        v_CALCULATEDHEADAMOUNT := v_result3::NUMERIC(18,2);
                        
                        INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_HRMED_IdCUR4, v_CALCULATEDHEADAMOUNT, v_HRMED_EDTypeFlagCUR4, v_HRMED_EarnDedFlagCUR4, v_HRMED_AmountPercentFlagCUR4, v_HRMED_RoundOffFlagCUR4);
                        RAISE NOTICE 'INSERT v_HRMED_IdCUR4 >> %', v_HRMED_IdCUR4;
                        
                        SELECT * INTO v_result1 FROM "CalculateRoundOffValue"(v_CALCULATEDHEADAMOUNT, v_HRMED_RoundOffFlagCUR3);
                        v_CALCULATEDHEADAMOUNT := v_result1::NUMERIC(18,2);
                        
                        SELECT (v_CALCULATEDHEADAMOUNT * v_HRCED_PercentageCUR3::NUMERIC / 100) INTO v_CALCULATEDHEADAMOUNT FROM "temp_salary_comp_detail" WHERE "HRMED_Id" = v_HRMEDP_HRMED_IdCUR3;
                        
                        INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_HRMED_IdCUR3, v_CALCULATEDHEADAMOUNT, v_HRMED_EDTypeFlagCUR3, v_HRMED_EarnDedFlagCUR3, v_HRMED_AmountPercentFlagCUR3, v_HRMED_RoundOffFlagCUR3);
                        RAISE NOTICE 'INSERT v_HRMED_IdCUR3 >>>> %', v_HRMED_IdCUR3;
                    END LOOP;
                ELSE
                    SELECT ("hrmed_amount" * v_HRCED_PercentageCUR3::NUMERIC / 100) INTO v_CALCULATEDHEADAMOUNT FROM "temp_salary_comp_detail" WHERE "HRMED_Id" = v_HRMEDP_HRMED_IdCUR3;
                    
                    SELECT * INTO v_result2 FROM "CalculateRoundOffValue"(v_CALCULATEDHEADAMOUNT, v_HRMED_RoundOffFlagCUR3);
                    v_CALCULATEDHEADAMOUNT := v_result2::NUMERIC(18,2);
                    
                    INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_HRMED_IdCUR3, v_CALCULATEDHEADAMOUNT, v_HRMED_EDTypeFlagCUR3, v_HRMED_EarnDedFlagCUR3, v_HRMED_AmountPercentFlagCUR3, v_HRMED_RoundOffFlagCUR3);
                    RAISE NOTICE 'INSERT v_HRMED_IdCUR3 >> %', v_HRMED_IdCUR3;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
    
    FOR rec IN
        SELECT A."HRMED_Id", A."HRCED_Percentage", B."HRMED_EDTypeFlag", B."HRMED_EarnDedFlag", B."HRMED_AmountPercentFlag", A."HRCED_Amount", B."HRMED_RoundOffFlag"
        FROM "HR_Candidate_EarningsDeductions" A
        LEFT JOIN "HR_Master_EarningsDeductions" B ON B."HRMED_Id" = A."HRMED_Id"
        WHERE B."HRMED_EarnDedFlag" = 'Deduction' AND B."HRMED_AmountPercentFlag" = 'Percentage' AND B."HRMED_ActiveFlag" = TRUE AND A."HRCED_ActiveFlag" = TRUE
              AND A."MI_Id" = p_MI_ID AND A."HRCD_Id" = p_HRCD_Id
    LOOP
        v_CUR5HRMED_ID := rec."HRMED_Id";
        v_CUR5HRMED_PERC := rec."HRCED_Percentage";
        v_CUR5HRMED_EDTypeFlag := rec."HRMED_EDTypeFlag";
        v_CUR5HRMED_EarnDedFlag := rec."HRMED_EarnDedFlag";
        v_CUR5HRMED_AmountPercentFlag := rec."HRMED_AmountPercentFlag";
        v_CUR5HRCED_Amount := rec."HRCED_Amount";
        v_CUR5HRMED_RoundOffFlag := rec."HRMED_RoundOffFlag";
        
        IF v_CUR5HRMED_EDTypeFlag = 'PT' THEN
            FOR rec IN
                SELECT "HRMED_Id", "HRMEDP_HRMED_Id"
                FROM "HR_Master_EarningsDeductionsPer"
                WHERE "HRMED_Id" = v_CUR5HRMED_ID AND
                      "HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
            LOOP
                v_CURPTHRMED_Id := rec."HRMED_Id";
                v_CURPTHRMEDP_HRMED_Id := rec."HRMEDP_HRMED_Id";
                
                SELECT SUM("hrmed_amount") INTO v_SUMAMOUNTPT
                FROM "temp_salary_comp_detail" WHERE "hrmed_id" = v_CURPTHRMEDP_HRMED_Id;
                
                v_CALCAMOUNTPT := v_SUMAMOUNTPT;
                INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_CUR5HRMED_ID, v_CALCAMOUNTPT, v_CUR5HRMED_EDTypeFlag, v_CUR5HRMED_EarnDedFlag, v_CUR5HRMED_AmountPercentFlag, v_CUR5HRMED_RoundOffFlag);
                RAISE NOTICE 'INSERT v_CUR5HRMED_ID PT>> %', v_CUR5HRMED_ID;
            END LOOP;
        ELSIF v_CUR5HRMED_EDTypeFlag = 'PF' THEN
            IF v_HRME_PFApplicableFlag = TRUE THEN
                IF v_HRC_AsPerEmpFlag = TRUE THEN
                    IF v_HRME_PFFixedFlag = TRUE THEN
                        INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_CUR5HRMED_ID, v_CUR5HRCED_Amount, v_CUR5HRMED_EDTypeFlag, v_CUR5HRMED_EarnDedFlag, v_CUR5HRMED_AmountPercentFlag, v_CUR5HRMED_RoundOffFlag);
                        RAISE NOTICE 'INSERT v_CUR5HRMED_ID PF PFFixed>> %', v_CUR5HRMED_ID;
                    ELSE
                        FOR rec IN
                            SELECT "HRMED_Id", "HRMEDP_HRMED_Id"
                            FROM "HR_Master_EarningsDeductionsPer"
                            WHERE "HRMED_Id" = v_CUR5HRMED_ID AND
                                  "HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
                        LOOP
                            v_CURPFMAXHRMED_Id := rec."HRMED_Id";
                            v_CURPFMAXHRMEDP_HRMED_Id := rec."HRMEDP_HRMED_Id";
                            
                            SELECT SUM("hrmed_amount") INTO v_SUMAMOUNTPFMAX
                            FROM "temp_salary_comp_detail" WHERE "hrmed_id" = v_CURPFMAXHRMEDP_HRMED_Id;
                            
                            v_CALCAMOUNTPFMAX := (v_SUMAMOUNTPFMAX * v_CUR5HRMED_PERC::NUMERIC) / 100;
                            INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_CUR5HRMED_ID, v_CALCAMOUNTPFMAX, v_CUR5HRMED_EDTypeFlag, v_CUR5HRMED_EarnDedFlag, v_CUR5HRMED_AmountPercentFlag, v_CUR5HRMED_RoundOffFlag);
                            RAISE NOTICE 'INSERT v_CUR5HRMED_ID PF MAX or General PF>> %', v_CUR5HRMED_ID;
                        END LOOP;
                    END IF;
                ELSE
                    FOR rec IN
                        SELECT "HRMED_Id", "HRMEDP_HRMED_Id"
                        FROM "HR_Master_EarningsDeductionsPer"
                        WHERE "HRMED_Id" = v_CUR5HRMED_ID AND
                              "HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
                    LOOP
                        v_CURPFHRMED_Id := rec."HRMED_Id";
                        v_CURPFHRMEDP_HRMED_Id := rec."HRMEDP_HRMED_Id";
                        
                        SELECT SUM("hrmed_amount") INTO v_SUMAMOUNTPF
                        FROM "temp_salary_comp_detail" WHERE "hrmed_id" = v_CURPFHRMEDP_HRMED_Id;
                        
                        v_CALCAMOUNTPF := (v_SUMAMOUNTPF * v_CUR5HRMED_PERC::NUMERIC) / 100;
                        INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_CUR5HRMED_ID, v_CALCAMOUNTPF, v_CUR5HRMED_EDTypeFlag, v_CUR5HRMED_EarnDedFlag, v_CUR5HRMED_AmountPercentFlag, v_CUR5HRMED_RoundOffFlag);
                        RAISE NOTICE 'INSERT v_CUR5HRMED_ID PF>> %', v_CUR5HRMED_ID;
                    END LOOP;
                END IF;
            END IF;
        ELSE
            FOR rec IN
                SELECT "HRMED_Id", "HRMEDP_HRMED_Id"
                FROM "HR_Master_EarningsDeductionsPer"
                WHERE "HRMED_Id" = v_CUR5HRMED_ID AND
                      "HRMEDP_HRMED_Id" IN (SELECT "HRMED_Id" FROM "HR_Candidate_EarningsDeductions" WHERE "HRCD_Id" = p_HRCD_Id AND "MI_Id" = p_MI_Id AND "HRCED_ActiveFlag" = TRUE)
            LOOP
                v_CUR6HRMED_Id := rec."HRMED_Id";
                v_CURHRMEDP_HRMED_Id := rec."HRMEDP_HRMED_Id";
                
                SELECT SUM("hrmed_amount") INTO v_SUMAMOUNT
                FROM "temp_salary_comp_detail" WHERE "hrmed_id" = v_CURHRMEDP_HRMED_Id;
                
                v_CALCAMOUNT := (v_SUMAMOUNT * v_CUR5HRMED_PERC::NUMERIC) / 100;
                INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRCD_Id, v_CUR5HRMED_ID, v_CALCAMOUNT, v_CUR5HRMED_EDTypeFlag, v_CUR5HRMED_EarnDedFlag, v_CUR5HRMED_AmountPercentFlag, v_CUR5HRMED_RoundOffFlag);
                RAISE NOTICE 'INSERT v_CUR5HRMED_ID -> %', v_CUR5HRMED_ID;
            END LOOP;
        END IF;
    END LOOP;
    
    FOR rec IN
        SELECT "hrmed_id", SUM("hrmed_amount") AS "AMT", "hrmed_ed_type", "hrmed_ed_flag", "hrmed_RoundOffFlag"
        FROM "temp_salary_comp_detail"
        GROUP BY "hrmed_id", "hrmed_ed_type", "hrmed_ed_flag", "hrmed_RoundOffFlag"
    LOOP
        v_CUR7HRMED_Id := rec."hrmed_id";
        v_CUR7HRMED_AMOUNT := rec."AMT";
        v_CUR7HRMED_EDTypeFlag := rec."hrmed_ed_type";
        v_CUR7HRMED_EarnDedFlag := rec."hrmed_ed_flag";
        v_CUR7HRMED_RoundOffFlag := rec."hrmed_RoundOffFlag";
        
        SELECT * INTO v_result FROM "CalculateRoundOffValue"(v_CUR7HRMED_AMOUNT, v_CUR7HRMED_RoundOffFlag);
        
        RAISE NOTICE 'v_CUR7HRMED_AMOUNT %', v_CUR7HRMED_AMOUNT;
        RAISE NOTICE 'v_result %', v_result;
        
        v_CUR7HRMED_AMOUNT := v_result::NUMERIC(10,2);
        
        IF v_CUR7HRMED_EDTypeFlag = 'PF' THEN
            IF v_HRME_PFApplicableFlag = TRUE THEN
                IF v_HRC_AsPerEmpFlag = TRUE THEN
                    IF v_HRME_PFMaxFlag = TRUE THEN
                        v_CUR7HRMED_AMOUNT := v_CUR7HRMED_AMOUNT;
                    ELSE
                        IF v_CUR7HRMED_AMOUNT > v_HRC_PFMAXAMT THEN
                            v_CUR7HRMED_AMOUNT := v_HRC_PFMAXAMT;
                        END IF;
                    END IF;
                END IF;
            ELSE
                v_CUR7HRMED_AMOUNT := 0.00;
            END IF;
            
            UPDATE "HR_Candidate_EarningsDeductions" SET "HRCED_Amount" = v_CUR7HRMED_AMOUNT WHERE "HRMED_Id" = v_CUR7HRMED_Id AND "MI_Id" = p_MI_ID AND "HRCD_Id" = p_HRCD_Id;
            UPDATE "temp_salary_comp_detail" SET "hrmed_amount" = v_CUR7HRMED_AMOUNT WHERE "HRMED_Id" = v_C