CREATE OR REPLACE FUNCTION "dbo"."ADMIN_ISM_User_EmployeeList_admin"(@MI_Id bigint)
RETURNS TABLE(
    "userEmpName" TEXT,
    "HRME_Id" bigint,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Id" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    RETURN QUERY
    SELECT  
        (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
        "HRME_EmployeeFirstName" END || 
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
        OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
        OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "userEmpName",
        "HRE"."HRME_Id" AS "HRME_Id",
        "HRMD_DepartmentName",
        "HRE"."MI_Id"
    FROM "HR_Master_Employee" "HRE" 
    INNER JOIN "HR_Master_Department" ON "HR_Master_Department"."HRMD_Id" = "HRE"."HRMD_Id" 
    WHERE "HRE"."HRME_ActiveFlag" = true 
        AND "HRE"."HRME_LeftFlag" = false 
        AND "HRE"."HRME_ActiveFlag" = true;
    
    RETURN;
END;
$$;