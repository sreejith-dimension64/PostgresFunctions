CREATE OR REPLACE FUNCTION "dbo"."BIS_Exam_ProgressCard_Report_Details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "EME_ExamName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_Id" BIGINT,
    "EMPSG_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_DisplayName" VARCHAR,
    "EMPSG_Order" INTEGER,
    "EME_ExamOrder" INTEGER,
    "EMPS_SubjOrder" INTEGER,
    "ObtainedMarks" NUMERIC,
    "ObtainedGrade" VARCHAR,
    "ObtainedGradePoints" NUMERIC,
    "PassFailFlag" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_EYC_Id" BIGINT;
    "v_EMCA_Id" BIGINT;
BEGIN

    SELECT "EMCA_Id" INTO "v_EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "p_MI_Id"::BIGINT 
        AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "p_ASMS_Id"::BIGINT
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO "v_EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "p_MI_Id"::BIGINT 
        AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
        AND "EMCA_Id" = "v_EMCA_Id" 
        AND "EYC_ActiveFlg" = 1;

    RETURN QUERY
    SELECT "TEMPMARKS"."AMST_Id", 
           "TEMPMARKS"."EME_Id", 
           "TEMPMARKS"."EME_ExamName", 
           "TEMPMARKS"."ISMS_SubjectName", 
           "TEMPMARKS"."ISMS_Id", 
           "TEMPMARKS"."EMPSG_Id", 
           "TEMPMARKS"."EMPSG_GroupName", 
           "TEMPMARKS"."EMPSG_DisplayName", 
           "TEMPMARKS"."EMPSG_Order", 
           "TEMPMARKS"."EME_ExamOrder", 
           "TEMPMARKS"."EMPS_SubjOrder", 
           "TEMPMARKS"."ObtainedMarks", 
           "TEMPMARKS"."ObtainedGrade", 
           "TEMPMARKS"."ObtainedGradePoints", 
           "TEMPMARKS"."PassFailFlag"
    FROM (
        SELECT DISTINCT A."AMST_Id", 
               B1."EME_Id", 
               H."EME_ExamName", 
               G."ISMS_SubjectName", 
               A."ISMS_Id", 
               B."EMPSG_Id", 
               C."EMPSG_GroupName", 
               C."EMPSG_DisplayName", 
               C."EMPSG_Order", 
               H."EME_ExamOrder", 
               E."EMPS_SubjOrder",
               B1."ESTMPPSGE_ExamConvertedMarks" AS "ObtainedMarks", 
               B1."ESTMPPSGE_ExamConvertedGrade" AS "ObtainedGrade", 
               B1."ESTMPPSGE_ExamConvertedPoints" AS "ObtainedGradePoints", 
               B1."ESTMPPSGE_ExamPassFailFlag" AS "PassFailFlag"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        WHERE A."MI_Id" = "p_MI_Id"::BIGINT 
            AND A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND F."EYC_Id" = "v_EYC_Id" 
            AND A."AMST_Id" = "p_AMST_Id"::BIGINT

        UNION

        SELECT DISTINCT A."AMST_Id", 
               9800000::BIGINT AS "EME_Id", 
               'Marks Obtained'::VARCHAR AS "EME_ExamName", 
               G."ISMS_SubjectName", 
               A."ISMS_Id", 
               B."EMPSG_Id", 
               C."EMPSG_GroupName", 
               C."EMPSG_DisplayName", 
               C."EMPSG_Order", 
               9800000 AS "EME_ExamOrder", 
               E."EMPS_SubjOrder",
               B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
               B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade", 
               B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
               ''::VARCHAR AS "PassFailFlag"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        WHERE A."MI_Id" = "p_MI_Id"::BIGINT 
            AND A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND F."EYC_Id" = "v_EYC_Id" 
            AND A."AMST_Id" = "p_AMST_Id"::BIGINT

        UNION

        SELECT DISTINCT A."AMST_Id", 
               9800001::BIGINT AS "EME_Id", 
               'Grade'::VARCHAR AS "EME_ExamName", 
               G."ISMS_SubjectName", 
               A."ISMS_Id", 
               B."EMPSG_Id", 
               C."EMPSG_GroupName", 
               C."EMPSG_DisplayName", 
               C."EMPSG_Order", 
               9800001 AS "EME_ExamOrder", 
               E."EMPS_SubjOrder",
               B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
               B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade", 
               B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
               ''::VARCHAR AS "PassFailFlag"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        WHERE A."MI_Id" = "p_MI_Id"::BIGINT 
            AND A."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND F."EYC_Id" = "v_EYC_Id" 
            AND A."AMST_Id" = "p_AMST_Id"::BIGINT
    ) AS "TEMPMARKS"
    WHERE "TEMPMARKS"."AMST_Id" = "p_AMST_Id"::BIGINT
    ORDER BY "TEMPMARKS"."EMPSG_Order", "TEMPMARKS"."EME_ExamOrder", "TEMPMARKS"."EMPS_SubjOrder";

    RETURN;

END;
$$;