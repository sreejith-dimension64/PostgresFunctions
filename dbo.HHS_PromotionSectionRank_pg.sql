CREATE OR REPLACE FUNCTION "dbo"."HHS_PromotionSectionRank"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_pass_fail_flagR int;
    v_passfail10AT int;
    v_passfail10FL int;
    v_rankCalFlagSUBpassM int;
    v_pass_fail_flagc varchar(100);
    v_rankCalFlagMAINpassM int;
    v_PassFailSubjectFlagC varchar(50);
    v_marksobtained decimal(10,2);
    v_total_marks decimal(10,2);
    v_EYCES_Id int;
    v_EYCE_Id int;
    v_ISMS_Id decimal(10,2);
    v_EYCES_AplResultFlg boolean;
    v_EYCES_MarksEntryMax decimal(10,2);
    v_EYCES_MaxMarks decimal(10,2);
    v_EYCES_MinMarks decimal(10,2);
    v_EMGR_Id int;
    v_ESTM_Marks decimal(10,2);
    v_ESTM_MarksGradeFlg char(1);
    v_ESTMP_Result varchar(30);
    v_AMST_Id bigint;
    v_ESTMP_Percentage decimal(10,2);
    v_ESTMPS_ObtainedGrade varchar(30);
    v_Exm_Grade int;
    v_ESTMP_TotalGrade varchar(30);
    v_ESTMPS_Percentage decimal(10,2);
    v_ESTMPS_MaxMarks decimal(10,2);
    v_Subject_Percentage decimal(10,2);
    v_Class_Totalmarks decimal(10,2);
    v_Class_Totalcount int;
    v_Section_Totalmarks decimal(10,2);
    v_Section_Totalcount int;
    v_FailCount int;
    v_ESTMPS_PassFailFlg varchar(30);
    v_ESTMPS_ClassAverage decimal(10,2);
    v_ESTMPS_SectionAverage decimal(10,2);
    v_ESTMPS_ClassHighest decimal(10,2);
    v_ESTMPS_SectionHighest decimal(10,2);
    v_ESTMP_ClassRank int;
    v_ESTMP_SectionRank int;
    v_ESTM_Flg varchar(10);
    v_Absentcount int;
    v_Sportscount int;
    v_Medicalcount int;
    v_Normalclassrank int;
    v_NormalSectionrank int;
    v_ExmConfig_RankingMethod varchar(50);
    v_Rank int;
    v_Ratio decimal(10,2);
    v_GredeFlag varchar(5);
    v_GradeMarksPercentage decimal(10,2);
    v_RoundOffFlg boolean;
    v_ESTM_Grade varchar(10);
    v_TotalMinMarks decimal(10,2);
    v_ESTMP_MaxMarks decimal(10,2);
    v_ESTMP_ObtainedMarks decimal(10,2);
    v_EYCES_SubExamFlg boolean;
    v_EYCES_SubSubjectFlg boolean;
    v_passfailflag varchar(50);
    v_passfail varchar(50);
    v_ODcount int;
    v_ESTMP_Percentage_Overallpercentage decimal(10,2);
    v_passfail10 varchar(10);
    v_ams varchar(10);
    v_count10 integer;
    v_count10M integer;
    v_count10F integer;
    v_count10op int;
    v_passfail10A varchar(10);
    v_passfail10M varchar(10);
    v_passfail10F varchar(10);
    v_passfail10C varchar(10);
    v_passfail10D varchar(50);
    v_passfailflagOP varchar(50);
    v_passfailflagA varchar(10);
    v_passfailflagM varchar(10);
    v_passfailflagF varchar(10);
    v_passfailflagC varchar(10);
    v_passfailflagD varchar(50);
    v_passfail1OP varchar(50);
    v_rankCalFlag varchar(10);
    v_EMCA_ID int;
    v_exmc_condition varchar(10);
    v_marks decimal(10,2);
    v_fail_count_temp int;
    v_pass_fail_flag varchar(50);
    v_overallPercentage decimal(10,2);
    v_overallFlag varchar(20);
    v_pass_sub_temp decimal(10,2);
    v_classrank1 int;
    v_fail_count integer;
    v_pass_sub integer;
    v_SUbmedicalcount integer;
    v_totalCount int;
    v_resultCount int;
    v_EMCA_ID2 bigint;
    v_PassFailSubjectFlag varchar(50);
    v_secrank1 int;
    v_Compulsory text;
    v_rankCalFlagMAINpass bigint;
    v_rankCalFlagSUBpass bigint;
    v_GroupMinMarks INT;
    v_groupids int;
    v_passfailflagN varchar(50);
    v_passfail10N varchar(50);
    v_NotCompSubcountM int;
    v_NotCompSubcountL int;
    v_NotCompSubcountF int;
    v_NotCompSubcountA int;
    v_NotCompSubcountOP int;
    v_AMFCondition varchar(50);
    v_localtest varchar(10);
    v_notcomfailsubjectscount int;
    v_notcomfailstudentcount int;
    v_notcomfailstudentabcount int;
    v_notcomfailstudentmcount int;
    v_rowcount int;
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
        SELECT "amst_id" FROM "Exm"."Exm_Student_MP_Promotion" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id 
        AND "ESTMPP_Result" = 'Pass' 
        ORDER BY "ESTMPP_Percentage" DESC
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
        WHERE ("EPFRC_Condition" = 'OP') AND "EMCA_Id" = v_EMCA_ID 
        AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_Id" = p_ASMAY_Id 
        AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

        IF (v_count10 > 0) THEN
            SELECT "EPFRC_OverallPercentage" INTO v_passfail1OP 
            FROM "Exm"."Exm_PassFailRank_Condition" 
            WHERE ("EPFRC_Condition" = 'OP') AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

            v_ESTMP_Percentage_Overallpercentage := (CAST((v_marksobtained / NULLIF(v_total_marks, 0)) * 100 AS DECIMAL(10,2)));

            IF (v_ESTMP_Percentage_Overallpercentage < v_passfail1OP::decimal) THEN
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
        WHERE ("EPFRC_Condition" = 'C') AND "EMCA_Id" = v_EMCA_ID 
        AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_ID" = p_ASMAY_Id 
        AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

        IF (v_count10 > 0) THEN
            FOR v_groupids IN 
                SELECT DISTINCT "Exm"."Exm_Subject_Group"."ESG_Id" 
                FROM "Exm"."Exm_Subject_Group"
                WHERE "EMCA_Id" = v_EMCA_ID AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y' 
                AND "esg_exampromotionflag" = 'PE'
                AND "Exm"."Exm_Subject_Group"."ESG_Id" IN (
                    SELECT DISTINCT "Exm_Subject_Group_Subjects"."ESG_Id" 
                    FROM "Exm"."Exm_Subject_Group_Subjects"
                )
            LOOP
                SELECT SUM("Exm"."Exm_Subject_Group"."ESG_GroupMinMarks") INTO v_GroupMinMarks
                FROM "Exm"."Exm_Subject_Group" 
                WHERE "ESG_Id" IN (
                    SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."esg_id" 
                    FROM "Exm"."Exm_Subject_Group_Subjects"
                ) 
                AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                AND "EMCA_Id" = v_EMCA_ID AND "esg_id" = v_groupids 
                AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y' 
                AND "esg_exampromotionflag" = 'PE';

                v_marks := NULL;
                SELECT ((SUM("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ESTMPPS_ObtainedMarks") / 
                    NULLIF(SUM("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ESTMPPS_MaxMarks"), 0)) * 100) - (v_GroupMinMarks) 
                INTO v_marks
                FROM "Exm"."Exm_Subject_Group"
                INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                    ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                    ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                WHERE ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                AND ("Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID) 
                AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y') 
                AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."amst_id" = v_amst_id) 
                AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMCL_Id" = p_ASMCL_Id) 
                AND ("Exm"."Exm_Subject_Group"."ESG_ExamPromotionFlag" = 'PE') 
                AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMS_Id" = p_ASMS_Id);

                SELECT "EPFRC_PassFailFlag" INTO v_passfail10C 
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE ("EPFRC_Condition" = 'C') AND "EMCA_Id" = v_EMCA_ID 
                AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

                IF (v_marks >= 0) THEN
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
            WHERE ("EPFRC_Condition" = 'N') AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_Id" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

            IF (v_count10 > 0) THEN
                SELECT "EMCA_Id" INTO v_EMCA_ID 
                FROM "Exm"."Exm_Yearly_Category" 
                WHERE "EMCA_Id" IN (
                    SELECT DISTINCT "EMCA_Id" FROM "exm"."Exm_Category_Class" 
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id
                ) AND "ASMAY_Id" = p_ASMAY_Id;

                SELECT "EPFRC_PassFailFlag" INTO v_passfail10N 
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE ("EPFRC_Condition" = 'N') AND "EMCA_Id" = v_EMCA_ID 
                AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_Id" = p_ASMAY_Id 
                AND "MI_Id" = p_MI_Id;

                FOR v_groupids IN 
                    SELECT DISTINCT "Exm"."Exm_Subject_Group"."ESG_Id" 
                    FROM "Exm"."Exm_Subject_Group"
                    WHERE "EMCA_Id" = v_EMCA_ID AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                    AND "esg_exampromotionflag" = 'PE' 
                    AND "Exm"."Exm_Subject_Group"."ESG_Id" IN (
                        SELECT DISTINCT "Exm_Subject_Group_Subjects"."ESG_Id" 
                        FROM "Exm"."Exm_Subject_Group_Subjects"
                    )
                LOOP
                    SELECT SUM("Exm"."Exm_Subject_Group"."ESG_GroupMinMarks") INTO v_GroupMinMarks
                    FROM "Exm"."Exm_Subject_Group" 
                    WHERE "ESG_Id" IN (
                        SELECT DISTINCT "Exm"."Exm_Subject_Group_Subjects"."esg_id" 
                        FROM "Exm"."Exm_Subject_Group_Subjects"
                    ) 
                    AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "EMCA_Id" = v_EMCA_ID AND "ESG_Id" = v_groupids 
                    AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                    AND "esg_exampromotionflag" = 'PE';

                    v_marks := NULL;
                    SELECT ((SUM("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ESTMPPS_ObtainedMarks") / 
                        NULLIF(SUM("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ESTMPPS_MaxMarks"), 0)) * 100) - (v_GroupMinMarks) 
                    INTO v_marks
                    FROM "Exm"."Exm_Subject_Group"
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                        ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                    INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                        ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                    WHERE ("Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id) 
                    AND ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                    AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                        AND "esg_exampromotionflag" = 'PE') 
                    AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."AMST_Id" = v_amst_id) 
                    AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                    AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids
                    AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMCL_Id" = p_ASMCL_Id) 
                    AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMS_Id" = p_ASMS_Id);

                    IF (v_marks >= 0) THEN
                        IF v_passfail10N = 'Pass' THEN
                            v_passfailflagN := 'true';
                        END IF;
                    ELSE
                        SELECT COUNT("ESTMPPS_PassFailFlg") INTO v_notcomfailsubjectscount
                        FROM "Exm"."Exm_Subject_Group"
                        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                            ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                            ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                        WHERE ("Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                            AND "esg_exampromotionflag" = 'PE') 
                        AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."AMST_Id" = v_amst_id) 
                        AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                        AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids;

                        SELECT COUNT("ESTMPPS_PassFailFlg") INTO v_notcomfailstudentcount
                        FROM "Exm"."Exm_Subject_Group"
                        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                            ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                            ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                        WHERE ("Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                            AND "esg_exampromotionflag" = 'PE') 
                        AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."AMST_Id" = v_amst_id) 
                        AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                        AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids 
                        AND "ESTMPPS_PassFailFlg" = 'Fail';

                        SELECT COUNT("ESTMPPS_PassFailFlg") INTO v_notcomfailstudentabcount
                        FROM "Exm"."Exm_Subject_Group"
                        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                            ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                            ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                        WHERE ("Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                            AND "esg_exampromotionflag" = 'PE') 
                        AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."AMST_Id" = v_amst_id) 
                        AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                        AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids 
                        AND "ESTMPPS_PassFailFlg" IN ('Fail', 'AB');

                        SELECT COUNT("ESTMPPS_PassFailFlg") INTO v_notcomfailstudentmcount
                        FROM "Exm"."Exm_Subject_Group"
                        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" 
                            ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id"
                        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                            ON "Exm"."Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                        WHERE ("Exm"."Exm_Subject_Group"."MI_Id" = p_MI_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id) 
                        AND ("Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'N' 
                            AND "esg_exampromotionflag" = 'PE') 
                        AND ("Exm"."Exm_Stu_MP_Promo_Subjectwise"."AMST_Id" = v_amst_id) 
                        AND "Exm"."Exm_Subject_Group"."EMCA_Id" = v_EMCA_ID 
                        AND "Exm"."Exm_Subject_Group"."ESG_Id" = v_groupids 
                        AND "ESTMPPS_PassFailFlg" IN ('M');

                        IF (v_notcomfailsubjectscount = v_notcomfailstudentcount) 
                            OR (v_notcomfailstudentabcount < v_notcomfailsubjectscount) THEN
                            v_NotCompSubcountF := 1;
                        ELSIF (v_notcomfailstudentmcount <> 0) THEN
                            v_NotCompSubcountF := 0;
                        END IF;
                    END IF;
                END LOOP;
            ELSE
                v_passfailflagN := 'true';
            END IF;

            v_count10 := NULL;
            SELECT COUNT(*) INTO v_count10 
            FROM "Exm"."Exm_PassFailRank_Condition" 
            WHERE ("EPFRC_Condition" = 'PO') AND "EMCA_Id" = v_EMCA_ID 
            AND "EPFRC_ExamFlag" = 'PE' AND "ASMAY_ID" = p_ASMAY_Id 
            AND "MI_Id" = p_MI_Id AND "EPFRC_ActiveFlag" = true;

            IF (v_count10 > 0) THEN
                SELECT COUNT("ESTMPPS_PassFailFlg") INTO v_totalCount 
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                WHERE ("amst_id" = v_amst_id) AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id
                AND "ISMS_Id" NOT IN (
                    SELECT DISTINCT "ESGS"."ISMS_Id" 
                    FROM "Exm"."Exm_Subject_Group" "ESG"
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" "ESGS" 
                        ON "ESGS"."ESG_Id" = "ESG"."ESG_Id"
                    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "EMCA_Id" = v_EMCA_ID AND "ESG_CompulsoryFlag" IN ('Y', 'N')
                )
                AND "ISMS_Id" NOT IN (
                    SELECT DISTINCT "EYCES"."ISMS_Id" 
                    FROM "Exm"."Exm_Category_Class" AS "ECC"
                    INNER JOIN "Exm"."Exm