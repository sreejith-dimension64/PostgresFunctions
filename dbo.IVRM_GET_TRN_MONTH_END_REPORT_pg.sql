CREATE OR REPLACE FUNCTION "dbo"."IVRM_GET_TRN_MONTH_END_REPORT"(
    "MI_Id" bigint,
    "frmdate" text,
    "todate" text,
    "type" varchar(10)
)
RETURNS TABLE(
    "MFIELDS" text,
    "MCOUNT" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "TRNSMSCOUNT" bigint;
    "TRNEMAILCOUNT" bigint;
    "BUSSMSCOUNT" bigint;
    "BUSEMAILCOUNT" bigint;
    "APPLTOTALCOUNT" bigint;
    "APRVLCOUNT" bigint;
    "REJCOUNT" bigint;
    "WAITCOUNT" bigint;
    "TOTALTRIP" bigint;
    "VCOUNT" bigint;
BEGIN
    IF "type" = 'T' THEN
        DROP TABLE IF EXISTS "TRNMONTHENDT";
        
        CREATE TEMP TABLE "TRNMONTHENDT"(
            "TRNSMSCOUNT" bigint,
            "TRNEMAILCOUNT" bigint,
            "BUSSMSCOUNT" bigint,
            "BUSEMAILCOUNT" bigint,
            "APPLTOTALCOUNT" bigint,
            "APRVLCOUNT" bigint,
            "REJCOUNT" bigint,
            "WAITCOUNT" bigint,
            "TOTALTRIP" bigint,
            "VCOUNT" bigint
        );

        SELECT COUNT("IVRM_SSB_ID") INTO "TRNSMSCOUNT"
        FROM "IVRM_sms_sentBox"
        WHERE "Module_Name" = 'Transport' 
            AND "MI_Id" = "MI_Id"
            AND CAST("Datetime" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "Mobile_no" <> '0' 
            AND "Mobile_no" <> '';

        SELECT COUNT("IVRM_SSB_ID") INTO "BUSSMSCOUNT"
        FROM "IVRM_sms_sentBox"
        WHERE "Module_Name" = 'BUSHIRE' 
            AND "MI_Id" = "MI_Id"
            AND CAST("Datetime" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "Mobile_no" <> '0' 
            AND "Mobile_no" <> '';

        SELECT COUNT("IVRMESB_ID") INTO "TRNEMAILCOUNT"
        FROM "IVRM_Email_sentBox"
        WHERE "Module_Name" = 'Transport' 
            AND "MI_Id" = "MI_Id"
            AND CAST("Datetime" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "Email_Id" <> '';

        SELECT COUNT("IVRMESB_ID") INTO "BUSEMAILCOUNT"
        FROM "IVRM_Email_sentBox"
        WHERE "Module_Name" = 'BUSHIRE' 
            AND "MI_Id" = "MI_Id"
            AND CAST("Datetime" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "Email_Id" <> '';

        SELECT COUNT("ASTA_Id") INTO "APPLTOTALCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "MI_Id"
            AND CAST("ASTA_ApplicationDate" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "ASTA_ActiveFlag" = 1;

        SELECT COUNT("ASTA_Id") INTO "APRVLCOUNT"
        FROM "Adm_Student_Transport_Application_Approve"
        WHERE CAST("ASTAA_Date" AS date) BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "ASTA_Id" IN (
                SELECT "ASTA_ID" 
                FROM "Adm_Student_Transport_Application" 
                WHERE "MI_Id" = "MI_Id" 
                    AND "ASTA_ActiveFlag" = 1 
                    AND "ASTA_ApplStatus" = 'Approved'
            );

        SELECT COUNT("ASTA_Id") INTO "REJCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "MI_Id"
            AND "ASTA_ApplicationDate" BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_ApplStatus" = 'Rejected';

        SELECT COUNT("ASTA_Id") INTO "WAITCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "MI_Id"
            AND "ASTA_ApplicationDate" BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date)
            AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_ApplStatus" = 'Waiting';

        SELECT COUNT(DISTINCT "TRTOB_Id") INTO "TOTALTRIP"
        FROM "TRN"."TR_Trip_OnlineBooking"
        WHERE "MI_Id" = "MI_Id" 
            AND "TRTOB_ActiveFlg" = 1 
            AND "TRTOB_BookingDate" BETWEEN CAST("frmdate" AS date) AND CAST("todate" AS date);

        INSERT INTO "TRNMONTHENDT"(
            "TRNSMSCOUNT", "TRNEMAILCOUNT", "BUSSMSCOUNT", "BUSEMAILCOUNT", 
            "APPLTOTALCOUNT", "APRVLCOUNT", "REJCOUNT", "WAITCOUNT", "TOTALTRIP"
        )
        VALUES(
            "TRNSMSCOUNT", "TRNEMAILCOUNT", "BUSSMSCOUNT", "BUSEMAILCOUNT",
            "APPLTOTALCOUNT", "APRVLCOUNT", "REJCOUNT", "WAITCOUNT", "TOTALTRIP"
        );

        RETURN QUERY
        SELECT "field_name"::text AS "MFIELDS", "field_value" AS "MCOUNT"
        FROM "TRNMONTHENDT"
        CROSS JOIN LATERAL (
            VALUES 
                ('TRNSMSCOUNT', "TRNMONTHENDT"."TRNSMSCOUNT"),
                ('TRNEMAILCOUNT', "TRNMONTHENDT"."TRNEMAILCOUNT"),
                ('BUSSMSCOUNT', "TRNMONTHENDT"."BUSSMSCOUNT"),
                ('BUSEMAILCOUNT', "TRNMONTHENDT"."BUSEMAILCOUNT"),
                ('APPLTOTALCOUNT', "TRNMONTHENDT"."APPLTOTALCOUNT"),
                ('APRVLCOUNT', "TRNMONTHENDT"."APRVLCOUNT"),
                ('REJCOUNT', "TRNMONTHENDT"."REJCOUNT"),
                ('WAITCOUNT', "TRNMONTHENDT"."WAITCOUNT"),
                ('TOTALTRIP', "TRNMONTHENDT"."TOTALTRIP")
        ) AS unpivot_data("field_name", "field_value");
    END IF;
END;
$$;