CREATE OR REPLACE FUNCTION "dbo"."GET_SMS_EMAIL_REPORT" (
    "ASMAY_Id" integer,
    "fromdate" timestamp,
    "todate" timestamp,
    "Mi_id" bigint
)
RETURNS TABLE (
    "Name" character varying,
    "SMSCount" bigint,
    "EmailCount" bigint
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

        DROP TABLE IF EXISTS "temp_a";
        
        CREATE TEMP TABLE "temp_a" AS
        WITH cte AS (
            SELECT A."Module_Name" as "Name", COUNT(*) as "SMSCount", 0 AS "EMAILCount" 
            FROM "IVRM_sms_sentBox" A 
            WHERE A."MI_Id" = "Mi_id" 
            AND A."Datetime" BETWEEN "fromdate1" AND "todate1"
            GROUP BY A."Module_Name"
            
            UNION 
            
            SELECT B."Module_Name" as "Name", 0 as "SMSCount", COUNT(*) AS "EMAILCount" 
            FROM "IVRM_Email_sentBox" B 
            WHERE B."MI_Id" = "Mi_id" 
            AND B."Datetime" BETWEEN "fromdate1" AND "todate1"
            GROUP BY B."Module_Name"
        )
        SELECT * FROM cte;
        
        UPDATE "temp_a" 
        SET "EMAILCount" = (
            SELECT "EMAILCount" 
            FROM "temp_a" 
            WHERE "SMSCount" = 0 
            AND "Name" = 'Admission'
        ) 
        WHERE "Name" = 'Admission' 
        AND "EMAILCount" = 0;
        
        UPDATE "temp_a" 
        SET "EMAILCount" = 0 
        WHERE "SMSCount" = 0 
        AND "Name" = 'Admission';
        
        RETURN QUERY
        SELECT "temp_a"."Name", 
               SUM("temp_a"."SMSCount")::bigint as "SMSCount", 
               SUM("temp_a"."EMAILCount")::bigint as "EmailCount" 
        FROM "temp_a" 
        GROUP BY "temp_a"."Name";
        
    ELSE
        DROP TABLE IF EXISTS "temp_a";
        
        CREATE TEMP TABLE "temp_a" AS
        WITH cte AS (
            SELECT A."Module_Name" as "Name", COUNT(*) as "SMSCount", 0 AS "EMAILCount" 
            FROM "IVRM_sms_sentBox" A 
            WHERE A."MI_Id" = "Mi_id" 
            AND A."Datetime" BETWEEN "fromdate" AND "todate"
            GROUP BY A."Module_Name"
            
            UNION 
            
            SELECT B."Module_Name" as "Name", 0 as "SMSCount", COUNT(*) AS "EMAILCount" 
            FROM "IVRM_Email_sentBox" B 
            WHERE B."MI_Id" = "Mi_id" 
            AND B."Datetime" BETWEEN "fromdate" AND "todate"
            GROUP BY B."Module_Name"
        )
        SELECT * FROM cte;
        
        UPDATE "temp_a" 
        SET "EMAILCount" = (
            SELECT "EMAILCount" 
            FROM "temp_a" 
            WHERE "SMSCount" = 0 
            AND "Name" = 'Admission'
        ) 
        WHERE "Name" = 'Admission' 
        AND "EMAILCount" = 0;
        
        UPDATE "temp_a" 
        SET "EMAILCount" = 0 
        WHERE "SMSCount" = 0 
        AND "Name" = 'Admission';
        
        RETURN QUERY
        SELECT "temp_a"."Name", 
               SUM("temp_a"."SMSCount")::bigint as "SMSCount", 
               SUM("temp_a"."EMAILCount")::bigint as "EmailCount" 
        FROM "temp_a" 
        GROUP BY "temp_a"."Name";
        
    END IF;
END;
$$;