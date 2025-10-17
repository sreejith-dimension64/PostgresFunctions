CREATE OR REPLACE FUNCTION "dbo"."ISM_EmployeeList_New" (
    "Userid" BIGINT
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "employeeName" TEXT,
    "HRMD_DepartmentName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Departhead" BIGINT;
BEGIN
    SELECT COUNT(*) INTO "Departhead"
    FROM "HR_Master_DepartmentCode_Head" a 
    INNER JOIN "IVRM_Staff_User_Login" b ON a."HRME_ID" = b."Emp_Code" 
    WHERE b."Id" = "Userid";

    IF "Departhead" > 0 THEN
        RETURN QUERY
        SELECT DISTINCT "HRE"."HRME_Id", "HRE"."HRMD_Id",
        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
        OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
        OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END))::TEXT AS "employeeName",
        "HRD"."HRMD_DepartmentName"::TEXT
        FROM "HR_Master_Employee" "HRE"
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Module" "MM" ON "MM"."MI_Id" = "HRE"."MI_Id" AND "MM"."ISMMMD_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Module_Developers" "MMD" ON "MM"."ISMMMD_Id" = "MMD"."ISMMMD_Id"
        WHERE "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0 AND "HRE"."HRME_ActiveFlag" = 1
        ORDER BY "employeeName";
    ELSE
        RETURN QUERY
        SELECT DISTINCT "HRE"."HRME_Id", "HRE"."HRMD_Id",
        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
        OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
        OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END))::TEXT AS "employeeName",
        "HRD"."HRMD_DepartmentName"::TEXT
        FROM "HR_Master_Employee" "HRE"
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Module" "MM" ON "MM"."MI_Id" = "HRE"."MI_Id" AND "MM"."ISMMMD_ActiveFlag" = 1
        LEFT JOIN "ISM_Master_Module_Developers" "MMD" ON "MM"."ISMMMD_Id" = "MMD"."ISMMMD_Id"
        WHERE "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0 AND "HRE"."HRME_ActiveFlag" = 1 
        AND "HRE"."HRME_Id" IN (SELECT "hrme_id" FROM "ISM_User_Employees_Mapping" WHERE "user_id" = "Userid")
        ORDER BY "employeeName";
    END IF;

    RETURN;
END;
$$;