CREATE OR REPLACE FUNCTION "dbo"."Exam_Promotion_Cumulative_ExamWiseTotal_Report_Format2"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "ESTMPPSGE_ExamConvertedMaxMarks" NUMERIC,
    "ESTMPPSGE_ExamConvertedMarks" NUMERIC,
    "ExamPercentage" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@SqlDynamic" TEXT;
    "@EMCA_Id" TEXT;
    "@EYC_Id" TEXT;
BEGIN

    SELECT DISTINCT "EMCA_Id"::TEXT INTO "@EMCA_Id"
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
    AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
    AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
    AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
    AND "ECAC_ActiveFlag" = TRUE;

    SELECT DISTINCT "EYC_Id"::TEXT INTO "@EYC_Id"
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
    AND "MI_Id" = "@MI_Id"::BIGINT 
    AND "EYC_ActiveFlg" = TRUE 
    AND "EMCA_Id" = "@EMCA_Id"::BIGINT;

    RETURN QUERY
    SELECT 
        "New"."AMST_Id",
        "New"."EME_Id",
        SUM("New"."ESTMPPSGE_ExamConvertedMaxMarks") AS "ESTMPPSGE_ExamConvertedMaxMarks",
        SUM("New"."ESTMPPSGE_ExamConvertedMarks") AS "ESTMPPSGE_ExamConvertedMarks",
        CAST(
            (SUM("New"."ESTMPPSGE_ExamConvertedMarks") / 
            NULLIF(COALESCE(SUM("New"."ESTMPPSGE_ExamConvertedMaxMarks"), 0), 0)) * 100 
            AS NUMERIC(18,2)
        ) AS "ExamPercentage"
    FROM (
        SELECT 
            "ESMPS"."AMST_Id",
            "ESMPSGE"."EME_Id",
            COALESCE("ESMPSGE"."ESTMPPSGE_ExamConvertedMaxMarks", 0) AS "ESTMPPSGE_ExamConvertedMaxMarks",
            COALESCE("ESMPSGE"."ESTMPPSGE_ExamConvertedMarks", 0) AS "ESTMPPSGE_ExamConvertedMarks"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "ESMPSG" 
            ON "ESMPSG"."ESTMPPS_Id" = "ESMPS"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" "ESMPSGE" 
            ON "ESMPSGE"."ESTMPPSG_Id" = "ESMPSG"."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" 
            ON "EMPS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        INNER JOIN "Exm"."EXM_MASTER_EXAM" "EME" 
            ON "EME"."EME_Id" = "ESMPSGE"."EME_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" "EMP" 
            ON "EMP"."EMP_Id" = "EMPS"."EMP_Id" 
            AND "EMP"."EYC_Id" = "@EYC_Id"::BIGINT
        WHERE "ESMPS"."MI_Id" = "@MI_Id"::BIGINT 
        AND "ESMPS"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ESMPS"."ASMCL_Id" = ANY(STRING_TO_ARRAY("@ASMCL_Id", ',')::BIGINT[])
        AND "ESMPS"."ASMS_Id" = ANY(STRING_TO_ARRAY("@ASMS_Id", ',')::BIGINT[])
        AND "ESMPS"."AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
        AND "EMPS"."EMPS_ActiveFlag" = TRUE 
        AND "EMPS"."EMPS_AppToResultFlg" = TRUE
    ) AS "New" 
    GROUP BY "New"."AMST_Id", "New"."EME_Id";

END;
$$;