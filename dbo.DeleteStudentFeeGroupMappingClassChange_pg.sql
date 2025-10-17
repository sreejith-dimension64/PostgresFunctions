CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingClassChange"(
    p_mi_id BIGINT,
    p_amst_id BIGINT,
    p_asmay_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount INTEGER;
BEGIN
    SELECT * FROM "Fee_Student_Status" 
    WHERE "ASMAY_Id" = p_asmay_id 
    AND "MI_Id" = p_mi_id 
    AND "AMST_Id" = p_amst_id 
    AND "FSS_PaidAmount" = 0;

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;

    IF v_rowcount > 0 THEN
        DELETE FROM "Fee_Student_Status" 
        WHERE "ASMAY_Id" = p_asmay_id 
        AND "MI_Id" = p_mi_id 
        AND "AMST_Id" = p_amst_id;

        DELETE FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMSG_Id" IN (
            SELECT "fmsg_id" 
            FROM "Fee_Master_Student_Group" 
            WHERE "AMST_Id" = p_amst_id 
            AND "MI_Id" = p_mi_id 
            AND "ASMAY_Id" = p_asmay_id
        );

        DELETE FROM "Fee_Master_Student_Group" 
        WHERE "AMST_Id" = p_amst_id 
        AND "MI_Id" = p_mi_id 
        AND "ASMAY_Id" = p_asmay_id;
    END IF;

    RETURN;
END;
$$;