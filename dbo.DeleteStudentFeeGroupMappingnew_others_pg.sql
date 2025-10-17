CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingnew_others"(
    p_mi_id bigint,
    p_FMOST_Id bigint,
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
    v_check_count integer;
BEGIN
    
    PERFORM * FROM "Fee_Student_Status_OthStu" a
    INNER JOIN "Fee_Master_OthStudents_GH" b ON a."FMOST_Id" = b."FMOST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
    INNER JOIN "Fee_Master_OthStudents_GH_Instl" c ON b."FMOSTGH_Id" = c."FMOSTGH_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
    WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."FMOST_Id" = p_FMOST_Id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSSOST_PaidAmount" = 0;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        
        DELETE FROM "Fee_Master_OthStudents_GH_Instl" 
        USING "Fee_Student_Status_OthStu" a
        INNER JOIN "Fee_Master_OthStudents_GH" b ON a."FMOST_Id" = b."FMOST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
        WHERE b."FMOSTGH_Id" = "Fee_Master_OthStudents_GH_Instl"."FMOSTGH_Id" 
        AND a."FMH_Id" = "Fee_Master_OthStudents_GH_Instl"."FMH_ID" 
        AND a."FTI_Id" = "Fee_Master_OthStudents_GH_Instl"."FTI_ID"
        AND b."MI_Id" = p_mi_id 
        AND b."ASMAY_Id" = p_asmay_id 
        AND b."FMOST_Id" = p_FMOST_Id 
        AND b."FMG_Id" = p_fmg_id 
        AND "Fee_Master_OthStudents_GH_Instl"."FMH_ID" = p_fmh_id 
        AND "Fee_Master_OthStudents_GH_Instl"."FTI_ID" = p_fti_id 
        AND a."FSSOST_PaidAmount" = 0;
        
        DELETE FROM "Fee_Student_Status_OthStu" 
        WHERE "MI_Id" = p_mi_id 
        AND "ASMAY_Id" = p_asmay_id 
        AND "FMOST_Id" = p_FMOST_Id 
        AND "FMG_Id" = p_fmg_id 
        AND "FMH_ID" = p_fmh_id 
        AND "FTI_ID" = p_fti_id 
        AND "FSSOST_PaidAmount" = 0;
        
        SELECT COUNT(*) INTO v_check_count 
        FROM "Fee_Master_OthStudents_GH_Instl" 
        WHERE "FMOSTGH_Id" IN (
            SELECT "FMOSTGH_Id" 
            FROM "Fee_Master_OthStudents_GH" 
            WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "FMOST_Id" = p_FMOST_Id
        );
        
        IF v_check_count = 0 THEN
            DELETE FROM "Fee_Master_OthStudents_GH" 
            WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "FMOST_Id" = p_FMOST_Id;
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;