CREATE OR REPLACE FUNCTION "dbo"."Exam_Student_SubjectWise_Marks_Details_New"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_EME_Id TEXT,
    p_FLAG TEXT
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
    "ExamConductFlag" INTEGER,
    "EMGD_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamic TEXT;
    v_AMST_Id BIGINT;
    v_EMGR_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
    v_ISMS_Id BIGINT;
    v_AMST_Id_N BIGINT;
    v_ISMS_Id_N BIGINT;
    v_TotalMaxMarks DECIMAL(18,2);
    v_TotalObtMarks DECIMAL(18,2);
    v_FinalTotMarks DECIMAL(18,2);
    v_FinalTotMarksPer DECIMAL(18,2);
    v_ObtainedGrade VARCHAR(50);
    v_ObtainedGradeRemarks TEXT;
    v_EME_IdG INT;
    v_EMEID_NEW INT;
    v_AttendanceFromDate DATE;
    v_AttendanceToDate DATE;
    v_classheld DECIMAL(18,2);
    v_Class_Attended DECIMAL(18,2);
    v_Dynamic1 TEXT;
    v_SRcount BIGINT;
    v_ROW_COUNT INT;
    v_EXAMATTENDED_NOTATTENDED_FLAG TEXT;
    v_AppResultcount BIGINT;
    v_AppResultcountFlag BIGINT;
    v_ISMS_Id_NEW BIGINT;
    v_OBTAINEDMARKS DECIMAL(18,2);
    v_MAXMARKS DECIMAL(18,2);
    v_PERCENTAGE DECIMAL(18,2);
    v_ROWCOUNT BIGINT;
    v_ROWCOUNT_FLAG BIGINT;
    v_GRADENAME TEXT;
    rec_student RECORD;
    rec_exam RECORD;
    rec_subject RECORD;
    rec_student_subject RECORD;
BEGIN

    DROP TABLE IF EXISTS "Exam_ReportTemp_New";
    DROP TABLE IF EXISTS "BGHS_Multi_EXAM_DETIAL_Report";

    CREATE TEMP TABLE "BGHS_Multi_EXAM_DETIAL_Report" (
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
        "ExamConductFlag" INTEGER,
        "EMGD_Remarks" TEXT
    );

    v_Dynamic1 := 'CREATE TEMP TABLE "Exam_ReportTemp_New" AS 
    SELECT DISTINCT "EME_Id", "EME_ExamOrder" FROM "Exm"."Exm_Master_Exam" 
    WHERE "MI_Id" = ' || p_MI_Id || ' AND "EME_ActiveFlag" = 1 AND "EME_Id" IN (' || p_EME_Id || ')';
    
    EXECUTE v_Dynamic1;

    SELECT "EME_Id" INTO v_EME_IdG FROM "Exam_ReportTemp_New" ORDER BY "EME_ExamOrder" DESC LIMIT 1;

    SELECT "EMCA_Id" INTO v_EMCA_Id FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
    AND "ASMS_Id" = p_ASMS_Id::BIGINT AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT AND "EMCA_Id" = v_EMCA_Id AND "EYC_ActiveFlg" = 1;

    SELECT DISTINCT "EMGR_Id" INTO v_EMGR_Id FROM "Exm"."Exm_Yearly_Category_Exams" 
    WHERE "EYC_Id" = v_EYC_Id AND "EME_Id" = v_EME_IdG AND "EYCE_ActiveFlg" = 1;

    FOR rec_student IN 
        SELECT DISTINCT "AMST_Id" FROM "Adm_School_Y_Student" 
        WHERE "ASMAY_Id" = p_ASMAY_Id::BIGINT AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT
    LOOP
        v_AMST_Id_N := rec_student."AMST_Id";

        FOR rec_exam IN 
            SELECT DISTINCT A."EME_Id" FROM "Exm"."Exm_Yearly_Category_Exams" A 
            INNER JOIN "Exm"."Exm_Yearly_Category" B ON A."EYC_Id" = B."EYC_Id"
            INNER JOIN "Exm"."Exm_Category_Class" C ON C."EMCA_Id" = B."EMCA_Id"
            WHERE B."MI_Id" = p_MI_Id::BIGINT AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT AND A."EYC_Id" = v_EYC_Id
            AND C."MI_Id" = p_MI_Id::BIGINT AND C."ASMAY_Id" = p_ASMAY_Id::BIGINT AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND C."ASMS_Id" = p_ASMS_Id::BIGINT AND A."EYCE_ActiveFlg" = 1 AND B."EYC_ActiveFlg" = 1
            AND C."ECAC_ActiveFlag" = 1 AND A."EME_Id" IN (SELECT DISTINCT "EME_Id" FROM "Exam_ReportTemp_New")
        LOOP
            v_EMEID_NEW := rec_exam."EME_Id";

            FOR rec_subject IN 
                SELECT DISTINCT "ISMS_Id" FROM "Exm"."Exm_Category_Class" CC
                INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON CC."EMCA_Id" = EYC."EMCA_Id" 
                    AND EYC."ASMAY_Id" = CC."ASMAY_Id" AND CC."MI_Id" = EYC."MI_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" CE ON CE."EYC_Id" = EYC."EYC_Id" AND "EYCE_ActiveFlg" = 1
                INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" CES ON CES."EYCE_Id" = CE."EYCE_Id" AND CES."EYCES_ActiveFlg" = 1
                WHERE CC."MI_Id" = p_MI_Id::BIGINT AND CC."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND CC."ASMCL_Id" = p_ASMCL_Id::BIGINT AND CC."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND EYC."EYC_ActiveFlg" = 1 AND CC."ECAC_ActiveFlag" = 1 AND EYC."EYC_Id" = v_EYC_Id 
                AND CC."EMCA_Id" = v_EMCA_Id AND CE."EME_Id" = v_EMEID_NEW
                AND "ISMS_Id" IN (
                    SELECT DISTINCT "ISMS_Id" FROM "Exm"."Exm_Studentwise_Subjects" ESS 
                    WHERE ESS."AMST_Id" = v_AMST_Id_N AND ESS."ASMAY_Id" = p_ASMAY_Id::BIGINT
                    AND ESS."MI_Id" = p_MI_Id::BIGINT AND ESS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                    AND ESS."ASMS_Id" = p_ASMS_Id::BIGINT AND ESS."ESTSU_ActiveFlg" = 1
                )
            LOOP
                v_ISMS_Id_N := rec_subject."ISMS_Id";
                v_ROW_COUNT := 0;
                v_EXAMATTENDED_NOTATTENDED_FLAG := '';

                SELECT COUNT(*) INTO v_ROW_COUNT FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                AND "EME_Id" = v_EMEID_NEW AND "AMST_Id" = v_AMST_Id_N AND "ISMS_Id" = v_ISMS_Id_N;

                IF v_ROW_COUNT <> 0 THEN
                    v_EXAMATTENDED_NOTATTENDED_FLAG := 'Attendend';

                    INSERT INTO "BGHS_Multi_EXAM_DETIAL_Report" (
                        "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS", 
                        "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", 
                        "ExamConductFlag", "EMGD_Remarks"
                    )
                    SELECT A."AMST_Id", A."ISMS_Id", A."EME_Id", '', '', A."ESTMPS_ObtainedMarks", 
                        A."ESTMPS_MaxMarks", A."ESTMPS_ObtainedGrade", A."ESTMPS_PassFailFlg",
                        v_EXAMATTENDED_NOTATTENDED_FLAG, 1, COALESCE(B."EMGD_Remarks", '')
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
                    LEFT JOIN "Exm"."Exm_Master_Grade_Details" B ON A."ESTMPS_ObtainedGrade" = B."EMGD_Name" 
                        AND B."EMGR_Id" = v_EMGR_Id
                    WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT AND A."ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND A."EME_Id" = v_EMEID_NEW AND A."AMST_Id" = v_AMST_Id_N AND A."ISMS_Id" = v_ISMS_Id_N;
                ELSE
                    v_EXAMATTENDED_NOTATTENDED_FLAG := 'Not Attendend';
                    
                    INSERT INTO "BGHS_Multi_EXAM_DETIAL_Report" (
                        "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS",
                        "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", 
                        "ExamConductFlag", "EMGD_Remarks"
                    )
                    VALUES (v_AMST_Id_N, v_ISMS_Id_N, v_EMEID_NEW, '', '', 0, 0, '', '', 
                        v_EXAMATTENDED_NOTATTENDED_FLAG, 0, '');
                END IF;
            END LOOP;

            v_AppResultcount := 0;
            v_AppResultcountFlag := 0;

            SELECT COUNT(*) INTO v_AppResultcount FROM "BGHS_Multi_EXAM_DETIAL_Report" 
            WHERE "ISMS_Id" IN (
                SELECT DISTINCT "ISMS_Id" FROM "Exm"."Exm_Category_Class" CC
                INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON CC."EMCA_Id" = EYC."EMCA_Id" 
                    AND EYC."ASMAY_Id" = CC."ASMAY_Id" AND CC."MI_Id" = EYC."MI_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" CE ON CE."EYC_Id" = EYC."EYC_Id" AND "EYCE_ActiveFlg" = 1
                INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" CES ON CES."EYCE_Id" = CE."EYCE_Id" AND CES."EYCES_ActiveFlg" = 1
                WHERE CC."MI_Id" = p_MI_Id::BIGINT AND CC."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND CC."ASMCL_Id" = p_ASMCL_Id::BIGINT AND CC."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND EYC."EYC_ActiveFlg" = 1 AND CC."ECAC_ActiveFlag" = 1 AND EYC."EYC_Id" = v_EYC_Id 
                AND CC."EMCA_Id" = v_EMCA_Id AND CE."EME_Id" = v_EMEID_NEW AND "EYCES_AplResultFlg" = 1
            ) 
            AND "AMST_Id" = v_AMST_Id_N AND "EME_Id" = v_EMEID_NEW;

            v_AppResultcountFlag := 1;

            INSERT INTO "BGHS_Multi_EXAM_DETIAL_Report" (
                "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS",
                "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag"
            )
            SELECT "AMST_Id", 50001, "EME_Id", '', '', "ESTMP_TotalObtMarks", "ESTMP_TotalMaxMarks", 
                "ESTMP_TotalGrade", "ESTMP_Result", '', v_AppResultcountFlag
            FROM "Exm"."Exm_Student_Marks_Process" 
            WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "ASMCL_Id" = p_ASMCL_Id::BIGINT AND "ASMS_Id" = p_ASMS_Id::BIGINT 
            AND "EME_Id" = v_EMEID_NEW AND "AMST_Id" = v_AMST_Id_N;
        END LOOP;

        FOR rec_student_subject IN 
            SELECT DISTINCT "ISMS_Id" FROM "BGHS_Multi_EXAM_DETIAL_Report" WHERE "AMST_Id" = v_AMST_Id_N
        LOOP
            v_ISMS_Id_NEW := rec_student_subject."ISMS_Id";
            v_OBTAINEDMARKS := 0;
            v_MAXMARKS := 0;
            v_PERCENTAGE := 0;
            v_ROWCOUNT := 0;
            v_ROWCOUNT_FLAG := 0;

            SELECT COUNT(*) INTO v_ROWCOUNT FROM "BGHS_Multi_EXAM_DETIAL_Report" 
            WHERE "AMST_Id" = v_AMST_Id_N AND "ISMS_Id" = v_ISMS_Id_NEW AND "ExamConductFlag" = 0;

            IF v_ROWCOUNT > 0 THEN
                v_ROWCOUNT_FLAG := 0;
            ELSE
                v_ROWCOUNT_FLAG := 1;
            END IF;

            SELECT COALESCE(SUM("OBTAINEDMARKS"), 0), COALESCE(SUM("MAXMARKS"), 0),
                COALESCE(CASE WHEN SUM(NULLIF("MAXMARKS", 0)) > 0 THEN 
                    ROUND((SUM(NULLIF("OBTAINEDMARKS", 0)) * 100.0 / SUM(NULLIF("MAXMARKS", 0)))::NUMERIC, 2)
                ELSE 0 END, 0)
            INTO v_OBTAINEDMARKS, v_MAXMARKS, v_PERCENTAGE
            FROM "BGHS_Multi_EXAM_DETIAL_Report" 
            WHERE "AMST_Id" = v_AMST_Id_N AND "ISMS_Id" = v_ISMS_Id_NEW;

            v_GRADENAME := '';

            SELECT "EMGD_Name" INTO v_GRADENAME FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE "EMGR_Id" = v_EMGR_Id AND v_PERCENTAGE BETWEEN "EMGD_From" AND "EMGD_To";

            v_SRcount := 0;

            SELECT COUNT(*) INTO v_SRcount FROM "BGHS_Multi_EXAM_DETIAL_Report" 
            WHERE "AMST_Id" = v_AMST_Id_N AND "EME_Id" = 150001 AND "ISMS_Id" = v_ISMS_Id_NEW;

            IF v_SRcount = 0 THEN
                INSERT INTO "BGHS_Multi_EXAM_DETIAL_Report" (
                    "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS",
                    "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag"
                )
                VALUES (v_AMST_Id_N, v_ISMS_Id_NEW, 150001, '', '', v_OBTAINEDMARKS, v_MAXMARKS, 
                    COALESCE(v_GRADENAME, ''), '', '', v_ROWCOUNT_FLAG);

                INSERT INTO "BGHS_Multi_EXAM_DETIAL_Report" (
                    "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", "OBTAINEDMARKS",
                    "MAXMARKS", "GRADE", "PASSORFAIL", "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag"
                )
                VALUES (v_AMST_Id_N, v_ISMS_Id_NEW, 150002, '', '', v_OBTAINEDMARKS, v_MAXMARKS, 
                    COALESCE(v_GRADENAME, ''), '', '', v_ROWCOUNT_FLAG);
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY SELECT * FROM "BGHS_Multi_EXAM_DETIAL_Report";
END;
$$;