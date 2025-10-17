CREATE OR REPLACE FUNCTION "dbo"."HR_PFOwnInstitution_TRANSACTION_INSERT"(
    p_MI_Id BIGINT,
    p_Monthname VARCHAR(500),
    p_YearId BIGINT,
    p_HRME_ID BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "IMFY_Id" BIGINT,
    "Month_Id" BIGINT,
    "HREPFST_OBOwnAmount" DECIMAL(18,2),
    "HREPFST_OBInstituteAmount" DECIMAL(18,2),
    "HREPFST_OwnContribution" DECIMAL(18,2),
    "HREPFST_IntstituteContribution" DECIMAL(18,2),
    "HREPFST_OwnInterest" DECIMAL(18,2),
    "HREPFST_InstituteInterest" DECIMAL(18,2),
    "HREPFST_OwnWithdrwanAmount" DECIMAL(18,2),
    "HREPFST_InstituteWithdrawnAmount" DECIMAL(18,2),
    "HREPFST_OwnSettlementAmount" DECIMAL(18,2),
    "HREPFST_InstituteLSettlementAmount" DECIMAL(18,2),
    "HREPFST_OwnClosingBalance" DECIMAL(18,2),
    "HREPFST_InstituteClosingBalance" DECIMAL(18,2),
    "HREPFST_ActiveFlg" BOOLEAN,
    "HREPFST_CreatedBy" BIGINT,
    "HREPFST_UpdatedBy" BIGINT,
    "HREPFST_CreatedDate" TIMESTAMP,
    "HREPFST_UpdatedDate" TIMESTAMP,
    "HREPFST_OwnTransferAmount" DECIMAL(18,2),
    "HREPFST_InstituteTransferAmount" DECIMAL(18,2),
    "HREPFST_OwnDepositAdjustmentAmount" DECIMAL(18,2),
    "HREPFST_OwnWithdrawAdjustmentAmount" DECIMAL(18,2),
    "HREPFST_InstituteDepositAdjustmentAmount" DECIMAL(18,2),
    "HREPFST_InstituteWithdrawAdjustmentAmount" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_COUNT BIGINT;
    v_HREVPFST_OpeningBalance DECIMAL(18,2);
    v_Contribution DECIMAL(18,2);
    v_ClosingBalance DECIMAL(18,2);
    v_COUNT1 BIGINT;
    v_Interest DECIMAL(18,2);
    v_IMFY_Id BIGINT;
    v_HRME_DOB DATE;
    v_SUMAMOUNT DECIMAL(18,2);
    v_HRME_FPFNotApplicableFlg BOOLEAN;
    v_HRMPFVPFINT_PFInterestRate DECIMAL(18,2);
    v_Inst_Contribution DECIMAL(18,2);
    v_INST_PF DECIMAL(18,2);
    v_HREPFST_InstituteOpeningBalance DECIMAL(18,2);
    v_INST_Interest DECIMAL(18,2);
    v_INST_ClosingBalance DECIMAL(18,2);
    v_MonthId BIGINT;
    v_DATE DATE;
BEGIN

    SELECT "IVRM_Month_Id" INTO v_MonthId 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Name" = p_Monthname;

    v_DATE := TO_DATE(CONCAT(p_YearId, '-', v_MonthId, '-', '01'), 'YYYY-MM-DD');

    SELECT "IMFY_ID" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE v_DATE BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";

    SELECT "HRMPFVPFINT_PFInterestRate" INTO v_HRMPFVPFINT_PFInterestRate 
    FROM "HR_Master_PFVPF_Interest" 
    WHERE "MI_Id" = p_MI_Id 
        AND "IMFY_Id" = v_IMFY_Id 
        AND "HRMPFVPFINT_ActiveFlg" = TRUE;

    SELECT DISTINCT 
        COALESCE(A."HRME_FPFNotApplicableFlg", FALSE),
        A."HRME_DOB"
    INTO v_HRME_FPFNotApplicableFlg, v_HRME_DOB
    FROM "HR_Master_Employee" A
    INNER JOIN "HR_Employee_Salary" B ON B."HRME_ID" = A."HRME_ID"
    WHERE A."MI_Id" = p_MI_Id 
        AND B."HRES_Year" = p_YearId 
        AND B."HRES_Month" = p_Monthname 
        AND A."HRME_PFApplicableFlag" = TRUE 
        AND A."HRME_Id" = p_HRME_ID 
        AND A."HRME_Id" NOT IN (
            SELECT "HRME_Id" 
            FROM "HR_Employee_PF_Status" 
            WHERE "MI_Id" = p_MI_Id 
                AND "IMFY_Id" = v_IMFY_Id 
                AND "Month_Id" = v_MonthId 
                AND "HRME_Id" = p_HRME_ID
        ) 
        AND A."HRME_ActiveFlag" = TRUE 
        AND A."HRME_LeftFlag" = FALSE;

    SELECT COUNT(*) INTO v_COUNT 
    FROM "HR_Employee_PF_Status" 
    WHERE "HRME_Id" = p_HRME_Id;

    IF (v_COUNT > 0) THEN

        SELECT 
            COALESCE("HREPFST_OwnClosingBalance", 0),
            COALESCE("HREPFST_InstituteClosingBalance", 0)
        INTO v_HREVPFST_OpeningBalance, v_HREPFST_InstituteOpeningBalance
        FROM "HR_Employee_PF_Status" 
        WHERE "HRME_Id" = p_HRME_Id 
        ORDER BY "HREPFST_CreatedDate" DESC 
        LIMIT 1;

        SELECT B."HRESD_Amount" INTO v_Contribution
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_ID" = B."HRES_ID"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_ID" = C."HRMED_ID"
        WHERE A."MI_ID" = p_MI_Id 
            AND A."HRME_ID" = p_HRME_Id 
            AND A."HRES_year" = p_YearId 
            AND A."HRES_Month" = p_MonthName 
            AND C."HRMED_EDTypeFlag" = 'PF'
            AND C."HRMED_ActiveFlag" = TRUE;

        v_Interest := ROUND((v_HREVPFST_OpeningBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);

        v_ClosingBalance := v_HREVPFST_OpeningBalance + v_Contribution;

        SELECT DISTINCT SUM(B."HRESD_Amount") INTO v_SUMAMOUNT
        FROM "HR_Employee_Salary" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_Id" = B."HRES_Id"
        INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_Id" = C."HRMED_Id"
        WHERE A."MI_Id" = p_MI_Id 
            AND A."HRES_Year" = p_YearId 
            AND A."HRES_Month" = p_MonthName 
            AND C."HRMED_EarnDedFlag" = 'Earning' 
            AND A."HRME_Id" = p_HRME_ID;

        IF (v_SUMAMOUNT < 15000 AND v_HRME_FPFNotApplicableFlg = TRUE) THEN
            v_INST_PF := ROUND(v_SUMAMOUNT * v_HRMPFVPFINT_PFInterestRate / 100, 0);
        ELSIF (v_HRME_FPFNotApplicableFlg = TRUE) THEN
            v_INST_PF := 1250;
        ELSE
            v_INST_PF := 0;
        END IF;

        IF (v_HRME_FPFNotApplicableFlg = FALSE) THEN
            v_Inst_Contribution := v_Contribution;
        ELSE
            v_Inst_Contribution := v_Contribution - v_INST_PF;
        END IF;

        v_INST_Interest := ROUND((v_HREPFST_InstituteOpeningBalance) * v_HRMPFVPFINT_PFInterestRate / (12 * 100), 0);

        v_INST_ClosingBalance := v_HREPFST_InstituteOpeningBalance + v_Inst_Contribution;

        SELECT COUNT(*) INTO v_COUNT1 
        FROM "HR_Employee_PF_Status" 
        WHERE "MI_Id" = p_MI_Id 
            AND "HRME_Id" = p_HRME_Id 
            AND "IMFY_Id" = v_IMFY_Id 
            AND "Month_Id" = v_MonthId;

        IF (v_COUNT1 = 0) THEN

            INSERT INTO "HR_Employee_PF_Status" (
                "MI_Id", "HRME_Id", "IMFY_Id", "Month_Id", "HREPFST_OBOwnAmount", "HREPFST_OBInstituteAmount", 
                "HREPFST_OwnContribution", "HREPFST_IntstituteContribution", "HREPFST_OwnInterest",
                "HREPFST_InstituteInterest", "HREPFST_OwnWithdrwanAmount", "HREPFST_InstituteWithdrawnAmount", 
                "HREPFST_OwnSettlementAmount", "HREPFST_InstituteLSettlementAmount", "HREPFST_OwnClosingBalance",
                "HREPFST_InstituteClosingBalance", "HREPFST_ActiveFlg", "HREPFST_CreatedBy", "HREPFST_UpdatedBy", 
                "HREPFST_CreatedDate", "HREPFST_UpdatedDate", "HREPFST_OwnTransferAmount", "HREPFST_InstituteTransferAmount", 
                "HREPFST_OwnDepositAdjustmentAmount", "HREPFST_OwnWithdrawAdjustmentAmount", 
                "HREPFST_InstituteDepositAdjustmentAmount", "HREPFST_InstituteWithdrawAdjustmentAmount"
            )
            VALUES (
                p_MI_Id, p_HRME_Id, v_IMFY_Id, v_MonthId, v_HREVPFST_OpeningBalance, v_HREPFST_InstituteOpeningBalance, 
                v_Contribution, v_Inst_Contribution, v_Interest, v_INST_Interest, 0, 0, 0, 0, v_ClosingBalance,
                v_INST_ClosingBalance, TRUE, 0, 0, 
                TO_TIMESTAMP(CONCAT(p_YearId, '-', v_MonthId, '-', '12'), 'YYYY-MM-DD'), 
                TO_TIMESTAMP(CONCAT(p_YearId, '-', v_MonthId, '-', '12'), 'YYYY-MM-DD'), 
                0, 0, 0, 0, 0, 0
            );

        END IF;
    END IF;

    RETURN QUERY
    SELECT 
        eps."MI_Id", eps."HRME_Id", eps."IMFY_Id", eps."Month_Id", eps."HREPFST_OBOwnAmount", 
        eps."HREPFST_OBInstituteAmount", eps."HREPFST_OwnContribution", eps."HREPFST_IntstituteContribution", 
        eps."HREPFST_OwnInterest", eps."HREPFST_InstituteInterest", eps."HREPFST_OwnWithdrwanAmount", 
        eps."HREPFST_InstituteWithdrawnAmount", eps."HREPFST_OwnSettlementAmount", 
        eps."HREPFST_InstituteLSettlementAmount", eps."HREPFST_OwnClosingBalance", 
        eps."HREPFST_InstituteClosingBalance", eps."HREPFST_ActiveFlg", eps."HREPFST_CreatedBy", 
        eps."HREPFST_UpdatedBy", eps."HREPFST_CreatedDate", eps."HREPFST_UpdatedDate", 
        eps."HREPFST_OwnTransferAmount", eps."HREPFST_InstituteTransferAmount", 
        eps."HREPFST_OwnDepositAdjustmentAmount", eps."HREPFST_OwnWithdrawAdjustmentAmount", 
        eps."HREPFST_InstituteDepositAdjustmentAmount", eps."HREPFST_InstituteWithdrawAdjustmentAmount"
    FROM "HR_Employee_PF_Status" eps
    WHERE eps."MI_Id" = p_MI_Id 
        AND eps."IMFY_Id" = v_IMFY_Id 
        AND eps."Month_Id" = v_MonthId 
        AND eps."HRME_Id" = p_HRME_ID;

    RETURN;

END;
$$;