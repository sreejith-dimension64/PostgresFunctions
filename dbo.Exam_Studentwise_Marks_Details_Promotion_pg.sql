CREATE OR REPLACE FUNCTION "dbo"."Exam_Studentwise_Marks_Details_Promotion"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_SubjectCode" VARCHAR,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "EMGR_Id" BIGINT,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ClassAverage" NUMERIC,
    "ESTMPS_SectionAverage" NUMERIC,
    "ESTMPS_ClassHighest" NUMERIC,
    "ESTMPS_SectionHighest" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" VARCHAR,
    "ESTMPS_PassFailFlg" VARCHAR,
    "EMGD_Remarks" VARCHAR,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN,
    "EME_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@EMCA_Id" BIGINT;
    "@EYC_Id" BIGINT;
BEGIN

    DROP TABLE IF EXISTS "TEMP_EXAM_DETAILS";

    SELECT "EMCA_Id" INTO "@EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND "ECAC_ActiveFlag" = TRUE;

    SELECT "EYC_Id" INTO "@EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "EMCA_Id" = "@EMCA_Id" 
        AND "EYC_ActiveFlg" = TRUE;

    CREATE TEMP TABLE "TEMP_EXAM_DETAILS" AS
    SELECT DISTINCT A."EME_Id" 
    FROM "Exm"."Exm_Yearly_Category_Exams" A 
    INNER JOIN "Exm"."Exm_Yearly_Category" B ON A."EYC_Id" = B."EYC_Id" 
    INNER JOIN "Exm"."Exm_Category_Class" C ON C."EMCA_Id" = B."EMCA_Id" 
    WHERE B."MI_Id" = "@MI_Id"::BIGINT 
        AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND A."EYC_Id" = "@EYC_Id" 
        AND C."MI_Id" = "@MI_Id"::BIGINT 
        AND C."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND C."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND C."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND A."EYCE_ActiveFlg" = TRUE 
        AND B."EYC_ActiveFlg" = TRUE 
        AND C."ECAC_ActiveFlag" = TRUE;

    RETURN QUERY
    SELECT DISTINCT 
        f."AMST_Id",
        m."ISMS_Id",
        d."ISMS_SubjectName", 
        d."ISMS_SubjectCode",
        m."EYCES_AplResultFlg",
        m."EYCES_MaxMarks",
        m."EYCES_MinMarks",
        m."EMGR_Id",
        COALESCE(a."ESTMPS_MaxMarks", 0) AS "ESTMPS_MaxMarks", 
        COALESCE(a."ESTMPS_ClassAverage", 0) AS "ESTMPS_ClassAverage",
        COALESCE(a."ESTMPS_SectionAverage", 0) AS "ESTMPS_SectionAverage",  
        ROUND(COALESCE(a."ESTMPS_ClassHighest", 0), 0) AS "ESTMPS_ClassHighest",
        ROUND(COALESCE(a."ESTMPS_SectionHighest", 0), 0) AS "ESTMPS_SectionHighest",  
        COALESCE(a."ESTMPS_ObtainedMarks", 0) AS "ESTMPS_ObtainedMarks",
        a."ESTMPS_ObtainedGrade",
        a."ESTMPS_PassFailFlg", 
        r."EMGD_Remarks", 
        m."EYCES_SubjectOrder",
        m."EYCES_MarksDisplayFlg",
        m."EYCES_GradeDisplayFlg",
        A."EME_Id"
    FROM "Adm_M_Student" AS f
    INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
        AND f."AMST_ActiveFlag" = TRUE 
        AND f."AMST_SOL" = 'S' 
        AND h."AMAY_ActiveFlag" = TRUE 
        AND h."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND h."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND h."ASMS_Id" = "@ASMS_Id"::BIGINT                          
    INNER JOIN "Exm"."Exm_Category_Class" AS j ON j."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND j."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND j."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND j."MI_Id" = "@MI_Id"::BIGINT 
        AND j."ECAC_ActiveFlag" = TRUE  
    INNER JOIN "Exm"."Exm_Yearly_Category" AS k ON j."EMCA_Id" = k."EMCA_Id" 
        AND k."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND k."MI_Id" = "@MI_Id"::BIGINT 
        AND k."EYC_ActiveFlg" = TRUE
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS l ON l."EYC_Id" = k."EYC_Id" 
        AND l."EME_Id" IN (SELECT "EME_Id" FROM "TEMP_EXAM_DETAILS")  
        AND l."EYCE_ActiveFlg" = TRUE
    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS m ON m."EYCE_Id" = l."EYCE_Id" 
        AND m."EYCES_ActiveFlg" = TRUE 
        AND m."EYCES_ActiveFlg" = TRUE
    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS a ON m."ISMS_Id" = a."ISMS_Id" 
        AND h."AMST_Id" = a."AMST_Id" 
        AND a."ASMCL_Id" = "@ASMCL_Id"::BIGINT  
        AND a."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND a."MI_Id" = "@MI_Id"::BIGINT 
        AND a."EME_Id" IN (SELECT "EME_Id" FROM "TEMP_EXAM_DETAILS")
    INNER JOIN "IVRM_Master_Subjects" AS d ON m."ISMS_Id" = d."ISMS_Id"  
        AND d."MI_Id" = "@MI_Id"::BIGINT     
    INNER JOIN "Adm_School_M_Class" AS b ON h."ASMCL_Id" = b."ASMCL_Id" 
        AND b."MI_Id" = "@MI_Id"::BIGINT
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS r ON m."EMGR_Id" = r."EMGR_Id" 
        AND a."ESTMPS_ObtainedGrade" = r."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS c ON l."EME_Id" = c."EME_Id" 
        AND c."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "Adm_School_M_Section" AS e ON h."ASMS_Id" = e."ASMS_Id" 
        AND e."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS n ON n."ISMS_Id" = m."ISMS_Id" 
        AND n."AMST_Id" = f."AMST_Id" 
        AND n."MI_Id" = "@MI_Id"::BIGINT 
        AND n."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND n."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND n."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND n."ESTSU_ActiveFlg" = TRUE;

    DROP TABLE IF EXISTS "TEMP_EXAM_DETAILS";

    RETURN;
END;
$$;