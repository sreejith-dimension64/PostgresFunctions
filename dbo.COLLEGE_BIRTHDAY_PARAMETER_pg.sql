CREATE OR REPLACE FUNCTION "dbo"."COLLEGE_BIRTHDAY_PARAMETER"(
    "UserID" varchar(50),
    "template" varchar(200),
    "type" varchar(20)
)
RETURNS TABLE (
    "result_name" varchar,
    "result_institute" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "template" = 'CLGBIRTHDAY' THEN
        IF "type" = 'Student' THEN
            RETURN QUERY
            SELECT 
                ("AMCST_FirstName" || ' ' || COALESCE("AMCST_MiddleName", '') || ' ' || COALESCE("AMCST_LastName", ''))::varchar AS "result_name",
                NULL::varchar AS "result_institute"
            FROM "CLG"."Adm_Master_College_Student"
            WHERE "AMCST_Id" = "UserID";
        ELSIF "type" = 'Employee' THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::varchar AS "result_name",
                NULL::varchar AS "result_institute"
            FROM "dbo"."HR_Master_Employee"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'CLGCOE' THEN
        IF "type" = 'Student' THEN
            RETURN QUERY
            SELECT 
                ("AMCST_FirstName" || ' ' || COALESCE("AMCST_MiddleName", '') || ' ' || COALESCE("AMCST_LastName", ''))::varchar AS "result_name",
                COALESCE("Master_Institution"."MI_Name", '')::varchar AS "result_institute"
            FROM "CLG"."Adm_Master_College_Student"
            INNER JOIN "Master_Institution" ON "CLG"."Adm_Master_College_Student"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "AMCST_id" = "UserID";
        ELSIF "type" = 'Employee' THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::varchar AS "result_name",
                COALESCE("Master_Institution"."MI_Name", '')::varchar AS "result_institute"
            FROM "dbo"."HR_Master_Employee"
            INNER JOIN "Master_Institution" ON "dbo"."HR_Master_Employee"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    END IF;
    
    RETURN;
END;
$$;