CREATE OR REPLACE FUNCTION "dbo"."HR_Employee_Salaryslip_Details"(
    "p_HRME_ID" TEXT,
    "p_HRELY_Year" TEXT
)
RETURNS TABLE(
    "HRES_Year" VARCHAR,
    "IVRM_Month_Id" INTEGER,
    "HRES_Month" VARCHAR,
    "Earning" NUMERIC,
    "Deduction" NUMERIC,
    "LOP" DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SALARY" TEXT;
BEGIN

    DROP TABLE IF EXISTS "temp_EarningTemp";
    DROP TABLE IF EXISTS "temp_DeductionTemp";
    DROP TABLE IF EXISTS "temp_LopTemp";

    CREATE TEMP TABLE "temp_EarningTemp" AS
    SELECT 
        B."HRES_Year",
        E."IVRM_Month_Id",
        B."HRES_Month",
        ROUND(SUM(C."HRESD_Amount"), 0) AS "Earning"
    FROM "HR_MAster_Employee" AS A 
    INNER JOIN "HR_employee_Salary" AS B ON A."HRME_Id" = B."HRME_Id"
    INNER JOIN "HR_employee_Salary_details" AS C ON C."HRES_Id" = B."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" AS D ON D."HRMED_Id" = C."HRMED_Id"
    INNER JOIN "IVRM_Month" E ON B."HRES_Month" = E."IVRM_Month_Name"
    WHERE A."HRME_Id"::TEXT IN ("p_HRME_ID") 
        AND B."HRES_Year"::TEXT IN ("p_HRELY_Year") 
        AND D."HRMED_EarnDedFlag" = 'Earning' 
        AND D."HRMED_EarnDedFlag" != 'Gross'
    GROUP BY B."HRES_Year", E."IVRM_Month_Id", B."HRES_Month"
    ORDER BY E."IVRM_Month_Id";

    CREATE TEMP TABLE "temp_DeductionTemp" AS
    SELECT 
        B."HRES_Year",
        E."IVRM_Month_Id",
        B."HRES_Month",
        ROUND(SUM(C."HRESD_Amount"), 0) AS "Deduction"
    FROM "HR_MAster_Employee" AS A 
    INNER JOIN "HR_employee_Salary" AS B ON A."HRME_Id" = B."HRME_Id"
    INNER JOIN "HR_employee_Salary_details" AS C ON C."HRES_Id" = B."HRES_Id"
    INNER JOIN "HR_Master_EarningsDeductions" AS D ON D."HRMED_Id" = C."HRMED_Id"
    INNER JOIN "IVRM_Month" E ON B."HRES_Month" = E."IVRM_Month_Name"
    WHERE A."HRME_Id"::TEXT IN ("p_HRME_ID") 
        AND B."HRES_Year"::TEXT IN ("p_HRELY_Year") 
        AND D."HRMED_EarnDedFlag" = 'Deduction' 
        AND D."HRMED_EarnDedFlag" != 'Gross'
    GROUP BY B."HRES_Year", E."IVRM_Month_Id", B."HRES_Month"
    ORDER BY E."IVRM_Month_Id";

    RETURN QUERY
    SELECT 
        a."HRES_Year",
        a."IVRM_Month_Id",
        a."HRES_Month",
        (a."Earning" - b."Deduction")::NUMERIC AS "Earning",
        b."Deduction"::NUMERIC,
        CAST('0.00' AS DOUBLE PRECISION) AS "LOP"
    FROM "temp_EarningTemp" a
    INNER JOIN "temp_DeductionTemp" b 
        ON a."IVRM_Month_Id" = b."IVRM_Month_Id" 
        AND a."HRES_Year" = b."HRES_Year";

    RAISE NOTICE '%', "v_SALARY";

END;
$$;