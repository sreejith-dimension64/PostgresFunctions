CREATE OR REPLACE FUNCTION "dbo"."IVRM_classwork_Topiclist"(
    p_MI_Id bigint,
    p_Login_Id bigint,
    p_ASMAY_Id bigint,
    p_ISMS_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_Parameter VARCHAR(50)
)
RETURNS TABLE(
    "Id" bigint,
    "Topic" TEXT,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "UserId" bigint,
    "DateFrom" TIMESTAMP,
    "DateTo" TIMESTAMP,
    "ISMS_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (p_Parameter = 'Classwork') THEN
        RETURN QUERY
        SELECT 
            "ICW_Id",
            "ICW_Topic"::TEXT,
            "ASMAY_Id",
            "ASMCL_Id",
            "ASMS_Id",
            "Login_Id",
            "ICW_FromDate",
            "ICW_ToDate",
            "ISMS_Id"
        FROM "IVRM_Assignment"
        WHERE "MI_Id" = p_MI_Id
            AND "ASMAY_Id" = p_ASMAY_Id
            AND "ISMS_Id" = p_ISMS_Id
            AND "Login_Id" = p_Login_Id
            AND "ASMCL_Id" = p_ASMCL_Id
            AND "ASMS_Id" = p_ASMS_Id;
    END IF;

    IF (p_Parameter = 'Homework') THEN
        RETURN QUERY
        SELECT 
            "IHW_Id",
            "IHW_Topic"::TEXT,
            "ASMAY_Id",
            "ASMCL_Id",
            "ASMS_Id",
            "IVRMUL_Id",
            "IHW_Date",
            NULL::TIMESTAMP,
            "ISMS_Id"
        FROM "IVRM_HomeWork"
        WHERE "MI_Id" = p_MI_Id
            AND "ASMAY_Id" = p_ASMAY_Id
            AND "ISMS_Id" = p_ISMS_Id
            AND "IVRMUL_Id" = p_Login_Id
            AND "ASMCL_Id" = p_ASMCL_Id
            AND "ASMS_Id" = p_ASMS_Id;
    END IF;

    RETURN;
END;
$$;