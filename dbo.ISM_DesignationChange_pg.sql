CREATE OR REPLACE FUNCTION "dbo"."ISM_DesignationChange"(
    "p_departments" TEXT,
    "p_designations" TEXT,
    "p_MI_Id" VARCHAR(100)
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
    "v_SqlDynamic" TEXT;
BEGIN
    "v_SqlDynamic" := 'SELECT 
        ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        HRE."HRME_EmployeeFirstName" END || CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
        OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
        OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END)) AS "userEmpName", 
        HRE."HRME_Id" AS "HRME_Id",
        "HRMDES_DesignationName" AS "HRMD_DepartmentName",
        HRE."MI_Id"
    FROM "HR_Master_Employee" HRE
    INNER JOIN "HR_Master_Designation" ON "HR_Master_Designation"."HRMDES_Id" = HRE."HRMDES_Id"
    INNER JOIN "HR_Master_Department" ON "HR_Master_Department"."HRMD_Id" = HRE."HRMD_Id"
    WHERE HRE."HRME_ActiveFlag" = 1 AND HRE."HRME_LeftFlag" = 0 AND HRE."HRME_ActiveFlag" = 1
    AND "HR_Master_Designation"."HRMDES_Id" IN (' || "p_designations" || ') 
    AND "HR_Master_Department"."HRMD_Id" IN (' || "p_departments" || ') 
    AND HRE."MI_Id" = ' || "p_MI_Id";

    RETURN QUERY EXECUTE "v_SqlDynamic";
END;
$$;