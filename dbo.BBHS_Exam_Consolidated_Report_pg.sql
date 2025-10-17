CREATE OR REPLACE FUNCTION "dbo"."BBHS_Exam_Consolidated_Report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "EME_Id" INTEGER,
    "ESTMPPSGE_ExamConvertedMaxMarks" NUMERIC,
    "ESTMPPSGE_ExamConvertedMarks" NUMERIC,
    "ExamPercentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
BEGIN
    "SqlDynamic" := '
    SELECT "AMST_Id", "EME_Id", 
           SUM("ESTMPPSGE_ExamConvertedMaxMarks") AS "ESTMPPSGE_ExamConvertedMaxMarks",
           SUM("ESTMPPSGE_ExamConvertedMarks") AS "ESTMPPSGE_ExamConvertedMarks",
           ((SUM("ESTMPPSGE_ExamConvertedMarks") / NULLIF(COALESCE(SUM("ESTMPPSGE_ExamConvertedMaxMarks"), 0), 0)) * 100) AS "ExamPercentage"
    FROM (
        SELECT DISTINCT "ESMPS"."AMST_Id", 
               "ESMPSGE"."EME_Id",
               COALESCE("ESTMPPSGE_ExamConvertedMaxMarks", 0) AS "ESTMPPSGE_ExamConvertedMaxMarks",
               COALESCE("ESTMPPSGE_ExamConvertedMarks", 0) AS "ESTMPPSGE_ExamConvertedMarks"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "ESMPSG" 
            ON "ESMPSG"."ESTMPPS_Id" = "ESMPS"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" "ESMPSGE" 
            ON "ESMPSGE"."ESTMPPSG_Id" = "ESMPSG"."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" 
            ON "EMPS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        WHERE "ESMPS"."MI_Id" = ' || "MI_Id" || ' 
          AND "ESMPS"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
          AND "ESMPS"."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
          AND "ESMPS"."ASMS_Id" IN (' || "ASMS_Id" || ') 
          AND "ESMPS"."AMST_Id" IN (' || "AMST_Id" || ') 
          AND "EMPS"."EMPS_ActiveFlag" = 1 
          AND "EMPS"."EMPS_AppToResultFlg" = 1
    ) AS "New" 
    GROUP BY "AMST_Id", "EME_Id"';

    RETURN QUERY EXECUTE "SqlDynamic";
END;
$$;