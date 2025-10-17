CREATE OR REPLACE FUNCTION "dbo"."ISM_User_EmployeeCount"(
    "p_MI_Id" BIGINT
)
RETURNS TABLE(
    "User_Id" BIGINT,
    "userName" TEXT,
    "employeecount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."User_Id",
        (CASE 
            WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' 
            ELSE c."HRME_EmployeeFirstName" 
         END || 
         CASE 
            WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeMiddleName" 
         END || 
         CASE 
            WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeLastName" 
         END)::TEXT AS "userName",
        COUNT(a."HRME_Id") AS "employeecount"
    FROM "ISM_User_Employees_Mapping" a
    INNER JOIN "IVRM_Staff_User_Login" b ON a."User_Id" = b."Id"
    INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = b."Emp_Code" AND b."MI_Id" = c."MI_Id"
    WHERE c."MI_Id" = "p_MI_Id" AND a."ISMUSEMM_ActiveFlag" = 1
    GROUP BY 
        a."User_Id",
        (CASE 
            WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' 
            ELSE c."HRME_EmployeeFirstName" 
         END || 
         CASE 
            WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeMiddleName" 
         END || 
         CASE 
            WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || c."HRME_EmployeeLastName" 
         END);
END;
$$;