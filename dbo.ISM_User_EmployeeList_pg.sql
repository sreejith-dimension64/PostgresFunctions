CREATE OR REPLACE FUNCTION "dbo"."ISM_User_EmployeeList" (
    "user_Id" VARCHAR(100), 
    "MI_Id" bigint
)
RETURNS TABLE (
    "HRME_Id" bigint,
    "HRMD_Id" bigint,
    "userEmpName" TEXT,
    "HRMD_DepartmentName" TEXT,
    "MI_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    IF ("user_Id" != '0') THEN
        RETURN QUERY
        SELECT DISTINCT 
            "UEM"."HRME_Id",
            "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
            OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
            OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "userEmpName",
            "HMD"."HRMD_DepartmentName",
            "HRE"."MI_Id"
        FROM "ISM_User_Employees_Mapping" "UEM"
        INNER JOIN "HR_Master_Employee" "HRE" ON "UEM"."HRME_Id" = "HRE"."HRME_Id" 
            AND "HRE"."HRME_ActiveFlag" = 1 
            AND "HRE"."HRME_LeftFlag" = 0 
            AND "HRE"."HRME_ActiveFlag" = 1 
        INNER JOIN "HR_Master_Department" "HMD" ON "HRE"."HRMD_Id" = "HMD"."HRMD_Id" 
            AND "HMD"."HRMD_ActiveFlag" = 1
        WHERE "UEM"."User_Id" = "user_Id"::bigint 
            AND "UEM"."ISMUSEMM_ActiveFlag" = 1
        ORDER BY "userEmpName";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            "HRE"."HRME_Id" AS "HRME_Id",
            NULL::bigint AS "HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
            OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
            OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "userEmpName",
            NULL::TEXT AS "HRMD_DepartmentName",
            "HRE"."MI_Id"
        FROM "HR_Master_Employee" "HRE" 
        WHERE "HRE"."HRME_ActiveFlag" = 1 
            AND "HRE"."HRME_LeftFlag" = 0 
            AND "HRE"."HRME_ActiveFlag" = 1 
            AND "MI_Id" = "MI_Id"
        ORDER BY "userEmpName";
    END IF;
    
    RETURN;
END;
$$;