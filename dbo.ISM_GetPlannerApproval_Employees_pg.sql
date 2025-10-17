CREATE OR REPLACE FUNCTION "dbo"."ISM_GetPlannerApproval_Employees"(
    "@mi_id" bigint
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "employeename" text,
    "Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        b."HRME_Id",
        (
            (CASE 
                WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '' THEN '' 
                ELSE b."HRME_EmployeeFirstName" 
            END || 
            CASE 
                WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '' OR b."HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || b."HRME_EmployeeMiddleName" 
            END || 
            CASE 
                WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '' OR b."HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || b."HRME_EmployeeLastName" 
            END)
        ) AS "employeename",
        a."Id"
    FROM "IVRM_Staff_User_Login" a
    INNER JOIN "HR_Master_Employee" b ON a."Emp_Code" = b."HRME_Id"
    WHERE a."Id" IN (
        SELECT DISTINCT a."User_Id" 
        FROM "ISM_User_Employees_Mapping" a 
        INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
        WHERE b."HRME_ActiveFlag" = 1 
            AND b."HRME_LeftFlag" = 0 
            AND b."HRME_ExcPunch" = 0 
            AND a."ISMUSEMM_ActiveFlag" = 1 
            AND a."ISMUSEMM_Order" = 1
    );

END;
$$;