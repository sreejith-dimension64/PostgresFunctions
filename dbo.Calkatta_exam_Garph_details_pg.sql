CREATE OR REPLACE FUNCTION "dbo"."Calkatta_exam_Garph_details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_AMST_Id TEXT,
    p_EMPG_GroupName TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "EME_ExamName" TEXT,
    "ISMS_SubjectName" TEXT,
    "ISMS_Id" BIGINT,
    "EMPSG_Id" BIGINT,
    "EMPSG_GroupName" TEXT,
    "EMPSG_DisplayName" TEXT,
    "EMPSG_Order" INTEGER,
    "EME_ExamOrder" BIGINT,
    "EMPS_SubjOrder" INTEGER,
    "ObtainedMarks" NUMERIC,
    "ObtainedGrade" TEXT,
    "ObtainedGradePoints" NUMERIC,
    "PassFailFlag" TEXT,
    "ESTMPPS_ClassHighest" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
    v_SQLQUERY TEXT;
BEGIN
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id"::BIGINT = p_MI_Id::BIGINT 
        AND "ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT 
        AND "ECAC_ActiveFlag" = true;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id"::BIGINT = p_MI_Id::BIGINT 
        AND "ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = true;

    DROP TABLE IF EXISTS "Calkatta_Temp_StudentDetails_Amstids";

    v_SQLQUERY := 'CREATE TEMP TABLE "Calkatta_Temp_StudentDetails_Amstids" AS 
                   SELECT DISTINCT "AMST_Id" 
                   FROM "ADM_M_STUDENT" 
                   WHERE "AMST_Id" IN(' || p_AMST_Id || ') 
                   AND "MI_Id" = ' || p_MI_Id;
    
    EXECUTE v_SQLQUERY;

    IF p_EMPG_GroupName != '' THEN
        IF p_FLAG = '1' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                98000012::BIGINT AS "EME_Id",
                'Highest in Class'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800001::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                A."ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND C."EMPSG_GroupName" = p_EMPG_GroupName
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        ELSIF p_FLAG = '2' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                98000012::BIGINT AS "EME_Id",
                'Highest in Class'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800001::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                A."ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND C."EMPSG_GroupName" = p_EMPG_GroupName
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        ELSIF p_FLAG = '3' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                9800000::BIGINT AS "EME_Id",
                'Marks Obtained'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800000::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                0::NUMERIC AS "ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND C."EMPSG_GroupName" = p_EMPG_GroupName
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        END IF;
    ELSE
        IF p_FLAG = '1' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                98000012::BIGINT AS "EME_Id",
                'Highest in Class'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800001::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                A."ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        ELSIF p_FLAG = '2' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                98000012::BIGINT AS "EME_Id",
                'Highest in Class'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800001::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                A."ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        ELSIF p_FLAG = '3' THEN
            RETURN QUERY
            SELECT DISTINCT A."AMST_Id", 
                9800000::BIGINT AS "EME_Id",
                'Marks Obtained'::TEXT AS "EME_ExamName", 
                G."ISMS_SubjectName", 
                A."ISMS_Id", 
                B."EMPSG_Id",   
                C."EMPSG_GroupName", 
                C."EMPSG_DisplayName",
                C."EMPSG_Order", 
                9800000::BIGINT AS "EME_ExamOrder",
                E."EMPS_SubjOrder",  
                B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", 
                B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",   
                B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", 
                ''::TEXT AS "PassFailFlag",
                0::NUMERIC AS "ESTMPPS_ClassHighest"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A   
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"  
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"  
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"  
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"  
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"  
            WHERE A."MI_Id"::BIGINT = p_MI_Id::BIGINT 
                AND A."ASMAY_Id"::BIGINT = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id"::BIGINT = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id"::BIGINT = p_ASMS_Id::BIGINT  
                AND F."EYC_Id" = v_EYC_Id 
                AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "Calkatta_Temp_StudentDetails_Amstids")  
            ORDER BY E."EMPS_SubjOrder"
            LIMIT 100;
        END IF;
    END IF;

    RETURN;
END;
$$;