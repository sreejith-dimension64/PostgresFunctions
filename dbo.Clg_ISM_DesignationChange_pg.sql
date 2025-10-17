CREATE OR REPLACE FUNCTION "Clg_ISM_DesignationChange"(
    "departments" TEXT,
    "designations" TEXT
)
RETURNS TABLE(
    "userEmpName" TEXT,
    "HRME_Id" INTEGER,
    "HRMD_DepartmentName" TEXT,
    "MI_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := 'SELECT ' ||
        '((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE ' ||
        '"HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' ' ||
        'OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' ' ||
        'OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "userEmpName", "HRE"."HRME_Id" AS "HRME_Id", "HRMDES_DesignationName" AS "HRMD_DepartmentName", "HRE"."MI_Id" ' ||
        'FROM "HR_Master_Employee" "HRE" ' ||
        'INNER JOIN "HR_Master_Designation" ON "HR_Master_Designation"."HRMDES_Id" = "HRE"."HRMDES_Id" ' ||
        'INNER JOIN "HR_Master_Department" ON "HR_Master_Department"."HRMD_Id" = "HRE"."HRMD_Id" ' ||
        'WHERE "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0 AND "HRE"."HRME_ActiveFlag" = 1 AND "HR_Master_Designation"."HRMDES_Id" IN (' || "designations" || ') AND "HR_Master_Department"."HRMD_Id" IN (' || "departments" || ')';
    
    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;