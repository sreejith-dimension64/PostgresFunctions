CREATE OR REPLACE FUNCTION "dbo"."Exam_Mark_cumalative_report"(
    "@MI_Id" BIGINT,
    "@ASMS_Id" BIGINT,
    "@ASMCL_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@EME_Id" TEXT,
    "@EMGR_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "EMSE_SubExamName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "Subject_Flag" INTEGER,
    "EME_ExamName" VARCHAR,
    "ESTMPSSS_ObtainedGrade" VARCHAR,
    "ESTMPSSS_ObtainedMarks" NUMERIC,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN,
    "ESTMPSSS_PassFailFlg" VARCHAR,
    "AMAY_RollNo" INTEGER,
    "EMSE_SubExamOrder" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@EYC_Id" BIGINT;
    "@EMCA_Id" BIGINT;
    "@EMGR_MarksPerFlag" VARCHAR(10);
BEGIN

    SELECT "EMCA_Id" INTO "@EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id" 
        AND "ASMAY_Id" = "@ASMAY_Id" 
        AND "ASMCL_Id" = "@ASMCL_Id" 
        AND "ASMS_Id" = "@ASMS_Id"   
        AND "ECAC_ActiveFlag" = 1;

    RAISE NOTICE '%', "@EMCA_Id";
  
    SELECT "EYC_Id" INTO "@EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "@MI_Id" 
        AND "ASMAY_Id" = "@ASMAY_Id" 
        AND "EMCA_Id" = "@EMCA_Id" 
        AND "EYC_ActiveFlg" = 1;
  
    RAISE NOTICE '%', "@EYC_Id";

    SELECT "EMGR_GradeName" INTO "@EMGR_MarksPerFlag" 
    FROM "exm"."Exm_Master_Grade"  
    WHERE "MI_Id" = "@MI_Id" 
        AND "EMGR_Id" = "@EMGR_Id"::BIGINT;
        
    RAISE NOTICE '%', "@EMGR_MarksPerFlag";

    DROP TABLE IF EXISTS "CBS_Temp_StudentDetails";

    CREATE TEMP TABLE "CBS_Temp_StudentDetails" AS
    WITH "CTE_Exam" AS (
        SELECT 
            "YS"."AMST_Id", 
            c."ISMS_Id",
            c."ISMS_SubjectName",
            b."EME_Id",
            d."EME_ExamName",
            COALESCE(f."EMSE_SubExamName", e."EMSS_SubSubjectName") AS "EMSE_SubExamName",
            a."ESTMPSSS_ObtainedGrade",
            a."ESTMPSSS_ObtainedMarks",
            a."ESTMPSSS_MaxMarks",
            0 AS "Subject_Flag",
            c."ISMS_OrderFlag" AS "EYCES_SubjectOrder",
            "I"."EYCES_MarksDisplayFlg",
            "I"."EYCES_GradeDisplayFlg",
            a."ESTMPSSS_PassFailFlg",
            "YS"."AMAY_RollNo",
            "EMSE_SubExamOrder"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" b
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" a ON a."ESTMPS_Id" = b."ESTMPS_Id"
        INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = b."AMST_Id" 
            AND "YS"."ASMCL_Id" = b."ASMCL_Id" 
            AND "YS"."ASMS_Id" = b."ASMS_Id" 
            AND "YS"."AMAY_ActiveFlag" = 1 
            AND "YS"."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" "G" ON "G"."ASMAY_Id" = "B"."ASMAY_Id" 
            AND "G"."EYC_Id" = "@EYC_Id" 
            AND "g"."EMCA_Id" = "@EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "H" ON "G"."EYC_Id" = "H"."EYC_Id" 
            AND "H"."EYC_Id" = "@EYC_Id" 
            AND "h"."EME_Id" = b."EME_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "I" ON "I"."EYCE_Id" = "H"."EYCE_Id" 
            AND "I"."ISMS_Id" = b."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "C" ON c."ISMS_Id" = b."ISMS_Id" 
            AND "I"."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "D" ON d."EME_Id" = b."EME_Id" 
            AND "D"."EME_Id" = "H"."EME_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" "F" ON f."EMSE_Id" = a."EMSE_Id"
        LEFT JOIN "Exm"."Exm_Master_SubSubject" "E" ON "E"."EMSS_Id" = a."EMSS_Id"
        WHERE b."MI_Id" = "@MI_Id" 
            AND b."ASMS_Id" = "@ASMS_Id" 
            AND b."ASMCL_Id" = "@ASMCL_Id" 
            AND b."ASMAY_Id" = "@ASMAY_Id" 
            AND "YS"."ASMAY_Id" = "@ASMAY_Id" 
            AND d."EME_Id"::TEXT IN (SELECT UNNEST(string_to_array("@EME_Id", ',')))

        UNION ALL

        SELECT 
            "YS"."AMST_Id", 
            c."ISMS_Id",
            c."ISMS_SubjectName",
            "D"."EME_Id",
            d."EME_ExamName",
            d."EME_ExamName" AS "EMSE_SubExamName",
            b."ESTMPS_ObtainedGrade" AS "ESTMPSSS_ObtainedGrade",
            b."ESTMPS_ObtainedMarks",
            b."ESTMPS_MaxMarks" AS "ESTMPSSS_MaxMarks",
            1 AS "Subject_Flag",
            c."ISMS_OrderFlag" AS "EYCES_SubjectOrder",
            "I"."EYCES_MarksDisplayFlg",
            "I"."EYCES_GradeDisplayFlg",
            b."ESTMPS_PassFailFlg",
            "YS"."AMAY_RollNo",
            '' AS "EMSE_SubExamOrder"
        FROM "Exm"."Exm_Master_Exam" "D"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" b ON d."EME_Id" = b."EME_Id"
        INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = b."AMST_Id" 
            AND "YS"."ASMCL_Id" = b."ASMCL_Id" 
            AND "YS"."ASMS_Id" = b."ASMS_Id" 
            AND "YS"."AMAY_ActiveFlag" = 1 
            AND "YS"."ASMAY_Id" = "@ASMAY_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" "G" ON "G"."ASMAY_Id" = "B"."ASMAY_Id" 
            AND "G"."EYC_Id" = "@EYC_Id" 
            AND "g"."EMCA_Id" = "@EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "H" ON "G"."EYC_Id" = "H"."EYC_Id" 
            AND "H"."EYC_Id" = "@EYC_Id" 
            AND "h"."EME_Id" = b."EME_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "I" ON "I"."EYCE_Id" = "H"."EYCE_Id" 
            AND "I"."ISMS_Id" = b."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "C" ON c."ISMS_Id" = b."ISMS_Id" 
            AND "I"."ISMS_Id" = "C"."ISMS_Id"
        WHERE b."MI_Id" = "@MI_Id" 
            AND b."ASMS_Id" = "@ASMS_Id" 
            AND b."ASMCL_Id" = "@ASMCL_Id" 
            AND b."ASMAY_Id" = "@ASMAY_Id" 
            AND d."EME_Id"::TEXT IN (SELECT UNNEST(string_to_array("@EME_Id", ',')))
            AND "I"."ISMS_Id" IN (
                SELECT DISTINCT "ISMS_Id" 
                FROM "Exm"."Exm_Studentwise_Subjects" 
                WHERE "ASMAY_Id" = "@ASMAY_Id" 
                    AND "ASMCL_Id" = "@ASMCL_Id" 
                    AND "ASMS_Id" = "@ASMS_Id"
            )
        GROUP BY c."ISMS_Id", c."ISMS_SubjectName", "YS"."AMST_Id", "D"."EME_Id", d."EME_ExamName", 
            b."ESTMPS_ObtainedGrade", b."ESTMPS_ObtainedMarks", b."ESTMPS_MaxMarks", c."ISMS_OrderFlag", 
            "I"."EYCES_MarksDisplayFlg", "I"."EYCES_GradeDisplayFlg", b."ESTMPS_PassFailFlg", "YS"."AMAY_RollNo"
    )
    SELECT 
        "AMST_Id", 
        "ISMS_Id",
        "ISMS_SubjectName",
        "EME_Id",
        "EME_ExamName",
        "EMSE_SubExamName",
        "ESTMPSSS_ObtainedGrade",
        "ESTMPSSS_ObtainedMarks",
        "Subject_Flag",
        "EYCES_SubjectOrder",
        "EYCES_MarksDisplayFlg",
        "EYCES_GradeDisplayFlg",
        "ESTMPSSS_PassFailFlg",
        "AMAY_RollNo",
        "EMSE_SubExamOrder"
    FROM "CTE_Exam"

    UNION ALL 

    SELECT 
        "AMST_Id", 
        "ISMS_Id",
        "ISMS_SubjectName",
        98000 AS "EME_Id",
        'Total' AS "EME_ExamName",
        '[Total]' AS "EMSE_SubExamName",
        (
            SELECT "EMGD_Name" 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE SUM("ESTMPSSS_ObtainedMarks") BETWEEN "EMGD_From" AND "EMGD_To" 
                AND "EMGR_Id" = "@EMGR_Id"::BIGINT
        ) AS "ESTMPSSS_ObtainedGrade",
        SUM("ESTMPSSS_ObtainedMarks"),
        2,
        "EYCES_SubjectOrder",
        "EYCES_MarksDisplayFlg",
        "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg",
        NULL AS "AMAY_RollNo",
        "EMSE_SubExamOrder"
    FROM "CTE_Exam"
    WHERE "Subject_Flag" = 1 AND "EYCES_GradeDisplayFlg" = TRUE
    GROUP BY "ISMS_Id", "ISMS_SubjectName", "AMST_Id", "Subject_Flag", "EYCES_SubjectOrder", 
        "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "EMSE_SubExamOrder"

    UNION ALL 

    SELECT 
        "AMST_Id", 
        "ISMS_Id",
        "ISMS_SubjectName",
        98000 AS "EME_Id",
        'Total' AS "EME_ExamName",
        '[Total]' AS "EMSE_SubExamName",
        (
            SELECT "EMGD_Name" 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE SUM("ESTMPSSS_ObtainedMarks") BETWEEN "EMGD_From" AND "EMGD_To" 
                AND "EMGR_Id" = "@EMGR_Id"::BIGINT
        ) AS "ESTMPSSS_ObtainedGrade",
        SUM("ESTMPSSS_ObtainedMarks"),
        2,
        "EYCES_SubjectOrder",
        "EYCES_MarksDisplayFlg",
        "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg",
        NULL AS "AMAY_RollNo",
        "EMSE_SubExamOrder"
    FROM "CTE_Exam"
    WHERE "Subject_Flag" = 1 AND "EYCES_MarksDisplayFlg" = TRUE
    GROUP BY "ISMS_Id", "ISMS_SubjectName", "AMST_Id", "Subject_Flag", "EYCES_SubjectOrder", 
        "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "EMSE_SubExamOrder"

    UNION ALL

    SELECT 
        "AMST_Id",
        "ISMS_Id",
        "ISMS_SubjectName",
        98001 AS "EME_Id",
        'Percentage' AS "EMSE_SubExamName",
        '[Percentage]' AS "EMSE_SubExamName",
        NULL AS "ESTMPSSS_ObtainedGrade",
        ROUND((SUM("ESTMPSSS_ObtainedMarks") * 100) / SUM("ESTMPSSS_MaxMarks"), 0) AS "Percentages",
        3,
        "EYCES_SubjectOrder",
        "EYCES_MarksDisplayFlg",
        "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg",
        NULL AS "AMAY_RollNo",
        "EMSE_SubExamOrder"
    FROM "CTE_Exam"
    WHERE "Subject_Flag" = 1 AND "EYCES_MarksDisplayFlg" = TRUE
    GROUP BY "ISMS_Id", "ISMS_SubjectName", "AMST_Id", "Subject_Flag", "EYCES_SubjectOrder", 
        "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "EMSE_SubExamOrder"
    ORDER BY "AMST_Id", "EYCES_SubjectOrder", "EME_Id", "Subject_Flag", "AMAY_RollNo", "EMSE_SubExamOrder";

    DROP TABLE IF EXISTS "#CBS_Temp_StudentDetails";
    DROP TABLE IF EXISTS "#CBS_Temp_StudentDetailsNew";

    CREATE TEMP TABLE "#CBS_Temp_StudentDetails" AS
    SELECT DISTINCT 
        "EME_Id",
        "ISMS_Id", 
        "EMSE_SubExamName",
        "EYCES_SubjectOrder",
        "ISMS_SubjectName",
        "Subject_Flag",
        "EMSE_SubExamOrder"
    FROM "CBS_Temp_StudentDetails"
    ORDER BY "EYCES_SubjectOrder", "EME_Id", "Subject_Flag", "EMSE_SubExamOrder";

    CREATE TEMP TABLE "#CBS_Temp_StudentDetailsNew" AS
    SELECT  
        "Y"."AMST_Id",
        "EME_Id",
        "ISMS_Id", 
        "EMSE_SubExamName",
        "EYCES_SubjectOrder",
        "ISMS_SubjectName",
        "Subject_Flag",
        "EMSE_SubExamOrder"
    FROM "#CBS_Temp_StudentDetails" a
    CROSS JOIN "Adm_School_Y_Student" "Y"
    WHERE "Y"."ASMAY_Id" = "@ASMAY_Id" 
        AND "Y"."ASMCL_Id" = "@ASMCL_Id" 
        AND "Y"."ASMS_Id" = "@ASMS_Id";

    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        a."EME_Id",
        a."ISMS_Id", 
        a."EMSE_SubExamName",
        a."ISMS_SubjectName",
        a."Subject_Flag",
        b."EME_ExamName",
        b."ESTMPSSS_ObtainedGrade",
        b."ESTMPSSS_ObtainedMarks",
        a."EYCES_SubjectOrder",
        b."EYCES_MarksDisplayFlg",
        b."EYCES_GradeDisplayFlg",
        b."ESTMPSSS_PassFailFlg",
        b."AMAY_RollNo",
        a."EMSE_SubExamOrder"
    FROM "#CBS_Temp_StudentDetailsNew" a
    LEFT JOIN "CBS_Temp_StudentDetails" b ON a."AMST_Id" = b."AMST_Id" 
        AND a."EME_Id" = b."EME_Id" 
        AND a."ISMS_Id" = b."ISMS_Id"
        AND a."EMSE_SubExamName" = b."EMSE_SubExamName" 
        AND a."EYCES_SubjectOrder" = b."EYCES_SubjectOrder"
        AND a."ISMS_SubjectName" = b."ISMS_SubjectName" 
        AND a."Subject_Flag" = b."Subject_Flag"
    INNER JOIN "Adm_M_Student" "K" ON "K"."AMST_Id" = "A"."AMST_Id" 
        AND "K"."AMST_ActiveFlag" = 1 
        AND "K"."AMST_SOL" = 'S'
    ORDER BY a."AMST_Id", a."EYCES_SubjectOrder", a."EME_Id", a."Subject_Flag", a."EMSE_SubExamOrder";

END;
$$;