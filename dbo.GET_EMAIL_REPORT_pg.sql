CREATE OR REPLACE FUNCTION "dbo"."GET_EMAIL_REPORT" (
    "@ASMAY_Id" INTEGER,
    "@fromdate" TIMESTAMP,
    "@todate" TIMESTAMP,
    "@Mi_id" BIGINT
)
RETURNS TABLE (
    "Name" VARCHAR,
    "SMSCount" VARCHAR,
    "EMAILCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@fromdate1" TIMESTAMP;
    "@todate1" TIMESTAMP;
BEGIN
    IF ("@ASMAY_Id" != 0) THEN
        SELECT "ASMAY_From_Date", "ASMAY_To_Date"
        INTO "@fromdate1", "@todate1"
        FROM "Adm_School_M_Academic_Year"
        WHERE "MI_Id" = "@Mi_id"
        AND "Is_Active" = 1
        AND "ASMAY_Id" = "@ASMAY_Id";

        RETURN QUERY
        SELECT DISTINCT "Module_Name" AS "Name",
               '0' AS "SMSCount",
               COUNT(*) AS "EMAILCount"
        FROM "IVRM_Email_sentBox"
        WHERE "MI_Id" = "@Mi_id"
        AND "Datetime" BETWEEN "@fromdate1" AND "@todate1"
        GROUP BY "Module_Name";
    ELSE
        RETURN QUERY
        SELECT DISTINCT "Module_Name" AS "Name",
               '0' AS "SMSCount",
               COUNT(*) AS "EMAILCount"
        FROM "IVRM_Email_sentBox"
        WHERE "MI_Id" = "@Mi_id"
        AND "Datetime" BETWEEN "@fromdate" AND "@todate"
        GROUP BY "Module_Name";
    END IF;

    RETURN;
END;
$$;