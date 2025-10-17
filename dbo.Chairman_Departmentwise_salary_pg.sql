CREATE OR REPLACE FUNCTION "dbo"."Chairman_Departmentwise_salary"(
    "@MI_ID" INT,
    "@year" VARCHAR(50),
    "@Month" VARCHAR(50)
)
RETURNS TABLE(
    "dept" VARCHAR,
    "HRMD_Id" INT,
    "Deduction" NUMERIC,
    "Earning" NUMERIC,
    "netamount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HRMD_DepartmentName" AS "dept",
        "HRMD_Id", 
        "Deduction",
        "Earning",
        COALESCE("Earning", 0) - COALESCE("Deduction", 0) AS "netamount" 
    FROM (
        SELECT DISTINCT
            "ED"."HRMED_EarnDedFlag",
            SUM("SD"."HRESD_Amount") AS "Amt",
            "MD"."HRMD_DepartmentName",
            "MD"."HRMD_Id"
        FROM "HR_Master_Department" "MD" 
        INNER JOIN "HR_Master_Employee" "E" 
            ON "MD"."HRMD_Id" = "E"."HRMD_Id" 
            AND "E"."MI_Id" = "@MI_ID" 
            AND "E"."HRME_ActiveFlag" = 1 
        INNER JOIN "HR_Master_GroupType" "GT" 
            ON "GT"."HRMGT_Id" = "E"."HRMGT_Id" 
            AND "GT"."MI_Id" = "@MI_ID"
        INNER JOIN "HR_Employee_Salary" "ES" 
            ON "ES"."MI_Id" = "@MI_ID" 
            AND "ES"."HRME_Id" = "E"."HRME_Id" 
            AND "ES"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Employee_Salary_Details" "SD" 
            ON "SD"."HRES_Id" = "ES"."HRES_Id" 
        INNER JOIN "HR_Master_EarningsDeductions" "ED" 
            ON "ED"."HRMED_Id" = "SD"."HRMED_Id" 
            AND "ED"."MI_Id" = "@MI_ID"
        INNER JOIN "IVRM_Month" AS "d" 
            ON "ES"."HRES_Month" = "d"."IVRM_Month_Name"
        WHERE "MD"."MI_Id" = "@MI_ID" 
            AND "MD"."HRMD_ActiveFlag" = 1
            AND "ES"."HRES_Month" = "@Month" 
            AND "ES"."HRES_Year" = "@year" 
            AND "ED"."HRMED_ActiveFlag" = 1
        GROUP BY "ED"."HRMED_EarnDedFlag", "MD"."HRMD_DepartmentName", "MD"."HRMD_Id"
        ORDER BY "MD"."HRMD_Id"
        LIMIT 100
    ) AS "New"
    PIVOT (
        SUM("Amt") FOR "HRMED_EarnDedFlag" IN ("Deduction", "Earning")
    ) AS "PVT";
    
    RETURN;
END;
$$;

-- Note: PostgreSQL does not have native PIVOT. Use crosstab or CASE WHEN instead:

CREATE OR REPLACE FUNCTION "dbo"."Chairman_Departmentwise_salary"(
    "@MI_ID" INT,
    "@year" VARCHAR(50),
    "@Month" VARCHAR(50)
)
RETURNS TABLE(
    "dept" VARCHAR,
    "HRMD_Id" INT,
    "Deduction" NUMERIC,
    "Earning" NUMERIC,
    "netamount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HRMD_DepartmentName" AS "dept",
        "HRMD_Id", 
        SUM(CASE WHEN "HRMED_EarnDedFlag" = 'Deduction' THEN "Amt" ELSE NULL END) AS "Deduction",
        SUM(CASE WHEN "HRMED_EarnDedFlag" = 'Earning' THEN "Amt" ELSE NULL END) AS "Earning",
        COALESCE(SUM(CASE WHEN "HRMED_EarnDedFlag" = 'Earning' THEN "Amt" ELSE NULL END), 0) - 
        COALESCE(SUM(CASE WHEN "HRMED_EarnDedFlag" = 'Deduction' THEN "Amt" ELSE NULL END), 0) AS "netamount"
    FROM (
        SELECT DISTINCT
            "ED"."HRMED_EarnDedFlag",
            SUM("SD"."HRESD_Amount") AS "Amt",
            "MD"."HRMD_DepartmentName",
            "MD"."HRMD_Id"
        FROM "HR_Master_Department" "MD" 
        INNER JOIN "HR_Master_Employee" "E" 
            ON "MD"."HRMD_Id" = "E"."HRMD_Id" 
            AND "E"."MI_Id" = "@MI_ID" 
            AND "E"."HRME_ActiveFlag" = 1 
        INNER JOIN "HR_Master_GroupType" "GT" 
            ON "GT"."HRMGT_Id" = "E"."HRMGT_Id" 
            AND "GT"."MI_Id" = "@MI_ID"
        INNER JOIN "HR_Employee_Salary" "ES" 
            ON "ES"."MI_Id" = "@MI_ID" 
            AND "ES"."HRME_Id" = "E"."HRME_Id" 
            AND "ES"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Employee_Salary_Details" "SD" 
            ON "SD"."HRES_Id" = "ES"."HRES_Id" 
        INNER JOIN "HR_Master_EarningsDeductions" "ED" 
            ON "ED"."HRMED_Id" = "SD"."HRMED_Id" 
            AND "ED"."MI_Id" = "@MI_ID"
        INNER JOIN "IVRM_Month" AS "d" 
            ON "ES"."HRES_Month" = "d"."IVRM_Month_Name"
        WHERE "MD"."MI_Id" = "@MI_ID" 
            AND "MD"."HRMD_ActiveFlag" = 1
            AND "ES"."HRES_Month" = "@Month" 
            AND "ES"."HRES_Year" = "@year" 
            AND "ED"."HRMED_ActiveFlag" = 1
        GROUP BY "ED"."HRMED_EarnDedFlag", "MD"."HRMD_DepartmentName", "MD"."HRMD_Id"
        ORDER BY "MD"."HRMD_Id"
        LIMIT 100
    ) AS "New"
    GROUP BY "HRMD_DepartmentName", "HRMD_Id"
    ORDER BY "HRMD_Id";
    
    RETURN;
END;
$$;