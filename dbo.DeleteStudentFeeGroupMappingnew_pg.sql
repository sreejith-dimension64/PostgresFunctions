CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingnew"(
    p_mi_id bigint,
    p_amst_id bigint,
    p_asmay_id bigint,
    p_fmg_id bigint,
    p_fmsg_id bigint,
    p_fmh_id bigint,
    p_fti_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount integer;
    v_rowcount2 integer;
BEGIN
    
    SELECT * FROM "Fee_Student_Status" a
    INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
    INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
    WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        
        DELETE FROM "Fee_Master_Student_Group_Installment" c
        USING "Fee_Student_Status" a
        INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
        WHERE b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
        AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND a."FSS_PaidAmount" = 0;
        
        DELETE FROM "Fee_Student_Status" 
        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id AND "AMST_Id" = p_amst_id AND "FMG_Id" = p_fmg_id AND "FMH_ID" = p_fmh_id AND "FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
        
        SELECT * FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMSG_Id" IN (
            SELECT "FMSG_Id" FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id
        );
        
        GET DIAGNOSTICS v_rowcount2 = ROW_COUNT;
        
        IF v_rowcount2 = 0 THEN
            DELETE FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id;
        END IF;
        
    END IF;
    
    RETURN;
END;
$$;