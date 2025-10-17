CREATE OR REPLACE FUNCTION "dbo"."COE_SmsEmailParameters"(
    "UserID" VARCHAR(50),
    "template" VARCHAR(200),
    "type" VARCHAR(20),
    "coe_id" TEXT
)
RETURNS TABLE(
    result_column1 TEXT,
    result_column2 TEXT,
    result_column3 TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "eventid" BIGINT;
BEGIN

    IF "coe_id" != '0' AND "coe_id" IS NOT NULL THEN
        SELECT "COEME_Id" INTO "eventid" 
        FROM "coe"."coe_events" 
        WHERE "coee_id" = "coe_id";
    END IF;

    IF "template" = 'BIRTHDAY' THEN
        IF "type" = 'Student' THEN
            RETURN QUERY
            SELECT 
                ("AMST_FirstName" || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", ''))::TEXT AS result_column1,
                NULL::TEXT AS result_column2,
                NULL::TEXT AS result_column3
            FROM "dbo"."Adm_M_Student"
            WHERE "AMST_Id" = "UserID";
        ELSIF "type" = 'Alumni' THEN
            RETURN QUERY
            SELECT 
                ("ALMST_FirstName" || ' ' || COALESCE("ALMST_MiddleName", '') || ' ' || COALESCE("ALMST_LastName", ''))::TEXT AS result_column1,
                NULL::TEXT AS result_column2,
                NULL::TEXT AS result_column3
            FROM "alu"."Alumni_Master_Student"
            WHERE "ALMST_Id" = "UserID";
        ELSIF "type" = 'Employee' THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::TEXT AS result_column1,
                NULL::TEXT AS result_column2,
                NULL::TEXT AS result_column3
            FROM "dbo"."HR_Master_Employee"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'STAFFBIRTHDAY' THEN
        IF "type" = 'Employee' THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::TEXT AS result_column1,
                NULL::TEXT AS result_column2,
                NULL::TEXT AS result_column3
            FROM "dbo"."HR_Master_Employee"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    ELSIF "template" = 'COE' THEN
        IF "type" = 'Student' THEN
            RETURN QUERY
            SELECT 
                ("AMST_FirstName" || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", ''))::TEXT AS result_column1,
                COALESCE("Master_Institution"."MI_Name", '')::TEXT AS result_column2,
                (SELECT "b"."COEME_EventName" FROM "coe"."coe_master_events" "b" WHERE "b"."COEME_Id" = "eventid")::TEXT AS result_column3
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "Master_Institution" ON "dbo"."Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "AMST_id" = "UserID";
        ELSIF "type" = 'Employee' THEN
            RETURN QUERY
            SELECT 
                ("HRME_EmployeeFirstName" || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", ''))::TEXT AS result_column1,
                COALESCE("Master_Institution"."MI_Name", '')::TEXT AS result_column2,
                (SELECT "b"."COEME_EventName" FROM "coe"."coe_master_events" "b" WHERE "b"."COEME_Id" = "eventid")::TEXT AS result_column3
            FROM "dbo"."HR_Master_Employee"
            INNER JOIN "Master_Institution" ON "dbo"."HR_Master_Employee"."MI_Id" = "Master_Institution"."MI_Id"
            WHERE "HR_Master_Employee"."HRME_Id" = "UserID";
        END IF;
    END IF;

    RETURN;
END;
$$;