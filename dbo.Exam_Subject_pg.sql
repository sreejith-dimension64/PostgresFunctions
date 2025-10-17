CREATE OR REPLACE FUNCTION "dbo"."Exam_Subject"(
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT,
    p_MI_Id BIGINT,
    p_EME_Id BIGINT
)
RETURNS TABLE(
    "ISMS_SubjectName" VARCHAR,
    "ISMS_Id" BIGINT,
    "ESTMPS_MaxMarks" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "IMS"."ISMS_SubjectName",
        "IMS"."ISMS_Id",
        "ESMPS"."ESTMPS_MaxMarks"
    FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
    LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
        ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
        AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
        AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
        AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
        AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" 
        ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
        AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
        ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
        AND "IMS"."MI_Id" = "EME"."MI_Id"
    WHERE "ESS"."MI_Id" = p_MI_Id 
        AND "ESMPS"."ASMAY_Id" = p_ASMAY_Id 
        AND "EME"."EME_Id" = p_EME_Id 
        AND "ESS"."ASMCL_Id" = p_ASMCL_Id 
        AND "ESS"."ASMS_Id" = p_ASMS_Id;
    
    RETURN;
END;
$$;