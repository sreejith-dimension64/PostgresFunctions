CREATE OR REPLACE FUNCTION "dbo"."EXAM_MARKS_QRCODE_COUNT"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@ASMCL_Id" BIGINT,
    "@ASMS_Id" BIGINT,
    "@EME_Id" BIGINT
)
RETURNS TABLE(
    "ESTMP_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "MI_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@IVRMGC_EnableQRCodeFlg" BOOLEAN;
BEGIN
    SELECT COALESCE("IVRMGC_EnableQRCodeFlg", FALSE)
    INTO "@IVRMGC_EnableQRCodeFlg"
    FROM "IVRM_General_Cofiguration_New"
    WHERE "MI_Id" = "@MI_Id"
    LIMIT 1;

    IF "@IVRMGC_EnableQRCodeFlg" = TRUE THEN
        RETURN QUERY
        SELECT 
            e."ESTMP_Id",
            e."ASMAY_Id",
            e."MI_Id",
            e."ASMCL_Id",
            e."ASMS_Id",
            e."AMST_Id",
            e."EME_Id"
        FROM "Exm"."Exm_Student_Marks_Process" e
        WHERE e."MI_Id" = "@MI_Id"
            AND e."ASMAY_Id" = "@ASMAY_Id"
            AND e."ASMCL_Id" = "@ASMCL_Id"
            AND e."ASMS_Id" = "@ASMS_Id"
            AND e."EME_Id" = "@EME_Id"
            AND e."ESTMP_QRCode" IS NULL
            AND e."ESTMP_ActiveFlg" = TRUE;
    END IF;

    RETURN;
END;
$$;