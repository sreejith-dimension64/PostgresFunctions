CREATE OR REPLACE FUNCTION "dbo"."EXAM_RULES_PROMOTION_Calculation"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_EMCA_Id int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_pass_fail_flag varchar(100);
    v_AyCl_id bigint;
    v_amst_id bigint;
    v_eme_id int;
    v_total_marks float;
    v_total_min float;
    v_marksobtained float;
    v_totalMinMarks float;
    v_FResult varchar(50);
    v_EYC_Id int;
    v_EMP_Id int;
    v_EMP_Max_Marks float;
    v_EMP_Min_Marks float;
    v_amsu_id bigint;
    v_emp_p_m_flag varchar(10);
    v_emp_w_mark float;
    v_emp_app_result int;
    v_ETP_Id int;
    v_ETP_Per float;
    v_ETP_Max float;
    v_ETP_Best int;
    v_EMGR_Id int;
    v_etp_mark float;
    v_ETP_Group_Name varchar(50);
    v_ETP_Display_Name varchar(50);
    v_amstid bigint;
    v_emes_max_marks float;
    v_emes_min_marks float;
    v_ems_marks float;
    v_flgPassFail varchar(20);
    v_EMES_Marks_Grade varchar(20);
    v_oldmax float;
    v_newratio float;
    v_ratiomarks float;
    v_emss_idp int;
    v_amsu_idp bigint;
    v_amsu_idpr bigint;
    v_etm_marks float;
    v_ExmPassFail varchar(1);
    v_ems_marks_final float;
    v_MaxMarksp float;
    v_emgr_idg int;
    v_et_id int;
    v_Etgr_id int;
    v_emgr_idfinal int;
    v_MaxMarkspGroup float;
    v_ems_marks_finalGroup float;
    v_MaxMarkspGroupwhole float;
    v_MinMarkspGroupwhole float;
    v_ems_marks_finalGroupwhole float;
    v_gr_type char(1);
    v_Ratio float;
    v_MinMarksp float;
    v_FlgPFwt varchar(1);
    v_Marks float;
    v_totMarks float;
    v_intCount int;
    v_Diff float;
    v_SubIdfinal bigint;
    v_sumems_marks_wt float;
    v_minsumems_marks_wt float;
    v_maxsumems_marks_wt float;
    v_SubPassFail varchar(1);
    v_failSub int;
    v_amsu_idGr bigint;
    v_ReqGr float;
    v_Total float;
    v_PassEachSub varchar(1);
    v_PassingCondition varchar(1);
    v_Per_or_mark varchar(50);
    v_ratiopro float;
    v_Per float;
    v_PerOrMarks varchar(10);
    v_EMP_MarksPerFlg char(10);
    v_totalCount int;
    v_resultCount int;
    v_overallFlag varchar(50);
    v_overallPercentage float;
    v_PassFailSubjectFlag varchar(50);
    v_ESTMPPS_Id int;
    v_ASMS_Id bigint;
    v_EMGD_Name varchar(50);
    v_scount int;
    v_Section_Totalmarks decimal(10,2);
    v_P_ASMCL_Id bigint;
    v_P_ASMS_Id bigint;
    v_ISMS_Id bigint;
    v_Section_Totalcount int;
    v_ESTMPS_SectionAverage decimal(10,2);
    v_Class_Totalmarks decimal(10,2);
    v_Class_Totalcount int;
    v_ESTMPS_ClassAverage decimal(10,2);
    v_ESTMPS_ClassHighest int;
    v_ESTMPS_SectionHighest int;
    v_AppForFinalTotal bit;
    v_ASMCL_Id bigint;
    v_ASMS_Id_New bigint;
    v_EMPS_Id int;
    v_EMGDReMarks varchar;
    v_ems_marks_final_New decimal(10,2);
    v_MaxMarksp_New decimal(10,2);
    v_MinMarkssp_New decimal(10,2);
    v_FRatio bigint;
    v_passfail10 varchar(10);
    v_ams varchar(10);
    v_count10 int;
    v_count10M int;
    v_count10F int;
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
    v_rowcount int;
BEGIN

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = p_EMCA_Id;

    FOR v_ASMCL_Id, v_ASMS_Id_New IN 
        SELECT DISTINCT "ASMCL_Id", "ASMS_Id" 
        FROM "Exm"."Exm_Category_Class" 
        WHERE "EMCA_Id" = p_EMCA_Id
    LOOP

        FOR v_amstid IN 
            SELECT DISTINCT "AMST_Id" 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "AMST_Id" IN (
                SELECT DISTINCT "Adm_M_Student"."AMST_Id" 
                FROM "dbo"."Adm_M_Student" 
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_M_Student"."AMST_SOL" = 'S' 
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1  
                    AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id" 
                WHERE "dbo"."Adm_School_Y_Student"."ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                    INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                    WHERE "EYC_Id" = v_EYC_Id
                )
            ) 
            AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ASMS_Id" = v_ASMS_Id_New
        LOOP

            DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" 
            WHERE "ESTMPPS_Id" IN (
                SELECT DISTINCT "ESTMPPS_Id" 
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Dup" 
                WHERE "AMST_ID" = v_amstid 
                AND "ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                    INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                    WHERE "EYC_Id" = v_EYC_Id
                )
            );

            DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Dup" 
            WHERE "AMST_ID" = v_amstid 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            );

            DELETE FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
            WHERE "AMST_ID" = v_amstid 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            );

            DELETE FROM "Exm"."Exm_Student_MP_Promotion" 
            WHERE "AMST_ID" = v_amstid 
            AND "ASMCL_Id" IN (
                SELECT DISTINCT "ASMCL_Id" 
                FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                WHERE "EYC_Id" = v_EYC_Id
            );

            FOR v_amsu_id IN 
                SELECT DISTINCT "ISMS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                INNER JOIN "dbo"."Adm_M_Student" ON "ESMPS"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_M_Student"."AMST_SOL" = 'S' 
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1  
                    AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
                INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id" 
                WHERE "dbo"."Adm_School_Y_Student"."ASMCL_Id" IN (
                    SELECT DISTINCT "ASMCL_Id" 
                    FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE" 
                    INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "EYCE"."EME_Id" = "ESM"."EME_Id" 
                    WHERE "EYC_Id" = v_EYC_Id
                ) 
                AND "ESMPS"."AMST_Id" = v_amstid
            LOOP

                FOR v_EMP_Id, v_EYC_Id, v_EMPS_Id, v_EMP_Max_Marks, v_EMP_Min_Marks, v_amsu_id, v_emp_p_m_flag, v_emp_app_result, v_etgr_id IN 
                    SELECT DISTINCT "EMP"."EMP_Id", "EMP"."EYC_Id", "EMPS_Id", "EMPS_MaxMarks", "EMPS_MinMarks", "EMPS"."ISMS_Id", "EMP_MarksPerFlg", "EMPS_AppToResultFlg", "EMPS"."EMGR_Id" 
                    FROM "Exm"."Exm_M_Promotion" "EMP" 
                    INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" ON "EMP"."EMP_Id" = "EMPS"."EMP_Id" 
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EMP"."EYC_Id" 
                    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
                    WHERE "EMP"."EYC_Id" = v_EYC_Id 
                    AND "EMPS"."ISMS_Id" = v_amsu_id 
                    AND "EMP_MarksPerFlg" <> 'T' 
                    AND "EMPS_AppToResultFlg" = 1
                LOOP

                    FOR v_ETP_Id, v_EMP_Id, v_ETP_Per, v_ETP_Max, v_ETP_Best, v_EMGR_Id, v_etp_mark, v_ETP_Group_Name, v_ETP_Display_Name IN 
                        SELECT DISTINCT "EMPSG_Id", "EMP_Id", "EMPSG_PercentValue", "EMPSG_MaxOff", "EMPSG_BestOff", "EMGR_Id", "EMPS_ConvertForMarks", "EMPSG_GroupName", "EMPSG_DisplayName" 
                        FROM "Exm"."Exm_M_Prom_Subj_Group" "EMPSG" 
                        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" ON "EMPSG"."EMPS_Id" = "EMPS"."EMPS_Id"  
                        WHERE "EMPS"."EMPS_Id" = v_EMPS_Id
                    LOOP

                        v_Per_or_mark := v_emp_p_m_flag;

                        IF v_Per_or_mark = 'M' THEN
                            SELECT "EMPS_ConvertForMarks" INTO v_emp_max_marks 
                            FROM "Exm"."Exm_M_Prom_Subj_Group" "EMPSG" 
                            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "EMPS" ON "EMPSG"."EMPS_Id" = "EMPS"."EMPS_Id" 
                            WHERE "EMPSG_Id" = v_ETP_Id;
                        END IF;

                        v_amsu_idp := v_amsu_id;
                        v_amst_id := v_amstid;

                        v_Ratio := 0;
                        v_ems_marks_final := 0;
                        v_MaxMarksp := 0;
                        v_MinMarksp := 0;
                        v_FlgPFwt := '';

                        IF v_etp_max <= v_etp_best THEN
                            SELECT v_EMP_Max_Marks / NULLIF("ESTMPS_MaxMarks", 0) INTO v_Ratio 
                            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS"  
                            WHERE "ESS"."ISMS_Id" = v_amsu_idp 
                            AND "ESS"."eme_id" IN (
                                SELECT DISTINCT "EME_Id" 
                                FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                WHERE "EMPSG_Id" = v_ETP_Id
                            ) 
                            AND "amst_id" = v_amst_id;

                            v_Marks := 0;
                            v_totmarks := 0;
                            v_intCount := 0;

                            FOR v_marks IN 
                                SELECT "ESTMPS_ObtainedMarks"  
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                                WHERE "amst_id" = v_amst_id 
                                AND "ISMS_Id" = v_amsu_idp 
                                AND "eme_id" IN (
                                    SELECT DISTINCT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                ) 
                                ORDER BY "ESTMPS_ObtainedMarks" DESC
                            LOOP
                                EXIT WHEN v_intCount >= v_etp_best;
                                v_totmarks := v_totmarks + (v_marks * v_Ratio);
                                v_intCount := v_intCount + 1;
                            END LOOP;

                            IF v_Per_or_mark <> 'M' THEN
                                v_ems_marks_final := (v_totmarks / NULLIF(v_etp_best, 0)) * v_ETP_Per / 100;
                                
                                SELECT "ESTMPS_MaxMarks" * v_ETP_Per * v_Ratio / 100 INTO v_MaxMarksp 
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" 
                                WHERE "ISMS_Id" = v_amsu_idp  
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT DISTINCT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );

                                SELECT "EYCES_MinMarks" * v_ETP_Per * v_Ratio / 100 INTO v_MinMarksp 
                                FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
                                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" ON "ESS"."ISMS_Id" = "EYCES"."ISMS_Id" 
                                WHERE "EYCES"."ISMS_Id" = v_amsu_idp 
                                AND "amst_id" = v_amst_id  
                                AND "ESS"."eme_id" IN (
                                    SELECT DISTINCT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );
                            ELSE
                                v_ems_marks_final := (v_totmarks / NULLIF(v_etp_best, 0));
                                
                                SELECT "ESTMPS_MaxMarks" * v_Ratio INTO v_MaxMarksp 
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS"  
                                WHERE "ISMS_Id" = v_amsu_idp  
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT DISTINCT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );

                                SELECT "EYCES_MinMarks" * v_Ratio INTO v_MinMarksp 
                                FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
                                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" ON "ESS"."ISMS_Id" = "EYCES"."ISMS_Id" 
                                WHERE "EYCES"."ISMS_Id" = v_amsu_idp  
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );
                            END IF;
                        ELSE
                            SELECT v_EMP_Max_Marks / NULLIF("ESTMPS_MaxMarks", 0) INTO v_Ratio 
                            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS"  
                            WHERE "ESS"."ISMS_Id" = v_amsu_idp 
                            AND "amst_id" = v_amst_id 
                            AND "ESS"."eme_id" IN (
                                SELECT DISTINCT "eme_id" 
                                FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                WHERE "EMPSG_Id" = v_ETP_Id
                            );

                            v_Marks := 0;
                            v_totmarks := 0;
                            v_intCount := 0;

                            FOR v_marks IN 
                                SELECT "ESTMPS_ObtainedMarks"  
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                                WHERE "amst_id" = v_amst_id 
                                AND "ISMS_Id" = v_amsu_idp 
                                AND "eme_id" IN (
                                    SELECT DISTINCT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                ) 
                                ORDER BY "ESTMPS_ObtainedMarks" DESC
                            LOOP
                                EXIT WHEN v_intCount >= v_etp_best;
                                v_totmarks := v_totmarks + (v_marks / NULLIF(v_Ratio, 0));
                                v_intCount := v_intCount + 1;
                            END LOOP;

                            IF v_Per_or_mark <> 'M' THEN
                                v_ems_marks_final := (v_totmarks / NULLIF(v_etp_best, 0)) * v_ETP_Per / 100;
                                
                                SELECT "ESTMPS_MaxMarks" * v_ETP_Per * v_Ratio / 100 INTO v_MaxMarksp 
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS"  
                                WHERE "ESS"."ISMS_Id" = v_amsu_idp 
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );

                                SELECT "EYCES_MinMarks" * v_ETP_Per * v_Ratio / 100 INTO v_MinMarksp 
                                FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
                                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" ON "ESS"."ISMS_Id" = "EYCES"."ISMS_Id" 
                                WHERE "EYCES"."ISMS_Id" = v_amsu_idp 
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );
                            ELSE
                                v_ems_marks_final := (v_totmarks / NULLIF(v_etp_best, 0));
                                
                                SELECT "ESTMPS_MaxMarks" * v_Ratio INTO v_MaxMarksp 
                                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS"  
                                WHERE "ESS"."ISMS_Id" = v_amsu_idp 
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );

                                SELECT "EYCES_MinMarks" * v_Ratio INTO v_MinMarksp 
                                FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
                                INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" ON "ESS"."ISMS_Id" = "EYCES"."ISMS_Id" 
                                WHERE "EYCES"."ISMS_Id" = v_amsu_idp 
                                AND "amst_id" = v_amst_id 
                                AND "ESS"."eme_id" IN (
                                    SELECT "eme_id" 
                                    FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                                    WHERE "EMPSG_Id" = v_ETP_Id
                                );
                            END IF;
                        END IF;

                        IF v_ems_marks_final < v_MinMarksp THEN
                            v_FlgPFwt := 'F';
                        ELSE
                            v_FlgPFwt := 'P';
                        END IF;

                        v_et_id := 0;
                        v_emgr_idg := 0;
                        
                        SELECT COALESCE("EYCES"."EMGR_Id", 0) INTO v_et_id 
                        FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id" 
                        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESS" ON "ESS"."ISMS_Id" = "EYCES"."ISMS_Id" 
                        WHERE "EYCES"."ISMS_Id" = v_amsu_idp 
                        AND "amst_id" = v_amst_id 
                        AND "ESS"."eme_id" IN (
                            SELECT DISTINCT "eme_id" 
                            FROM "Exm"."Exm_M_Prom_Subj_Group_Exams" 
                            WHERE "EMPSG_