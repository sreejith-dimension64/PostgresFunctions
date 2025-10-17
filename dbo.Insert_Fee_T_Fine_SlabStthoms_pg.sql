CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Fine_SlabStthoms"(
    p_mi_id bigint,
    p_asmay_id bigint,
    p_fmh_id bigint,
    p_fti_id bigint,
    p_fmg_id bigint,
    p_FTFS_FineType varchar(50),
    p_FTFS_Amount bigint,
    p_FMFS_Id bigint,
    p_FMCC_ID bigint,
    p_FTFS_Duedate timestamp,
    p_FTFS_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fma_id bigint;
    v_row_count integer;
BEGIN
    
    SELECT "FMA_Id" INTO v_fma_id 
    FROM "Fee_Master_Amount" 
    WHERE "FMH_Id" = p_fmh_id 
        AND "FTI_Id" = p_fti_id 
        AND "FMG_Id" = p_fmg_id 
        AND "ASMAY_Id" = p_asmay_id 
        AND "MI_Id" = p_mi_id 
        AND "FMCC_Id" = p_FMCC_ID;
    
    PERFORM * 
    FROM "Fee_T_Fine_Slabs" 
    WHERE "FMA_Id" = v_fma_id 
        AND "FMFS_Id" = p_FMFS_Id 
        AND "FTFS_Id" = p_FTFS_Id;
    
    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    
    IF v_row_count = 0 THEN
        INSERT INTO "Fee_T_Fine_Slabs" ("FMFS_Id", "FMA_Id", "FTFS_FineType", "FTFS_Amount", "FTFS_Date") 
        VALUES (p_FMFS_Id, v_fma_id, p_FTFS_FineType, p_FTFS_Amount, p_FTFS_Duedate);
    ELSE
        UPDATE "Fee_T_Fine_Slabs" 
        SET "FTFS_Amount" = p_FTFS_Amount,
            "FTFS_FineType" = p_FTFS_FineType,
            "FMFS_Id" = p_FMFS_Id,
            "FTFS_Date" = p_FTFS_Duedate 
        WHERE "FTFS_Id" = p_FTFS_Id;
    END IF;
    
    RETURN;
END;
$$;