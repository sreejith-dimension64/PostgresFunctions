CREATE OR REPLACE FUNCTION "dbo"."ISM_EmployeeList"(
    "MI_Id" bigint,
    "Type" varchar(50)
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "employeemane" text,
    "HRMD_DepartmentName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "Type" = 'Employee' THEN
        RETURN QUERY
        SELECT 
            a."HRME_Id",
            (COALESCE(a."HRME_EmployeeFirstName", '') || COALESCE(a."HRME_EmployeeMiddleName", '') || COALESCE(a."HRME_EmployeeLastName", '')) as "employeemane",
            b."HRMD_DepartmentName"
        FROM "HR_Master_Employee" a
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        WHERE a."HRME_ActiveFlag" = 1 AND a."HRME_LeftFlag" = 0;
    END IF;
END;
$$;