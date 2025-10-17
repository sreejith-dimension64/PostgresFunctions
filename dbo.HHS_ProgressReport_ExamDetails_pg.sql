CREATE OR REPLACE FUNCTION "dbo"."HHS_ProgressReport_ExamDetails"(
    "@mi_id" TEXT,
    "@asmay_id" TEXT,
    "@asmcl_id" TEXT,
    "@asms_id" TEXT,
    "@amst_id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "Stuname" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_FatherName" VARCHAR,
    "AMST_MotherName" VARCHAR,
    "ISMS_Id" INTEGER,
    "EME_Id" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MarksEntryMax" NUMERIC,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "EMGR_Id" INTEGER,
    "ESTM_Marks" NUMERIC,
    "ESTM_MarksGradeFlg" VARCHAR,
    "ESTM_Flg" VARCHAR,
    "ESTMPS_Id" INTEGER,
    "EMSS_Id" INTEGER,
    "ISMS_SubjectName" VARCHAR,
    "EMSS_SubSubjectName" VARCHAR,
    "EMSE_Id" INTEGER,
    "EYCESSS_MaxMarks" NUMERIC,
    "EYCESSS_MinMarks" NUMERIC,
    "EYCESSE_ExemptedFlg" BOOLEAN,
    "ESTMSS_Marks" NUMERIC,
    "subSubjectGrade" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@eme_id" INTEGER;
    "cursor1_record" RECORD;
BEGIN

    DROP TABLE IF EXISTS "Test1";
    
    CREATE TEMP TABLE "Test1"("eme_id" INTEGER);

    FOR "cursor1_record" IN
        SELECT DISTINCT d."eme_id"
        FROM "Exm"."Exm_Category_Class" a,
             "exm"."Exm_Yearly_Category" b,
             "Exm"."Exm_Yearly_Category_Exams" c,
             "Exm"."Exm_Master_Exam" d,
             "exm"."Exm_Yrly_Cat_Exams_Subwise" e,
             "dbo"."adm_m_student" f
        WHERE c."EYC_Id" = b."EYC_Id" 
          AND b."EYC_ActiveFlg" = 1 
          AND c."EYCE_ActiveFlg" = 1 
          AND d."EME_Id" = c."EME_Id" 
          AND d."EME_ActiveFlag" = 1  
          AND a."MI_Id" = "@mi_id" 
          AND a."ASMAY_Id" = "@asmay_id"
          AND a."ASMCL_Id" = "@asmcl_id"  
          AND a."ECAC_ActiveFlag" = 1 
          AND a."ASMS_Id" = "@asms_id" 
          AND a."EMCA_Id" = b."EMCA_Id" 
          AND b."MI_Id" = "@mi_id" 
          AND b."ASMAY_Id" = "@asmay_id"
    LOOP
        "@eme_id" := "cursor1_record"."eme_id";
        
        INSERT INTO "Test1"("eme_id") VALUES("@eme_id");
    END LOOP;

    RETURN QUERY
    SELECT DISTINCT 
        "ESM"."AMST_Id",
        (COALESCE(f."AMST_FirstName", '') || ' ' || COALESCE(f."AMST_MiddleName", '') || ' ' || COALESCE(f."AMST_LastName", '')) AS "Stuname",
        f."AMST_AdmNo",
        f."AMST_FatherName",
        f."AMST_MotherName",
        "ESM"."ISMS_Id",
        "ESM"."EME_Id",
        "EYCES"."EYCES_AplResultFlg",
        "EYCES"."EYCES_MarksEntryMax",
        "EYCES"."EYCES_MaxMarks",
        "EYCES"."EYCES_MinMarks",
        "EYCES"."EMGR_Id",
        "ESM"."ESTM_Marks",
        "ESM"."ESTM_MarksGradeFlg",
        "ESM"."ESTM_Flg",
        "ESMPS"."ESTMPS_Id",
        "ESMSS"."EMSS_Id",
        sub."ISMS_SubjectName",
        subsubj."EMSS_SubSubjectName",
        "ESMSS"."EMSE_Id",
        "EYCESS"."EYCESSS_MaxMarks",
        "EYCESS"."EYCESSS_MinMarks",
        "EYCESSE"."EYCESSE_ExemptedFlg",
        "ESMSS"."ESTMSS_Marks",
        "EYCESS"."EMGR_Id" AS "subSubjectGrade"
    FROM "Adm_M_Student" AS f
    JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
        AND f."AMST_ActiveFlag" = 1 
        AND f."AMST_SOL" = 'S' 
        AND h."AMAY_ActiveFlag" = 1 
        AND h."ASMAY_Id" = f."ASMAY_Id"
    INNER JOIN "Exm"."Exm_Category_Class" "ECC" ON "ECC"."MI_Id" = f."MI_Id" 
        AND "ECC"."ASMAY_Id" = f."ASMAY_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "EYC"."MI_Id" = f."MI_Id" 
        AND "EYC"."ASMAY_Id" = f."ASMAY_Id" 
        AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
    INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "ESM"."AMST_Id" = f."AMST_Id" 
        AND "ESM"."ISMS_Id" = "EYCES"."ISMS_Id"
    INNER JOIN "ivrm_master_subjects" sub ON sub."ISMS_Id" = "ESM"."ISMS_Id"
        AND "ESM"."MI_Id" = "EYC"."MI_Id" 
        AND "ESM"."EME_Id" = "EYCE"."EME_Id" 
        AND "ESM"."ASMAY_Id" = "ECC"."ASMAY_Id" 
        AND "ESM"."ASMS_Id" = "ECC"."ASMS_Id" 
        AND "ESM"."ASMCL_Id" = "ECC"."ASMCL_Id"
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS n ON n."ISMS_Id" = "EYCES"."ISMS_Id" 
        AND n."AMST_Id" = f."AMST_Id" 
        AND n."MI_Id" = f."MI_Id" 
        AND n."ASMAY_Id" = f."ASMAY_Id" 
        AND n."ASMCL_Id" = h."ASMCL_Id" 
        AND n."ASMS_Id" = h."ASMS_Id"
    LEFT JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" "EYCESS" ON "EYCESS"."EYCES_Id" = "EYCES"."EYCES_Id"
    LEFT JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubExams" "EYCESSE" ON "EYCESSE"."EYCES_Id" = "EYCESS"."EYCES_Id"
    LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" ON "ESMPS"."EME_Id" = "EYCE"."EME_Id"
    LEFT JOIN "Exm"."Exm_Student_Marks_SubSubject" "ESMSS" ON "ESMSS"."ESTM_Id" = "ESMSS"."ESTM_Id"
    LEFT JOIN "exm"."Exm_Master_SubSubject" subsubj ON subsubj."EMSS_Id" = "ESMSS"."EMSS_Id"
    WHERE "EYC"."MI_Id" = "@mi_id" 
      AND "EYC"."ASMAY_Id" = "@asmay_id" 
      AND "ECC"."ASMCL_Id" = "@asmcl_id" 
      AND "ECC"."ASMS_Id" = "@asms_id" 
      AND "ESM"."AMST_Id" = "@amst_id"
      AND "EYCE"."EME_Id" IN (SELECT DISTINCT "eme_id" FROM "Test1");

    RETURN;
END;
$$;