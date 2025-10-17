CREATE OR REPLACE FUNCTION "dbo"."Exam_Promotion_Cumulative_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_FLAG" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "EMPSG_Id" INTEGER,
    "EMPSG_GroupName" TEXT,
    "EMPSG_DisplayName" TEXT,
    "ESTMPPSG_GroupMaxMarks" NUMERIC,
    "ESTMPPSG_GroupObtMarks" NUMERIC,
    "ESTMPPSG_GroupObtGrade" TEXT,
    "ESTMPPSG_GradePoints" NUMERIC,
    "EMPS_SubjOrder" INTEGER,
    "EME_Id" INTEGER,
    "EME_ExamName" TEXT,
    "ESTMPS_MaxMarks" NUMERIC,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_ObtainedGrade" TEXT,
    "ESTMPS_PassFailFlg" TEXT,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_EMCA_Id" TEXT;
    "v_EYC_Id" TEXT;
BEGIN
    
    SELECT DISTINCT "EMCA_Id" INTO "v_EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "p_MI_Id"::INTEGER 
    AND "ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
    AND "ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
    AND "ASMS_Id" = "p_ASMS_Id"::INTEGER 
    AND "ECAC_ActiveFlag" = 1;

    SELECT DISTINCT "EYC_Id" INTO "v_EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
    AND "MI_Id" = "p_MI_Id"::INTEGER 
    AND "EYC_ActiveFlg" = 1 
    AND "EMCA_Id" = "v_EMCA_Id"::INTEGER;

    IF "p_FLAG" = 'P' OR "p_FLAG" = 'M' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id", 
            A."ISMS_Id", 
            D."ISMS_SubjectName", 
            B."EMPSG_Id", 
            C."EMPSG_GroupName", 
            C."EMPSG_DisplayName", 
            B."ESTMPPSG_GroupMaxMarks",
            B."ESTMPPSG_GroupObtMarks", 
            B."ESTMPPSG_GroupObtGrade", 
            B."ESTMPPSG_GradePoints",
            CASE WHEN J."EMPS_SubjOrder" IS NULL THEN D."ISMS_OrderFlag" ELSE J."EMPS_SubjOrder" END AS "EMPS_SubjOrder",
            NULL::INTEGER AS "EME_Id",
            NULL::TEXT AS "EME_ExamName",
            NULL::NUMERIC AS "ESTMPS_MaxMarks",
            NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
            NULL::TEXT AS "ESTMPS_ObtainedGrade",
            NULL::TEXT AS "ESTMPS_PassFailFlg",
            NULL::INTEGER AS "EYCES_SubjectOrder",
            NULL::BOOLEAN AS "EYCES_AplResultFlg",
            NULL::BOOLEAN AS "EYCES_MarksDisplayFlg",
            NULL::BOOLEAN AS "EYCES_GradeDisplayFlg"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id" AND C."EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_MASTER_SUBJECTS" D ON D."ISMS_Id" = A."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" E ON E."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id" = E."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "ADM_SCHOOL_M_CLASS" H ON H."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "ADM_SCHOOL_M_SECTION" I ON I."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" J ON J."EMPS_Id" = C."EMPS_Id" AND J."ISMS_Id" = D."ISMS_Id" AND J."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" K ON K."EMP_Id" = J."EMP_Id" AND K."EMP_ActiveFlag" = 1 AND K."EYC_Id" = "v_EYC_Id"::INTEGER
        INNER JOIN "EXM"."Exm_Yearly_Category" L ON L."EYC_Id" = K."EYC_Id" AND L."EYC_ActiveFlg" = 1 AND L."ASMAY_Id" = "p_ASMAY_Id"::INTEGER AND L."EYC_Id" = "v_EYC_Id"::INTEGER
        INNER JOIN "Exm"."Exm_Category_Class" M ON M."EMCA_Id" = L."EMCA_Id" AND M."ASMAY_Id" = "p_ASMAY_Id"::INTEGER AND M."ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
            AND M."ASMS_Id" = "p_ASMS_Id"::INTEGER AND M."ECAC_ActiveFlag" = 1 AND M."EMCA_Id" = "v_EMCA_Id"::INTEGER
        WHERE A."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
        AND A."ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
        AND A."ASMS_Id" = "p_ASMS_Id"::INTEGER 
        AND A."MI_Id" = "p_MI_Id"::INTEGER
        AND E."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
        AND E."ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
        AND E."ASMS_Id" = "p_ASMS_Id"::INTEGER
        AND C."EMPSG_ActiveFlag" = 1 
        AND E."AMAY_ActiveFlag" = 1 
        AND F."AMST_SOL" = 'S' 
        AND F."AMST_ActiveFlag" = 1
        ORDER BY "EMPS_SubjOrder";

    ELSIF "p_FLAG" = 'T' THEN
        RETURN QUERY
        SELECT 
            A."AMST_Id",
            A."ISMS_Id", 
            A."EME_Id", 
            H."ISMS_SubjectName", 
            NULL::INTEGER AS "EMPSG_Id",
            NULL::TEXT AS "EMPSG_GroupName",
            NULL::TEXT AS "EMPSG_DisplayName",
            NULL::NUMERIC AS "ESTMPPSG_GroupMaxMarks",
            NULL::NUMERIC AS "ESTMPPSG_GroupObtMarks",
            NULL::TEXT AS "ESTMPPSG_GroupObtGrade",
            NULL::NUMERIC AS "ESTMPPSG_GradePoints",
            NULL::INTEGER AS "EMPS_SubjOrder",
            G."EME_ExamName",
            A."ESTMPS_MaxMarks", 
            A."ESTMPS_ObtainedMarks", 
            A."ESTMPS_ObtainedGrade", 
            A."ESTMPS_PassFailFlg",
            J."EYCES_SubjectOrder", 
            J."EYCES_AplResultFlg", 
            J."EYCES_MarksDisplayFlg", 
            J."EYCES_GradeDisplayFlg"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = B."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" G ON G."EME_Id" = A."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" H ON H."ISMS_Id" = A."ISMS_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" I ON I."EME_Id" = G."EME_Id" AND I."EYCE_ActiveFlg" = 1 AND I."EYC_Id" = "v_EYC_Id"::INTEGER
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" J ON J."EYCE_Id" = I."EYCE_Id" AND J."ISMS_Id" = H."ISMS_Id" AND J."EYCES_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Yearly_Category" K ON K."EYC_Id" = I."EYC_Id" AND K."EYC_ActiveFlg" = 1 AND K."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
            AND K."MI_Id" = "p_MI_Id"::INTEGER AND K."EYC_Id" = "v_EYC_Id"::INTEGER
        INNER JOIN "Exm"."Exm_Category_Class" L ON L."EMCA_Id" = K."EMCA_Id" AND L."ECAC_ActiveFlag" = 1 AND L."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
            AND L."ASMCL_Id" = "p_ASMCL_Id"::INTEGER AND L."ASMS_Id" = "p_ASMS_Id"::INTEGER AND L."EMCA_Id" = "v_EMCA_Id"::INTEGER
        WHERE A."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
        AND A."ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
        AND A."ASMS_Id" = "p_ASMS_Id"::INTEGER
        AND B."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
        AND B."ASMCL_Id" = "p_ASMCL_Id"::INTEGER 
        AND B."ASMS_Id" = "p_ASMS_Id"::INTEGER 
        AND B."AMAY_ActiveFlag" = 1
        AND C."AMST_SOL" = 'S' 
        AND C."AMST_ActiveFlag" = 1
        ORDER BY "EYCES_SubjectOrder";

    END IF;

    RETURN;
END;
$$;