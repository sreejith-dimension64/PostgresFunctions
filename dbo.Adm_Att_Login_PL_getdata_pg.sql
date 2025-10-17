CREATE OR REPLACE FUNCTION "dbo"."Adm_Att_Login_PL_getdata"(
    "MI_Id" int,
    "flag" int,
    "ASMAY_Id" text
)
RETURNS TABLE(
    "Id" int,
    "UserName" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "flag" = 2 THEN
        RETURN QUERY
        SELECT 
            a."HRME_Id" AS "Id", 
            (CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '' THEN '' ELSE b."HRME_EmployeeFirstName" END ||
            CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '' OR b."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || 
            b."HRME_EmployeeMiddleName" END ||
            CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '' OR b."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || b."HRME_EmployeeLastName" END || ':' || b."HRME_EmployeeCode") AS "UserName"
        FROM "IVRM_Master_ClassTeacher" a 
        INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" 
        WHERE a."MI_Id" = "MI_Id" 
            AND b."HRME_ActiveFlag" = 1 
            AND a."ASMAY_Id" = "ASMAY_Id"
            AND a."IMCT_ActiveFlag" = 1 
        ORDER BY "UserName";
    ELSE
        RETURN QUERY
        SELECT 
            b."HRME_Id" AS "Id", 
            (CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '' THEN '' ELSE b."HRME_EmployeeFirstName" END ||
            CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '' OR b."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || 
            b."HRME_EmployeeMiddleName" END ||
            CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '' OR b."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || b."HRME_EmployeeLastName" END || ':' || b."HRME_EmployeeCode") AS "UserName"
        FROM "IVRM_Staff_User_Login" a 
        INNER JOIN "HR_Master_Employee" b ON a."Emp_Code" = b."HRME_Id" 
        WHERE a."MI_Id" = "MI_Id" 
            AND b."HRME_ActiveFlag" = 1 
        ORDER BY "UserName";
    END IF;

END;
$$;