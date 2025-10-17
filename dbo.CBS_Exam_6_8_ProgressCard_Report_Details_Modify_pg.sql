CREATE OR REPLACE FUNCTION "dbo"."CBS_Exam_6_8_ProgressCard_Report_Details_Modify"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_AMST_Id" TEXT,
    "p_EMPG_GroupName" TEXT
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
    "PassFailFlag" VARCHAR,
    "ESTMPPS_ClassHighest" NUMERIC,
    "GroupMarks" NUMERIC,
    "GropuFlag" INTEGER,
    "colspan" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_EYC_Id" BIGINT;
    "v_EMCA_Id" BIGINT;
    "v_SQLQUERY" TEXT;
    "v_grp_name" VARCHAR;
    "v_EME_Id" BIGINT;
    "v_AMST_IdNew" BIGINT;
    "v_ESG_Id" BIGINT;
    "v_Gropup_Marks" NUMERIC(18,2);
    "v_SubjectCount" BIGINT;
    "rec_grp" RECORD;
    "rec_esg" RECORD;
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

    DROP TABLE IF EXISTS "NDS_Temp_StudentDetails_Amstids_NEW";
    DROP TABLE IF EXISTS "MARKS_Temp_StudentDetails";

    "v_SQLQUERY" := 'CREATE TEMP TABLE "NDS_Temp_StudentDetails_Amstids_NEW" AS 
        SELECT DISTINCT "AMST_Id" 
        FROM "ADM_M_STUDENT" 
        WHERE "AMST_Id" IN (' || "p_AMST_Id" || ') 
            AND "MI_Id" = ' || "p_MI_Id";
    
    EXECUTE "v_SQLQUERY";

    CREATE TEMP TABLE "MARKS_Temp_StudentDetails" AS
    SELECT * FROM (
        SELECT DISTINCT A."AMST_Id", B1."EME_Id", H."EME_ExamName", G."ISMS_SubjectName", A."ISMS_Id", B."EMPSG_Id", 
            C."EMPSG_GroupName", C."EMPSG_DisplayName", C."EMPSG_Order", H."EME_ExamOrder", E."EMPS_SubjOrder",
            B1."ESTMPPSGE_ExamConvertedMarks" AS "ObtainedMarks", B1."ESTMPPSGE_ExamConvertedGrade" AS "ObtainedGrade",
            B1."ESTMPPSGE_ExamConvertedPoints" AS "ObtainedGradePoints", B1."ESTMPPSGE_ExamPassFailFlag" AS "PassFailFlag",
            0::NUMERIC as "ESTMPPS_ClassHighest", 0::NUMERIC as "GroupMarks", 0 as "GropuFlag", 0 as "colspan"
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
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
        
        UNION
        
        SELECT DISTINCT A."AMST_Id", 9800000 AS "EME_Id", 'Marks Obtained' as "EME_ExamName", G."ISMS_SubjectName", 
            A."ISMS_Id", B."EMPSG_Id", C."EMPSG_GroupName", C."EMPSG_DisplayName", C."EMPSG_Order", 
            9800000 "EME_ExamOrder", E."EMPS_SubjOrder",
            B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",
            B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", '' AS "PassFailFlag", 
            0::NUMERIC as "ESTMPPS_ClassHighest", 0::NUMERIC as "GroupMarks", 0 as "GropuFlag", 0 as "colspan"
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
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
        
        UNION
        
        SELECT DISTINCT A."AMST_Id", 9800001 AS "EME_Id", 'Grade' as "EME_ExamName", G."ISMS_SubjectName", 
            A."ISMS_Id", B."EMPSG_Id", C."EMPSG_GroupName", C."EMPSG_DisplayName", C."EMPSG_Order", 
            9800001 "EME_ExamOrder", E."EMPS_SubjOrder",
            B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",
            B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", '' AS "PassFailFlag", 
            0::NUMERIC as "ESTMPPS_ClassHighest", 0::NUMERIC as "GroupMarks", 0 as "GropuFlag", 0 as "colspan"
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
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
        
        UNION
        
        SELECT DISTINCT A."AMST_Id", 98000012 AS "EME_Id", 'Highest in Class' as "EME_ExamName", G."ISMS_SubjectName", 
            A."ISMS_Id", B."EMPSG_Id", C."EMPSG_GroupName", C."EMPSG_DisplayName", C."EMPSG_Order", 
            9800001 "EME_ExamOrder", E."EMPS_SubjOrder",
            B."ESTMPPSG_GroupObtMarks" AS "ObtainedMarks", B."ESTMPPSG_GroupObtGrade" AS "ObtainedGrade",
            B."ESTMPPSG_GradePoints" AS "ObtainedGradePoints", '' AS "PassFailFlag", 
            A."ESTMPPS_ClassHighest" as "ESTMPPS_ClassHighest", 0::NUMERIC as "GroupMarks", 0 as "GropuFlag", 0 as "colspan"
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
            AND A."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
    ) AS TEMPMARKS 
    WHERE "AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids_NEW")
    ORDER BY "EMPSG_Order", "EME_ExamOrder", "EMPS_SubjOrder";

    FOR "rec_grp" IN 
        SELECT DISTINCT M."EMPSG_GroupName", M."EME_Id", M."AMST_Id" 
        FROM "MARKS_Temp_StudentDetails" M 
        WHERE M."EME_Id" = 9800000
    LOOP
        "v_grp_name" := "rec_grp"."EMPSG_GroupName";
        "v_EME_Id" := "rec_grp"."EME_Id";
        "v_AMST_IdNew" := "rec_grp"."AMST_Id";

        FOR "rec_esg" IN 
            SELECT DISTINCT "ESG_Id" 
            FROM "Exm"."Exm_Subject_Group" 
            WHERE "EMCA_Id" = "v_EMCA_Id" 
                AND "ESG_ExamPromotionFlag" = 'PE'
        LOOP
            "v_ESG_Id" := "rec_esg"."ESG_Id";

            SELECT COUNT("ISMS_Id") INTO "v_SubjectCount"
            FROM "exm"."Exm_Subject_Group_Subjects" 
            WHERE "ESG_Id" = "v_ESG_Id";

            SELECT SUM("ObtainedMarks") / "v_SubjectCount" INTO "v_Gropup_Marks"
            FROM "MARKS_Temp_StudentDetails" 
            WHERE "EME_Id" = "v_EME_Id" 
                AND "EMPSG_GroupName" = "v_grp_name" 
                AND "AMST_Id" = "v_AMST_IdNew"
                AND "ISMS_Id" IN (SELECT "ISMS_Id" FROM "exm"."Exm_Subject_Group_Subjects" WHERE "ESG_Id" = "v_ESG_Id");

            UPDATE "MARKS_Temp_StudentDetails" 
            SET "GroupMarks" = "v_Gropup_Marks", 
                "GropuFlag" = 1, 
                "colspan" = "v_SubjectCount"
            WHERE "EME_Id" = "v_EME_Id" 
                AND "EMPSG_GroupName" = "v_grp_name" 
                AND "AMST_Id" = "v_AMST_IdNew"
                AND "ISMS_Id" IN (
                    SELECT "ISMS_Id" 
                    FROM "exm"."Exm_Subject_Group_Subjects" 
                    WHERE "ESG_Id" = "v_ESG_Id" 
                    ORDER BY "ESG_Id" ASC 
                    LIMIT 1
                );

            UPDATE "MARKS_Temp_StudentDetails" 
            SET "GropuFlag" = 1
            WHERE "EME_Id" = "v_EME_Id" 
                AND "EMPSG_GroupName" = "v_grp_name" 
                AND "AMST_Id" = "v_AMST_IdNew"
                AND "ISMS_Id" IN (
                    SELECT "ISMS_Id" 
                    FROM "exm"."Exm_Subject_Group_Subjects" 
                    WHERE "ESG_Id" = "v_ESG_Id" 
                    ORDER BY "ESG_Id" DESC 
                    LIMIT 1
                );
        END LOOP;
    END LOOP;

    RETURN QUERY SELECT * FROM "MARKS_Temp_StudentDetails";

END;
$$;