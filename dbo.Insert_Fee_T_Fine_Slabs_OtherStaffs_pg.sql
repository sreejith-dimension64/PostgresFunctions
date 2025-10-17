CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Fine_Slabs_OtherStaffs"(
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_fmh_id BIGINT,
    p_fti_id BIGINT,
    p_fmg_id BIGINT,
    p_FTFS_FineType VARCHAR(50),
    p_FTFS_Amount BIGINT,
    p_FMFS_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMAOST_Id BIGINT;
    v_row_count INTEGER;
BEGIN
    SELECT "FMAOST_Id" INTO v_FMAOST_Id 
    FROM "Fee_Master_Amount_OthStaffs" 
    WHERE "FMH_Id" = p_fmh_id 
        AND "FTI_Id" = p_fti_id 
        AND "FMG_Id" = p_fmg_id 
        AND "ASMAY_Id" = p_asmay_id 
        AND "MI_Id" = p_mi_id;

    SELECT COUNT(*) INTO v_row_count
    FROM "Fee_T_Fine_Slabs_OthStaffs" 
    WHERE "FMAOST_Id" = v_FMAOST_Id 
        AND "FMFS_Id" = p_FMFS_Id;

    IF v_row_count = 0 THEN
        INSERT INTO "Fee_T_Fine_Slabs_OthStaffs" (
            "FMFS_Id",
            "FMAOST_Id",
            "FTFSOST_FineType",
            "FTFSOST_Amount",
            "CreatedDate",
            "UpdatedDate"
        ) VALUES (
            p_FMFS_Id,
            v_FMAOST_Id,
            p_FTFS_FineType,
            p_FTFS_Amount,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );
    ELSE
        UPDATE "Fee_T_Fine_Slabs_OthStaffs" 
        SET "FTFSOST_Amount" = p_FTFS_Amount,
            "FTFSOST_FineType" = p_FTFS_FineType,
            "FMFS_Id" = p_FMFS_Id,
            "UpdatedDate" = CURRENT_TIMESTAMP
        WHERE "FMAOST_Id" = v_FMAOST_Id;
    END IF;

    RETURN;
END;
$$;