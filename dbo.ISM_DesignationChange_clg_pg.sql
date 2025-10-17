CREATE OR REPLACE FUNCTION "dbo"."ISM_DesignationChange_clg"(
    "@departments" VARCHAR
)
RETURNS TABLE(
    "userEmpName" TEXT,
    "HRME_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    "@Slqdymaic" := 'SELECT  
    ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "userEmpName", 
    HRE."HRME_Id" AS "HRME_Id",
    "HRMDES_DesignationName" AS "HRMD_DepartmentName",
    HRE."MI_Id" AS "MI_Id"
    FROM "HR_Master_Employee" HRE 
    INNER JOIN "HR_Master_Designation" ON "HR_Master_Designation"."HRMDES_Id" = HRE."HRMDES_Id" 
    WHERE HRE."HRME_ActiveFlag" = 1 AND HRE."HRME_LeftFlag" = 0 AND HRE."HRME_ActiveFlag" = 1 
    AND "HR_Master_Designation"."HRMDES_Id" IN (' || "@departments" || ')';

    RETURN QUERY EXECUTE "@Slqdymaic";
END;
$$;