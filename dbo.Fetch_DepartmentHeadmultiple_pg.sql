CREATE OR REPLACE FUNCTION "dbo"."Fetch_DepartmentHeadmultiple"(
    "HRMD_Id" TEXT
)
RETURNS TABLE(
    "Head" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT "HRMEM_EmailId" AS "Head" FROM "HR_Master_Employee" "HR" ' ||
               'INNER JOIN "HR_Master_Employee_EmailId" "HRE" ON "HR"."HRME_Id" = "HRE"."HRME_Id" ' ||
               'WHERE "HR"."HRME_Id" IN (SELECT "HRME_ID" FROM "HR_Master_DepartmentCode" "HRDC" ' ||
               'INNER JOIN "HR_Master_DepartmentCode_Head" "HRDCH" ON "HRDC"."HRMDC_ID" = "HRDCH"."HRMDC_ID" ' ||
               'WHERE "HRDC"."HRMDC_ID" IN (SELECT "HRMDC_ID" FROM "HR_Master_Department" WHERE "HRMD_Id" IN (' || "HRMD_Id" || ')))';
    
    RETURN QUERY EXECUTE "query";
END;
$$;