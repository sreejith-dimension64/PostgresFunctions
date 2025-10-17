CREATE OR REPLACE FUNCTION "HR_Emploan_Report"(
    p_mi_id BIGINT,
    p_hrme_id BIGINT,
    p_HRELT_Month TEXT,
    p_HRELT_Year BIGINT
)
RETURNS TABLE(
    "hrmE_EmployeeFirstName" TEXT,
    "hrmE_EmployeeCode" VARCHAR,
    "hreL_LoanAmount" NUMERIC,
    "hreL_LoanInsallments" INTEGER,
    "hreLT_LoanAmount" NUMERIC,
    "hreLT_Month" VARCHAR,
    "hreLT_Year" BIGINT,
    "hrmL_LoanType" VARCHAR,
    "hreL_TotalPending" NUMERIC,
    "ivrM_Month_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_hrme_id != 0) THEN
        RETURN QUERY
        SELECT 
            CONCAT(COALESCE(a."HRME_EmployeeFirstName",''),' ',COALESCE(a."HRME_EmployeeMiddleName",''),' ',COALESCE(a."HRME_EmployeeLastName",'')) AS "hrmE_EmployeeFirstName",
            a."HRME_EmployeeCode" AS "hrmE_EmployeeCode",
            c."HREL_LoanAmount" AS "hreL_LoanAmount",
            c."HREL_LoanInsallments" AS "hreL_LoanInsallments",
            d."HRELT_LoanAmount" AS "hreLT_LoanAmount",
            d."HRELT_Month" AS "hreLT_Month",
            d."HRELT_Year" AS "hreLT_Year",
            e."HRML_LoanType" AS "hrmL_LoanType",
            c."HREL_TotalPending" AS "hreL_TotalPending",
            f."IVRM_Month_Id" AS "ivrM_Month_Id"
        FROM "HR_Master_Employee" a 
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "HR_Emp_Loan" c ON c."HRME_Id" = a."HRME_Id"
        INNER JOIN "HR_Emp_Loan_Transaction" d ON c."HREL_Id" = d."HREL_Id" AND c."HRME_Id" = d."HRME_Id"
        INNER JOIN "HR_Master_Loan" e ON e."HRMLN_Id" = c."HRMLN_Id"
        INNER JOIN "IVRM_Month" f ON f."IVRM_Month_Name" = d."HRELT_Month"
        WHERE a."MI_Id" = p_mi_id AND a."HRME_Id" = p_hrme_id
        ORDER BY d."HRELT_Year", f."IVRM_Month_Id";
    ELSE
        RETURN QUERY
        SELECT 
            CONCAT(COALESCE(a."HRME_EmployeeFirstName",''),' ',COALESCE(a."HRME_EmployeeMiddleName",''),' ',COALESCE(a."HRME_EmployeeLastName",'')) AS "hrmE_EmployeeFirstName",
            a."HRME_EmployeeCode" AS "hrmE_EmployeeCode",
            c."HREL_LoanAmount" AS "hreL_LoanAmount",
            c."HREL_LoanInsallments" AS "hreL_LoanInsallments",
            d."HRELT_LoanAmount" AS "hreLT_LoanAmount",
            d."HRELT_Month" AS "hreLT_Month",
            d."HRELT_Year" AS "hreLT_Year",
            e."HRML_LoanType" AS "hrmL_LoanType",
            c."HREL_TotalPending" AS "hreL_TotalPending",
            NULL::INTEGER AS "ivrM_Month_Id"
        FROM "HR_Master_Employee" a 
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "HR_Emp_Loan" c ON c."HRME_Id" = a."HRME_Id"
        INNER JOIN "HR_Emp_Loan_Transaction" d ON c."HREL_Id" = d."HREL_Id" AND c."HRME_Id" = d."HRME_Id"
        INNER JOIN "HR_Master_Loan" e ON e."HRMLN_Id" = c."HRMLN_Id"
        WHERE a."MI_Id" = p_mi_id AND d."HRELT_Month" = p_HRELT_Month AND d."HRELT_Year" = p_HRELT_Year;
    END IF;

    RETURN;
END;
$$;