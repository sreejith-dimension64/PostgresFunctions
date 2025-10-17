CREATE OR REPLACE FUNCTION "dbo"."College_Birthday_Month_End_Report"(
    "ASMAY_Id" VARCHAR,
    "MI_Id" VARCHAR,
    "month" VARCHAR,
    "year" VARCHAR
)
RETURNS TABLE(
    total BIGINT,
    sms BIGINT,
    email BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "staffcount" VARCHAR;
    "studentcount" VARCHAR;
    "staffstudentcount" VARCHAR;
    "smscount" VARCHAR;
    "emailcount" VARCHAR;
    v_studentcount BIGINT;
    v_staffcount BIGINT;
    v_staffstudentcount BIGINT;
    v_smscount BIGINT;
    v_emailcount BIGINT;
BEGIN

    SELECT 
        SUM(d.student),
        SUM(d.staff),
        (SUM(d.student) + SUM(d.staff))
    INTO 
        v_studentcount,
        v_staffcount,
        v_staffstudentcount
    FROM (
        SELECT 
            COUNT(*) AS student, 
            0 AS staff 
        FROM "clg"."Adm_Master_College_Student" 
        WHERE "MI_Id" = "MI_Id" 
            AND "AMCST_SOL" = 'S' 
            AND "AMCST_ActiveFlag" = 1 
            AND EXTRACT(MONTH FROM "AMCST_DOB") = "month"::INTEGER
        
        UNION ALL
        
        SELECT 
            0 AS student,
            COUNT(*) AS staff 
        FROM "HR_Master_Employee" 
        WHERE "mi_id" = "MI_Id" 
            AND "HRME_ActiveFlag" = 1 
            AND "HRME_LeftFlag" = 0 
            AND EXTRACT(MONTH FROM "HRME_DOB") = "month"::INTEGER
    ) d;

    SELECT 
        COUNT(*) 
    INTO 
        v_smscount 
    FROM "IVRM_sms_sentBox" 
    WHERE "MI_Id" = "MI_Id" 
        AND EXTRACT(MONTH FROM "Datetime") = "month"::INTEGER 
        AND EXTRACT(YEAR FROM "Datetime") = "year"::INTEGER 
        AND "Module_Name" = 'College Birthday';

    SELECT 
        COUNT(*) 
    INTO 
        v_emailcount 
    FROM "IVRM_Email_sentBox" 
    WHERE "MI_Id" = "MI_Id" 
        AND EXTRACT(MONTH FROM "Datetime") = "month"::INTEGER 
        AND EXTRACT(YEAR FROM "Datetime") = "year"::INTEGER 
        AND "Module_Name" = 'College Birthday';

    RETURN QUERY
    SELECT 
        v_staffstudentcount AS total,
        v_smscount AS sms,
        v_emailcount AS email;

END;
$$;