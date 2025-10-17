CREATE OR REPLACE FUNCTION "dbo"."GetPREVAMAYID"(
    "AMaY_ID" bigint,
    OUT "Previd" bigint
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    "amay_year" varchar(20);
    v_rowcount integer;
BEGIN
    SELECT "ASMAY_Id", "AsMaY_Year"
    INTO "Previd", "amay_year"
    FROM "dbo"."Adm_School_M_Academic_Year"
    WHERE "ASMAY_Year" < (
        SELECT "ASMAY_Year"
        FROM "dbo"."Adm_School_M_Academic_Year"
        WHERE "ASMAY_Id" = "AMaY_ID"
    )
    ORDER BY "ASMAY_Year"
    LIMIT 100;

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;

    IF v_rowcount = 0 THEN
        "Previd" := 0;
    END IF;

    RETURN;
END;
$$;