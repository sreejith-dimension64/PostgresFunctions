CREATE OR REPLACE FUNCTION "dbo"."getEditdata"(
    p_MI_Id int,
    p_IVRMSTAUL_Id int
)
RETURNS TABLE(
    "Id" int,
    "UserName1" varchar,
    "UserName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."HRME_Id" AS "Id",
        a."IVRMSTAUL_UserName" AS "UserName1",
        (COALESCE(b."HRME_EmployeeFirstName",'') || ' ' || COALESCE(b."HRME_EmployeeMiddleName",'') || ' ' || COALESCE(b."HRME_EmployeeLastName",'') || ':' || COALESCE(b."HRME_EmployeeCode",'')) AS "UserName"
    FROM "IVRM_Staff_User_Login" a
    INNER JOIN "HR_Master_Employee" b ON a."Emp_Code" = b."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND b."HRME_ActiveFlag" = 1 
        AND a."Emp_Code" = p_IVRMSTAUL_Id;
END;
$$;