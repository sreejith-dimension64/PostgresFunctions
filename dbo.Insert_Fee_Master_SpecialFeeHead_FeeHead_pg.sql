CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Master_SpecialFeeHead_FeeHead"(
    "@mi_id" BIGINT,
    "@FMSFH_Name" VARCHAR(50),
    "@IVRMSTAUL_Id" BIGINT,
    "@fmh_id" BIGINT,
    "@FMSFH_ActiceFlag" BOOLEAN,
    "@FMSFH_Id" BIGINT,
    "@curtime" TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@maxid" BIGINT;
    "v_rowcount" INTEGER;
BEGIN
    SELECT * FROM "Fee_Master_SpecialFeeHead" 
    WHERE "FMSFH_Name" = "@FMSFH_Name" AND "MI_Id" = "@mi_id";
    
    GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
    
    IF ("v_rowcount" = 0) THEN
        INSERT INTO "Fee_Master_SpecialFeeHead" (
            "MI_Id",
            "FMSFH_Name",
            "FMSFH_ActiceFlag",
            "IVRMSTAUL_Id",
            "CreatedDate",
            "UpdatedDate"
        ) 
        VALUES (
            "@mi_id",
            "@FMSFH_Name",
            "@FMSFH_ActiceFlag",
            "@IVRMSTAUL_Id",
            "@curtime",
            "@curtime"
        );
    END IF;
    
    SELECT MAX("FMSFH_Id") INTO "@maxid" FROM "Fee_Master_SpecialFeeHead";
    
    INSERT INTO "Fee_Master_SpecialFeeHead_FeeHead" (
        "FMSFH_Id",
        "FMH_Id",
        "FMSFHFH_ActiceFlag",
        "CreatedDate",
        "UpdatedDate"
    ) 
    VALUES (
        "@maxid",
        "@fmh_id",
        TRUE,
        "@curtime",
        "@curtime"
    );
    
    RETURN;
END;
$$;