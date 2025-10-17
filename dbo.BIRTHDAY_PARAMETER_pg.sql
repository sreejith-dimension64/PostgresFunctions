CREATE OR REPLACE FUNCTION "dbo"."BIRTHDAY_PARAMETER"(
    "UserID" varchar(50),
    "template" varchar(200),
    "type" varchar(20),
    "coe_id" text
)
RETURNS TABLE (
    result_column1 text,
    result_column2 text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "template" = 'BIRTHDAY' THEN
        IF ("type" = 'Student') THEN
            RETURN QUERY
            SELECT 
                "AMST_FirstName" || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '') as result_column1,
                NULL::text as result_column2
            FROM "dbo"."Adm_M_Student"
            WHERE "AMST_Id" = "UserID";
        ELSIF ("type" = 'Employee') THEN
            RETURN QUERY
            SELECT 
                "HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') as result_column1,
                NULL::text as result_column2
            FROM "dbo"."HR_Master_Employee"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'COE' THEN
        IF ("type" = 'Student') THEN
            RETURN QUERY
            SELECT 
                "AMST_FirstName" || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '') as result_column1,
                COALESCE("Master_Institution"."MI_Name", '') as result_column2
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "Master_Institution" ON "dbo"."Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "AMST_id" = "UserID";
        ELSIF ("type" = 'Employee') THEN
            RETURN QUERY
            SELECT 
                "HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') as result_column1,
                COALESCE("Master_Institution"."MI_Name", '') as result_column2
            FROM "dbo"."HR_Master_Employee"
            INNER JOIN "Master_Institution" ON "dbo"."HR_Master_Employee"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'STAFFBIRTHDAY' THEN
        IF ("type" = 'Employee') THEN
            RETURN QUERY
            SELECT 
                "HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') as result_column1,
                NULL::text as result_column2
            FROM "dbo"."HR_Master_Employee"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    END IF;
    
    RETURN;
END;
$$;