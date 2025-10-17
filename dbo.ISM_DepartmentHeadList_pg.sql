CREATE OR REPLACE FUNCTION "dbo"."ISM_DepartmentHeadList"(
    "departments" VARCHAR
)
RETURNS TABLE(
    "HRME_ID" INTEGER,
    "employeename" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
    SELECT b."HRME_ID",
           ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' 
                  ELSE "HRME_EmployeeFirstName" END ||
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
                       OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' 
                  ELSE '' '' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
                       OR "HRME_EmployeeLastName" = ''0'' THEN '''' 
                  ELSE '' '' || "HRME_EmployeeLastName" END)) AS "employeename"
    FROM "HR_Master_DepartmentCode" a
    INNER JOIN "HR_Master_DepartmentCode_Head" b ON a."HRMDC_ID" = b."HRMDC_ID"
    INNER JOIN "HR_Master_Employee" h ON b."HRME_ID" = h."HRME_Id"
    WHERE a."HRMDC_ID" IN (' || "departments" || ')';

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;