CREATE OR REPLACE FUNCTION "dbo"."HHS_ProgressReport_Sub_SubjectList"(
    "p_mi_id" TEXT,
    "p_asmay_id" TEXT,
    "p_asmcl_id" TEXT,
    "p_asms_id" TEXT,
    "p_amst_id" TEXT,
    "p_eme_id" TEXT,
    "p_isms_id" TEXT
)
RETURNS TABLE(
    "eme_id" INTEGER,
    "ISMS_Id" INTEGER,
    "Isms_SubjectName" TEXT,
    "eyces_id" INTEGER,
    "emss_id" INTEGER,
    "emss_SubsubjectName" TEXT,
    "ISMS_OrderFlag" INTEGER,
    "amst_id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
BEGIN
    "v_sql" := 'SELECT DISTINCT z."eme_id", z."ISMS_Id", z."Isms_SubjectName", z."eyces_id", y."emss_id", x."emss_SubsubjectName", z."ISMS_OrderFlag", z."amst_id"
    FROM 
    (SELECT d."eme_id", e."ISMS_Id", f."Isms_SubjectName", e."EYCES_SubSubjectFlg", e."eyces_id", h."amst_id",
    e."EYCES_SubExamFlg", f."ISMS_OrderFlag" 
    FROM "Exm"."Exm_Category_Class" a,
    "exm"."Exm_Yearly_Category" b,
    "Exm"."Exm_Yearly_Category_Exams" c,
    "Exm"."Exm_Master_Exam" d, 
    "exm"."Exm_Yrly_Cat_Exams_Subwise" e,
    "IVRM_Master_Subjects" f,
    "exm"."Exm_Student_Marks_Process" g,
    "dbo"."adm_school_Y_student" h,
    "dbo"."Adm_M_Student" i 
    WHERE c."EYC_Id" = b."EYC_Id" 
    AND "EYC_ActiveFlg" = 1 
    AND "EYCE_ActiveFlg" = 1 
    AND d."EME_Id" = c."EME_Id" 
    AND d."EME_ActiveFlag" = 1 
    AND e."EYCE_Id" = c."EYCE_Id" 
    AND e."EYCES_ActiveFlg" = 1 
    AND a."MI_Id" = ' || "p_mi_id" || ' 
    AND a."ASMAY_Id" = ' || "p_asmay_id" || ' 
    AND a."ASMCL_Id" = ' || "p_asmcl_id" || '  
    AND "ECAC_ActiveFlag" = 1 
    AND a."ASMS_Id" = ' || "p_asms_id" || '
    AND a."EMCA_Id" = b."EMCA_Id"
    AND b."MI_Id" = ' || "p_mi_id" || ' 
    AND b."ASMAY_Id" = ' || "p_asmay_id" || '  
    AND f."isms_id" = e."isms_id" 
    AND e."isms_id" IN(' || "p_isms_id" || ') 
    AND f."isms_activeflag" = 1 
    AND d."EME_Id" IN(' || "p_eme_id" || ')
    AND g."amst_id" = h."amst_id" 
    AND h."AMST_Id" = i."AMST_Id"  
    AND g."AMST_Id" = ' || "p_amst_id" || ') z,
    "exm"."Exm_Yrly_Cat_Exams_Subwise_Subsubjects" y,
    "Exm"."Exm_master_subsubject" x
    WHERE z."eyces_id" = y."eyces_id" 
    AND z."EYCES_SubSubjectFlg" = 1 
    AND x."emss_id" = y."emss_id" 
    AND x."emss_activeflag" = 1';

    RETURN QUERY EXECUTE "v_sql";
END;
$$;