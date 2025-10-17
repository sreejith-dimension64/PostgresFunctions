CREATE OR REPLACE FUNCTION "dbo"."insertcast"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_IMCC_Id" bigint;
    "v_IMC_CasteName" varchar(200);
    "v_IMC_CasteDesc" varchar(200);
    "Exmsubjectdetails_rec" RECORD;
BEGIN

    FOR "Exmsubjectdetails_rec" IN
        SELECT "IMCC_Id", "IMC_CasteName", "IMC_CasteDesc" 
        FROM "IVRM_Master_Caste" 
        WHERE "mi_id" = 6
    LOOP
        "v_IMCC_Id" := "Exmsubjectdetails_rec"."IMCC_Id";
        "v_IMC_CasteName" := "Exmsubjectdetails_rec"."IMC_CasteName";
        "v_IMC_CasteDesc" := "Exmsubjectdetails_rec"."IMC_CasteDesc";

        INSERT INTO "IVRM_Master_Caste" 
        VALUES ("v_IMCC_Id", "v_IMC_CasteName", "v_IMC_CasteDesc", 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

    END LOOP;

    RETURN;
END;
$$;