CREATE OR REPLACE FUNCTION "dbo"."Exam_BBHS_Student_SubjectWise__StTabular"(
    @MI_Id TEXT,
    @ASMAY_Id TEXT,
    @ASMCL_Id TEXT,
    @ASMS_Id TEXT,
    @AMST_Id TEXT,
    @EMPG_GroupName TEXT
)
RETURNS TABLE (
    "EME_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_DisplayName" VARCHAR,
    "AMST_Id" BIGINT,
    "ObtainedMarks" NUMERIC,
    "TotalMarks" NUMERIC,
    "TotalPercentage" NUMERIC(18,2),
    "EMGD_Name" VARCHAR,
    "ESTMPP_SectionRank" INTEGER
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
    WHERE "MI_Id" = @MI_Id::BIGINT 
        AND "ASMAY_Id" = @ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = @ASMCL_Id::BIGINT 
        AND "ASMS_Id" = @ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = @MI_Id::BIGINT 
        AND "ASMAY_Id" = @ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;

    DROP TABLE IF EXISTS "NDS_Temp_StudentDetails_Amstids";

    v_SQLQUERY := 'CREATE TEMP TABLE "NDS_Temp_StudentDetails_Amstids" AS 
                   SELECT DISTINCT "AMST_Id" 
                   FROM "ADM_M_STUDENT" 
                   WHERE "AMST_Id" IN (' || @AMST_Id || ') 
                   AND "MI_Id" = ' || @MI_Id;
    
    EXECUTE v_SQLQUERY;

    RETURN QUERY
    SELECT * FROM (
        SELECT 
            E."EME_Id",
            "EMPSG_GroupName",
            "EMPSG_DisplayName",
            G."AMST_Id",
            SUM("ESTMPPSGE_ExamConvertedMarks") AS "ObtainedMarks",
            SUM("EMPSGE_ForMaxMarkrs") AS "TotalMarks",
            CAST((SUM("ESTMPPSGE_ExamConvertedMarks") * 100.0 / SUM("EMPSGE_ForMaxMarkrs")) AS NUMERIC(18,2)) AS "TotalPercentage",
            Fn."ESTMP_TotalGrade" AS "EMGD_Name",
            I."ESTMPP_SectionRank"
        FROM "Exm"."Exm_M_Promotion" A
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id" 
            AND C."EMPSG_GroupName" = @EMPG_GroupName
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "EXM"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" E ON E."EME_Id" = D."EME_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" F ON F."EMPSG_Id" = C."EMPSG_Id" 
            AND F."ESTMPPSG_Id" = E."ESTMPPSG_Id" AND F."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" G ON G."ESTMPPS_Id" = F."ESTMPPS_Id" 
            AND B."ISMS_Id" = G."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND H."EME_Id" = E."EME_Id"
        INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = G."ASMAY_Id" 
            AND I."ASMCL_Id" = G."ASMCL_Id" AND I."ASMS_Id" = G."ASMS_Id" AND I."AMST_Id" = G."AMST_Id"
        INNER JOIN "EXM"."Exm_Student_Marks_Process" FN ON FN."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND FN."ASMS_Id" = @ASMS_Id::BIGINT AND FN."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND G."AMST_Id" = FN."AMST_Id" AND FN."EME_Id" = H."EME_Id"
        WHERE G."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND G."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND G."ASMS_Id" = @ASMS_Id::BIGINT 
            AND I."ASMAY_Id" = @ASMAY_Id::BIGINT
            AND I."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND I."ASMS_Id" = @ASMS_Id::BIGINT
            AND "EMPS_AppToResultFlg" = 1 
            AND "EYC_Id" = v_EYC_Id 
            AND H."EME_ActiveFlag" = 1
            AND G."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        GROUP BY E."EME_Id", "EMPSG_GroupName", "EMPSG_DisplayName", G."AMST_Id", A."EMGR_Id", 
                 Fn."ESTMP_TotalGrade", I."ESTMPP_SectionRank"

        UNION

        SELECT 
            9800000 AS "EME_Id",
            "EMPSG_GroupName",
            "EMPSG_DisplayName",
            C."AMST_Id",
            SUM(CASE WHEN "EMPS_ConvertForMarks" = "EMPS_MaxMarks" 
                THEN B."ESTMPPSG_GroupObtMarks" 
                ELSE B."ESTMPPSG_GroupObtMarks" / 2 END) AS "ObtainedMarks",
            SUM("ESTMPPSG_GroupMaxMarks") AS "TotalMarks",
            CAST((SUM("ESTMPPSG_GroupObtMarks") * 100.0 / SUM("ESTMPPSG_GroupMaxMarks")) AS NUMERIC(18,2)) AS "TotalPercentage",
            (SELECT "EMGD_Name"
             FROM "Exm"."Exm_Master_Grade_Details" AS L
             WHERE ((SUM("ESTMPPSG_GroupObtMarks") * 100.0 / SUM("ESTMPPSG_GroupMaxMarks") 
                     BETWEEN L."EMGD_From" AND L."EMGD_To" AND L."EMGR_Id" = H."EMGR_Id")
                 OR (SUM("ESTMPPSG_GroupObtMarks") * 100.0 / SUM("ESTMPPSG_GroupMaxMarks") 
                     BETWEEN L."EMGD_To" AND L."EMGD_From" AND L."EMGR_Id" = H."EMGR_Id"))
             LIMIT 1) AS "EMGD_Name",
            I."ESTMPP_SectionRank"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" 
            AND "EMPSG_ActiveFlag" = 1 AND F."EMPSG_GroupName" = @EMPG_GroupName
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" 
            AND "EMPS_AppToResultFlg" = 1 AND "EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" 
            AND "EMP_ActiveFlag" = 1 AND "EYC_Id" = v_EYC_Id
        INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = C."ASMAY_Id" 
            AND I."ASMCL_Id" = C."ASMCL_Id" AND I."ASMS_Id" = C."ASMS_Id" AND I."AMST_Id" = C."AMST_Id"
        WHERE C."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND C."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND C."ASMS_Id" = @ASMS_Id::BIGINT
            AND C."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
            AND I."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND I."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND I."ASMS_Id" = @ASMS_Id::BIGINT
        GROUP BY "EMPSG_GroupName", "EMPSG_DisplayName", C."AMST_Id", H."EMGR_Id", I."ESTMPP_SectionRank"

        UNION

        SELECT DISTINCT 
            9800001 AS "EME_Id",
            C."EMPSG_GroupName",
            C."EMPSG_DisplayName",
            M."AMST_Id",
            SUM(M."ESTMPPSG_GroupObtMarks") AS "ObtainedMarks",
            SUM(M."ESTMPPSG_GroupMaxMarks") AS "TotalMarks",
            CAST((SUM(M."ESTMPPSG_GroupObtMarks") * 100.0 / SUM(M."ESTMPPSG_GroupMaxMarks")) AS NUMERIC(18,2)) AS "TotalPercentage",
            '' AS "EMGD_Name",
            I."ESTMPP_SectionRank"
        FROM "stjames_temp_promotion_details" M
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" A ON M."AMST_Id" = A."AMST_Id" 
            AND A."ISMS_Id" = M."ISMS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id" 
            AND M."EMPSG_DisplayName" = C."EMPSG_DisplayName" AND C."EMPSG_GroupName" = @EMPG_GroupName
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
        INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
        INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = A."ASMAY_Id" 
            AND I."ASMCL_Id" = A."ASMCL_Id" AND I."ASMS_Id" = A."ASMS_Id" AND I."AMST_Id" = A."AMST_Id"
        WHERE A."MI_Id" = @MI_Id::BIGINT 
            AND M."EMPSG_GroupName" != 'Final Average'
            AND A."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND A."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND A."ASMS_Id" = @ASMS_Id::BIGINT
            AND F."EYC_Id" = v_EYC_Id 
            AND M."complusoryflag" != 'C' 
            AND M."ESG_Id" > 0 
            AND M."grporder" > 0
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
            AND I."ASMAY_Id" = @ASMAY_Id::BIGINT 
            AND I."ASMCL_Id" = @ASMCL_Id::BIGINT 
            AND I."ASMS_Id" = @ASMS_Id::BIGINT
        GROUP BY C."EMPSG_GroupName", C."EMPSG_DisplayName", M."AMST_Id", F."EMGR_Id", I."ESTMPP_SectionRank"
    ) AS D 
    ORDER BY "AMST_Id";

    RETURN;
END;
$$;