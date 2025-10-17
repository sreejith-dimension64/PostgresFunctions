CREATE OR REPLACE FUNCTION "HR_PF_TRANSACTION_INSERT"(
    p_MI_Id BIGINT,
    p_userid BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_COUNT BIGINT;
    v_HRME_ID BIGINT;
    v_HREVPFST_OpeningBalance DECIMAL(18,2);
    v_Contribution DECIMAL(18,2);
    v_ClosingBalance DECIMAL(18,2);
    v_Interest DECIMAL(18,2);
    v_IMFY_Id BIGINT;
    v_MonthId BIGINT;
    v_YearId BIGINT;
    v_MonthName VARCHAR(500);
    v_DATE DATE;
    emp_record RECORD;
BEGIN
    v_MonthId := EXTRACT(MONTH FROM CURRENT_TIMESTAMP);
    v_YearId := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    v_MonthName := TO_CHAR(CURRENT_TIMESTAMP, 'Month');
    v_MonthName := TRIM(v_MonthName);
    v_DATE := CURRENT_DATE;

    SELECT "IMFY_ID" INTO v_IMFY_Id 
    FROM "IVRM_Master_FinancialYear" 
    WHERE v_DATE BETWEEN "IMFY_FromDate" AND "IMFY_ToDate"
    LIMIT 1;

    FOR emp_record IN 
        SELECT DISTINCT A."HRME_ID" 
        FROM "HR_Master_Employee" A
        INNER JOIN "HR_Employee_Salary" B ON B."HRME_ID" = A."HRME_ID"
        WHERE A."MI_Id" = p_MI_Id 
            AND B."HRES_Year" = v_YearId 
            AND B."HRES_Month" = v_MonthName 
            AND A."HRME_PFApplicableFlag" = 1
    LOOP
        v_HRME_ID := emp_record."HRME_ID";

        SELECT COUNT(*) INTO v_COUNT 
        FROM "HR_Employee_PF_Transaction" 
        WHERE "HRME_Id" = v_HRME_ID;

        IF (v_COUNT > 0) THEN

            SELECT "HREVPFST_ClosingBalance" INTO v_HREVPFST_OpeningBalance
            FROM "HR_Employee_PF_Transaction" 
            WHERE "HRME_Id" = v_HRME_ID 
            ORDER BY "HREVPFST_CreatedDate" DESC 
            LIMIT 1;

            SELECT B."HRESD_Amount" INTO v_Contribution
            FROM "HR_Employee_Salary" A
            INNER JOIN "HR_Employee_Salary_Details" B ON A."HRES_ID" = B."HRES_ID"
            INNER JOIN "HR_Master_EarningsDeductions" C ON B."HRMED_ID" = C."HRMED_ID"
            WHERE A."MI_ID" = p_MI_Id 
                AND A."HRME_ID" = v_HRME_ID 
                AND A."HRES_year" = v_YearId 
                AND A."HRES_Month" = v_MonthName 
                AND C."HRMED_EDTypeFlag" = 'PF'
                AND C."HRMED_ActiveFlag" = 1
            LIMIT 1;

            v_Contribution := COALESCE(v_Contribution, 0);
            v_HREVPFST_OpeningBalance := COALESCE(v_HREVPFST_OpeningBalance, 0);

            v_Interest := ROUND((v_HREVPFST_OpeningBalance + v_Contribution) * 8.5 / (12 * 100), 0);

            v_ClosingBalance := v_HREVPFST_OpeningBalance + v_Contribution;

            INSERT INTO "HR_Employee_PF_Transaction" (
                "MI_Id", "HRME_Id", "IMFY_Id", "Month_Id", "HREVPFST_VPFOBAmount", 
                "HREVPFST_Contribution", "HREVPFST_Intersest", "HREVPFST_WithdrawAmount", 
                "HREVPFST_DepositAmount", "HREVPFST_ClosingBalance", "HREVPFST_PFVPF_Flag", 
                "HREVPFST_Type_Flag", "HREVPFST_ActiveFlg", "HREVPFST_CreatedBy", 
                "HREVPFST_UpdatedBy", "HREVPFST_CreatedDate", "HREVPFST_UpdatedDate"
            )
            VALUES (
                p_MI_Id, v_HRME_ID, v_IMFY_Id, v_MonthId, v_HREVPFST_OpeningBalance, 
                v_Contribution, v_Interest, 0, 0, v_ClosingBalance, '', '', 
                1, p_userid, p_userid, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );

        END IF;

    END LOOP;

END;
$$;