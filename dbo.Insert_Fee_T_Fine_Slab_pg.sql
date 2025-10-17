CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Fine_Slab"(
    "@mi_id" BIGINT,
    "@asmay_id" BIGINT,
    "@fmh_id" BIGINT,
    "@fti_id" BIGINT,
    "@fmg_id" BIGINT,
    "@FTFS_FineType" VARCHAR(50),
    "@FTFS_Amount" BIGINT,
    "@FMFS_Id" BIGINT,
    "@FMCC_ID" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@fma_id" BIGINT;
    "@COUNT" BIGINT;
BEGIN
    SELECT "FMA_Id" INTO "@fma_id"
    FROM "Fee_Master_Amount"
    WHERE "FMH_Id" = "@fmh_id"
        AND "FTI_Id" = "@fti_id"
        AND "FMG_Id" = "@fmg_id"
        AND "ASMAY_Id" = "@asmay_id"
        AND "MI_Id" = "@mi_id"
        AND "FMCC_Id" = "@FMCC_ID";

    SELECT COUNT(1) INTO "@COUNT"
    FROM "Fee_T_Fine_Slabs"
    WHERE "FMA_Id" = "@fma_id"
        AND "FMFS_Id" = "@FMFS_Id";

    IF ("@COUNT" = 0) THEN
        INSERT INTO "Fee_T_Fine_Slabs" ("FMFS_Id", "FMA_Id", "FTFS_FineType", "FTFS_Amount")
        VALUES ("@FMFS_Id", "@fma_id", "@FTFS_FineType", "@FTFS_Amount");
    ELSE
        UPDATE "Fee_T_Fine_Slabs"
        SET "FTFS_Amount" = "@FTFS_Amount",
            "FTFS_FineType" = "@FTFS_FineType",
            "FMFS_Id" = "@FMFS_Id"
        WHERE "FMA_Id" = "@fma_id";
    END IF;

    RETURN;
END;
$$;