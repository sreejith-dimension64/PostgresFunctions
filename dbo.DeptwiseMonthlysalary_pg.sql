CREATE OR REPLACE FUNCTION "dbo"."DeptwiseMonthlysalary"(
    "@MI_Id" VARCHAR(50),
    "@year" VARCHAR(100),
    "@Month" VARCHAR(100),
    "@HRMD_Id" TEXT
)
RETURNS TABLE(
    "HRES_Month" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "Salary" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT "ES"."HRES_Month", "MD"."HRMD_DepartmentName", SUM("ESD"."HRESD_Amount") AS "Salary"
    FROM "HR_Employee_Salary" "ES"
    INNER JOIN "HR_Employee_Salary_Details" "ESD" ON "ESD"."HRES_ID" = "ES"."HRES_Id"
    INNER JOIN "HR_Master_Department" "MD" ON "MD"."HRMD_Id" = "ES"."HRMD_Id" AND "MD"."MI_ID" = "ES"."MI_Id"
    INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = "ES"."HRES_Month"
    WHERE "ES"."MI_Id" = ' || "@MI_Id" || ' AND "HRES_Year" IN (' || "@year" || ') AND "IM"."IVRM_Month_Id" IN (' || "@Month" || ') AND "MD"."HRMD_Id" IN (' || "@HRMD_Id" || ')
    GROUP BY "HRES_Year", "ES"."HRES_Month", "IVRM_Month_Id", "HRMD_DepartmentName" 
    ORDER BY "IVRM_Month_Id", "HRES_Year"';
    
    RETURN QUERY EXECUTE v_query;
    
END;
$$;