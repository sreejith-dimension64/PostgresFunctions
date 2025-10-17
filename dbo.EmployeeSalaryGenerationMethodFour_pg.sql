CREATE OR REPLACE FUNCTION "dbo"."EmployeeSalaryGenerationMethodFour"(
    p_HRME_ID BIGINT,
    p_MI_ID BIGINT,
    p_HRMLY_ID BIGINT,
    p_IVRM_Month_Name VARCHAR(20)
)
RETURNS TABLE (
    "NEW_IDENTITY" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_LOPDAYS FLOAT; v_DAYS_IN_MONTH INT; v_CURRENT_MONTH INT; v_PREVIOUS_MONTH INT; v_DAYFROM INT; v_DAYTO INT;
    v_LEAVE_YEAR INT; v_PREVIOUS_YEAR INT; v_CURRENT_YEAR INT; v_MONTH_START_DATE VARCHAR(20); v_MONTH_END_DATE VARCHAR(20);
    v_MONTH INT; v_CALCBASICPAY DECIMAL(10,2) := 0.00; v_PTAMOUNT DECIMAL(10,2) := 0.00;
    v_WORKINGDAYS FLOAT;
    v_SALFROMDATE DATE; v_SALTODATE DATE; v_TEMPAMOUNT DECIMAL(18,2); v_STRFROMDATE VARCHAR(20); v_STRTODATE VARCHAR(20);
    v_FROMDATE DATE; v_TODATE DATE;
    v_BASICPAY DECIMAL(10,2); v_SALARYPERDAY DECIMAL(10,2); v_LOPAMOUNT DECIMAL(10,2); v_NEWBASICSALARY DECIMAL(10,2);
    v_EMPMI_ID BIGINT; v_EMPHRME_ID BIGINT; v_EMPHRMET_Id BIGINT; v_EMPHRMGT_Id BIGINT; v_EMPHRMD_Id BIGINT;
    v_EMPHRMDES_Id BIGINT; v_EMPHRMG_Id BIGINT; v_HRES_EPF DECIMAL(18,2); v_HRES_FPF DECIMAL(18,2);
    v_HRME_PFApplicableFlag BOOLEAN; v_HRME_PFDate DATE; v_HRME_PFFixedFlag BOOLEAN; v_HRME_PFMaxFlag BOOLEAN; v_HRME_ESIApplicableFlag BOOLEAN;
    v_HRME_ESIDate DATE; v_HRME_PaymentType VARCHAR(50); v_HRMBD_BankName VARCHAR(50); v_HRMEB_AccountNo BIGINT; v_HRMEB_ActiveFlag VARCHAR(50);
    v_HRES_ACCNO2 DECIMAL(18,2); v_HRES_ACCNO21 DECIMAL(18,2); v_HRES_ACCNO22 DECIMAL(18,2);
    v_HRES_COUNT INT;
    v_HRES_ID BIGINT; v_HRES_ESIEmplr DECIMAL(18,2) := 0.00;
    v_NEW_IDENTITY BIGINT; v_NEW_SDIDENTITY BIGINT;
    v_HRC_PFMAXAMT DECIMAL(18,2); v_HRC_FPFPER DECIMAL(18,2); v_HRC_EPFPER DECIMAL(18,2); v_HRC_ACCNO2 DECIMAL(18,2);
    v_HRC_ACCNO21 DECIMAL(18,2); v_HRC_ACCNO22 DECIMAL(18,2); v_HRC_ESIMAX DECIMAL(18,2); v_HRC_ESIEMPCONT DECIMAL(18,2);
    v_HRC_ESIMaxAmount DECIMAL(18,2); v_HRC_AC2MinAmount DECIMAL(18,2); v_HRC_AC21MinAmount DECIMAL(18,2);
    v_HRC_AC22MinAmount DECIMAL(18,2); v_HRC_AsPerEmpFlag BOOLEAN;
    v_HRMED_IdBasic BIGINT; v_HRMED_EarnDedFlagBasic VARCHAR(50); v_HRMED_EDTypeFlagBasic VARCHAR(50); v_HRMED_RoundOffFlag VARCHAR(50); v_HREED_ApplicableMaxValue DECIMAL(18,2);
    v_HRC_SalApprovalFlg BOOLEAN;
    v_HRMED_IdCUR1 BIGINT; v_TEMPSALCOUNT INT; v_HRMED_IdCUR3 BIGINT; v_HRMEDP_HRMED_IdCUR2 BIGINT; v_HRMEDP_HRMED_IdCUR3 BIGINT; v_CUR3HEADCOUNT INT;
    v_HRMED_EDTypeFlagCUR1 VARCHAR(50); v_HRMED_EarnDedFlagCUR1 VARCHAR(50); v_HRMED_AmountPercentFlagCUR1 VARCHAR(50); v_HRMED_RoundOffFlagCUR1 VARCHAR(50); v_HREED_ApplicableMaxValueCUR DECIMAL(18,2); v_HREED_ApplicableMaxValueCUR1 DECIMAL(18,2);
    v_HREED_PercentageCUR2 VARCHAR(50); v_HREED_PercentageCUR3 VARCHAR(50);
    v_HRMED_EDTypeFlagCUR3 VARCHAR(50); v_HRMED_EarnDedFlagCUR3 VARCHAR(50); v_HRMED_AmountPercentFlagCUR3 VARCHAR(50); v_HRMED_RoundOffFlagCUR3 VARCHAR(50); v_HREED_ApplicableMaxValueCUR3 DECIMAL(18,2);
    v_HRMED_IdCUR4 BIGINT; v_HRMEDP_HRMED_IdCUR4 BIGINT; v_hrmed_amountCUR4 DECIMAL(18,2); v_HREED_PercentageCUR4 VARCHAR(50); v_HRMED_EDTypeFlagCUR4 VARCHAR(50);
    v_HRMED_EarnDedFlagCUR4 VARCHAR(50); v_HRMED_AmountPercentFlagCUR4 VARCHAR(50); v_HRMED_RoundOffFlagCUR4 VARCHAR(50); v_HREED_ApplicableMaxValueCUR4 DECIMAL(18,2);
    v_HREED_AmountCUR1 DECIMAL(18,2); v_CALCULATEDHEADAMOUNT DECIMAL(18,2); v_hrmed_amount DECIMAL(18,2); v_HREED_ApplicableMaxValueCU7 DECIMAL(18,2);
    v_HRME_DOJ DATE; v_HRME_DOL DATE; v_HRME_DOB DATE;
    v_HRME_LeftFlag BOOLEAN;
    v_TOTAL_DAYS INT;
    v_EMPTOTAL_DAYS INT;
    v_CUR5HRMED_ID BIGINT; v_CUR5HRMED_PERC VARCHAR(50); v_CUR5HRMED_EDTypeFlag VARCHAR(50); v_CUR5HRMED_EarnDedFlag VARCHAR(50); v_CUR5HRMED_AmountPercentFlag VARCHAR(50); v_CUR5HREED_Amount DECIMAL(18,2); v_CUR5HRMED_RoundOffFlag VARCHAR(50); v_CUR5HRMED_HREED_ApplicableMaxValue DECIMAL(18,2);
    v_CURPTHRMED_Id BIGINT; v_CURPTHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPT DECIMAL(18,2); v_CALCAMOUNTPT DECIMAL(18,2);
    v_CURPFMAXHRMED_Id BIGINT; v_CURPFMAXHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPFMAX DECIMAL(18,2); v_CALCAMOUNTPFMAX DECIMAL(18,2);
    v_CURPFHRMED_Id BIGINT; v_CURPFHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNTPF DECIMAL(18,2); v_CALCAMOUNTPF DECIMAL(18,2);
    v_CUR6HRMED_Id BIGINT; v_CURHRMEDP_HRMED_Id BIGINT;
    v_SUMAMOUNT DECIMAL(18,2); v_CALCAMOUNT DECIMAL(18,2);
    v_CUR7HRMED_Id BIGINT; v_CUR7HRMED_AMOUNT DECIMAL(10,2); v_CUR7HRMED_EDTypeFlag VARCHAR(50); v_CUR7HRMED_EarnDedFlag VARCHAR(50); v_CUR7HRMED_RoundOffFlag VARCHAR(50); v_CUR7HRMED_amtperc_flag VARCHAR(50);
    v_result DECIMAL(10,2);
    v_SALARYPERDAYPF DECIMAL(10,2);
    v_HRESA_SanctinedAmount DECIMAL(18,2);
    v_HREL_SanctionedAmount DECIMAL(18,2) := 0.00; v_HREL_TotalPending DECIMAL(18,2) := 0.00; v_HREL_LoanInterest DECIMAL(18,2) := 0.00; v_HREL_LaonEMI DECIMAL(18,2) := 0.00;
    v_HREL_TotalPrincipalPaid DECIMAL(18,2) := 0.00; v_HREL_TotalInterestPaid DECIMAL(18,2) := 0.00;
    v_CountTotalPending INT;
    v_CountCurrentMonth INT;
    v_HREL_Id BIGINT;
    v_InstallMentPaid INT;
    v_HREL_LoanInsallments INT;
    v_PerAnumInterest DECIMAL(18,2) := 0.00; v_PerMonthInterest DECIMAL(18,2) := 0.00;
    v_HRELT_LoanAmount DECIMAL(18,2) := 0.00; v_HRELT_PrincipalAmount DECIMAL(18,2) := 0.00; v_HRELT_InterestAmount DECIMAL(18,2) := 0.00;
    v_ADDCount INT;
    v_COUNTRECORD INT;
    v_HRELT_PaidFlag BOOLEAN;
    v_HRELT_Id BIGINT;
    v_CNT INT;
    v_ArrearHeadAMTIDENTITYID INT;
    v_result1 DECIMAL(18,2);
    v_result2 DECIMAL(18,2);
    v_result3 DECIMAL(18,2);
    rec RECORD;
BEGIN
    SELECT "MI_ID", "HRME_Id", "HRMET_Id", "HRMGT_Id", "HRMD_Id",
           "HRMDES_Id", "HRMG_Id",
           "HRME_PFApplicableFlag", "HRME_PFDate", "HRME_PFFixedFlag",
           "HRME_PFMaxFlag", "HRME_ESIApplicableFlag", "HRME_PaymentType",
           "HRME_ESIDate", "HRME_DOJ", "HRME_DOL", "HRME_LeftFlag", "HRME_DOB"
    INTO v_EMPMI_ID, v_EMPHRME_ID, v_EMPHRMET_Id, v_EMPHRMGT_Id, v_EMPHRMD_Id,
         v_EMPHRMDES_Id, v_EMPHRMG_Id,
         v_HRME_PFApplicableFlag, v_HRME_PFDate, v_HRME_PFFixedFlag,
         v_HRME_PFMaxFlag, v_HRME_ESIApplicableFlag, v_HRME_PaymentType,
         v_HRME_ESIDate, v_HRME_DOJ, v_HRME_DOL, v_HRME_LeftFlag, v_HRME_DOB
    FROM "HR_Master_Employee"
    WHERE "MI_Id" = p_MI_ID AND "HRME_id" = p_HRME_ID;

    SELECT "HRC_PFMaxAmt", "HRC_FPFPer", "HRC_EPFPer",
           "HRC_AsPerEmpFlag",
           "HRC_AccNo2", "HRC_AccNo21", "HRC_AccNo22",
           "HRC_ESIMax", "HRC_ESIEmplrCont", "HRC_ESIMaxAmount",
           "HRC_AC2MinAmount", "HRC_AC21MinAmount", "HRC_AC22MinAmount", "HRC_SalaryFromDay", "HRC_SalaryToDay", "HRC_SalApprovalFlg"
    INTO v_HRC_PFMAXAMT, v_HRC_FPFPER, v_HRC_EPFPER,
         v_HRC_AsPerEmpFlag,
         v_HRC_ACCNO2, v_HRC_ACCNO21, v_HRC_ACCNO22,
         v_HRC_ESIMAX, v_HRC_ESIEMPCONT, v_HRC_ESIMaxAmount,
         v_HRC_AC2MinAmount, v_HRC_AC21MinAmount, v_HRC_AC22MinAmount, v_DAYFROM, v_DAYTO, v_HRC_SalApprovalFlg
    FROM "HR_Configuration"
    WHERE "MI_Id" = p_MI_ID;

    SELECT "IVRM_Month_Id"
    INTO v_MONTH
    FROM "IVRM_Month"
    WHERE "IVRM_Month_Name" = p_IVRM_Month_Name;

    v_LEAVE_YEAR := p_HRMLY_ID;

    IF v_DAYFROM > 1 AND v_MONTH < 12 THEN
        v_MONTH_START_DATE := CONCAT(v_LEAVE_YEAR, '-', v_MONTH, '-', v_DAYFROM);
        v_MONTH_END_DATE := CONCAT(v_LEAVE_YEAR, '-', v_MONTH + 1, '-', v_DAYTO);
    ELSIF v_DAYFROM > 1 AND v_MONTH = 12 THEN
        v_MONTH_START_DATE := CONCAT(v_LEAVE_YEAR, '-', v_MONTH, '-', v_DAYFROM);
        v_MONTH_END_DATE := CONCAT(v_LEAVE_YEAR + 1, '-01-', v_DAYTO);
    ELSE
        v_MONTH_START_DATE := CONCAT(v_LEAVE_YEAR, '-', v_MONTH, '-', v_DAYFROM);
        v_DAYTO := EXTRACT(DAY FROM (DATE_TRUNC('MONTH', CAST(CONCAT(v_LEAVE_YEAR, '-', v_MONTH, '-01') AS DATE)) + INTERVAL '1 month' - INTERVAL '1 day'));
        v_MONTH_END_DATE := CONCAT(v_LEAVE_YEAR, '-', v_MONTH, '-', v_DAYTO);
    END IF;

    v_TOTAL_DAYS := (CAST(v_MONTH_END_DATE AS DATE) - CAST(v_MONTH_START_DATE AS DATE)) + 1;
    v_DAYS_IN_MONTH := v_TOTAL_DAYS;

    IF v_HRME_DOJ <= CAST(v_MONTH_END_DATE AS DATE) THEN
        IF v_HRME_DOJ BETWEEN CAST(v_MONTH_START_DATE AS DATE) AND CAST(v_MONTH_END_DATE AS DATE) THEN
            v_MONTH_START_DATE := v_HRME_DOJ::TEXT;
        END IF;

        IF v_HRME_LeftFlag = TRUE THEN
            IF v_HRME_DOL BETWEEN CAST(v_MONTH_START_DATE AS DATE) AND CAST(v_MONTH_END_DATE AS DATE) THEN
                v_MONTH_END_DATE := v_HRME_DOL::TEXT;
            END IF;
        END IF;
    ELSE
        RAISE NOTICE 'Date of Join Is >> %', v_HRME_DOJ;
        RETURN;
    END IF;

    v_EMPTOTAL_DAYS := (CAST(v_MONTH_END_DATE AS DATE) - CAST(v_MONTH_START_DATE AS DATE)) + 1;

    SELECT COALESCE(SUM("HRELT_TotDays"), 0)
    INTO v_LOPDAYS
    FROM "HR_Emp_Leave_Trans" A
    LEFT JOIN "HR_Master_Leave" B ON B."HRML_Id" = A."HRELT_LeaveId"
    INNER JOIN "HR_Emp_Leave_Trans_Details" C ON A."HRELT_Id" = C."HRELT_Id"
    WHERE A."MI_Id" = p_MI_ID AND A."HRME_Id" = p_HRME_ID AND C."HRELTD_LWPFlag" = 1
    AND A."HRELT_ActiveFlag" = 1
    AND (("HRELT_FromDate" BETWEEN CAST(v_MONTH_START_DATE AS DATE) AND CAST(v_MONTH_END_DATE AS DATE)) 
         OR ("HRELT_ToDate" BETWEEN CAST(v_MONTH_START_DATE AS DATE) AND CAST(v_MONTH_END_DATE AS DATE)));

    SELECT "HRMED"."HRMED_Id", "HREED"."HREED_Amount", "HRMED"."HRMED_EarnDedFlag",
           "HRMED"."HRMED_EDTypeFlag", "HRMED"."HRMED_RoundOffFlag", COALESCE("HREED_ApplicableMaxValue", 0)
    INTO v_HRMED_IdBasic, v_BASICPAY, v_HRMED_EarnDedFlagBasic,
         v_HRMED_EDTypeFlagBasic, v_HRMED_RoundOffFlag, v_HREED_ApplicableMaxValue
    FROM "HR_Employee_EarningsDeductions" "HREED"
    LEFT JOIN "HR_Master_EarningsDeductions" "HRMED" ON "HRMED"."HRMED_Id" = "HREED"."HRMED_Id"
    WHERE "HRMED"."MI_Id" = p_MI_ID AND "HREED"."HRME_Id" = p_HRME_ID AND "HRMED"."HRMED_EDTypeFlag" = 'Basic Pay'
          AND "HREED"."HREED_ActiveFlag" = 1 AND "HRMED"."HRMED_ActiveFlag" = 1;

    IF v_HREED_ApplicableMaxValue <> 0 THEN
        SELECT v_HREED_ApplicableMaxValue INTO v_BASICPAY 
        FROM "HR_Employee_EarningsDeductions" 
        WHERE "HRMED_Id" = v_HRMED_IdBasic;
    END IF;

    v_SALARYPERDAY := v_BASICPAY / v_DAYS_IN_MONTH;

    IF v_EMPTOTAL_DAYS < v_DAYS_IN_MONTH THEN
        v_BASICPAY := v_SALARYPERDAY * v_EMPTOTAL_DAYS;

        IF v_LOPDAYS = 0 THEN
            v_WORKINGDAYS := v_EMPTOTAL_DAYS;
        ELSE
            v_WORKINGDAYS := v_EMPTOTAL_DAYS - v_LOPDAYS;
        END IF;
    ELSE
        v_SALARYPERDAY := v_BASICPAY / v_DAYS_IN_MONTH;

        IF v_LOPDAYS = 0 THEN
            v_WORKINGDAYS := v_DAYS_IN_MONTH;
        ELSE
            v_WORKINGDAYS := v_DAYS_IN_MONTH - v_LOPDAYS;
        END IF;
    END IF;

    INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRME_ID, v_HRMED_IdBasic, v_BASICPAY, v_HRMED_EDTypeFlagBasic, v_HRMED_EarnDedFlagBasic, 'Amount', v_HRMED_RoundOffFlag);

    IF v_HRME_PaymentType = 'Bank' THEN
        SELECT "HRMBD_BankName", "HRMEB_AccountNo", "HRMEB_ActiveFlag"
        INTO v_HRMBD_BankName, v_HRMEB_AccountNo, v_HRMEB_ActiveFlag
        FROM "HR_Master_Employee_Bank" EMP
        LEFT JOIN "HR_Master_BankDeatils" BANK ON BANK."HRMBD_Id" = EMP."HRMBD_Id"
        WHERE "HRME_Id" = p_HRME_ID AND "HRMEB_ActiveFlag" = 'default';
    END IF;

    SELECT "HRES_ID"
    INTO v_HRES_ID
    FROM "HR_Employee_Salary"
    WHERE "MI_Id" = p_MI_ID AND "HRME_Id" = p_HRME_ID AND "HRES_Year" = v_LEAVE_YEAR AND "HRES_Month" = p_IVRM_Month_Name;

    IF v_HRES_ID > 0 THEN
        IF v_HRC_SalApprovalFlg = TRUE THEN
            UPDATE "HR_Employee_Salary" 
            SET "MI_Id" = p_MI_ID, "HRME_Id" = p_HRME_ID, "HRES_Year" = v_LEAVE_YEAR, "HRES_Month" = p_IVRM_Month_Name, 
                "HRES_WorkingDays" = v_WORKINGDAYS, "HRES_DailyRates" = v_SALARYPERDAY, "HRES_EPF" = NULL, "HRES_FPF" = NULL, 
                "HRES_Ac21" = NULL, "HRES_Ac22" = NULL, "HRES_Ac5" = NULL,
                "HRES_FromDate" = CAST(v_MONTH_START_DATE AS DATE), "HRES_ToDate" = CAST(v_MONTH_END_DATE AS DATE),
                "HRMGT_Id" = v_EMPHRMGT_Id, "HRMD_Id" = v_EMPHRMD_Id, "HRMDES_Id" = v_EMPHRMDES_Id,
                "HRES_BankCashFlag" = v_HRME_PaymentType, "HRES_BankCode" = v_HRMBD_BankName, "HRES_AccountNo" = v_HRMEB_AccountNo, "HRES_ApproveFlg" = 0
            WHERE "MI_Id" = p_MI_ID AND "HRME_Id" = p_HRME_ID AND "HRES_Year" = v_LEAVE_YEAR AND "HRES_Month" = p_IVRM_Month_Name;
        ELSE
            UPDATE "HR_Employee_Salary" 
            SET "MI_Id" = p_MI_ID, "HRME_Id" = p_HRME_ID, "HRES_Year" = v_LEAVE_YEAR, "HRES_Month" = p_IVRM_Month_Name, 
                "HRES_WorkingDays" = v_WORKINGDAYS, "HRES_DailyRates" = v_SALARYPERDAY, "HRES_EPF" = NULL, "HRES_FPF" = NULL, 
                "HRES_Ac21" = NULL, "HRES_Ac22" = NULL, "HRES_Ac5" = NULL,
                "HRES_FromDate" = CAST(v_MONTH_START_DATE AS DATE), "HRES_ToDate" = CAST(v_MONTH_END_DATE AS DATE),
                "HRMGT_Id" = v_EMPHRMGT_Id, "HRMD_Id" = v_EMPHRMD_Id, "HRMDES_Id" = v_EMPHRMDES_Id,
                "HRES_BankCashFlag" = v_HRME_PaymentType, "HRES_BankCode" = v_HRMBD_BankName, "HRES_AccountNo" = v_HRMEB_AccountNo, "HRES_ApproveFlg" = 1
            WHERE "MI_Id" = p_MI_ID AND "HRME_Id" = p_HRME_ID AND "HRES_Year" = v_LEAVE_YEAR AND "HRES_Month" = p_IVRM_Month_Name;
        END IF;

        v_NEW_IDENTITY := v_HRES_ID;
        DELETE FROM "HR_Employee_Salary_Details" WHERE "HRES_Id" = v_NEW_IDENTITY;
    ELSE
        IF v_HRC_SalApprovalFlg = TRUE THEN
            INSERT INTO "HR_Employee_Salary"("MI_Id", "HRME_Id", "HRES_Year", "HRES_Month", "HRES_WorkingDays", "HRES_DailyRates", "HRES_EPF", "HRES_FPF", "HRES_Ac21", "HRES_Ac22", "HRES_Ac5", "HRES_FromDate", "HRES_ToDate", "HRES_ArrearRegFlag", "HRES_BankCashFlag", "HRMGT_Id", "HRMD_Id", "HRMDES_Id", "HRES_BankCode", "HRES_AccountNo", "HRES_ESIEmplr", "HRES_ApproveFlg")
            VALUES (p_MI_ID, p_HRME_ID, v_LEAVE_YEAR, p_IVRM_Month_Name, v_WORKINGDAYS, v_SALARYPERDAY, NULL, NULL, NULL, NULL, NULL, CAST(v_MONTH_START_DATE AS DATE), CAST(v_MONTH_END_DATE AS DATE), NULL, v_HRME_PaymentType, v_EMPHRMGT_Id, v_EMPHRMD_Id, v_EMPHRMDES_Id, v_HRMBD_BankName, v_HRMEB_AccountNo, NULL, 0)
            RETURNING "HRES_Id" INTO v_NEW_IDENTITY;
        ELSE
            INSERT INTO "HR_Employee_Salary"("MI_Id", "HRME_Id", "HRES_Year", "HRES_Month", "HRES_WorkingDays", "HRES_DailyRates", "HRES_EPF", "HRES_FPF", "HRES_Ac21", "HRES_Ac22", "HRES_Ac5", "HRES_FromDate", "HRES_ToDate", "HRES_ArrearRegFlag", "HRES_BankCashFlag", "HRMGT_Id", "HRMD_Id", "HRMDES_Id", "HRES_BankCode", "HRES_AccountNo", "HRES_ESIEmplr", "HRES_ApproveFlg")
            VALUES (p_MI_ID, p_HRME_ID, v_LEAVE_YEAR, p_IVRM_Month_Name, v_WORKINGDAYS, v_SALARYPERDAY, NULL, NULL, NULL, NULL, NULL, CAST(v_MONTH_START_DATE AS DATE), CAST(v_MONTH_END_DATE AS DATE), NULL, v_HRME_PaymentType, v_EMPHRMGT_Id, v_EMPHRMD_Id, v_EMPHRMDES_Id, v_HRMBD_BankName, v_HRMEB_AccountNo, NULL, 1)
            RETURNING "HRES_Id" INTO v_NEW_IDENTITY;
        END IF;
    END IF;

    FOR rec IN
        SELECT A."HRMED_Id", A."HREED_Amount", B."HRMED_EDTypeFlag", B."HRMED_EarnDedFlag", B."HRMED_AmountPercentFlag", B."HRMED_RoundOffFlag", A."HREED_ApplicableMaxValue"
        FROM "HR_Employee_EarningsDeductions" A
        LEFT JOIN "HR_Master_EarningsDeductions" B ON B."HRMED_Id" = A."HRMED_Id"
        WHERE A."MI_Id" = p_MI_ID AND A."HRME_Id" = p_HRME_ID AND B."HRMED_AmountPercentFlag" = 'Amount' AND B."HRMED_ActiveFlag" = 1 AND A."HREED_ActiveFlag" = 1
              AND A."HRMED_Id" NOT IN (SELECT "hrmed_id" FROM "temp_salary_comp_detail" WHERE "mi_id" = p_MI_ID AND "emp_id" = p_HRME_ID)
        ORDER BY B."HRMED_EarnDedFlag" DESC, B."HRMED_AmountPercentFlag" ASC
    LOOP
        v_HRMED_IdCUR1 := rec."HRMED_Id";
        v_HREED_AmountCUR1 := rec."HREED_Amount";
        v_HRMED_EDTypeFlagCUR1 := rec."HRMED_EDTypeFlag";
        v_HRMED_EarnDedFlagCUR1 := rec."HRMED_EarnDedFlag";
        v_HRMED_AmountPercentFlagCUR1 := rec."HRMED_AmountPercentFlag";
        v_HRMED_RoundOffFlagCUR1 := rec."HRMED_RoundOffFlag";
        v_HREED_ApplicableMaxValueCUR1 := rec."HREED_ApplicableMaxValue";

        SELECT COUNT(*) INTO v_TEMPSALCOUNT FROM "temp_salary_comp_detail" WHERE "mi_id" = p_MI_ID AND "emp_id" = p_HRME_ID AND "hrmed_id" = v_HRMED_IdCUR1;
        
        IF v_TEMPSALCOUNT = 0 THEN
            IF v_HRMED_EDTypeFlagCUR1 = 'Basic Pay' THEN
                RAISE NOTICE 'INSERT v_HRMED_IdCUR1 >> Basic Pay Already exist %', v_HRMED_IdCUR1;
            ELSE
                IF v_HREED_ApplicableMaxValueCUR1 <> 0 THEN
                    SELECT v_HREED_ApplicableMaxValueCUR1 INTO v_HREED_AmountCUR1;
                END IF;
                INSERT INTO "temp_salary_comp_detail" VALUES(p_MI_ID, p_HRME_ID, v_HRMED_IdCUR1, v_HREED_AmountCUR1, v_HRMED_EDTypeFlagCUR1, v_HRMED_EarnDedFlagCUR1, v_HRMED_AmountPercentFlagCUR1, v_HRMED_RoundOffFlagCUR1);
                RAISE NOTICE 'INSERT v_HRMED_IdCUR1 >> %', v_HRMED_IdCUR1;
            END IF;
        END IF;
    END LOOP;

    FOR rec IN