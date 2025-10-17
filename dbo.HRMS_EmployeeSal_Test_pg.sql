CREATE OR REPLACE FUNCTION "dbo"."HRMS_EmployeeSal_Test"(
    "MI_Id" bigint,
    "fromdate" varchar(10),
    "todate" varchar(10)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "pivot_cols" text;
    "dynamicsql" text;
    "dynamicsql1" text;
BEGIN
    DROP TABLE IF EXISTS "FEmpSalaryDetails_Temp";
    DROP TABLE IF EXISTS "FEmpSalaryDetails_Temp1";

    SELECT STRING_AGG('"' || "HRMED_Name" || '"', ',' ORDER BY "HRMED_Name")
    INTO "pivot_cols"
    FROM (SELECT DISTINCT "HRMED_Name" 
          FROM "HR_Master_EarningsDeductions" 
          WHERE "MI_Id" = "MI_Id") sub;

    "dynamicsql" := 'CREATE TEMP TABLE "FEmpSalaryDetails_Temp" AS 
                     SELECT DISTINCT "HRME_Id", "HRMED_Name", "HRESD_Amount"
                     FROM "HR_Employee_Salary" "HES"
                     INNER JOIN "HR_Employee_Salary_Details" "ESD" ON "HES"."HRES_Id" = "ESD"."HRES_Id"
                     INNER JOIN "HR_Master_EarningsDeductions" "HMED" ON "HMED"."HRMED_Id" = "ESD"."HRMED_Id"
                     WHERE "HES"."MI_Id" = ' || "MI_Id" || 
                    ' AND "HMED"."MI_Id" = ' || "MI_Id" || 
                    ' AND "HES"."HRES_FromDate"::varchar(10) >= ''' || "fromdate" || '''' ||
                    ' AND "HES"."HRES_ToDate"::varchar(10) <= ''' || "todate" || '''';

    EXECUTE "dynamicsql";

    "dynamicsql1" := 'CREATE TEMP TABLE "FEmpSalaryDetails_Temp1" AS 
                      SELECT * FROM CROSSTAB(
                          ''SELECT "HRME_Id", "HRMED_Name", SUM("HRESD_Amount") 
                            FROM "FEmpSalaryDetails_Temp" 
                            GROUP BY "HRME_Id", "HRMED_Name" 
                            ORDER BY 1, 2'',
                          ''SELECT DISTINCT "HRMED_Name" FROM "FEmpSalaryDetails_Temp" ORDER BY 1''
                      ) AS ct("HRME_Id" bigint, ' || "pivot_cols" || ' numeric)';

    EXECUTE "dynamicsql1";

    RETURN;
END;
$$;