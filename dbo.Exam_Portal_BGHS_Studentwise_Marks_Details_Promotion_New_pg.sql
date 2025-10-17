CREATE OR REPLACE FUNCTION "dbo"."Exam_Portal_BGHS_Studentwise_Marks_Details_Promotion_New"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
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
    "PASSORFAIL" TEXT,
    "EXAMATTENDED_NOTATTENDEDFLAG" TEXT,
    "ExamConductFlag" INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_GROUPNAME TEXT;
    v_DISPLAYNAME TEXT;
    v_GROUPORDER INT;
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
    v_AMST_Id_N BIGINT;
    v_ISMS_Id_N BIGINT;
    v_ExamProcessRnt BIGINT;
    v_EMEID INT;
    v_EMEORDER INT;
    v_ProGroupRnt BIGINT;
    v_ExamNotConductedFlag BIGINT;
    v_ROW_COUNT INT;
    v_EXAMATTENDED_NOTATTENDED_FLAG TEXT;
    v_AppResultcount BIGINT;
    v_AppResultcountFlag BIGINT;
    v_ISMS_Id_New BIGINT;
    v_EXAM_CONDUCT_FLAG_GROUP INT;
    v_EXAM_CONDUCT_FLAG INT;
    v_COUNT BIGINT;
    v_COUNT_FLAG BIGINT;
    rec_student RECORD;
    rec_group RECORD;
    rec_exam RECORD;
    rec_subject RECORD;
    rec_groupwise_subject RECORD;
BEGIN

    DROP TABLE IF EXISTS "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal";

    CREATE TEMP TABLE "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" (
        "AMST_Id" BIGINT,
        "ISMS_Id" BIGINT,
        "EME_Id" BIGINT,
        "GROUPNAME" TEXT,
        "DISPLAYNAME" TEXT,
        "OBTAINEDMARKS" DECIMAL(18,2),
        "MAXMARKS" DECIMAL(18,2),
        "GRADE" TEXT,
        "PASSORFAIL" TEXT,
        "EXAMATTENDED_NOTATTENDEDFLAG" TEXT,
        "ExamConductFlag" INT
    );

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id AND "EYC_ActiveFlg" = 1;

    FOR rec_student IN 
        SELECT DISTINCT "AMST_Id" 
        FROM "Adm_School_Y_Student" 
        WHERE "ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND "ASMS_Id" = p_ASMS_Id::BIGINT 
            AND "AMST_Id" = p_AMST_Id::BIGINT
    LOOP
        v_AMST_Id_N := rec_student."AMST_Id";

        FOR rec_group IN 
            SELECT DISTINCT "EMPSG_GroupName", "EMPSG_DisplayName", "EMPSG_Order" 
            FROM "Exm"."Exm_M_Prom_Subj_Group" A 
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMPS_Id" = B."EMPS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion" C ON C."EMP_Id" = B."EMP_Id" AND C."EMP_ActiveFlag" = 1 
            WHERE C."EYC_Id" = v_EYC_Id AND C."MI_Id" = p_MI_Id::BIGINT 
                AND A."EMPSG_ActiveFlag" = 1 AND B."EMPS_ActiveFlag" = 1
        LOOP
            v_GROUPNAME := rec_group."EMPSG_GroupName";
            v_DISPLAYNAME := rec_group."EMPSG_DisplayName";
            v_GROUPORDER := rec_group."EMPSG_Order";

            FOR rec_exam IN 
                SELECT DISTINCT D."EME_Id", E."EME_ExamOrder" 
                FROM "Exm"."Exm_M_Prom_Subj_Group" A 
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMPS_Id" = B."EMPS_Id"
                INNER JOIN "Exm"."Exm_M_Promotion" C ON C."EMP_Id" = B."EMP_Id" AND C."EMP_ActiveFlag" = 1
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = A."EMPSG_Id" AND D."EMPSGE_ActiveFlg" = 1
                INNER JOIN "Exm"."Exm_Master_Exam" E ON E."EME_Id" = D."EME_Id" 
                WHERE C."EYC_Id" = v_EYC_Id AND C."MI_Id" = p_MI_Id::BIGINT 
                    AND A."EMPSG_ActiveFlag" = 1 AND B."EMPS_ActiveFlag" = 1 
                    AND A."EMPSG_GroupName" = v_GROUPNAME 
                ORDER BY E."EME_ExamOrder"
            LOOP
                v_EMEID := rec_exam."EME_Id";
                v_EMEORDER := rec_exam."EME_ExamOrder";
                v_ExamNotConductedFlag := 0;

                FOR rec_subject IN 
                    SELECT DISTINCT "ISMS_Id" 
                    FROM "Exm"."Exm_Category_Class" CC 
                    INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON CC."EMCA_Id" = EYC."EMCA_Id" 
                        AND EYC."ASMAY_Id" = CC."ASMAY_Id" AND CC."MI_Id" = EYC."MI_Id"
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" CE ON CE."EYC_Id" = EYC."EYC_Id" 
                        AND "EYCE_ActiveFlg" = 1
                    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" CES ON CES."EYCE_Id" = CE."EYCE_Id" 
                        AND CES."EYCES_ActiveFlg" = 1
                    WHERE CC."MI_Id" = p_MI_Id::BIGINT AND CC."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND CC."ASMCL_Id" = p_ASMCL_Id::BIGINT AND CC."ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND EYC."EYC_ActiveFlg" = 1 
                        AND CC."ECAC_ActiveFlag" = 1 AND EYC."EYC_Id" = v_EYC_Id 
                        AND CC."EMCA_Id" = v_EMCA_Id AND CE."EME_Id" = v_EMEID
                        AND "ISMS_Id" IN (
                            SELECT DISTINCT "ISMS_Id" 
                            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" ESS 
                            WHERE ESS."AMST_Id" = v_AMST_Id_N AND ESS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                                AND ESS."MI_Id" = p_MI_Id::BIGINT 
                                AND ESS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                                AND ESS."ASMS_Id" = p_ASMS_Id::BIGINT
                        )
                LOOP
                    v_ISMS_Id_N := rec_subject."ISMS_Id";
                    v_ROW_COUNT := 0;
                    v_EXAMATTENDED_NOTATTENDED_FLAG := '';

                    SELECT COUNT(*) INTO v_ROW_COUNT 
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND "EME_Id" = v_EMEID AND "AMST_Id" = v_AMST_Id_N 
                        AND "ISMS_Id" = v_ISMS_Id_N;

                    IF v_ROW_COUNT <> 0 THEN
                        v_EXAMATTENDED_NOTATTENDED_FLAG := 'Attendend';
                        
                        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                        ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                         "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
                        SELECT "AMST_Id", "ISMS_Id", "EME_Id", v_GROUPNAME, v_DISPLAYNAME, 
                               "ESTMPS_ObtainedMarks", "ESTMPS_MaxMarks", "ESTMPS_ObtainedGrade", 
                               "ESTMPS_PassFailFlg", v_EXAMATTENDED_NOTATTENDED_FLAG, 1
                        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                        WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                            AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                            AND "EME_Id" = v_EMEID AND "AMST_Id" = v_AMST_Id_N 
                            AND "ISMS_Id" = v_ISMS_Id_N;
                    ELSE
                        v_EXAMATTENDED_NOTATTENDED_FLAG := 'Not Attendend';
                        
                        INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                        ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                         "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
                        SELECT v_AMST_Id_N, v_ISMS_Id_N, v_EMEID, v_GROUPNAME, v_DISPLAYNAME, 
                               0, 0, '', '', v_EXAMATTENDED_NOTATTENDED_FLAG, 0;
                        
                        v_ExamNotConductedFlag := v_ExamNotConductedFlag + 1;
                    END IF;

                END LOOP;

                v_AppResultcount := 0;
                v_AppResultcountFlag := 0;

                SELECT COUNT(*) INTO v_AppResultcount 
                FROM "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                WHERE "ISMS_Id" IN (
                    SELECT DISTINCT "ISMS_Id" 
                    FROM "Exm"."Exm_Category_Class" CC 
                    INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON CC."EMCA_Id" = EYC."EMCA_Id" 
                        AND EYC."ASMAY_Id" = CC."ASMAY_Id" AND CC."MI_Id" = EYC."MI_Id"
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" CE ON CE."EYC_Id" = EYC."EYC_Id" 
                        AND "EYCE_ActiveFlg" = 1
                    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" CES ON CES."EYCE_Id" = CE."EYCE_Id" 
                        AND CES."EYCES_ActiveFlg" = 1
                    WHERE CC."MI_Id" = p_MI_Id::BIGINT AND CC."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND CC."ASMCL_Id" = p_ASMCL_Id::BIGINT AND CC."ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND EYC."EYC_ActiveFlg" = 1 
                        AND CC."ECAC_ActiveFlag" = 1 AND EYC."EYC_Id" = v_EYC_Id 
                        AND CC."EMCA_Id" = v_EMCA_Id AND CE."EME_Id" = v_EMEID 
                        AND "EYCES_AplResultFlg" = 1
                ) AND "AMST_Id" = v_AMST_Id_N AND "EME_Id" = v_EMEID 
                    AND "GROUPNAME" = v_GROUPNAME AND "ExamConductFlag" = 0;

                IF v_AppResultcount > 0 THEN
                    v_AppResultcountFlag := 0;
                ELSE
                    v_AppResultcountFlag := 1;
                END IF;

                INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                 "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
                SELECT "AMST_Id", 50001, "EME_Id", v_GROUPNAME, v_DISPLAYNAME, 
                       "ESTMP_TotalObtMarks", "ESTMP_TotalMaxMarks", "ESTMP_TotalGrade", 
                       "ESTMP_Result", '', v_AppResultcountFlag
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND "EME_Id" = v_EMEID AND "AMST_Id" = v_AMST_Id_N;

            END LOOP;

            FOR rec_groupwise_subject IN 
                SELECT DISTINCT B."ISMS_Id" 
                FROM "Exm"."Exm_M_Promotion" A 
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id"
                INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = B."ISMS_Id"
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" D ON D."EMPS_Id" = B."EMPS_Id" 
                    AND D."EMPSG_ActiveFlag" = 1
                WHERE A."EYC_Id" = v_EYC_Id AND B."EMPS_ActiveFlag" = 1 
                    AND A."EMP_ActiveFlag" = 1 AND D."EMPSG_GroupName" = v_GROUPNAME
            LOOP
                v_ISMS_Id_New := rec_groupwise_subject."ISMS_Id";
                v_EXAM_CONDUCT_FLAG_GROUP := 0;
                v_EXAM_CONDUCT_FLAG := 0;

                SELECT COUNT(*) INTO v_EXAM_CONDUCT_FLAG_GROUP 
                FROM "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                WHERE "AMST_Id" = v_AMST_Id_N AND "ISMS_Id" = v_ISMS_Id_New 
                    AND "GROUPNAME" = v_GROUPNAME AND "ExamConductFlag" = 0;

                IF v_EXAM_CONDUCT_FLAG_GROUP > 0 THEN 
                    v_EXAM_CONDUCT_FLAG := 0;
                ELSE 
                    v_EXAM_CONDUCT_FLAG := 1;
                END IF;

                INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                 "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
                SELECT A."AMST_Id", A."ISMS_Id", 10000, v_GROUPNAME, v_DISPLAYNAME, 
                       B."ESTMPPSG_GroupObtMarks", B."ESTMPPSG_GroupMaxMarks", 
                       B."ESTMPPSG_GroupObtGrade", '', '', v_EXAM_CONDUCT_FLAG
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
                INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
                WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND C."EMPSG_GroupName" = v_GROUPNAME
                    AND A."ISMS_Id" = v_ISMS_Id_New AND "AMST_Id" = v_AMST_Id_N;

                INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
                ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                 "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
                SELECT A."AMST_Id", A."ISMS_Id", 100001, v_GROUPNAME, v_DISPLAYNAME, 
                       B."ESTMPPSG_GroupObtMarks", B."ESTMPPSG_GroupMaxMarks", 
                       B."ESTMPPSG_GroupObtGrade", '', '', v_EXAM_CONDUCT_FLAG
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
                INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
                WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND C."EMPSG_GroupName" = v_GROUPNAME
                    AND A."ISMS_Id" = v_ISMS_Id_New AND A."AMST_Id" = v_AMST_Id_N 
                    AND A."ISMS_Id" = v_ISMS_Id_New;

            END LOOP;

            v_COUNT := 0;
            v_COUNT_FLAG := 0;

            SELECT COUNT(*) INTO v_COUNT 
            FROM "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
            WHERE "ISMS_Id" IN (
                SELECT "ISMS_Id" 
                FROM "Exm"."Exm_M_Promotion" A 
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id" 
                    AND A."EMP_ActiveFlag" = 1 AND B."EMPS_ActiveFlag" = 1
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id" 
                    AND C."EMPSG_ActiveFlag" = 1 AND C."EMPSG_GroupName" = v_GROUPNAME
                INNER JOIN "Exm"."Exm_Yearly_Category" D ON D."EYC_Id" = A."EYC_Id" 
                    AND D."EYC_ActiveFlg" = 1 AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT
                INNER JOIN "Exm"."Exm_Category_Class" E ON E."EMCA_Id" = D."EMCA_Id" 
                    AND E."ASMAY_Id" = p_ASMAY_Id::BIGINT AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                    AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND E."ECAC_ActiveFlag" = 1 AND B."EMPS_AppToResultFlg" = 1
            ) AND "ExamConductFlag" = 0 AND "EME_Id" = 10000 
                AND "GROUPNAME" = v_GROUPNAME AND "AMST_Id" = v_AMST_Id_N;

            IF v_COUNT > 0 THEN 
                v_COUNT_FLAG := 0;
            ELSE 
                v_COUNT_FLAG := 1;
            END IF;

            INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
            ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
             "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
            SELECT A."AMST_Id", 50001, 10000, v_GROUPNAME, v_GROUPNAME, 
                   SUM(B."ESTMPPSG_GroupObtMarks"), SUM(B."ESTMPPSG_GroupMaxMarks"), 
                   '', '', '', v_COUNT_FLAG
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
            WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND C."EMPSG_GroupName" = v_GROUPNAME AND A."AMST_Id" = v_AMST_Id_N
                AND A."ISMS_Id" IN (
                    SELECT "ISMS_Id" 
                    FROM "Exm"."Exm_M_Promotion" A 
                    INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id" 
                        AND A."EMP_ActiveFlag" = 1 AND B."EMPS_ActiveFlag" = 1
                    INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id" 
                        AND C."EMPSG_ActiveFlag" = 1 AND C."EMPSG_GroupName" = v_GROUPNAME
                    INNER JOIN "Exm"."Exm_Yearly_Category" D ON D."EYC_Id" = A."EYC_Id" 
                        AND D."EYC_ActiveFlg" = 1 AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT
                    INNER JOIN "Exm"."Exm_Category_Class" E ON E."EMCA_Id" = D."EMCA_Id" 
                        AND E."ASMAY_Id" = p_ASMAY_Id::BIGINT AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                        AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND E."ECAC_ActiveFlag" = 1 AND B."EMPS_AppToResultFlg" = 1
                ) 
            GROUP BY A."AMST_Id";

            INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N_Portal" 
            ("AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
             "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag")
            SELECT A."AMST_Id", 50001, 100001, v_GROUPNAME, v_GROUPNAME, 
                   SUM(B."ESTMPPSG_GroupObtMarks"), SUM(B."ESTMPPSG_GroupMaxMarks"), 
                   '', '', '', v_COUNT_FLAG
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" A 
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id"
            WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND C."EMPSG_GroupName" = v_GROUPNAME AND A."AMST_Id" = v_AMST_Id_N
                AND A."ISMS_Id" IN (
                    SELECT "ISMS_Id" 
                    FROM "Exm"."Exm_M_Promotion" A 
                    INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id" = B."EMP_Id" 
                        AND A."EMP_ActiveFlag" = 1 AND B."EMPS_ActiveFlag" = 1
                    INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id" = B."EMPS_Id" 
                        AND C."EMPSG_ActiveFlag" = 1 AND C."EMPSG_GroupName" = v_GROUPNAME
                    INNER JOIN "Exm"."Exm_Yearly_Category" D ON D."EYC_Id" = A."EYC_Id" 
                        AND D."EYC_ActiveFlg" = 1 AND D."ASMAY_Id" = p_ASMAY_Id::BIGINT
                    INNER JOIN "Exm"."Exm_Category_Class" E ON E."EMCA_Id" = D."EMCA_Id" 
                        AND E."ASMAY_Id" = p_ASMAY_Id::BIGINT AND E."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                        AND E."ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND E."ECAC_ActiveFlag" = 1 AND B."EMPS_App