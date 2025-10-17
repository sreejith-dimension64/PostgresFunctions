CREATE OR REPLACE FUNCTION "dbo"."HHS_ProgressReport_ExamList"(
    "@mi_id" TEXT,
    "@asmay_id" TEXT,
    "@asmcl_id" TEXT,
    "@asms_id" TEXT,
    "@amst_id" TEXT
)
RETURNS TABLE(
    "eme_id" INTEGER,
    "EME_ExamName" VARCHAR,
    "EME_ExamOrder" INTEGER,
    "AMST_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        d."eme_id", 
        d."EME_ExamName",
        d."EME_ExamOrder",
        g."AMST_Id"
    FROM "Exm"."Exm_Category_Class" a
    INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
    INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
    INNER JOIN "exm"."Exm_Student_Marks_Process" g ON g."EYC_Id" = b."EYC_Id"
    INNER JOIN "dbo"."adm_school_Y_student" f ON g."amst_id" = f."amst_id"
    INNER JOIN "dbo"."Adm_M_Student" h ON h."AMST_Id" = f."AMST_Id"
    WHERE b."EYC_ActiveFlg" = 1 
        AND c."EYCE_ActiveFlg" = 1 
        AND d."EME_ActiveFlag" = 1
        AND a."MI_Id" = "@mi_id"
        AND a."ASMAY_Id" = "@asmay_id"
        AND a."ASMCL_Id" = "@asmcl_id"
        AND a."ECAC_ActiveFlag" = 1
        AND a."ASMS_Id" = "@asms_id"
        AND b."MI_Id" = "@mi_id"
        AND b."ASMAY_Id" = "@asmay_id"
        AND g."AMST_Id" = "@amst_id";
END;
$$;