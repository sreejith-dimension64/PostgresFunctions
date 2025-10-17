CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Fine_Slabs_OtherStaffsCollege"(
    p_mi_id bigint,
    p_asmay_id bigint,
    p_fmh_id bigint,
    p_fti_id bigint,
    p_fmg_id bigint,
    p_FTFS_FineType varchar(50),
    p_FTFS_Amount bigint,
    p_FMFS_Id bigint,
    p_USER_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMCAOST_Id bigint;
    v_row_count integer;
BEGIN

    SELECT "FMCAOST_Id" INTO v_FMCAOST_Id 
    FROM "CLG"."Fee_Master_College_Amount_OthStaffs" 
    WHERE "FMH_Id" = p_fmh_id 
        AND "FTI_Id" = p_fti_id 
        AND "FMG_Id" = p_fmg_id 
        AND "ASMAY_Id" = p_asmay_id 
        AND "MI_Id" = p_mi_id;

    SELECT COUNT(*) INTO v_row_count 
    FROM "CLG"."Fee_College_T_Fine_Slabs_OthStaffs" 
    WHERE "FMCAOST_Id" = v_FMCAOST_Id 
        AND "FMFS_Id" = p_FMFS_Id;

    IF v_row_count = 0 THEN
        INSERT INTO "CLG"."Fee_College_T_Fine_Slabs_OthStaffs" (
            "FMFS_Id",
            "FMCAOST_Id",
            "FCTFSOST_FineType",
            "FCTFSOST_Amount",
            "FCTFSOST_CreatedDate",
            "FCTFSOST_UpdatedDate",
            "FCTFSOST_CreatedBy",
            "FCTFSOST_UpdatedBy"
        ) VALUES (
            p_FMFS_Id,
            v_FMCAOST_Id,
            p_FTFS_FineType,
            p_FTFS_Amount,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            p_USER_Id,
            p_USER_Id
        );
    ELSE
        UPDATE "CLG"."Fee_College_T_Fine_Slabs_OthStaffs" 
        SET "FCTFSOST_Amount" = p_FTFS_Amount,
            "FCTFSOST_FineType" = p_FTFS_FineType,
            "FMFS_Id" = p_FMFS_Id,
            "FCTFSOST_UpdatedBy" = p_USER_Id 
        WHERE "FMCAOST_Id" = v_FMCAOST_Id;
    END IF;

END;
$$;