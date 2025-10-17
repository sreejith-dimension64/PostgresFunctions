CREATE OR REPLACE FUNCTION "dbo"."ISM_User_EmployeeList_admin_DR_Approval"(
    "p_MI_Id" bigint,
    "p_role" text,
    "p_user_Id" bigint
)
RETURNS TABLE(
    "userEmpName" text,
    "HRME_Id" bigint,
    "HRMD_DepartmentName" text,
    "MI_Id" bigint,
    "HRMD_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_HRME_Id" bigint;
BEGIN
    IF "p_role" = 'Admin' OR "p_role" = 'HR' THEN
        RETURN QUERY
        SELECT  
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
            OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
            OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "userEmpName",
            "HRE"."HRME_Id" AS "HRME_Id",
            "HRMDES_DesignationName" AS "HRMD_DepartmentName",
            "HRE"."MI_Id",
            NULL::bigint AS "HRMD_Id"
        FROM "HR_Master_Employee" "HRE"
        INNER JOIN "HR_Master_Designation" ON "HR_Master_Designation"."HRMDES_Id" = "HRE"."HRMDES_Id"
        WHERE "HRE"."HRME_ActiveFlag" = 1 
            AND "HRE"."HRME_LeftFlag" = 0 
            AND "HRE"."HRME_ActiveFlag" = 1
        ORDER BY "userEmpName";
    ELSE
        IF "p_user_Id" != 0 THEN
            SELECT "Emp_Code" INTO "v_HRME_Id" 
            FROM "IVRM_Staff_User_Login" 
            WHERE "ID" = "p_user_Id";

            RETURN QUERY
            SELECT DISTINCT 
                ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
                "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
                OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
                OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "userEmpName",
                "UEM"."HRME_Id",
                "HMD"."HRMDES_DesignationName" AS "HRMD_DepartmentName",
                "HRE"."MI_Id",
                "HRE"."HRMD_Id"
            FROM "ISM_User_Employees_Mapping" "UEM"
            INNER JOIN "HR_Master_Employee" "HRE" ON "UEM"."HRME_Id" = "HRE"."HRME_Id" 
                AND "HRE"."HRME_ActiveFlag" = 1 
                AND "HRE"."HRME_LeftFlag" = 0 
                AND "HRE"."HRME_ActiveFlag" = 1
            INNER JOIN "HR_Master_Designation" "HMD" ON "HRE"."HRMDES_Id" = "HMD"."HRMDES_Id" 
                AND "HMD"."HRMDES_ActiveFlag" = 1
            WHERE "UEM"."User_Id" = "p_user_Id" 
                AND "UEM"."ISMUSEMM_ActiveFlag" = 1 
                AND "UEM"."HRME_Id" != "v_HRME_Id"
            ORDER BY "userEmpName";
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
                "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
                OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
                OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "userEmpName",
                "HRE"."HRME_Id" AS "HRME_Id",
                NULL::text AS "HRMD_DepartmentName",
                "HRE"."MI_Id",
                NULL::bigint AS "HRMD_Id"
            FROM "HR_Master_Employee" "HRE" 
            WHERE "HRE"."HRME_ActiveFlag" = 1 
                AND "HRE"."HRME_LeftFlag" = 0 
                AND "HRE"."HRME_ActiveFlag" = 1 
                AND "MI_Id" = "p_MI_Id"
            ORDER BY "userEmpName";
        END IF;
    END IF;
END;
$$;