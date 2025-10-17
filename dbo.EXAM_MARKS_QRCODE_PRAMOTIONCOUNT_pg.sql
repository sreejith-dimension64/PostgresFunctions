CREATE OR REPLACE FUNCTION "dbo"."EXAM_MARKS_QRCODE_PRAMOTIONCOUNT"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT
)
RETURNS TABLE(
    "ESTMPP_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "MI_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e."ESTMPP_Id",
        e."ASMAY_Id",
        e."MI_Id",
        e."ASMCL_Id",
        e."ASMS_Id",
        e."AMST_Id"
    FROM "Exm"."Exm_Student_MP_Promotion" e
    WHERE e."MI_Id" = p_MI_Id
        AND e."ASMAY_Id" = p_ASMAY_Id
        AND e."ASMCL_Id" = p_ASMCL_Id
        AND e."ASMS_Id" = p_ASMS_Id
        AND e."ESTMPP_QRCode" IS NULL;
END;
$$;