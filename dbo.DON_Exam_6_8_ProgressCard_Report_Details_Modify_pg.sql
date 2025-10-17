CREATE OR REPLACE FUNCTION "dbo"."DON_Exam_6_8_ProgressCard_Report_Details_Modify"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "EME_ExamName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "EMPSG_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_DisplayName" VARCHAR,
    "EMPSG_Order" INTEGER,
    "EME_ExamOrder" INTEGER,
    "EMPS_SubjOrder" INTEGER,
    "ObtainedMarks" NUMERIC,
    "ObtainedGrade" VARCHAR,
    "ObtainedGradePoints" NUMERIC,
    "PassFailFlag" VARCHAR,
    "ESG_Id" VARCHAR,
    "Grouporder" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_IVRSSubjectName" VARCHAR,
    "ROWNUMBER" BIGINT,
    "GradeDisplay" BOOLEAN,
    "MarksDisplay" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
BEGIN
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = TRUE;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = TRUE;

    DROP TABLE IF EXISTS "St_ThomosTotalDetails";
    
    CREATE TEMPORARY TABLE "St_ThomosTotalDetails" AS
    SELECT * FROM (
        SELECT DISTINCT 
            A."AMST_Id", 
            B1."EME_Id",
            H."EME_ExamName", 
            G."ISMS_SubjectName", 
            B."EMPSG_Id", 
            C."EMPSG_GroupName",
            C."EMPSG_DisplayName", 
            C."EMPSG_Order",
            H."EME_ExamOrder",
            E."EMPS_SubjOrder",
            I."ESTMPS_ObtainedMarks" AS "ObtainedMarks",
            I."ESTMPS_ObtainedGrade" AS "ObtainedGrade",
            B1."ESTMPPSGE_ExamConvertedPoints" AS "ObtainedGradePoints",
            (CASE WHEN E."EMPS_ConvertForMarks" != E."EMPS_MaxMarks" AND B1."ESTMPPSGE_ExamPassFailFlag" = 'AB' 
                  THEN ' ' 
                  ELSE B1."ESTMPPSGE_ExamPassFailFlag" END) AS "PassFailFlag",
            '' AS "ESG_Id",
            '' AS "Grouporder",
            A."ISMS_Id",
            G."ISMS_IVRSSubjectName"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" I ON I."MI_Id" = A."MI_Id" 
            AND I."ASMAY_Id" = A."ASMAY_Id" 
            AND I."ASMCL_Id" = A."ASMCL_Id" 
            AND I."ASMS_Id" = A."ASMS_Id"
            AND I."AMST_Id" = A."AMST_Id" 
            AND I."ISMS_Id" = A."ISMS_Id" 
            AND I."EME_Id" = D."EME_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND F."EYC_Id" = v_EYC_Id 
            AND A."AMST_Id"::TEXT = ANY(string_to_array(p_AMST_Id, ','))
        ORDER BY C."EMPSG_Order", H."EME_ExamOrder", E."EMPS_SubjOrder"
        LIMIT 100

        UNION

        SELECT DISTINCT 
            A."AMST_Id", 
            9800000 AS "EME_Id",
            'Marks Obtained' AS "EME_ExamName", 
            G."ISMS_SubjectName", 
            B."EMPSG_Id",
            C."EMPSG_GroupName", 
            C."EMPSG_DisplayName",
            C."EMPSG_Order", 
            9800000 AS "EME_ExamOrder",
            E."EMPS_SubjOrder",
            (CASE WHEN E."EMPS_ConvertForMarks" = E."EMPS_MaxMarks" 
                  THEN B."ESTMPPSG_GroupObtMarks" 
                  ELSE B."ESTMPPSG_GroupObtMarks" / 2 END) AS "ObtainedMarks",
            B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",
            B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints",
            (CASE WHEN B."ESTMPPSG_GroupObtMarks" > 0 
                  THEN '' 
                  ELSE B1."ESTMPPSGE_ExamPassFailFlag" END) AS "PassFailFlag",
            '' AS "ESG_Id",
            '' AS "Grouporder",
            A."ISMS_Id",
            G."ISMS_IVRSSubjectName"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND F."EYC_Id" = v_EYC_Id 
            AND A."AMST_Id"::TEXT = ANY(string_to_array(p_AMST_Id, ','))
        ORDER BY C."EMPSG_Order", 9800000, E."EMPS_SubjOrder"
        LIMIT 100

        UNION

        SELECT DISTINCT 
            M."AMST_Id",
            9800001 AS "EME_Id",
            'AVG' AS "EME_ExamName",
            M."ISMS_SubjectName",
            B."EMPSG_Id",
            C."EMPSG_GroupName", 
            C."EMPSG_DisplayName",
            C."EMPSG_Order", 
            9800001 AS "EME_ExamOrder",
            E."EMPS_SubjOrder",
            (CASE WHEN E."EMPS_ConvertForMarks" = E."EMPS_MaxMarks" 
                  THEN M."ESTMPPSG_GroupObtMarks" 
                  ELSE M."ESTMPPSG_GroupObtMarks" / 2 END) AS "ObtainedMarks",
            B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",
            B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints",
            '' AS "PassFailFlag",
            M."ESG_Id",
            M."grporder" AS "Grouporder",
            (CASE WHEN M."grporder"::INTEGER > 1000 
                  THEN M."grporder"::BIGINT 
                  ELSE M."ISMS_Id" END) AS "ISMS_Id",
            G."ISMS_IVRSSubjectName"
        FROM "stjames_temp_promotion_details" M
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" A ON M."AMST_Id" = A."AMST_Id" AND A."ISMS_Id" = M."ISMS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id" AND M."EMPSG_DisplayName" = C."EMPSG_DisplayName"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        WHERE A."MI_Id" = p_MI_Id::BIGINT 
            AND M."EMPSG_GroupName" != 'Final Average'
            AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            AND F."EYC_Id" = v_EYC_Id 
            AND M."complusoryflag" != 'C'
            AND A."AMST_Id"::TEXT = ANY(string_to_array(p_AMST_Id, ','))
    ) AS "TEMPMARKS"
    ORDER BY "EMPSG_Order", "EME_ExamOrder", "EMPS_SubjOrder";

    RETURN QUERY
    SELECT 
        A."AMST_Id",
        A."EME_Id",
        A."EME_ExamName",
        A."ISMS_SubjectName",
        A."EMPSG_Id",
        A."EMPSG_GroupName",
        A."EMPSG_DisplayName",
        A."EMPSG_Order",
        A."EME_ExamOrder",
        A."EMPS_SubjOrder",
        A."ObtainedMarks",
        A."ObtainedGrade",
        A."ObtainedGradePoints",
        A."PassFailFlag",
        A."ESG_Id",
        A."Grouporder",
        A."ISMS_Id",
        A."ISMS_IVRSSubjectName",
        A."ROWNUMBER",
        A."GradeDisplay",
        A."MarksDisplay"
    FROM (
        SELECT 
            a."AMST_Id",
            a."EME_Id",
            a."EME_ExamName",
            a."ISMS_SubjectName",
            a."EMPSG_Id",
            a."EMPSG_GroupName",
            a."EMPSG_DisplayName",
            a."EMPSG_Order",
            a."EME_ExamOrder",
            a."EMPS_SubjOrder",
            a."ObtainedMarks",
            a."ObtainedGrade",
            a."ObtainedGradePoints",
            a."PassFailFlag",
            a."ESG_Id",
            a."Grouporder",
            a."ISMS_Id",
            a."ISMS_IVRSSubjectName",
            ROW_NUMBER() OVER (PARTITION BY a."AMST_Id", a."EME_Id", a."EME_ExamName", a."ISMS_SubjectName", a."EMPSG_Id", a."EMPSG_GroupName" 
                              ORDER BY a."PassFailFlag" DESC) AS "ROWNUMBER",
            c."EYCES_GradeDisplayFlg" AS "GradeDisplay",
            c."EYCES_MarksDisplayFlg" AS "MarksDisplay"
        FROM "St_ThomosTotalDetails" a 
        INNER JOIN "exm"."Exm_Yearly_Category_Exams" b ON a."EME_Id" = b."EME_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id" AND c."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" d ON d."EYC_Id" = b."EYC_Id" AND d."EYC_Id" = v_EYC_Id
    ) A  
    WHERE A."ROWNUMBER" = 1 
    ORDER BY A."EMPSG_Order", A."EME_ExamOrder", A."EMPS_SubjOrder";

END;
$$;