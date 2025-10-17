CREATE OR REPLACE FUNCTION "Exm"."Exam_BBHS_Student_SubjectWise_Details_Ind"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "EME_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_DisplayName" VARCHAR,
    "AMST_Id" BIGINT,
    "ObtainedMarks" NUMERIC,
    "TotalMarks" NUMERIC,
    "TotalPercentage" NUMERIC(18,2),
    "EMGD_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_SQLQUERY TEXT;
BEGIN

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = 1
    LIMIT 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1
    LIMIT 1;

    DROP TABLE IF EXISTS "NDS_Temp_StudentDetails_Amstids";

    v_SQLQUERY := 'CREATE TEMP TABLE "NDS_Temp_StudentDetails_Amstids" AS 
                   SELECT DISTINCT "AMST_Id" 
                   FROM "ADM_M_STUDENT" 
                   WHERE "AMST_Id" IN (' || p_AMST_Id || ') 
                   AND "MI_Id" = ' || p_MI_Id;
    
    EXECUTE v_SQLQUERY;

    RETURN QUERY
    SELECT * FROM (
        SELECT 
            E."EME_Id",
            C."EMPSG_GroupName",
            C."EMPSG_DisplayName",
            G."AMST_Id",
            SUM(E."ESTMPPSGE_ExamConvertedMarks") AS "ObtainedMarks",
            SUM(D."EMPSGE_ForMaxMarkrs") AS "TotalMarks",
            CAST((SUM(E."ESTMPPSGE_ExamConvertedMarks") * 100.0 / NULLIF(SUM(D."EMPSGE_ForMaxMarkrs"), 0)) AS NUMERIC(18,2)) AS "TotalPercentage",
            Fn."ESTMP_TotalGrade" AS "EMGD_Name"
        FROM "Exm"."Exm_M_Promotion" A
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" E ON E."EME_Id" = D."EME_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" F ON F."EMPSG_Id" = C."EMPSG_Id" 
            AND F."ESTMPPSG_Id" = E."ESTMPPSG_Id" AND F."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" G ON G."ESTMPPS_Id" = F."ESTMPPS_Id" 
            AND B."ISMS_Id" = G."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND H."EME_Id" = E."EME_Id"
        INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = G."ASMAY_Id" 
            AND I."ASMCL_Id" = G."ASMCL_Id" AND I."ASMS_Id" = G."ASMS_Id" AND I."AMST_Id" = G."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" Fn ON Fn."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND Fn."ASMS_Id" = p_ASMS_Id::BIGINT
            AND Fn."ASMCL_Id" = p_ASMCL_Id::BIGINT AND G."AMST_Id" = Fn."AMST_Id" AND Fn."EME_Id" = H."EME_Id"
        WHERE G."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND G."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND G."ASMS_Id" = p_ASMS_Id::BIGINT 
            AND I."ASMAY_Id" = p_ASMAY_Id::BIGINT
            AND I."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND I."ASMS_Id" = p_ASMS_Id::BIGINT
            AND B."EMPS_AppToResultFlg" = 1 
            AND A."EYC_Id" = v_EYC_Id 
            AND H."EME_ActiveFlag" = 1
            AND G."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        GROUP BY E."EME_Id", C."EMPSG_GroupName", C."EMPSG_DisplayName", G."AMST_Id", A."EMGR_Id", Fn."ESTMP_TotalGrade"

        UNION

        SELECT 
            9800000::BIGINT AS "EME_Id",
            F."EMPSG_GroupName",
            F."EMPSG_DisplayName",
            C."AMST_Id",
            SUM(B."ESTMPPSG_GroupTotalMarks") AS "ObtainedMarks",
            SUM(B."ESTMPPSG_GroupMaxMarks") AS "TotalMarks",
            CAST((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) AS NUMERIC(18,2)) AS "TotalPercentage",
            (SELECT L."EMGD_Name"
             FROM "Exm"."Exm_Master_Grade_Details" AS L
             WHERE ((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                    BETWEEN L."EMGD_From" AND L."EMGD_To" AND L."EMGR_Id" = H."EMGR_Id")
                OR ((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                    BETWEEN L."EMGD_To" AND L."EMGD_From" AND L."EMGR_Id" = H."EMGR_Id")
             LIMIT 1) AS "EMGD_Name"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" AND F."EMPSG_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" 
            AND G."EMPS_AppToResultFlg" = 1 AND G."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" 
            AND H."EMP_ActiveFlag" = 1 AND H."EYC_Id" = v_EYC_Id
        WHERE C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND C."ASMS_Id" = p_ASMS_Id::BIGINT
            AND C."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        GROUP BY F."EMPSG_GroupName", F."EMPSG_DisplayName", C."AMST_Id", H."EMGR_Id"

        UNION

        SELECT 
            9800001::BIGINT AS "EME_Id",
            F."EMPSG_GroupName",
            F."EMPSG_DisplayName",
            C."AMST_Id",
            SUM(B."ESTMPPSG_GroupTotalMarks") AS "ObtainedMarks",
            SUM(B."ESTMPPSG_GroupMaxMarks") AS "TotalMarks",
            CAST((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) AS NUMERIC(18,2)) AS "TotalPercentage",
            (SELECT L."EMGD_Name"
             FROM "Exm"."Exm_Master_Grade_Details" AS L
             WHERE ((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                    BETWEEN L."EMGD_From" AND L."EMGD_To" AND L."EMGR_Id" = H."EMGR_Id")
                OR ((SUM(B."ESTMPPSG_GroupTotalMarks") * 100.0 / NULLIF(SUM(B."ESTMPPSG_GroupMaxMarks"), 0)) 
                    BETWEEN L."EMGD_To" AND L."EMGD_From" AND L."EMGR_Id" = H."EMGR_Id")
             LIMIT 1) AS "EMGD_Name"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" AND F."EMPSG_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" 
            AND G."EMPS_AppToResultFlg" = 1 AND G."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" 
            AND H."EMP_ActiveFlag" = 1 AND H."EYC_Id" = v_EYC_Id
        WHERE C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND C."ASMS_Id" = p_ASMS_Id::BIGINT
            AND C."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        GROUP BY F."EMPSG_GroupName", F."EMPSG_DisplayName", C."AMST_Id", H."EMGR_Id"
    ) AS D 
    ORDER BY "AMST_Id";

END;
$$;