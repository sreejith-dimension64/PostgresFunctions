CREATE OR REPLACE FUNCTION "dbo"."GET_TRN_MONTH_END_REPORT"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@frmdate" TEXT,
    "@todate" TEXT,
    "@type" varchar(10)
)
RETURNS TABLE(
    "MFIELDS" TEXT,
    "MCOUNT" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@TRNSMSCOUNT" bigint;
    "@TRNEMAILCOUNT" bigint;
    "@BUSSMSCOUNT" bigint;
    "@BUSEMAILCOUNT" bigint;
    "@APPLTOTALCOUNT" bigint;
    "@APRVLCOUNT" bigint;
    "@REJCOUNT" bigint;
    "@WAITCOUNT" bigint;
    "@TOTALTRIP" bigint;
    "@VCOUNT" bigint;
    "@monthid" bigint;
BEGIN
    IF "@type" = 'T' THEN
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

        SELECT COUNT("IVRM_SSB_ID") INTO "@TRNSMSCOUNT"
        FROM "IVRM_sms_sentBox" 
        WHERE "Module_Name" = 'Transport' AND "MI_Id" = "@MI_Id" 
        AND EXTRACT(YEAR FROM "Datetime") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "Datetime") = "@todate"::bigint 
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';

        SELECT COUNT("IVRM_SSB_ID") INTO "@BUSSMSCOUNT"
        FROM "IVRM_sms_sentBox" 
        WHERE "Module_Name" = 'BUSHIRE' AND "MI_Id" = "@MI_Id" 
        AND EXTRACT(YEAR FROM "Datetime") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "Datetime") = "@todate"::bigint 
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';

        SELECT COUNT("IVRMESB_ID") INTO "@TRNEMAILCOUNT"
        FROM "IVRM_Email_sentBox" 
        WHERE "Module_Name" = 'Transport' AND "MI_Id" = "@MI_Id"
        AND EXTRACT(YEAR FROM "Datetime") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "Datetime") = "@todate"::bigint 
        AND "Email_Id" <> '';

        SELECT COUNT("IVRMESB_ID") INTO "@BUSEMAILCOUNT"
        FROM "IVRM_Email_sentBox" 
        WHERE "Module_Name" = 'BUSHIRE' AND "MI_Id" = "@MI_Id"
        AND EXTRACT(YEAR FROM "Datetime") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "Datetime") = "@todate"::bigint 
        AND "Email_Id" <> '';

        SELECT COUNT("ASTA_Id") INTO "@APPLTOTALCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "@MI_Id" 
        AND EXTRACT(YEAR FROM "ASTA_ApplicationDate") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "ASTA_ApplicationDate") = "@todate"::bigint 
        AND "ASTA_ActiveFlag" = 1;

        SELECT COUNT("ASTA_Id") INTO "@APRVLCOUNT"
        FROM "Adm_Student_Transport_Application_Approve"
        WHERE EXTRACT(YEAR FROM "ASTAA_Date") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "ASTAA_Date") = "@todate"::bigint 
        AND "ASTA_Id" IN (
            SELECT "ASTA_ID" 
            FROM "Adm_Student_Transport_Application" 
            WHERE "MI_Id" = "@MI_Id" 
            AND "ASTA_ActiveFlag" = 1 
            AND "ASTA_ApplStatus" = 'Approved'
        );

        SELECT COUNT("ASTA_Id") INTO "@REJCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "@MI_Id" 
        AND EXTRACT(YEAR FROM "ASTA_ApplicationDate") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "ASTA_ApplicationDate") = "@todate"::bigint 
        AND "ASTA_ActiveFlag" = 1 
        AND "ASTA_ApplStatus" = 'Rejected';

        SELECT COUNT("ASTA_Id") INTO "@WAITCOUNT"
        FROM "Adm_Student_Transport_Application"
        WHERE "MI_Id" = "@MI_Id" 
        AND EXTRACT(YEAR FROM "ASTA_ApplicationDate") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "ASTA_ApplicationDate") = "@todate"::bigint 
        AND "ASTA_ActiveFlag" = 1 
        AND "ASTA_ApplStatus" = 'Waiting';

        SELECT COUNT(DISTINCT "TRTOB_Id") INTO "@TOTALTRIP"
        FROM "TRN"."TR_Trip_OnlineBooking" AS A 
        WHERE "MI_Id" = "@MI_Id" 
        AND "TRTOB_ActiveFlg" = 1 
        AND EXTRACT(YEAR FROM "TRTOB_BookingDate") = "@frmdate"::bigint 
        AND EXTRACT(MONTH FROM "TRTOB_BookingDate") = "@todate"::bigint;

        "@monthid" := 12;

        IF ("@todate"::bigint < 12) THEN
            "@todate" := ("@todate"::bigint + 1)::TEXT;
        ELSE
            "@frmdate" := ("@frmdate"::bigint + 1)::TEXT;
            "@todate" := '01';
        END IF;

        SELECT COUNT(DISTINCT "TRMV_Id") INTO "@VCOUNT"
        FROM "TRN"."TR_Master_Vehicle" AS A 
        WHERE "MI_Id" = "@MI_Id" 
        AND "TRMV_ActiveFlag" = 1 
        AND EXTRACT(YEAR FROM "CreatedDate") <= "@frmdate"::bigint
        AND "CreatedDate" < ("@frmdate" || '-' || "@todate" || '-' || '01')::timestamp;

        INSERT INTO "TRNMONTHENDT"(
            "TRNSMSCOUNT", "TRNEMAILCOUNT", "BUSSMSCOUNT", "BUSEMAILCOUNT", 
            "APPLTOTALCOUNT", "APRVLCOUNT", "REJCOUNT", "WAITCOUNT", "TOTALTRIP", "VCOUNT"
        )
        VALUES(
            "@TRNSMSCOUNT", "@TRNEMAILCOUNT", "@BUSSMSCOUNT", "@BUSEMAILCOUNT", 
            "@APPLTOTALCOUNT", "@APRVLCOUNT", "@REJCOUNT", "@WAITCOUNT", "@TOTALTRIP", "@VCOUNT"
        );

        RETURN QUERY
        SELECT "MFIELDS", "MCOUNT"
        FROM (
            SELECT 
                "TRNSMSCOUNT", "TRNEMAILCOUNT", "BUSSMSCOUNT", "BUSEMAILCOUNT",
                "APPLTOTALCOUNT", "APRVLCOUNT", "REJCOUNT", "WAITCOUNT", "TOTALTRIP", "VCOUNT"
            FROM "TRNMONTHENDT"
        ) t
        CROSS JOIN LATERAL (
            VALUES 
                ('TRNSMSCOUNT', "TRNSMSCOUNT"),
                ('TRNEMAILCOUNT', "TRNEMAILCOUNT"),
                ('BUSSMSCOUNT', "BUSSMSCOUNT"),
                ('BUSEMAILCOUNT', "BUSEMAILCOUNT"),
                ('APPLTOTALCOUNT', "APPLTOTALCOUNT"),
                ('APRVLCOUNT', "APRVLCOUNT"),
                ('REJCOUNT', "REJCOUNT"),
                ('WAITCOUNT', "WAITCOUNT"),
                ('TOTALTRIP', "TOTALTRIP"),
                ('VCOUNT', "VCOUNT")
        ) AS unpvt("MFIELDS", "MCOUNT");

    ELSIF "@type" = 'F' THEN
        RETURN QUERY
        SELECT "MFIELDS", "MCOUNT"
        FROM (
            SELECT 
                SUM("TRDC_TOTALKM") AS "TOTALKM",
                SUM("TRDC_TOTALMILEAGE") AS "TOTALMILEAGE",
                SUM("TRDC_NOOFLTR") AS "NOOFLTR",
                SUM("TRDC_TOTALAMOUNT") AS "TOTALAMOUNT",
                SUM("TRDC_GrossAmount") AS "GROSSAMOUNT"
            FROM "TRN"."TR_DISTANCECHART" 
            WHERE "MI_Id" = "@MI_Id"
            AND EXTRACT(YEAR FROM "TRDC_Date") = "@frmdate"::bigint 
            AND EXTRACT(MONTH FROM "TRDC_Date") = "@todate"::bigint
        ) P
        CROSS JOIN LATERAL (
            VALUES 
                ('TOTALKM', "TOTALKM"),
                ('TOTALMILEAGE', "TOTALMILEAGE"),
                ('NOOFLTR', "NOOFLTR"),
                ('TOTALAMOUNT', "TOTALAMOUNT"),
                ('GROSSAMOUNT', "GROSSAMOUNT")
        ) AS unpvt("MFIELDS", "MCOUNT");

    END IF;

    RETURN;
END;
$$;