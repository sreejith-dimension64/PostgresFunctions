CREATE OR REPLACE FUNCTION "dbo"."INV_PEFORMINVOICE_UPDATE"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    INOUT "@StudentAdmnoOP" text DEFAULT ''
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    "@SchNo" text;
    "@StuCount" int;
    "@StudentAdmno" text;
    "@AdmPrefix" text;
    "@AMST_Id" bigint;
    "@ASMAY_Year" text;
BEGIN

    IF ("@MI_Id" = 16) THEN
        "@AdmPrefix" := 'VKS';
    ELSIF ("@MI_Id" = 17) THEN
        "@AdmPrefix" := 'VTS';
    ELSIF ("@MI_Id" = 20) THEN
        "@AdmPrefix" := 'Unnathi';
    ELSIF ("@MI_Id" = 21) THEN
        "@AdmPrefix" := 'Smart';
    ELSIF ("@MI_Id" = 22) THEN
        "@AdmPrefix" := 'Marga';
    ELSIF ("@MI_Id" = 23) THEN
        "@AdmPrefix" := 'VTS';
    ELSIF ("@MI_Id" = 24) THEN
        "@AdmPrefix" := 'VTS';
    ELSIF ("@MI_Id" = 27) THEN
        "@AdmPrefix" := 'VTS';
    END IF;

    SELECT "ASMAY_Year" INTO "@ASMAY_Year"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@ASMAY_Id";

    SELECT COUNT(*) INTO "@StuCount"
    FROM "ISM_Proforma_Invoice" AMS
    WHERE AMS."MI_Id" = "@MI_Id" 
    AND (LENGTH(COALESCE("ISMPRINC_PrInviceNo", '')) > 0 OR LENGTH(COALESCE("ISMPRINC_PrInviceNo", '')) > 0);

    IF ("@StuCount" <> 0) THEN
        SELECT COUNT(*) INTO "@SchNo"
        FROM "ISM_Proforma_Invoice" AMS
        WHERE AMS."MI_Id" = "@MI_Id" 
        AND (LENGTH(COALESCE("ISMPRINC_PrInviceNo", '')) > 0 OR LENGTH(COALESCE("ISMPRINC_PrInviceNo", '')) > 0);

        "@SchNo" := (CAST("@SchNo" AS int) + 1)::text;
    ELSE
        "@SchNo" := '1';
    END IF;

    "@StudentAdmno" := "@AdmPrefix" || '/' || REPEAT('0', 4 - LENGTH("@SchNo")) || "@SchNo" || '/' || "@ASMAY_Year";
    "@StudentAdmnoOP" := "@StudentAdmno";

    RETURN;

END;
$$;