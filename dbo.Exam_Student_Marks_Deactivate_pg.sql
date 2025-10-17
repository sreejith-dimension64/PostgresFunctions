CREATE OR REPLACE FUNCTION "Exm"."Exam_Student_Marks_Deactivate"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id bigint,
    p_ISMS_Id bigint,
    p_LoginId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE "Exm"."Exm_Student_Marks" 
    SET "ESTM_ActiveFlg" = false,
        "UpdatedDate" = CURRENT_TIMESTAMP,
        "ESTM_UpdatedBy" = p_LoginId
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id 
        AND "EME_Id" = p_EME_Id 
        AND "ISMS_Id" = p_ISMS_Id;

END;
$$;