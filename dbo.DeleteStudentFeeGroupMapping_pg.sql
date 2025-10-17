CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMapping"(
    p_mi_id bigint,
    p_amst_id bigint,
    p_asmay_id bigint,
    p_fmg_id bigint,
    p_fmsg_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount integer;
BEGIN
    SELECT * FROM "Fee_Student_Status" 
    WHERE "FMG_Id" = p_fmg_id 
        AND "ASMAY_Id" = p_asmay_id 
        AND "MI_Id" = p_mi_id 
        AND "AMST_Id" = p_amst_id 
        AND "FSS_PaidAmount" > 0;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount = 0 THEN
        DELETE FROM "Fee_Student_Status" 
        WHERE "FMG_Id" = p_fmg_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "AMST_Id" = p_amst_id;
        
        DELETE FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMSG_Id" = p_fmsg_id;
        
        DELETE FROM "Fee_Master_Student_Group" 
        WHERE "AMST_Id" = p_amst_id 
            AND "MI_Id" = p_mi_id 
            AND "FMG_Id" = p_fmg_id 
            AND "FMSG_Id" = p_fmsg_id;
    END IF;
    
    RETURN;
END;
$$;