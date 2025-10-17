CREATE OR REPLACE FUNCTION "dbo"."HR_EmployeeDetials"(
    "HRME_ID" TEXT
)
RETURNS TABLE(
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_DOJ" TIMESTAMP
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := '
    SELECT "HRMD_DepartmentName", "HRMDES_DesignationName", "HRME_DOJ"
    FROM "hr_master_employee" "A"
    INNER JOIN "HR_Master_Department" "B" ON "B"."HRMD_ID" = "A"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "C" ON "C"."HRMDES_Id" = "A"."HRMDES_Id"
    WHERE "HRME_Id" IN (' || "HRME_ID" || ')';
    
    RETURN QUERY EXECUTE "query";
END;
$$;