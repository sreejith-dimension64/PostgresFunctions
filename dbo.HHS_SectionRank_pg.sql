
CREATE OR REPLACE FUNCTION "dbo"."HHS_SectionRank"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT,
    p_EME_Id INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_pass_fail_flagR INT;
    v_passfail10AT INT;
    v_passfail10FL INT;
    v_rankCalFlagSUBpassM INT;
    v_pass_fail_flagc VARCHAR(100);
    v_rankCalFlagMAINpassM INT;
    v_PassFailSubjectFlagC VARCHAR(50);
    v_ESTMP_TotalMaxMarks DECIMAL(10,2);
    v_ESTMP_TotalObtMarks DECIMAL(10,2);
    v_EYCES_Id INT;
    v_EYCE_Id INT;
    v_ISMS_Id DECIMAL(10,2);
    v_EYCES_AplResultFlg BOOLEAN;
    v_EYCES_MarksEntryMax DECIMAL(10,2);
    v_EYCES_MaxMarks DECIMAL(10,2);
    v_EYCES_MinMarks DECIMAL(10,2);
    v_EMGR_Id INT;
    v_ESTM_Marks DECIMAL(10,2);
    v_ESTM_MarksGradeFlg CHAR(1);
    v_ESTMP_Result VARCHAR(30);
    v_AMST_Id BIGINT;
    v_ESTMP_Percentage DECIMAL(10,2);
    v_ESTMPS_ObtainedGrade VARCHAR(30);
    v_Exm_Grade INT;
    v_ESTMP_TotalGrade VARCHAR(30);
    v_ESTMPS_Percentage DECIMAL(10,2);
    v_ESTMPS_MaxMarks DECIMAL(10,2);
    v_Subject_Percentage DECIMAL(10,2);
    v_Class_Totalmarks DECIMAL(10,2);
    v_Class_Totalcount INT;
    v_Section_Totalmarks DECIMAL(10,2);
    v_Section_Totalcount INT;
    v_FailCount INT;
    v_ESTMPS_PassFailFlg VARCHAR(30);
    v_ESTMPS_ClassAverage DECIMAL(10,2);
    v_ESTMPS_SectionAverage DECIMAL(10,2);
    v_ESTMPS_ClassHighest DECIMAL(10,2);
    v_ESTMPS_SectionHighest DECIMAL(10,2);
    v_ESTMP_ClassRank INT;
    v_ESTMP_SectionRank INT;
    v_ESTM_Flg VARCHAR(10);
    v_Absentcount INT;
    v_Sportscount INT;
    v_Medicalcount INT;
    v_Normalclassrank INT;
    v_NormalSectionrank INT;
    v_ExmConfig_RankingMethod VARCHAR(50);
    v_Rank INT;
    v_Ratio DECIMAL(10,2);
    v_GredeFlag VARCHAR(5);
    v_GradeMarksPercentage DECIMAL(10,2);
    v_RoundOffFlg BOOLEAN;
    v_ESTM_Grade VARCHAR(10);
    v_TotalMinMarks DECIMAL(10,2);
    v_ESTMP_MaxMarks DECIMAL(10,2);
    v_ESTMP_ObtainedMarks DECIMAL(10,2);
    v_EYCES_SubExamFlg BOOLEAN;
    v_EYCES_SubSubjectFlg BOOLEAN;
    v_passfailflag VARCHAR(50);
    v_passfail VARCHAR(50);
    v_ODcount INT;
    v_ESTMP_Percentage_Overallpercentage DECIMAL(10,2);
    v_passfail10 VARCHAR(10);
    v_ams VARCHAR(10);
    v_count10 INTEGER;
    v_count10M INTEGER;
    v_count10F INTEGER;
    v_count10op INT;
    v_passfail10A VARCHAR(10);
    v_passfail10M VARCHAR(10);
    v_passfail10F VARCHAR(10);
    v_passfail10C VARCHAR(10);
    v_passfail10D VARCHAR(50);
    v_passfailflagOP VARCHAR(50);
    v_passfailflagA VARCHAR(10);
    v_passfailflagM VARCHAR(10);
    v_passfailflagF VARCHAR(10);
    v_passfailflagC VARCHAR(10);
    v_passfailflagD VARCHAR(50);
    v_passfail1OP VARCHAR(50);
    v_rankCalFlag VARCHAR(10);
    v_EMCA_ID INT;
    v_exmc_condition VARCHAR(10);
    v_marks DECIMAL(10,2);
    v_fail_count_temp INT;
    v_pass_fail_flag VARCHAR(50);
    v_overallPercentage DECIMAL(10,2);
    v_overallFlag VARCHAR(20);
    v_pass_sub_temp DECIMAL(10,2);
    v_classrank1 INT;
    v_fail_count INTEGER;
    v_pass_sub INTEGER;
    v_SUbmedicalcount INTEGER;
    v_totalCount INT;
    v_resultCount INT;
    v_EMCA_ID2 BIGINT;
    v_PassFailSubjectFlag VARCHAR(50);
    v_secrank1 INT;
    v_Compulsory VARCHAR(MAX);
    v_rankCalFlagMAINpass BIGINT;
    v_rankCalFlagSUBpass BIGINT;
    v_GroupMinMarks INT;
    v_groupids INT;
    v_passfailflagN VARCHAR(50);
    v_passfail10N VARCHAR(50);
    v_NotCompSubcountM INT;
    v_NotCompSubcountL INT;
    v_NotCompSubcountF INT;
    v_NotCompSubcountA INT;
    v_NotCompSubcountOP INT;
    v_AMFCondition VARCHAR(50);
    v_localtest VARCHAR(10);
    v_row_count INT;
BEGIN

    v_secrank1 := 0;
    v_NotCompSubcountM := 0;
    v_NotCompSubcountL := 0;
    v_NotCompSubcountF := 0;
    v_NotCompSubcountA := 0;
    v_SUbmedicalcount := 0;
    v_secrank1 := 0;
    v_count10 := 0;
    v_count10M := 0;
    v_count10F := 0;
    v_count10op := 0;

    FOR v_amst_id IN 
        SELECT "AMST_ID" FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ESTMP_Result" = 'Pass' 
        ORDER BY "ESTMP_Percentage" DESC
    LOOP

        SELECT "EMCA_Id" INTO v_EMCA_ID 
        FROM "Exm"."Exm_Yearly_Category" 
        WHERE "EMCA_Id" IN (
            SELECT DISTINCT "EMCA_Id" FROM "Exm"."Exm_Category_Class" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id
        ) AND "ASMAY_Id" = p_ASMAY_Id;

        v_count10 := NULL;
        SELECT COUNT(*) INTO v_count10 
        FROM "Exm"."Exm_PassFailRank_Condition" 
        WHERE "EPFRC_Condition" = 'OP' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
        AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
        AND "EPFRC_ActiveFlag" = TRUE;

        IF v_count10 > 0 THEN
            SELECT "EPFRC_OverallPercentage" INTO v_passfail1OP 
            FROM "Exm"."Exm_PassFailRank_Condition" 
            WHERE "EPFRC_Condition" = 'OP' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "EPFRC_ActiveFlag" = TRUE;

            v_ESTMP_Percentage_Overallpercentage := CAST((v_ESTMP_TotalObtMarks / NULLIF(v_ESTMP_TotalMaxMarks, 0)) * 100 AS DECIMAL(10,2));

            IF v_ESTMP_Percentage_Overallpercentage < v_passfail1OP::DECIMAL THEN
                v_passfailflagOP := 'false';
            ELSE
                v_passfailflagOP := 'true';
            END IF;
        ELSE
            v_passfailflagOP := 'true';
        END IF;

        v_count10 := NULL;
        SELECT COUNT(*) INTO v_count10 
        FROM "Exm"."Exm_PassFailRank_Condition" 
        WHERE "EPFRC_Condition" = 'C' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
        AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_ID" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
        AND "EPFRC_ActiveFlag" = TRUE;

        IF v_count10 > 0 THEN
            FOR v_groupids IN 
                SELECT DISTINCT "Exm"."Exm_Subject_Group"."ESG_Id" 
                FROM "Exm"."Exm_Subject_Group" 
                INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group"."ESG_Id" 
                WHERE "EMCA_Id" = v_EMCA_ID AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                AND "EME_Id" = p_EME_Id AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y'
                AND "Exm"."Exm_Subject_Group"."ESG_Id" IN (
                    SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                    FROM "Exm"."Exm_Subject_Group_Subjects" 
                    INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                    WHERE "EME_Id" = p_EME_Id
                )
            LOOP
                SELECT SUM("Exm"."Exm_Subject_Group"."ESG_GroupMinMarks") INTO v_GroupMinMarks
                FROM "Exm"."Exm_Subject_Group" 
                WHERE "ESG_Id" IN (
                    SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                    FROM "Exm"."Exm_Subject_Group_Subjects" 
                    INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                    WHERE "EME_Id" = p_EME_Id
                ) AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = v_EMCA_ID 
                AND "ESG_Id" = v_groupids AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y';

                v_marks := NULL;
                SELECT ((SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_ObtainedMarks") / 
                        NULLIF(SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_MaxMarks"), 0)) * 100) - v_GroupMinMarks 
                INTO v_marks
                FROM "Exm"."Exm_Subject_Group"
                INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Student_Marks_Process_Subjectwise"."ISMS_Id"
                INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group"."ESG_Id"
                WHERE "Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id AND "Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id 
                AND "Exm"."Exm_Subject_Group_Exams"."EME_Id" = p_EME_Id 
                AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y'
                AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = v_amst_id 
                AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."EME_Id" = p_EME_Id 
                AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids;

                SELECT "EPFRC_PassFailFlag" INTO v_passfail10C 
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'C' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
                AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
                AND "EPFRC_ActiveFlag" = TRUE;

                IF v_marks >= 0 THEN
                    IF v_passfail10C = 'Pass' THEN
                        v_Compulsory := 'TRUE';
                    END IF;
                ELSE
                    v_Compulsory := 'FALSE';
                    EXIT;
                END IF;
            END LOOP;
        ELSE
            v_Compulsory := 'TRUE';
        END IF;

        IF (v_marks >= 0 AND v_Compulsory = 'TRUE') OR (v_Compulsory = 'FALSE') THEN

            v_count10 := NULL;
            SELECT COUNT(*) INTO v_count10 
            FROM "Exm"."Exm_PassFailRank_Condition" 
            WHERE "EPFRC_Condition" = 'N' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "EPFRC_ActiveFlag" = TRUE;

            IF v_count10 > 0 THEN
                SELECT "EMCA_Id" INTO v_EMCA_ID 
                FROM "Exm"."Exm_Yearly_Category" 
                WHERE "EMCA_Id" IN (
                    SELECT DISTINCT "EMCA_Id" FROM "Exm"."Exm_Category_Class" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id
                ) AND "ASMAY_Id" = p_ASMAY_Id;

                SELECT "EPFRC_PassFailFlag" INTO v_passfail10N 
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'N' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
                AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id;

                FOR v_groupids IN 
                    SELECT DISTINCT "Exm"."Exm_Subject_Group"."ESG_Id" 
                    FROM "Exm"."Exm_Subject_Group" 
                    INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group_Exams"."ESG_Id" 
                    WHERE "EMCA_Id" = v_EMCA_ID AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "EME_Id" = p_EME_Id AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                    AND "Exm"."Exm_Subject_Group"."ESG_Id" IN (
                        SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                        FROM "Exm"."Exm_Subject_Group_Subjects" 
                        INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                        WHERE "EME_Id" = p_EME_Id
                    )
                LOOP
                    SELECT SUM("Exm"."Exm_Subject_Group"."ESG_GroupMinMarks") INTO v_GroupMinMarks
                    FROM "Exm"."Exm_Subject_Group" 
                    WHERE "ESG_Id" IN (
                        SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                        FROM "Exm"."Exm_Subject_Group_Subjects" 
                        INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                        WHERE "EME_Id" = p_EME_Id
                    ) AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = v_EMCA_ID 
                    AND "ESG_Id" = v_groupids AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N';

                    v_marks := NULL;
                    SELECT ((SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_ObtainedMarks") / 
                            NULLIF(SUM("Exm"."Exm_Student_Marks_Process_Subjectwise"."ESTMPS_MaxMarks"), 0)) * 100) - v_GroupMinMarks 
                    INTO v_marks
                    FROM "Exm"."Exm_Subject_Group"
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                    INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group"."ESG_Id"
                    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Student_Marks_Process_Subjectwise"."ISMS_Id"
                    WHERE "Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id AND "Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id 
                    AND "Exm"."Exm_Subject_Group_Exams"."EME_Id" = p_EME_Id 
                    AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N'
                    AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = v_amst_id 
                    AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."EME_Id" = p_EME_Id 
                    AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                    AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids;

                    IF v_marks >= 0 THEN
                        IF v_passfail10N = 'Pass' THEN
                            v_passfailflagN := 'true';
                        END IF;
                    ELSE
                        SELECT "ESTMPS_PassFailFlg" INTO v_AMFCondition
                        FROM "Exm"."Exm_Subject_Group"
                        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm"."Exm_Subject_Group_Exams"."ESG_Id" = "Exm"."Exm_Subject_Group"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Student_Marks_Process_Subjectwise"."ISMS_Id"
                        WHERE "Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id AND "Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id 
                        AND "Exm"."Exm_Subject_Group_Exams"."EME_Id" = p_EME_Id 
                        AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N'
                        AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = v_amst_id 
                        AND "Exm"."Exm_Student_Marks_Process_Subjectwise"."EME_Id" = p_EME_Id 
                        AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                        AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids
                        LIMIT 1;

                        IF v_AMFCondition = 'M' THEN
                            v_passfailflagN := 'false';
                            IF v_NotCompSubcountM = 0 THEN
                                v_NotCompSubcountM := 1;
                            ELSIF v_NotCompSubcountM >= 1 THEN
                                v_NotCompSubcountM := v_NotCompSubcountM + 1;
                            END IF;
                        ELSIF v_AMFCondition = 'L' THEN
                            v_passfailflagN := 'false';
                            IF v_NotCompSubcountL = 0 THEN
                                v_NotCompSubcountL := 1;
                            ELSIF v_NotCompSubcountL >= 1 THEN
                                v_NotCompSubcountL := v_NotCompSubcountL + 1;
                            END IF;
                        ELSIF v_AMFCondition = 'Fail' THEN
                            v_passfailflagN := 'false';
                            IF v_NotCompSubcountF = 0 THEN
                                v_NotCompSubcountF := 1;
                            ELSIF v_NotCompSubcountF >= 1 THEN
                                v_NotCompSubcountF := v_NotCompSubcountF + 1;
                            END IF;
                        ELSIF v_AMFCondition = 'AB' THEN
                            v_passfailflagN := 'false';
                            IF v_NotCompSubcountA = 0 THEN
                                v_NotCompSubcountA := 1;
                            ELSIF v_NotCompSubcountA >= 1 THEN
                                v_NotCompSubcountA := v_NotCompSubcountA + 1;
                            END IF;
                        END IF;
                    END IF;
                END LOOP;
            ELSE
                v_passfailflagN := 'true';
            END IF;

            v_count10 := NULL;
            SELECT COUNT(*) INTO v_count10 
            FROM "Exm"."Exm_PassFailRank_Condition" 
            WHERE "EPFRC_Condition" = 'PO' AND "EME_Id" = p_EME_Id AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'IE' AND "ASMAY_ID" = p_ASMAY_Id AND "MI_Id" = p_MI_Id 
            AND "EPFRC_ActiveFlag" = TRUE;

            IF v_count10 > 0 THEN
                SELECT COUNT("ESTMPS_PassFailFlg") INTO v_totalCount 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "AMST_ID" = v_amst_id AND "EME_Id" = p_EME_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id
                AND "ISMS_Id" NOT IN (
                    SELECT DISTINCT "ESGS"."ISMS_Id" 
                    FROM "Exm"."Exm_Subject_Group" "ESG"
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" "ESGS" ON "ESGS"."ESG_Id" = "ESG"."ESG_Id"
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = v_EMCA_ID 
                    AND "ESG_CompulsoryFlag" IN ('Y', 'N')
                )
                AND "ISMS_Id" NOT IN (
                    SELECT DISTINCT "EYCES"."ISMS_Id" 
                    FROM "Exm"."Exm_Category_Class" AS "ECC"
                    INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "EYC"."MI_Id" = p_MI_Id 
                        AND "EYC"."ASMAY_Id" = p_ASMAY_Id AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
                    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
                    WHERE "ECC"."MI_Id" = p_MI_Id AND "ECC"."ASMAY_Id" = p_ASMAY_Id 
                    AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id 
                    AND "EYCES"."EYCES_AplResultFlg" = FALSE AND "EYCE"."EME_Id" =