CREATE OR REPLACE FUNCTION "dbo"."Get_InternalAssesment_Subject_marks_Record"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "Isms_SubjectName" VARCHAR,
    "ISMS_OrderFlag" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."ISMS_Id",
        f."Isms_SubjectName",
        f."ISMS_OrderFlag",
        e."EYCES_AplResultFlg",
        e."EYCES_MarksDisplayFlg",
        e."EYCES_GradeDisplayFlg"
    FROM 
        "Exm"."Exm_Category_Class" a,
        "exm"."Exm_Yearly_Category" b,
        "Exm"."Exm_Yearly_Category_Exams" c,
        "Exm"."Exm_Master_Exam" d,
        "exm"."Exm_Yrly_Cat_Exams_Subwise" e,
        "IVRM_Master_Subjects" f,
        "exm"."Exm_Student_Marks_Process" g,
        "dbo"."adm_school_Y_student" h,
        "dbo"."Adm_M_Student" i,
        "exm"."Exm_Studentwise_Subjects" j
    WHERE 
        c."EYC_Id" = b."EYC_Id" 
        AND b."EYC_ActiveFlg" = 1 
        AND c."EYCE_ActiveFlg" = 1 
        AND d."EME_Id" = c."EME_Id" 
        AND d."EME_ActiveFlag" = 1 
        AND e."EYCE_Id" = c."EYCE_Id" 
        AND e."EYCES_ActiveFlg" = 1
        AND j."ISMS_Id" = e."ISMS_Id" 
        AND j."ASMAY_Id" = b."ASMAY_Id" 
        AND j."ASMCL_Id" = g."ASMCL_Id" 
        AND j."ASMS_Id" = g."ASMS_Id" 
        AND j."ASMAY_Id" = h."ASMAY_Id" 
        AND j."ASMCL_Id" = h."ASMCL_Id" 
        AND j."ASMS_Id" = h."ASMS_Id" 
        AND j."AMST_Id" = h."AMST_Id" 
        AND j."MI_Id" = p_MI_Id 
        AND j."ASMAY_Id" = p_ASMAY_Id 
        AND j."ASMCL_Id" = p_ASMCL_Id 
        AND j."ASMS_Id" = p_ASMS_Id 
        AND j."ESTSU_ActiveFlg" = 1
        AND a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."ASMCL_Id" = p_ASMCL_Id 
        AND a."ECAC_ActiveFlag" = 1 
        AND a."ASMS_Id" = p_ASMS_Id 
        AND a."EMCA_Id" = b."EMCA_Id" 
        AND b."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND f."isms_id" = e."isms_id" 
        AND f."isms_activeflag" = 1 
        AND g."amst_id" = h."amst_id" 
        AND h."AMST_Id" = i."AMST_Id" 
        AND g."AMST_Id" = p_AMST_Id 
        AND c."EYCE_SubExamFlg" = 1 
        AND e."EYCES_SubExamFlg" = 1
    ORDER BY f."ISMS_OrderFlag";
END;
$$;