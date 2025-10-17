CREATE OR REPLACE FUNCTION "dbo"."CLGBIRTHDAY_PARAMETER"(
    "UserID" varchar(50),
    "template" varchar(200),
    "type" varchar(20)
)
RETURNS TABLE(
    "STUDENT_NAME" TEXT,
    "NAME" TEXT,
    "INSTUITENAME" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "template" = 'CLGBIRTHDAY' THEN
        IF ("type" = 'Student') THEN
            RETURN QUERY
            SELECT 
                ("AMCST_FirstName" || ' ' || COALESCE("AMCST_MiddleName", '') || ' ' || COALESCE("AMCST_LastName", ''))::TEXT AS "STUDENT_NAME",
                NULL::TEXT AS "NAME",
                NULL::TEXT AS "INSTUITENAME"
            FROM "clg"."Adm_Master_College_Student"
            WHERE "AMCST_Id" = "UserID";
        ELSIF ("type" = 'Employee') THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::TEXT AS "STUDENT_NAME",
                NULL::TEXT AS "NAME",
                NULL::TEXT AS "INSTUITENAME"
            FROM "dbo"."HR_Master_Employee"
            WHERE "HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'CLGCOE' THEN
        IF ("type" = 'Student') THEN
            RETURN QUERY
            SELECT 
                NULL::TEXT AS "STUDENT_NAME",
                ("AMCST_FirstName" || ' ' || COALESCE("AMCST_MiddleName", '') || ' ' || COALESCE("AMCST_LastName", ''))::TEXT AS "NAME",
                COALESCE("Master_Institution"."MI_Name", '')::TEXT AS "INSTUITENAME"
            FROM "clg"."Adm_Master_College_Student"
            INNER JOIN "Master_Institution" ON "clg"."Adm_Master_College_Student"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "AMCST_Id" = "UserID";
        ELSIF ("type" = 'Employee') THEN
            RETURN QUERY
            SELECT 
                NULL::TEXT AS "STUDENT_NAME",
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::TEXT AS "NAME",
                COALESCE("Master_Institution"."MI_Name", '')::TEXT AS "INSTUITENAME"
            FROM "dbo"."HR_Master_Employee"
            INNER JOIN "Master_Institution" ON "dbo"."HR_Master_Employee"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "HRME_Id" = "UserID";
        END IF;
    END IF;
    
    RETURN;
END;
$$;