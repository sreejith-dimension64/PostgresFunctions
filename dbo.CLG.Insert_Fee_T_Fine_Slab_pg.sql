CREATE OR REPLACE FUNCTION "dbo"."CLG.Insert_Fee_T_Fine_Slab"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMH_Id bigint,
    p_FTI_Id bigint,
    p_FMG_Id bigint,
    p_FCTFS_FineType bigint,
    p_FCTFS_Amount bigint,
    p_FMFS_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FCMA_Id bigint;
    v_FCMAS_Id bigint;
    v_row_count integer;
BEGIN

    SELECT MAX("FCMA_Id") INTO v_FCMA_Id 
    FROM "Clg"."Fee_College_Master_Amount" 
    WHERE "FMH_Id" = p_FMH_Id 
        AND "FTI_Id" = p_FTI_Id 
        AND "FMG_Id" = p_FMG_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "MI_Id" = p_MI_Id;

    SELECT MAX("FCMAS_Id") INTO v_FCMAS_Id 
    FROM "Clg"."Fee_College_Master_Amount_Semesterwise" 
    WHERE "MI_Id" = p_MI_Id 
        AND "FCMA_Id" = v_FCMA_Id 
        AND "AMSE_Id" = p_AMSE_Id;

    SELECT COUNT(*) INTO v_row_count 
    FROM "Clg"."Fee_College_T_Fine_Slabs" 
    WHERE "FMFS_Id" = p_FMFS_Id 
        AND "FCMAS_Id" = v_FCMAS_Id;

    IF v_row_count = 0 THEN
        INSERT INTO "Clg"."Fee_College_T_Fine_Slabs" 
            ("FMFS_Id", "FCTFS_FineType", "FCTFS_Amount", "FCMAS_Id") 
        VALUES 
            (p_FMFS_Id, p_FCTFS_FineType, p_FCTFS_Amount, v_FCMAS_Id);
    ELSE
        UPDATE "Clg"."Fee_College_T_Fine_Slabs" 
        SET "FCTFS_Amount" = p_FCTFS_Amount,
            "FCTFS_FineType" = p_FCTFS_FineType,
            "FMFS_Id" = p_FMFS_Id 
        WHERE "FCMAS_Id" = v_FCMAS_Id;
    END IF;

END;
$$;