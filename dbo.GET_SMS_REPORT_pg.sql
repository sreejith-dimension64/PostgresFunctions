CREATE OR REPLACE FUNCTION "dbo"."GET_SMS_REPORT" (
    "ASMAY_Id" integer,
    "fromdate" timestamp,
    "todate" timestamp,
    "Mi_id" bigint
)
RETURNS TABLE (
    "Name" character varying,
    "SMSCount" bigint,
    "EMAILCount" character varying
)
LANGUAGE plpgsql
AS $$
DECLARE
    "fromdate1" timestamp;
    "todate1" timestamp;
BEGIN
    IF ("ASMAY_Id" != 0) THEN
        SELECT "ASMAY_From_Date", "ASMAY_To_Date" 
        INTO "fromdate1", "todate1"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "Mi_id" 
            AND "Is_Active" = 1 
            AND "ASMAY_Id" = "ASMAY_Id";

        RETURN QUERY
        SELECT DISTINCT "Module_Name" AS "Name",
            COUNT(*) AS "SMSCount",
            '0' AS "EMAILCount" 
        FROM "IVRM_sms_sentBox" 
        WHERE "MI_Id" = "Mi_id" 
            AND "Datetime" BETWEEN "fromdate1" AND "todate1"
        GROUP BY "Module_Name";
    ELSE
        RETURN QUERY
        SELECT DISTINCT "Module_Name" AS "Name",
            COUNT(*) AS "SMSCount",
            '0' AS "EMAILCount" 
        FROM "IVRM_sms_sentBox" 
        WHERE "MI_Id" = "Mi_id" 
            AND "Datetime" BETWEEN "fromdate" AND "todate"
        GROUP BY "Module_Name";
    END IF;
END;
$$;