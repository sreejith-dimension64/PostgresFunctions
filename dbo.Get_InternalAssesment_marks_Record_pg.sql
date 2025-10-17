CREATE OR REPLACE FUNCTION "dbo"."Get_InternalAssesment_marks_Record"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@AMST_Id" bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "EME_Id" bigint,
    "EMSE_Id" bigint,
    "EME_ExamName" VARCHAR,
    "EMSE_SubExamName" VARCHAR,
    "ESTMPSSS_ObtainedMarks" NUMERIC,
    "MaxMarks" NUMERIC,
    "ESTMPS_PassFailFlg" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH a AS (
        SELECT 
            a."EMSE_Id",
            b."EME_Id",
            b."ISMS_Id",
            a."ESTMPSSS_PassFailFlg"
        FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" AS a
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id" = b."ESTMPS_Id"
        WHERE a."ESTMPS_Id" IN (
            SELECT "ESTMPS_Id" 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = "@MI_Id" 
                AND "ASMAY_Id" = "@ASMAY_Id" 
                AND "ASMCL_Id" = "@ASMCL_Id" 
                AND "ASMS_Id" = "@ASMS_Id" 
                AND "AMST_Id" = "@AMST_Id"
        )
    ),
    b AS (
        SELECT 
            b."ISMS_Id",
            b."EME_Id",
            a."EMSE_Id",
            d."EME_ExamName",
            c."EMSE_SubExamName",
            SUM(a."ESTMPSSS_ObtainedMarks") AS "ESTMPSSS_ObtainedMarks",
            SUM(a."ESTMPSSS_MaxMarks") AS "MaxMarks"
        FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" AS a
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id" = b."ESTMPS_Id"
        INNER JOIN "Exm"."Exm_Master_SubExam" AS c ON a."EMSE_Id" = c."EMSE_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" AS d ON b."EME_Id" = d."EME_Id"
        WHERE a."ESTMPS_Id" IN (
            SELECT "ESTMPS_Id" 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = "@MI_Id" 
                AND "ASMAY_Id" = "@ASMAY_Id" 
                AND "ASMCL_Id" = "@ASMCL_Id" 
                AND "ASMS_Id" = "@ASMS_Id" 
                AND "AMST_Id" = "@AMST_Id"
        )
        GROUP BY b."ISMS_Id", b."EME_Id", a."EMSE_Id", d."EME_ExamName", c."EMSE_SubExamName"
    )
    SELECT DISTINCT 
        b."ISMS_Id",
        b."EME_Id",
        a."EMSE_Id",
        b."EME_ExamName",
        b."EMSE_SubExamName",
        b."ESTMPSSS_ObtainedMarks",
        b."MaxMarks",
        a."ESTMPSSS_PassFailFlg" AS "ESTMPS_PassFailFlg"
    FROM a, b 
    WHERE a."ISMS_Id" = b."ISMS_Id" 
        AND a."EME_Id" = b."EME_Id" 
        AND a."EMSE_Id" = b."EMSE_Id";
END;
$$;