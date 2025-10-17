CREATE OR REPLACE FUNCTION "dbo"."EXAM_WITHOUT_RULES_PROMOTION_Calculation"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_EMCA_ID int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AyCl_id bigint;
    v_Amst_id bigint;
    v_eme_id int;
    v_total_marks float;
    v_total_min float;
    v_marksobtained float;
    v_Average float;
    v_classRank int;
    v_totalMinMarks float;
    v_emgr_id int;
    v_FResult varchar(10);
    v_Etgr_id int;
    v_secrank int;
    v_EYC_Id int;
    v_pass_fail_flag varchar(100);
    v_amsu_id bigint;
    v_amstid bigint;
    v_emes_max_marks float;
    v_emes_min_marks float;
    v_ems_marks float;
    v_WhetherOptional bigint;
    v_flgPassFail varchar(20);
    v_amsu_idp bigint;
    v_ExmPassFail varchar(1);
    v_ems_marks_final float;
    v_MaxMarksp float;
    v_emgr_idg bigint;
    v_emgr_idfinal bigint;
    v_MaxMarkspGroup float;
    v_ems_marks_finalGroup float;
    v_MaxMarkspGroupwhole float;
    v_MinMarkspGroupwhole float;
    v_ems_marks_finalGroupwhole float;
    v_amst_idCr bigint;
    v_MarksObtainedCr float;
    v_Rank int;
    v_Mrks float;
    v_gr_type char(1);
    v_Ratio float;
    v_MinMarksp float;
    v_FlgPFwt varchar(1);
    v_Marks float;
    v_totMarks float;
    v_intCount bigint;
    v_Diff float;
    v_SubIdfinal bigint;
    v_sumems_marks_wt float;
    v_minsumems_marks_wt float;
    v_maxsumems_marks_wt float;
    v_SubPassFail varchar(1);
    v_SubCount int;
    v_failSub int;
    v_amsu_idGr bigint;
    v_ReqGr float;
    v_Total float;
    v_PassEachSub varchar(1);
    v_PassingCondition varchar(1);
    v_Per_or_mark varchar;
    v_ratiopro float;
    v_etp_marks float;
    v_Per float;
    v_PerOrMarks varchar(10);
    v_ESS_Max_Mark float;
    v_totalCount int;
    v_resultCount int;
    v_overallFlag varchar;
    v_overallPercentage float;
    v_PassFailSubjectFlag varchar;
    v_fail_count_temp integer;
    v_EMGD_Name varchar(50);
    v_ASMS_Id bigint;
    v_passfail10 varchar(10);
    v_ams varchar(10);
    v_count10 integer;
    v_count10M integer;
    v_count10F integer;
    v_passfail10A varchar(10);
    v_passfail10M varchar(10);
    v_passfail10F varchar(10);
    v_passfail10C varchar(10);
    v_passfailflagA varchar(10);
    v_passfailflagM varchar(10);
    v_passfailflagF varchar(10);
    v_passfailflagC varchar(10);
    v_passfailflag varchar(10);
    v_rankCalFlag varchar(10);
    v_exmc_condition varchar(10);
    v_FRatio bigint;
    v_row_count int;
    rec_ClassId RECORD;
    rec_studentwise RECORD;
    rec_ExmSub RECORD;
    rec_rank2 RECORD;
BEGIN
    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "EMCA_Id" = p_EMCA_ID;

    FOR rec_ClassId IN 
        SELECT DISTINCT "ASMCL_Id" 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "AMST_Id" IN (
            SELECT DISTINCT "Adm_M_Student"."AMST_Id" 
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                AND "Adm_M_Student"."AMST_SOL" = 'S' 
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" 
            WHERE "Adm_School_Y_Student"."ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" EYCE 
                INNER JOIN "Exm"."Exm_Student_Marks" ESM ON EYCE."EME_Id" = ESM."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            )
        )
    LOOP
        v_AyCl_id := rec_ClassId."ASMCL_Id";

        DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
        WHERE "AMST_ID" = v_amstid 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" EYCE 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ESM ON EYCE."EME_Id" = ESM."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            );

        DELETE FROM "Exm"."Exm_Student_MP_Promotion" 
        WHERE "AMST_ID" = v_amstid 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" EYCE 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ESM ON EYCE."EME_Id" = ESM."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            );

        FOR rec_studentwise IN 
            SELECT DISTINCT "amst_id" 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "AMST_Id" IN (
                SELECT DISTINCT "Adm_M_Student"."AMST_Id" 
                FROM "dbo"."Adm_M_Student"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_M_Student"."AMST_SOL" = 'S' 
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
                    AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
                WHERE "Adm_School_Y_Student"."ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Exm"."Exm_Yearly_Category_Exams" EYCE 
                    INNER JOIN "Exm"."Exm_Student_Marks" ESM ON EYCE."EME_Id" = ESM."EME_Id" 
                    WHERE "EYC_Id" = v_EYC_Id
                )
            )
        LOOP
            v_amstid := rec_studentwise."amst_id";

            v_PassEachSub := '';
            v_Diff := 0;
            v_SubIdfinal := 0;
            v_sumems_marks_wt := 0;
            v_minsumems_marks_wt := 0;
            v_maxsumems_marks_wt := 0;
            v_SubPassFail := '';

            FOR rec_ExmSub IN 
                SELECT DISTINCT "ISMS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "ASMCL_Id" = v_AyCl_id 
                    AND "AMST_Id" = v_amstid
            LOOP
                v_SubIdfinal := rec_ExmSub."ISMS_Id";

                SELECT SUM("ESTMPS_ObtainedMarks"), SUM("EYCES_MinMarks"), SUM("ESTMPS_MaxMarks") 
                INTO v_sumems_marks_wt, v_minsumems_marks_wt, v_maxsumems_marks_wt
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" ESM 
                INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" EYCES ON EYCES."ISMS_Id" = ESM."ISMS_Id" 
                WHERE "ASMCL_Id" = v_AyCl_id 
                    AND ESM."ISMS_Id" = v_SubIdfinal 
                    AND "AMST_Id" = v_amstid;

                IF v_sumems_marks_wt < v_minsumems_marks_wt THEN
                    v_SubPassFail := 'F';
                    v_PassEachSub := 'F';
                ELSE
                    v_SubPassFail := 'P';
                    v_diff := 0;
                END IF;

                IF v_SubPassFail = 'P' OR v_SubPassFail = 'F' THEN
                    SELECT COUNT(*) INTO v_row_count
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                    WHERE "ASMCL_Id" = v_AyCl_id 
                        AND "AMST_Id" = v_amstid 
                        AND "ISMS_Id" = v_SubIdfinal 
                        AND "ESTMPS_PassFailFlg" = 'M';

                    IF v_row_count = 0 THEN
                        v_SubPassFail := v_SubPassFail;
                    ELSE
                        v_SubPassFail := 'M';
                    END IF;

                    SELECT COUNT(*) INTO v_row_count
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                    WHERE "ASMCL_Id" = v_AyCl_id 
                        AND "AMST_Id" = v_amstid 
                        AND "ISMS_Id" = v_SubIdfinal 
                        AND "ESTMPS_PassFailFlg" = 'A';

                    IF v_row_count = 0 THEN
                        v_SubPassFail := v_SubPassFail;
                    ELSE
                        v_SubPassFail := 'A';
                    END IF;
                END IF;

                v_emgr_idfinal := 0;
                v_PassingCondition := '';
                
                SELECT COALESCE(EYCES."EMGR_Id", 0), "EYCES_MarksGradeEntryFlg", "EYCES_MaxMarks", "ESTMPS_PassFailFlg" 
                INTO v_emgr_idfinal, v_PerOrMarks, v_ESS_Max_Mark, v_PassingCondition
                FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" EYCES 
                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" EYCE ON EYCES."EYCE_Id" = EYCE."EYCE_Id" 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ESMPS ON ESMPS."EME_Id" = EYCE."EME_Id" 
                WHERE EYCE."EYC_Id" = v_EYC_Id
                LIMIT 1;

                IF v_emgr_idfinal <> 0 THEN
                    SELECT "EMGR_MarksPerFlag" INTO v_gr_type
                    FROM "Exm"."Exm_Master_Grade" 
                    WHERE "EMGR_Id" = v_emgr_idfinal;

                    v_per := 0;

                    IF v_sumems_marks_wt <> 0 THEN
                        v_per := ROUND((v_sumems_marks_wt / v_maxsumems_marks_wt) * 100, 1);
                    END IF;

                    IF v_gr_type = 'A' THEN
                        SELECT "EMGD_Name" INTO v_EMGD_Name
                        FROM "Exm"."Exm_Master_Grade_Details" 
                        WHERE v_per BETWEEN "EMGD_From" AND "EMGD_To" 
                            AND "emgr_id" = v_emgr_idfinal
                        LIMIT 1;
                    ELSE
                        SELECT "EMGD_Name" INTO v_EMGD_Name
                        FROM "Exm"."Exm_Master_Grade_Details" 
                        WHERE v_sumems_marks_wt BETWEEN "EMGD_From" AND "EMGD_To" 
                            AND "emgr_id" = v_emgr_idfinal
                        LIMIT 1;
                    END IF;
                END IF;

                SELECT "ASMCL_Id", "ASMS_Id" INTO v_aycl_id, v_ASMS_Id
                FROM "Adm_School_Y_Student" 
                WHERE "amst_id" = v_amst_id
                LIMIT 1;

                INSERT INTO "Exm"."Exm_Stu_MP_Promo_Subjectwise"(
                    "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", 
                    "ESTMPPS_MaxMarks", "ESTMPPS_ObtainedMarks", "ESTMPPS_ObtainedGrade", 
                    "ESTMPPS_PassFailFlg", "CreatedDate", "UpdatedDate"
                ) 
                VALUES(
                    p_MI_Id, p_ASMAY_Id, v_AyCL_Id, v_ASMS_Id, v_amstid, v_amsu_idp, 
                    v_MaxMarksp, v_ems_marks_final, v_EMGD_Name, 
                    v_FlgPFwt, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                );
            END LOOP;
        END LOOP;

        FOR rec_rank2 IN 
            SELECT "AMST_Id", "ASMCL_Id", "ESTMP_TotalMaxMarks", "ESTMP_TotalObtMarks", 
                   "ESTMP_TotalGrade", "ESTMP_Result", "ESTMP_SectionRank", "ESTMP_ClassRank" 
            FROM "Exm"."Exm_Student_Marks_Process" 
            WHERE "ASMCL_Id" = v_AyCl_id 
            ORDER BY "ESTMP_TotalObtMarks" DESC
        LOOP
            v_amst_id := rec_rank2."AMST_Id";
            v_aycl_id := rec_rank2."ASMCL_Id";
            v_total_marks := rec_rank2."ESTMP_TotalMaxMarks";
            v_marksobtained := rec_rank2."ESTMP_TotalObtMarks";
            v_Etgr_id := rec_rank2."ESTMP_TotalGrade";
            v_FResult := rec_rank2."ESTMP_Result";
            v_SecRank := rec_rank2."ESTMP_SectionRank";
            v_ClassRank := rec_rank2."ESTMP_ClassRank";

            SELECT COUNT(*) INTO v_row_count
            FROM "Exm"."Exm_Student_MP_Promotion" 
            WHERE "ASMCL_Id" = v_AyCl_id 
                AND "amst_id" = v_amst_id;

            IF v_row_count = 0 THEN
                SELECT SUM("ESTMP_TotalMaxMarks"), SUM("ESTMP_TotalObtMarks") 
                INTO v_total_marks, v_marksobtained
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "ASMCL_Id" = v_AyCl_id 
                    AND "amst_id" = v_amst_id;

                v_Average := v_marksobtained / (v_total_marks / 100);
                v_Average := ROUND(v_Average::numeric, 2);

                SELECT COUNT(*) INTO v_row_count
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'C' 
                    AND "EMCA_Id" = p_EMCA_ID 
                    AND "EPFRC_ExamFlag" = 'PE' 
                    AND "ASMAY_Id" = p_ASMAY_Id;

                IF v_row_count > 0 THEN
                    SELECT "EMCA_Id" INTO p_EMCA_ID
                    FROM "Exm"."Exm_Yearly_Category" 
                    WHERE "EMCA_Id" IN (
                        SELECT "EMCA_Id" 
                        FROM "Exm"."Exm_Yearly_Category" 
                        WHERE "EYC_Id" IN (
                            SELECT "EYC_Id" 
                            FROM "Exm"."Exm_Yearly_Category_Exams" a 
                            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" b ON a."EYCE_Id" = b."EYCE_Id" 
                            INNER JOIN "Exm"."Exm_Student_Marks" c ON c."ISMS_Id" = b."ISMS_Id" 
                                AND c."EME_Id" = a."EME_Id" 
                            WHERE "ASMCL_Id" = v_aycl_id
                        ) 
                        AND "ASMAY_Id" = p_asmay_id
                    )
                    LIMIT 1;

                    SELECT "EPFRC_PassFailFlag" INTO v_passfail10C
                    FROM "Exm"."Exm_PassFailRank_Condition" 
                    WHERE "EPFRC_Condition" = 'C' 
                        AND "EMCA_Id" = p_EMCA_ID 
                        AND "EPFRC_ExamFlag" = 'PE' 
                        AND "ASMAY_Id" = p_ASMAY_Id
                    LIMIT 1;

                    SELECT SUM("Exm"."Exm_Stu_MP_Promo_Subjectwise"."ESTMPPS_ObtainedMarks") - "Exm"."Exm_Subject_Group"."ESG_GroupMinMarks" 
                    INTO v_marks
                    FROM "Exm"."Exm_Subject_Group" 
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm"."Exm_Subject_Group"."ESG_Id" = "Exm"."Exm_Subject_Group_Subjects"."ESG_Id" 
                    INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" ON "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id" = "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ISMS_Id"
                    WHERE "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMAY_Id" = p_asmay_id 
                        AND "Exm"."Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y' 
                        AND "Exm"."Exm_Stu_MP_Promo_Subjectwise"."amst_id" = v_amst_id 
                        AND "Exm"."Exm_Stu_MP_Promo_Subjectwise"."ASMCL_Id" = v_aycl_id
                    GROUP BY "Exm"."Exm_Subject_Group"."ESG_GroupMinMarks"
                    LIMIT 1;

                    IF v_marks >= 0 THEN
                        IF v_passfail10C = 'P' THEN
                            v_passfailflagC := 'true';
                        ELSIF v_passfail10C = 'F' THEN
                            v_passfailflagC := 'false';
                        END IF;
                    ELSE
                        v_passfailflagC := 'false';
                    END IF;
                ELSE
                    v_passfailflagC := 'true';
                END IF;

                SELECT COUNT(*) INTO v_row_count
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'A' 
                    AND "EMCA_Id" = p_EMCA_ID 
                    AND "EPFRC_ExamFlag" = 'PE' 
                    AND "ASMAY_Id" = p_ASMAY_Id;

                IF v_row_count > 0 THEN
                    SELECT COUNT(*) INTO v_count10
                    FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                    WHERE "amst_id" = v_amstid 
                        AND "ESTMPPS_PassFailFlg" = 'A';

                    SELECT "EMCA_Id" INTO p_EMCA_ID
                    FROM "Exm"."Exm_Yearly_Category" 
                    WHERE "EMCA_Id" IN (
                        SELECT "EMCA_Id" 
                        FROM "Exm"."Exm_Yearly_Category" 
                        WHERE "EYC_Id" IN (
                            SELECT "EYC_Id" 
                            FROM "Exm"."Exm_Yearly_Category_Exams" a 
                            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" b ON a."EYCE_Id" = b."EYCE_Id" 
                            INNER JOIN "Exm"."Exm_Student_Marks" c ON c."ISMS_Id" = b."ISMS_Id" 
                                AND c."EME_Id" = a."EME_Id" 
                            WHERE "ASMCL_Id" = v_aycl_id
                        ) 
                        AND "ASMAY_Id" = p_ASMAY_ID
                    )
                    LIMIT 1;

                    SELECT "EPFRC_PassFailFlag" INTO v_passfail10A
                    FROM "Exm"."Exm_PassFailRank_Condition" 
                    WHERE v_count10 BETWEEN "EPFRC_From" AND "EPFRC_To" 
                        AND "EPFRC_Condition" = 'A' 
                        AND "EMCA_Id" = p_EMCA_ID 
                        AND "EPFRC_Condition" = 'PE' 
                        AND "ASMAY_Id" = p_ASMAY_ID
                    LIMIT 1;

                    IF v_passfail10A = 'P' THEN
                        v_passfailflagA := 'true';
                    ELSIF v_passfail10A = 'F' THEN
                        v_passfailflagA := 'false';
                    END IF;
                ELSE
                    v_passfailflagA := 'true';
                END IF;

                SELECT COUNT(*) INTO v_row_count
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'M' 
                    AND "EMCA_Id" = p_EMCA_ID 
                    AND "EPFRC_ExamFlag" = 'PE' 
                    AND "ASMAY_Id" = p_ASMAY_ID;

                IF v_row_count > 0 THEN
                    SELECT COUNT(*) INTO v_count10
                    FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                    WHERE "amst_id" = v_amstid 
                        AND "ASMCL_Id" = v_aycl_id 
                        AND "ESTMPPS_PassFailFlg" = 'M';

                    SELECT "EMCA_Id" INTO p_EMCA_ID
                    FROM "Exm"."Exm_Yearly_Category" 
                    WHERE "EMCA_Id" IN (
                        SELECT "EMCA_Id" 
                        FROM "Exm"."Exm_Yearly_Category" 
                        WHERE "EYC_Id" IN (
                            SELECT "EYC_Id" 
                            FROM "Exm"."Exm_Yearly_Category_Exams" a 
                            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" b ON a."EYCE_Id" = b."EYCE_Id" 
                            INNER JOIN "Exm"."Exm_Student_Marks" c ON c."ISMS_Id" = b."ISMS_Id" 
                                AND c."EME_Id" = a."EME_Id" 
                            WHERE "ASMCL_Id" = v_aycl_id
                        ) 
                        AND "ASMAY_Id" = p_ASMAY_ID
                    )
                    LIMIT 1;

                    SELECT "EPFRC_PassFailFlag" INTO v_passfail10M
                    FROM "Exm"."Exm_PassFailRank_Condition" 
                    WHERE v_count10 BETWEEN "EPFRC_From" AND "EPFRC_To" 
                        AND "EPFRC_Condition" = 'M' 
                        AND "Emca_id" = p_EMCA_ID 
                        AND "EPFRC_ExamFlag" = 'PE' 
                        AND "ASMAY_Id" = p_ASMAY_ID
                    LIMIT 1;

                    IF v_passfail10M = 'P' THEN
                        v_passfailflagM := 'true';
                    ELSIF v_passfail10M = 'F' THEN
                        v_passfailflagM := 'false';
                    END IF;
                ELSE
                    v_passfailflagM := 'true';
                END IF;

                SELECT COUNT(*) INTO v_row_count
                FROM "Exm"."Exm_PassFailRank_Condition" 
                WHERE "EPFRC_Condition" = 'F' 
                    AND "EMCA_Id" = p_EMCA_ID 
                    AND "EPFRC_ExamFlag" = 'PE' 
                    AND "ASMAY_Id" = p_ASMAY_ID;

                IF v_row_count > 0 THEN
                    SELECT COUNT(*) INTO v_count10
                    FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
                    WHERE "amst_id" = v_amstid 
                        AND "ASMCL_Id" = v_aycl_id 
                        AND "ESTMPPS_PassFailFlg" = 'F';

                    SELECT "EMCA_Id" INTO p_EMCA_ID
                    FROM "Exm"."Exm_Yearly_Category" 
                    WHERE "EMCA_Id" IN (
                        SELECT "EMCA_Id" 
                        FROM "Exm"."Exm_Yearly_Category" 
                        WHERE "EYC_Id" IN (
                            SELECT "EYC_Id" 
                            FROM "Exm"."Exm_Yearly_Category_Exams" a 
                            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" b ON a."EYCE_Id" = b."EYCE_Id" 
                            INNER