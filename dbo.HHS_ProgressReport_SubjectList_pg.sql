CREATE OR REPLACE FUNCTION "dbo"."HHS_ProgressReport_SubjectList"(
    "p_mi_id" TEXT,
    "p_asmay_id" TEXT,
    "p_asmcl_id" TEXT,
    "p_asms_id" TEXT,
    "p_amst_id" TEXT,
    "p_eme_id" TEXT
)
RETURNS TABLE(
    "ISMS_Id" INTEGER,
    "Isms_SubjectName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
BEGIN
    "v_sql" := 'SELECT DISTINCT e."ISMS_Id", f."Isms_SubjectName" 
    FROM "Exm"."Exm_Category_Class" a
    INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
    INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
    INNER JOIN "IVRM_Master_Subjects" f ON f."isms_id" = e."isms_id"
    INNER JOIN "exm"."Exm_Student_Marks_Process" g ON 1=1
    INNER JOIN "dbo"."adm_school_Y_student" h ON g."amst_id" = h."amst_id"
    INNER JOIN "dbo"."Adm_M_Student" i ON h."AMST_Id" = i."AMST_Id"
    WHERE b."EYC_ActiveFlg" = 1 
    AND c."EYCE_ActiveFlg" = 1 
    AND d."EME_ActiveFlag" = 1 
    AND e."EYCES_ActiveFlg" = 1 
    AND a."MI_Id" = ' || "p_mi_id" || ' 
    AND a."ASMAY_Id" = ' || "p_asmay_id" || ' 
    AND a."ASMCL_Id" = ' || "p_asmcl_id" || ' 
    AND a."ECAC_ActiveFlag" = 1 
    AND a."ASMS_Id" = ' || "p_asms_id" || ' 
    AND b."MI_Id" = ' || "p_mi_id" || ' 
    AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
    AND f."isms_activeflag" = 1 
    AND d."EME_Id" IN (' || "p_eme_id" || ')
    AND g."AMST_Id" = ' || "p_amst_id";

    RETURN QUERY EXECUTE "v_sql";
    
    RETURN;
END;
$$;