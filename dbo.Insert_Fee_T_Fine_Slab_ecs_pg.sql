CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Fine_Slab_ecs"(
    "@mi_id" bigint,
    "@asmay_id" bigint,
    "@fmh_id" bigint,
    "@fti_id" bigint,
    "@fmg_id" bigint,
    "@FTFS_FineType" varchar(50),
    "@FTFS_Amount" bigint,
    "@FMFS_Id" bigint,
    "@FMCC_ID" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@fma_id" bigint;
    "v_row_count" integer;
BEGIN
    SELECT "FMA_Id" INTO "@fma_id" 
    FROM "Fee_Master_Amount" 
    WHERE "FMH_Id" = "@fmh_id" 
        AND "FTI_Id" = "@fti_id" 
        AND "FMG_Id" = "@fmg_id" 
        AND "ASMAY_Id" = "@asmay_id" 
        AND "MI_Id" = "@mi_id" 
        AND "FMCC_Id" = "@FMCC_ID";

    SELECT COUNT(*) INTO "v_row_count"
    FROM "Fee_T_Fine_Slabs" 
    WHERE "FMA_Id" = "@fma_id" 
        AND "FMFS_Id" = "@FMFS_Id";

    IF "v_row_count" = 0 THEN
        INSERT INTO "Fee_T_Fine_Slabs_ECS" ("FMFS_Id", "FMA_Id", "FTFSE_FineType", "FTFSE_Amount") 
        VALUES ("@FMFS_Id", "@fma_id", "@FTFS_FineType", "@FTFS_Amount");
    ELSE
        UPDATE "Fee_T_Fine_Slabs_ECS" 
        SET "FTFSE_Amount" = "@FTFS_Amount",
            "FTFSE_FineType" = "@FTFS_FineType",
            "FMFS_Id" = "@FMFS_Id" 
        WHERE "FMA_Id" = "@fma_id";
    END IF;

    RETURN;
END;
$$;