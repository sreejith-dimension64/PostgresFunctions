CREATE OR REPLACE FUNCTION "dbo"."EMAILSMS_HISTORY"(
    p_startdate TEXT,
    p_enddate TEXT,
    p_optionflag TEXT,
    p_MI_Id BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "Contact_Info" TEXT,
    "Rcount" BIGINT,
    "Message" TEXT,
    "Datetime" TIMESTAMP,
    "Module_Name" TEXT,
    "EmpName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_optionflag = 'SMS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMS1"."AMST_Id",
            "SS"."Mobile_no"::TEXT AS "Contact_Info",
            COUNT("SS"."Mobile_no") AS "Rcount",
            "SS"."Message",
            "SS"."Datetime",
            "SS"."Module_Name",
            COALESCE("AMS1"."AMST_FirstName", '') || ' ' || COALESCE("AMS1"."AMST_MiddleName", '') || ' ' || COALESCE("AMS1"."AMST_LastName", '') AS "EmpName"
        FROM "IVRM_sms_sentBox" "SS"
        INNER JOIN "Adm_M_Student" "AMS1" ON "AMS1"."AMST_MobileNo" = "SS"."Mobile_no"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS1"."AMST_Id"
        WHERE "SS"."MI_Id" = p_MI_Id 
            AND "AMS1"."MI_Id" = p_MI_Id 
            AND (CAST("SS"."Datetime" AS DATE) BETWEEN CAST(p_startdate AS DATE) AND CAST(p_enddate AS DATE))
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS1"."AMST_ActiveFlag" = 1 
            AND "AMS1"."AMST_SOL" = 'S'
        GROUP BY 
            "AMS1"."AMST_Id",
            "SS"."Mobile_no",
            "SS"."Message",
            "SS"."Datetime",
            "SS"."Module_Name",
            COALESCE("AMS1"."AMST_FirstName", '') || ' ' || COALESCE("AMS1"."AMST_MiddleName", '') || ' ' || COALESCE("AMS1"."AMST_LastName", '')
        ORDER BY "AMS1"."AMST_Id";

    ELSIF p_optionflag = 'EMAIL' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMS1"."AMST_Id",
            "SS"."Email_Id"::TEXT AS "Contact_Info",
            COUNT(*)::BIGINT AS "Rcount",
            "SS"."Message",
            "SS"."Datetime",
            "SS"."Module_Name",
            COALESCE("AMS1"."AMST_FirstName", '') || ' ' || COALESCE("AMS1"."AMST_MiddleName", '') || ' ' || COALESCE("AMS1"."AMST_LastName", '') AS "EmpName"
        FROM "IVRM_Email_sentBox" "SS"
        INNER JOIN "Adm_M_Student" "AMS1" ON "AMS1"."AMST_emailId" = "SS"."Email_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS1"."AMST_Id"
        WHERE (CAST("SS"."Datetime" AS DATE) BETWEEN CAST(p_startdate AS DATE) AND CAST(p_enddate AS DATE))
            AND "SS"."MI_Id" = p_MI_Id 
            AND "AMS1"."MI_Id" = p_MI_Id 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS1"."AMST_ActiveFlag" = 1 
            AND "AMS1"."AMST_SOL" = 'S'
        GROUP BY 
            "AMS1"."AMST_Id",
            "SS"."Email_Id",
            COALESCE("AMS1"."AMST_FirstName", '') || ' ' || COALESCE("AMS1"."AMST_MiddleName", '') || ' ' || COALESCE("AMS1"."AMST_LastName", ''),
            "SS"."Message",
            "SS"."Datetime",
            "SS"."Module_Name"
        ORDER BY "AMS1"."AMST_Id";

    END IF;

    RETURN;

END;
$$;