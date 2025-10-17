CREATE OR REPLACE FUNCTION "dbo"."ISM_OnChangeofDept"(
    "MI_Id" VARCHAR(50),
    "HRMD_IDsss" TEXT
)
RETURNS TABLE (
    "employeeName" TEXT,
    "HRME_Id" INTEGER,
    "HRMD_DepartmentName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := '
    SELECT 
    ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    HRE."HRME_EmployeeFirstName" END || CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = ''''
    OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || 
    CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
    OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END )) AS "employeeName", 
    HRE."HRME_Id" AS "HRME_Id", "HR_Master_Department"."HRMD_DepartmentName" AS "HRMD_DepartmentName" 
    FROM "HR_Master_Employee" HRE 
    INNER JOIN "HR_Master_Department" ON "HR_Master_Department"."HRMD_Id" = HRE."HRMD_Id" 
    WHERE HRE."HRME_ActiveFlag" = 1 AND HRE."HRME_LeftFlag" = 0 AND HRE."HRME_ActiveFlag" = 1 
    AND "HR_Master_Department"."HRMD_Id" IN (' || "HRMD_IDsss" || ')';

    RETURN QUERY EXECUTE v_query;
END;
$$;