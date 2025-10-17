CREATE OR REPLACE FUNCTION "dbo"."getdata"(
    p_MI_Id integer
)
RETURNS TABLE (
    "Id" integer,
    "UserName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "b"."HRME_Id" as "Id", 
        (COALESCE("b"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("b"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("b"."HRME_EmployeeLastName", '') || ':' || "b"."HRME_EmployeeCode") as "UserName" 
    FROM 
        "IVRM_Staff_User_Login" "a" 
        INNER JOIN "HR_Master_Employee" "b" ON "a"."Emp_Code" = "b"."HRME_Id" 
    WHERE 
        "a"."MI_Id" = p_MI_Id 
        AND "HRME_ActiveFlag" = 1
    GROUP BY 
        "HRME_Id", 
        "HRME_EmployeeFirstName", 
        "HRME_EmployeeMiddleName", 
        "HRME_EmployeeLastName", 
        "HRME_EmployeeCode";
END;
$$;