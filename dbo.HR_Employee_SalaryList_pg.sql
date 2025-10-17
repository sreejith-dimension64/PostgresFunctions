CREATE OR REPLACE FUNCTION "dbo"."HR_Employee_SalaryList"(
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_HRES_Year bigint
)
RETURNS TABLE(
    salary numeric,
    ivrM_Month_Id integer,
    monthName varchar,
    hres_id bigint,
    hreS_Year bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    WITH earningdetails AS (
        SELECT 
            sum("HRESD_Amount") AS "HRESD_Amount",
            "HRES_Month",
            "IVRM_Month_Id",
            a."hres_id",
            a."hreS_Year"
        FROM "HR_Employee_Salary" a
        INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
        INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
        INNER JOIN "IVRM_Month" d ON a."HRES_Month" = d."IVRM_Month_Name"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."HRME_Id" = p_HRME_Id 
            AND "HRES_Year" = p_HRES_Year 
            AND "HRMED_EarnDedFlag" = 'Earning'
        GROUP BY "HRES_Month", "IVRM_Month_Id", a."hres_id", a."hreS_Year"
    ),
    deductiondetails AS (
        SELECT 
            sum("HRESD_Amount") AS "HRESD_Amount",
            "HRES_Month",
            "IVRM_Month_Id",
            a."hres_id",
            a."hreS_Year"
        FROM "HR_Employee_Salary" a
        INNER JOIN "HR_Employee_Salary_Details" b ON a."HRES_Id" = b."HRES_Id"
        INNER JOIN "HR_Master_EarningsDeductions" c ON b."HRMED_Id" = c."HRMED_Id"
        INNER JOIN "IVRM_Month" d ON a."HRES_Month" = d."IVRM_Month_Name"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."HRME_Id" = p_HRME_Id 
            AND "HRES_Year" = p_HRES_Year 
            AND "HRMED_EarnDedFlag" = 'Deduction'
        GROUP BY "HRES_Month", "IVRM_Month_Id", a."hres_id", a."hreS_Year"
    )
    SELECT 
        (a."HRESD_Amount" - b."HRESD_Amount") AS salary,
        a."IVRM_Month_Id" AS ivrM_Month_Id,
        a."HRES_Month" AS monthName,
        a."hres_id",
        a."hreS_Year"
    FROM earningdetails a
    INNER JOIN deductiondetails b ON a."HRES_Month" = b."HRES_Month"
    ORDER BY a."IVRM_Month_Id";

END;
$$;