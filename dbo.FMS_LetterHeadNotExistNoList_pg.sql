CREATE OR REPLACE FUNCTION "dbo"."FMS_LetterHeadNotExistNoList"(
    "@MI_Id" bigint,
    "@HRMD_Id" bigint,
    "@FromNo" text,
    "@ToNo" text
)
RETURNS TABLE(
    "ANO" integer,
    "Flag" text,
    "FMSDLHT_LetterheadNo" text,
    "FMSDLHT_CancelledFlag" integer,
    "FMSDLHT_Reason" text,
    "FMSDLHT_Date" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@FMSDLH_LetterheadsToNo" bigint;
    "@count" integer;
BEGIN

    DROP TABLE IF EXISTS "AutoGenerateNo_Temp";
    DROP TABLE IF EXISTS "LetterHeadNumbers_Temp";

    CREATE TEMP TABLE "AutoGenerateNo_Temp"("ANO" integer);

    SELECT SUBSTRING(
        "FMSDLH_LetterheadsToNo"::text, 
        (SELECT POSITION(SUBSTRING("FMSDLH_LetterheadsToNo"::text FROM '[0-9]') IN "FMSDLH_LetterheadsToNo"::text)),
        (SELECT POSITION(SUBSTRING("FMSDLH_LetterheadsToNo"::text || 't' FROM '[0-9][^0-9]') IN "FMSDLH_LetterheadsToNo"::text || 't')) - 
        (SELECT POSITION(SUBSTRING("FMSDLH_LetterheadsToNo"::text FROM '[0-9]') IN "FMSDLH_LetterheadsToNo"::text)) + 1
    )::bigint INTO "@FMSDLH_LetterheadsToNo"
    FROM "FMS_Department_LetterHeads" 
    WHERE "MI_Id" = "@MI_Id" AND "HRMD_Id" = "@HRMD_Id" AND "FMSDFC_ActiveFlg" = 1;

    "@count" := 0;
    
    WHILE "@count" < "@FMSDLH_LetterheadsToNo" LOOP
        "@count" := "@count" + 1;
        INSERT INTO "AutoGenerateNo_Temp"("ANO") VALUES("@count");
    END LOOP;

    CREATE TEMP TABLE "LetterHeadNumbers_Temp" AS
    SELECT "ANO", 'Used Numbers' AS "Flag" FROM (
        SELECT DISTINCT "ANO" FROM "AutoGenerateNo_Temp" 
        INTERSECT
        SELECT DISTINCT SUBSTRING(
            "FMSDLHT_LetterheadNo"::text,
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text FROM '[0-9]') IN "FMSDLHT_LetterheadNo"::text)),
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text || 't' FROM '[0-9][^0-9]') IN "FMSDLHT_LetterheadNo"::text || 't')) - 
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text FROM '[0-9]') IN "FMSDLHT_LetterheadNo"::text)) + 1
        )::integer AS "FMSDLHT_LetterheadNo"
        FROM "FMS_Department_LetterHeads_Tracking" 
        WHERE "MI_Id" = "@MI_Id" AND "HRMD_Id" = "@HRMD_Id"
    ) AS "New" 
    WHERE "ANO" BETWEEN "@FromNo"::integer AND "@ToNo"::integer

    UNION ALL 
   
    SELECT "ANO", 'Not Used Numbers' AS "Flag" FROM (
        SELECT DISTINCT "ANO" FROM "AutoGenerateNo_Temp" 
        EXCEPT
        SELECT DISTINCT SUBSTRING(
            "FMSDLHT_LetterheadNo"::text,
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text FROM '[0-9]') IN "FMSDLHT_LetterheadNo"::text)),
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text || 't' FROM '[0-9][^0-9]') IN "FMSDLHT_LetterheadNo"::text || 't')) - 
            (SELECT POSITION(SUBSTRING("FMSDLHT_LetterheadNo"::text FROM '[0-9]') IN "FMSDLHT_LetterheadNo"::text)) + 1
        )::integer AS "FMSDLHT_LetterheadNo"
        FROM "FMS_Department_LetterHeads_Tracking" 
        WHERE "MI_Id" = "@MI_Id" AND "HRMD_Id" = "@HRMD_Id"
    ) AS "New" 
    WHERE "ANO" BETWEEN "@FromNo"::integer AND "@ToNo"::integer;

    RETURN QUERY
    SELECT 
        NULL::integer AS "ANO",
        NULL::text AS "Flag",
        "FMSDLHT_LetterheadNo"::text,
        "FMSDLHT_CancelledFlag"::integer,
        "FMSDLHT_Reason"::text,
        COALESCE("FMSDLHT_Date"::text, '') AS "FMSDLHT_Date"
    FROM "FMS_Department_LetterHeads_Tracking" 
    WHERE "MI_Id" = "@MI_Id" 
        AND "HRMD_Id" = "@HRMD_Id" 
        AND "FMSDLHT_LetterheadNo"::text IN (
            SELECT DISTINCT "ANO"::text FROM "LetterHeadNumbers_Temp"
        )

    UNION ALL

    SELECT 
        "ANO"::integer,
        "Flag"::text,
        "ANO"::text AS "FMSDLHT_LetterheadNo",
        0 AS "FMSDLHT_CancelledFlag",
        '' AS "FMSDLHT_Reason",
        '' AS "FMSDLHT_Date"
    FROM "LetterHeadNumbers_Temp" 
    WHERE "ANO"::text NOT IN (
        SELECT DISTINCT "FMSDLHT_LetterheadNo"::text 
        FROM "FMS_Department_LetterHeads_Tracking" 
        WHERE "MI_Id" = "@MI_Id" AND "HRMD_Id" = "@HRMD_Id"
    )
    ORDER BY "ANO";

    DROP TABLE IF EXISTS "AutoGenerateNo_Temp";
    DROP TABLE IF EXISTS "LetterHeadNumbers_Temp";

    RETURN;
END;
$$;