CREATE OR REPLACE FUNCTION "BankCash_Report"(
    p_MI_ID BIGINT,
    p_HRES_Year TEXT,
    p_HRES_Month TEXT,
    p_HRMDES_Id TEXT,
    p_BankCash TEXT
)
RETURNS TABLE(
    "HRME_EmployeeOrder" INT,
    "HRME_EmployeeCode" TEXT,
    "EmployeeName" TEXT,
    "HRMEB_AccountNo" TEXT,
    "HRMBD_BankAccountNo" TEXT,
    "HRMBD_BankName" TEXT,
    "HRMBD_BranchName" TEXT,
    "Netsalary" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRES_BankCashFlag TEXT;
    v_TotalEarning BIGINT;
    v_TotalDeduction BIGINT;
    v_NetSalary BIGINT;
    v_HRES_Id BIGINT;
    v_HRME_ID BIGINT;
    v_HRME_EmployeeOrder INT;
    rec RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "Temp"(
        "HRME_EmployeeOrder" INT,
        "HRME_EmployeeCode" TEXT,
        "EmployeeName" TEXT,
        "HRMEB_AccountNo" TEXT,
        "HRMBD_BankAccountNo" TEXT,
        "HRMBD_BankName" TEXT,
        "HRMBD_BranchName" TEXT,
        "Netsalary" BIGINT
    ) ON COMMIT DROP;

    FOR rec IN 
        SELECT A."HRME_EmployeeOrder", A."HRME_Id", B."HRES_Id"
        FROM "HR_Master_Employee" A
        INNER JOIN "HR_Employee_Salary" B ON A."HRME_Id" = B."HRME_Id"
        WHERE B."HRES_Year" = p_HRES_Year 
            AND B."HRES_Month" = p_HRES_Month 
            AND A."HRMDES_Id" = p_HRMDES_Id
    LOOP
        v_HRME_EmployeeOrder := rec."HRME_EmployeeOrder";
        v_HRME_ID := rec."HRME_Id";
        v_HRES_Id := rec."HRES_Id";

        SELECT SUM(B."HRESD_Amount") INTO v_TotalEarning
        FROM "HR_Master_EarningsDeductions" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRMED_Id" = B."HRMED_Id"
        WHERE A."HRMED_EarnDedFlag" = 'Earning' AND A."MI_ID" = p_MI_ID;

        SELECT SUM(B."HRESD_Amount") INTO v_TotalDeduction
        FROM "HR_Master_EarningsDeductions" A
        INNER JOIN "HR_Employee_Salary_Details" B ON A."HRMED_Id" = B."HRMED_Id"
        WHERE A."HRMED_EarnDedFlag" = 'Deduction' AND A."MI_ID" = p_MI_ID;

        v_NetSalary := COALESCE(v_TotalEarning, 0) - COALESCE(v_TotalDeduction, 0);

        IF (p_BankCash = 'BANK') THEN
            INSERT INTO "Temp"
            SELECT 
                a."HRME_EmployeeOrder",
                a."HRME_EmployeeCode",
                COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '') AS "EmployeeName",
                e."HRMEB_AccountNo",
                d."HRMBD_BankAccountNo",
                d."HRMBD_BankName",
                d."HRMBD_BranchName",
                v_NetSalary
            FROM "HR_Master_Employee" a
            INNER JOIN "HR_Employee_Salary" b ON a."HRME_Id" = b."HRME_Id"
            INNER JOIN "HR_Master_Department" c ON c."HRMD_Id" = a."HRMD_Id"
            INNER JOIN "HR_Master_BankDeatils" d ON d."MI_Id" = a."MI_Id"
            INNER JOIN "HR_Master_Employee_Bank" e ON e."HRMBD_Id" = d."HRMBD_Id"
            WHERE a."HRME_Id" = v_HRME_ID
                AND b."MI_Id" = p_MI_ID
                AND b."HRES_BankCashFlag" = p_BankCash
                AND b."HRES_Id" = v_HRES_Id
                AND d."MI_Id" = p_MI_ID;

        ELSIF (p_BankCash = 'CASH') THEN
            INSERT INTO "Temp"
            SELECT 
                a."HRME_EmployeeOrder",
                a."HRME_EmployeeCode",
                COALESCE(a."HRME_EmployeeFirstName", '') || '' || COALESCE(a."HRME_EmployeeMiddleName", '') || '' || COALESCE(a."HRME_EmployeeLastName", '') AS "EmployeeName",
                e."HRMEB_AccountNo",
                d."HRMBD_BankAccountNo",
                f."HRMBD_BankName",
                f."HRMBD_BranchName",
                v_NetSalary
            FROM "HR_Master_Employee" a
            INNER JOIN "HR_Employee_Salary" b ON a."HRME_Id" = b."HRME_Id"
            INNER JOIN "HR_Master_Department" c ON c."HRMD_Id" = a."HRMD_Id"
            INNER JOIN "HR_Master_BankDeatils" d ON d."MI_Id" = a."MI_Id"
            INNER JOIN "HR_Master_Employee_Bank" e ON e."HRMBD_Id" = d."HRMBD_Id" AND e."HRME_Id" = a."HRME_Id"
            INNER JOIN "HR_Master_BankDeatils" f ON f."HRMBD_Id" = e."HRMBD_Id"
            WHERE b."MI_Id" = p_MI_ID
                AND b."HRES_BankCashFlag" = p_BankCash
                AND d."MI_Id" = p_MI_ID
            ORDER BY a."HRME_EmployeeOrder";
        END IF;

    END LOOP;

    RETURN QUERY
    SELECT DISTINCT 
        t."HRME_EmployeeOrder",
        t."HRME_EmployeeCode",
        t."EmployeeName",
        t."HRMEB_AccountNo",
        t."HRMBD_BankAccountNo",
        t."HRMBD_BankName",
        t."HRMBD_BranchName",
        t."Netsalary"
    FROM "Temp" t;

    DROP TABLE IF EXISTS "Temp";
END;
$$;