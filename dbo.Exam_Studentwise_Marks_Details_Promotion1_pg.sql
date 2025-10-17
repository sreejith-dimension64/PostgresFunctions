CREATE OR REPLACE FUNCTION "dbo"."Exam_Studentwise_Marks_Details_Promotion1"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "EME_Id" BIGINT,
    "GROUPNAME" TEXT,
    "DISPLAYNAME" TEXT,
    "OBTAINEDMARKS" DECIMAL(18,2),
    "MAXMARKS" DECIMAL(18,2),
    "GRADE" TEXT,
    "PASSORFAIL" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_EMCA_Id" BIGINT;
    "v_EYC_Id" BIGINT;
    "v_GROUPNAME" TEXT;
    "v_DISPLAYNAME" TEXT;
    "v_GROUPORDER" INT;
    "v_EMEID" BIGINT;
    "v_EMEORDER" INT;
    "rec_group" RECORD;
    "rec_exam" RECORD;
BEGIN

    DROP TABLE IF EXISTS "BGHS_EXAM_PROMOTION_DETIAL1";

    CREATE TEMP TABLE "BGHS_EXAM_PROMOTION_DETIAL1" (
        "AMST_Id" BIGINT,
        "ISMS_Id" BIGINT,
        "EME_Id" BIGINT,
        "GROUPNAME" TEXT,
        "DISPLAYNAME" TEXT,
        "OBTAINEDMARKS" DECIMAL(18,2),
        "MAXMARKS" DECIMAL(18,2),
        "GRADE" TEXT,
        "PASSORFAIL" TEXT
    );

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

    FOR "rec_group" IN
        SELECT DISTINCT "A"."EMPSG_GroupName", "A"."EMPSG_DisplayName", "A"."EMPSG_Order" 
        FROM "Exm"."Exm_M_Prom_Subj_Group" "A"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "B" ON "A"."EMPS_Id" = "B"."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion" "C" ON "C"."EMP_Id" = "B"."EMP_Id" AND "C"."EMP_ActiveFlag" = 1
        WHERE "C"."EYC_Id" = "v_EYC_Id" 
            AND "C"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "A"."EMPSG_ActiveFlag" = 1 
            AND "B"."EMPS_ActiveFlag" = 1
    LOOP
        "v_GROUPNAME" := "rec_group"."EMPSG_GroupName";
        "v_DISPLAYNAME" := "rec_group"."EMPSG_DisplayName";
        "v_GROUPORDER" := "rec_group"."EMPSG_Order";

        FOR "rec_exam" IN
            SELECT DISTINCT "D"."EME_Id", "E"."EME_ExamOrder" 
            FROM "Exm"."Exm_M_Prom_Subj_Group" "A"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "B" ON "A"."EMPS_Id" = "B"."EMPS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion" "C" ON "C"."EMP_Id" = "B"."EMP_Id" AND "C"."EMP_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" "D" ON "D"."EMPSG_Id" = "A"."EMPSG_Id" AND "D"."EMPSGE_ActiveFlg" = 1
            INNER JOIN "Exm"."Exm_Master_Exam" "E" ON "E"."EME_Id" = "D"."EME_Id"
            WHERE "C"."EYC_Id" = "v_EYC_Id" 
                AND "C"."MI_Id" = "p_MI_Id"::BIGINT 
                AND "A"."EMPSG_ActiveFlag" = 1 
                AND "B"."EMPS_ActiveFlag" = 1 
                AND "A"."EMPSG_GroupName" = "v_GROUPNAME"
            ORDER BY "E"."EME_ExamOrder"
        LOOP
            "v_EMEID" := "rec_exam"."EME_Id";
            "v_EMEORDER" := "rec_exam"."EME_ExamOrder";

            INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
            SELECT "AMST_Id", "ISMS_Id", "EME_Id", "v_GROUPNAME", "v_DISPLAYNAME", "ESTMPS_ObtainedMarks", "ESTMPS_MaxMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg"
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = "p_MI_Id"::BIGINT 
                AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND "ASMS_Id" = "p_ASMS_Id"::BIGINT 
                AND "EME_Id" = "v_EMEID";

            INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
            SELECT "AMST_Id", 50001, "EME_Id", "v_GROUPNAME", "v_DISPLAYNAME", "ESTMP_TotalObtMarks", "ESTMP_TotalMaxMarks", "ESTMP_TotalGrade", "ESTMP_Result"
            FROM "Exm"."Exm_Student_Marks_Process" 
            WHERE "MI_Id" = "p_MI_Id"::BIGINT 
                AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
                AND "ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
                AND "ASMS_Id" = "p_ASMS_Id"::BIGINT 
                AND "EME_Id" = "v_EMEID";

        END LOOP;

        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
        SELECT "A"."AMST_Id", "A"."ISMS_Id", 10000, "v_GROUPNAME", "v_DISPLAYNAME", "B"."ESTMPPSG_GroupObtMarks", "B"."ESTMPPSG_GroupMaxMarks", "B"."ESTMPPSG_GroupObtGrade", ''
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "A" 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "B" ON "A"."ESTMPPS_Id" = "B"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPSG_Id" = "B"."EMPSG_Id"
        WHERE "A"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "A"."ASMS_Id" = "p_ASMS_Id"::BIGINT 
            AND "C"."EMPSG_GroupName" = "v_GROUPNAME";

        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
        SELECT "A"."AMST_Id", 50001, 10000, "v_GROUPNAME", "v_GROUPNAME", SUM("B"."ESTMPPSG_GroupObtMarks"), SUM("B"."ESTMPPSG_GroupMaxMarks"), '', ''
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "A" 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "B" ON "A"."ESTMPPS_Id" = "B"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPSG_Id" = "B"."EMPSG_Id"
        WHERE "A"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "A"."ASMS_Id" = "p_ASMS_Id"::BIGINT 
            AND "C"."EMPSG_GroupName" = "v_GROUPNAME"
            AND "A"."ISMS_Id" IN(
                SELECT "B"."ISMS_Id" 
                FROM "Exm"."Exm_M_Promotion" "A" 
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "B" ON "A"."EMP_Id" = "B"."EMP_Id" AND "A"."EMP_ActiveFlag" = 1 AND "B"."EMPS_ActiveFlag" = 1
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPS_Id" = "B"."EMPS_Id" AND "C"."EMPSG_ActiveFlag" = 1 AND "C"."EMPSG_GroupName" = "v_GROUPNAME"
                INNER JOIN "Exm"."Exm_Yearly_Category" "D" ON "D"."EYC_Id" = "A"."EYC_Id" AND "D"."EYC_ActiveFlg" = 1 AND "D"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                INNER JOIN "Exm"."Exm_Category_Class" "E" ON "E"."EMCA_Id" = "D"."EMCA_Id" AND "E"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND "E"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND "E"."ASMS_Id" = "p_ASMS_Id"::BIGINT
                    AND "E"."ECAC_ActiveFlag" = 1 AND "B"."EMPS_AppToResultFlg" = 1
            )
        GROUP BY "A"."AMST_Id";

        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
        SELECT "A"."AMST_Id", "A"."ISMS_Id", 100001, "v_GROUPNAME", "v_DISPLAYNAME", "B"."ESTMPPSG_GroupObtMarks", "B"."ESTMPPSG_GroupMaxMarks", "B"."ESTMPPSG_GroupObtGrade", ''
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "A" 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "B" ON "A"."ESTMPPS_Id" = "B"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPSG_Id" = "B"."EMPSG_Id"
        WHERE "A"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "A"."ASMS_Id" = "p_ASMS_Id"::BIGINT 
            AND "C"."EMPSG_GroupName" = "v_GROUPNAME";

        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1" ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL")
        SELECT "A"."AMST_Id", 50001, 100001, "v_GROUPNAME", "v_GROUPNAME", SUM("B"."ESTMPPSG_GroupObtMarks"), SUM("B"."ESTMPPSG_GroupMaxMarks"), '', ''
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "A" 
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "B" ON "A"."ESTMPPS_Id" = "B"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPSG_Id" = "B"."EMPSG_Id"
        WHERE "A"."MI_Id" = "p_MI_Id"::BIGINT 
            AND "A"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
            AND "A"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT 
            AND "A"."ASMS_Id" = "p_ASMS_Id"::BIGINT 
            AND "C"."EMPSG_GroupName" = "v_GROUPNAME"
            AND "A"."ISMS_Id" IN(
                SELECT "B"."ISMS_Id" 
                FROM "Exm"."Exm_M_Promotion" "A" 
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "B" ON "A"."EMP_Id" = "B"."EMP_Id" AND "A"."EMP_ActiveFlag" = 1 AND "B"."EMPS_ActiveFlag" = 1
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "C" ON "C"."EMPS_Id" = "B"."EMPS_Id" AND "C"."EMPSG_ActiveFlag" = 1 AND "C"."EMPSG_GroupName" = "v_GROUPNAME"
                INNER JOIN "Exm"."Exm_Yearly_Category" "D" ON "D"."EYC_Id" = "A"."EYC_Id" AND "D"."EYC_ActiveFlg" = 1 AND "D"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                INNER JOIN "Exm"."Exm_Category_Class" "E" ON "E"."EMCA_Id" = "D"."EMCA_Id" AND "E"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT AND "E"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT AND "E"."ASMS_Id" = "p_ASMS_Id"::BIGINT
                    AND "E"."ECAC_ActiveFlag" = 1 AND "B"."EMPS_AppToResultFlg" = 1
            )
        GROUP BY "A"."AMST_Id";

    END LOOP;

    RETURN QUERY SELECT * FROM "BGHS_EXAM_PROMOTION_DETIAL1";

END;
$$;