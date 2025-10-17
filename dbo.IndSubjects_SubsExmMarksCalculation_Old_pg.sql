CREATE OR REPLACE FUNCTION "dbo"."IndSubjects_SubsExmMarksCalculation_Old"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id integer,
    p_ESTMP_PublishToStudentFlg integer
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ESTMP_TotalMaxMarks decimal(10,2);
    v_ESTMP_TotalObtMarks decimal(10,2);
    v_EYCES_Id integer;
    v_EYCE_Id integer;
    v_ISMS_Id decimal(10,2);
    v_EYCES_AplResultFlg boolean;
    v_EYCES_MarksEntryMax decimal(10,2);
    v_EYCES_MaxMarks decimal(10,2);
    v_EYCES_MinMarks decimal(10,2);
    v_EMGR_Id integer;
    v_ESTM_Marks decimal(10,2);
    v_ESTM_MarksGradeFlg char(1);
    v_ESTMP_Result varchar(30);
    v_AMST_Id bigint;
    v_ESTMP_Percentage decimal(10,2);
    v_ESTMP_Percentage_Overallpercentage decimal(10,2);
    v_ESTMPS_ObtainedGrade varchar(30);
    v_Exm_Grade integer;
    v_ESTMP_TotalGrade varchar(30);
    v_ESTMPS_Percentage decimal(10,2);
    v_ESTMPS_MaxMarks decimal(10,2);
    v_Subject_Percentage decimal(10,2);
    v_Class_Totalmarks decimal(10,2);
    v_Class_Totalcount integer;
    v_Section_Totalmarks decimal(10,2);
    v_Section_Totalcount integer;
    v_FailCount integer;
    v_ESTMPS_PassFailFlg varchar(30);
    v_ESTMPS_ClassAverage decimal(10,2);
    v_ESTMPS_SectionAverage decimal(10,2);
    v_ESTMPS_ClassHighest decimal(10,2);
    v_ESTMPS_SectionHighest decimal(10,2);
    v_ESTMP_ClassRank integer;
    v_ESTMP_SectionRank integer;
    v_ESTM_Flg varchar(10);
    v_Absentcount integer;
    v_Sportscount integer;
    v_Medicalcount integer;
    v_Normalclassrank integer;
    v_NormalSectionrank integer;
    v_ExmConfig_RankingMethod varchar(50);
    v_Rank integer;
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
    v_ODcount integer;
    v_AMST_Id_New bigint;
    v_MedicalMaxMarksSum decimal(10,2);
    v_ESTMMSMarksCount integer;
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_ASMCL_Id bigint;
    v_ASMS_Id bigint;
    v_EME_Id integer;
    v_passfail10 varchar(10);
    v_ams varchar(10);
    v_count10 integer;
    v_count10M integer;
    v_count10F integer;
    v_count10op integer;
    v_passfail10A varchar(10);
    v_passfail10M varchar(10);
    v_passfail10F varchar(10);
    v_passfail10C varchar(10);
    v_passfail10D varchar(50);
    v_passfail1OP varchar(50);
    v_passfailflagA varchar(10);
    v_passfailflagM varchar(10);
    v_passfailflagF varchar(10);
    v_passfailflagC varchar(10);
    v_passfailflagD varchar(50);
    v_passfailflagOP varchar(50);
    v_rankCalFlag varchar(10);
    v_EMCA_ID integer;
    v_exmc_condition varchar(10);
    v_marks decimal(10,2);
    v_fail_count_temp integer;
    v_pass_fail_flag varchar(50);
    v_overallPercentage integer;
    v_overallFlag varchar(20);
    v_pass_sub_temp decimal(10,2);
    v_classrank1 integer;
    v_fail_count integer;
    v_pass_sub integer;
    v_SUbmedicalcount integer;
    v_totalCount integer;
    v_resultCount integer;
    v_rankCalFlagMAINpass varchar(10);
    v_rankCalFlagSUBpass varchar(10);
    v_EMCA_ID2 integer;
    v_PassFailSubjectFlag varchar(50);
    v_secrank1 integer;
    v_Compulsory varchar(max);
    v_groupids integer;
    v_GroupMinMarks integer;
    v_passfailflagN varchar(50);
    v_passfail10N varchar(50);
    v_NotCompSubcountM integer;
    v_NotCompSubcountL integer;
    v_NotCompSubcountF integer;
    v_NotCompSubcountA integer;
    v_NotCompSubcountOP integer;
    v_AMFCondition varchar(50);
    v_AMST_IdM bigint;
    v_ESTMPS_Id integer;
    v_ESTMPSSS_MaxMarks decimal(10,2);
    v_AMST_IdMS bigint;
    v_ESTMP_TotalMaxMarks_M decimal(10,2);
    v_ESTMP_TotalMaxMarks_ST decimal(10,2);
    v_MStudentObtainedMarks decimal(10,2);
    v_ESTMP_Percentage_M decimal(10,2);
    v_ESTMP_TotalGrade_M varchar(50);
    v_ESTMP_TotalMaxMarks_R decimal(10,2);
    v_Exm_Grade_M integer;
    v_passfail1OP_N decimal(18,2);
    v_AMST_IdMSub bigint;
    v_ESTMPS_TotalMaxMarks_Msub decimal(10,2);
    v_ESTMPS_TotalMaxMarks_STSub decimal(10,2);
    v_MStudentObtainedMarkssub decimal(10,2);
    v_ESTMPS_TotalMaxMarks_Rsub decimal(10,2);
    v_AMST_IdMSsub bigint;
    v_ESTMPS_Idsub integer;
    v_ESTMPSSS_MaxMarkssub decimal(10,2);
    v_ESTMPS_MaxMarkssub decimal(10,2);
    v_AMST_IdD bigint;
    v_DESTMP_TotalMaxMarks decimal(10,2);
    v_DESTMP_TotalMaxMarks_ST decimal(10,2);
    v_DStudentObtainedMarks decimal(10,2);
    v_ESTMP_Percentage_D decimal(10,2);
    v_ESTMP_TotalGrade_D varchar(50);
    v_DESTMP_TotalMaxMarks_R decimal(10,2);
    v_ODMaxMarksSum decimal(10,2);
    v_Exm_Grade_OD integer;
    v_AllSubjectAbsentFlg boolean;
    v_AMST_IdU bigint;
    v_EME_IdU bigint;
    v_SubjectCountU bigint;
    v_AbsentcountU bigint;
    v_MedicalcountU bigint;
    v_SportscountU bigint;
    v_ODcountU bigint;
    rec RECORD;
BEGIN

    v_MedicalMaxMarksSum := 0;

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id
    LIMIT 1;

    IF (v_ExmConfig_RankingMethod = 'Dense') THEN
        v_Rank := 0;
    ELSE
        v_Rank := 1;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'Exm' AND tablename = 'Exm_Student_Marks_Pro_Sub_SubSubject'
    ) THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" 
        WHERE "ESTMPS_Id" IN (
            SELECT "ESTMPS_Id" FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id
        );
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'Exm' AND tablename = 'Exm_Student_Marks_Process_Subjectwise'
    ) THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'Exm' AND tablename = 'Exm_Student_Marks_Process'
    ) THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
    END IF;

    FOR rec IN
        SELECT DISTINCT "ESM"."AMST_Id", "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", 
               "ESM"."ISMS_Id", "ESM"."EME_Id", "EYCES"."EYCES_AplResultFlg", "EYCES"."EYCES_MarksEntryMax", 
               "EYCES"."EYCES_MaxMarks", "EYCES"."EYCES_MinMarks", "EYCES"."EMGR_Id", "ESM"."ESTM_Marks", 
               "ESM"."ESTM_MarksGradeFlg", "ESM"."ESTM_Grade", "ESM"."ESTM_Flg"
        FROM "Adm_M_Student" AS f
        INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
            AND f."AMST_ActiveFlag" = 1 AND f."AMST_SOL" = 'S' AND h."AMAY_ActiveFlag" = 1 
            AND h."ASMAY_Id" = p_ASMAY_Id AND h."ASMCL_Id" = p_ASMCL_Id 
            AND h."ASMS_Id" = p_ASMS_Id AND f."mi_id" = p_MI_Id
        INNER JOIN "Exm"."Exm_Category_Class" AS "ECC" ON "ECC"."MI_Id" = p_MI_Id 
            AND "ECC"."ASMAY_Id" = p_ASMAY_Id
        INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "EYC"."MI_Id" = p_MI_Id 
            AND "EYC"."ASMAY_Id" = p_ASMAY_Id AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" AS "ESM" ON "ESM"."AMST_Id" = f."AMST_Id" 
            AND "ESM"."ISMS_Id" = "EYCES"."ISMS_Id" AND "ESM"."MI_Id" = "EYC"."MI_Id" 
            AND "ESM"."EME_Id" = "EYCE"."EME_Id" AND "ESM"."ASMAY_Id" = "ECC"."ASMAY_Id" 
            AND "ESM"."ASMS_Id" = "ECC"."ASMS_Id" AND "ESM"."ASMCL_Id" = "ECC"."ASMCL_Id"
        INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS n ON n."ISMS_Id" = "EYCES"."ISMS_Id" 
            AND n."AMST_Id" = f."AMST_Id" AND n."MI_Id" = p_MI_Id AND n."ASMAY_Id" = p_ASMAY_Id 
            AND n."ASMCL_Id" = p_ASMCL_Id AND n."ASMS_Id" = p_ASMS_Id
        WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
            AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id 
            AND "EYCE"."EME_Id" = p_EME_Id
        ORDER BY "ESM"."AMST_Id"
    LOOP
        v_AMST_Id := rec."AMST_Id";
        v_MI_Id := rec."MI_Id";
        v_ASMAY_Id := rec."ASMAY_Id";
        v_ASMCL_Id := rec."ASMCL_Id";
        v_ASMS_Id := rec."ASMS_Id";
        v_ISMS_Id := rec."ISMS_Id";
        v_EME_Id := rec."EME_Id";
        v_EYCES_AplResultFlg := rec."EYCES_AplResultFlg";
        v_EYCES_MarksEntryMax := rec."EYCES_MarksEntryMax";
        v_EYCES_MaxMarks := rec."EYCES_MaxMarks";
        v_EYCES_MinMarks := rec."EYCES_MinMarks";
        v_EMGR_Id := rec."EMGR_Id";
        v_ESTM_Marks := rec."ESTM_Marks";
        v_ESTM_MarksGradeFlg := rec."ESTM_MarksGradeFlg";
        v_ESTM_Grade := rec."ESTM_Grade";
        v_ESTM_Flg := rec."ESTM_Flg";

        IF v_ESTM_MarksGradeFlg = 'M' THEN
            IF (v_EYCES_MaxMarks > v_EYCES_MarksEntryMax) THEN
                v_Ratio := (v_EYCES_MaxMarks / NULLIF(v_EYCES_MarksEntryMax, 0));
                v_ESTM_Marks := v_ESTM_Marks * v_Ratio;
            ELSIF (v_EYCES_MaxMarks < v_EYCES_MarksEntryMax) THEN
                v_Ratio := (v_EYCES_MarksEntryMax / NULLIF(v_EYCES_MaxMarks, 0));
                v_ESTM_Marks := v_ESTM_Marks / NULLIF(v_Ratio, 0);
            ELSIF (v_EYCES_MaxMarks = v_EYCES_MarksEntryMax) THEN
                v_ESTM_Marks := v_ESTM_Marks;
            END IF;
        ELSIF v_ESTM_MarksGradeFlg = 'G' THEN
            SELECT (("EMGD_From" + "EMGD_To") / 2) INTO v_ESTM_Marks
            FROM "Exm"."Exm_Master_Grade_Details"
            WHERE ("EMGD_Name" = v_ESTM_Grade) AND "EMGD_ActiveFlag" = 1 AND "EMGR_Id" = v_EMGR_Id
            LIMIT 1;
        END IF;

        SELECT "ExmConfig_RoundoffFlag" INTO v_RoundOffFlg
        FROM "Exm"."Exm_Configuration" 
        WHERE "MI_Id" = p_MI_Id
        LIMIT 1;

        IF (v_RoundOffFlg = true) THEN
            v_ESTM_Marks := ROUND(v_ESTM_Marks, 0);
        ELSIF (v_RoundOffFlg = false) THEN
            v_ESTM_Marks := v_ESTM_Marks;
        END IF;

        IF ((v_EYCES_AplResultFlg = true OR v_EYCES_AplResultFlg = false) AND (v_EYCES_MinMarks > v_ESTM_Marks)) THEN
            v_ESTMPS_PassFailFlg := 'Fail';
        ELSE
            v_ESTMPS_PassFailFlg := 'Pass';
        END IF;

        IF (v_ESTM_Flg = 'AB') THEN
            SELECT COUNT("ESTMSS_Marks") INTO v_ESTMMSMarksCount
            FROM "Exm"."Exm_Student_Marks" "ESM"
            INNER JOIN "Exm"."Exm_Student_Marks_SubSubject" "ESMS" ON "ESMS"."ESTM_Id" = "ESM"."ESTM_Id"
            WHERE "ESM"."MI_Id" = p_MI_Id AND "ESM"."ASMAY_Id" = p_ASMAY_Id 
                AND "ESM"."ASMCL_Id" = p_ASMCL_Id AND "ESM"."ASMS_Id" = p_ASMS_Id 
                AND "ESM"."AMST_Id" = v_AMST_Id AND "ESM"."EME_Id" = p_EME_Id 
                AND "ESM"."ISMS_Id" = v_ISMS_Id;

            IF (v_ESTMMSMarksCount = 0) THEN
                v_ESTMPS_PassFailFlg := 'AB';
            END IF;
        END IF;

        IF (v_ESTM_Flg = 'L') THEN
            v_ESTMPS_PassFailFlg := 'L';
        ELSIF (v_ESTM_Flg = 'M') THEN
            v_ESTMPS_PassFailFlg := 'M';
        ELSIF (v_ESTM_Flg = 'OD') THEN
            v_ESTMPS_PassFailFlg := 'OD';
        END IF;

        v_ESTM_Marks := v_ESTM_Marks;

        SELECT "EMGR_MarksPerFlag" INTO v_GredeFlag 
        FROM "Exm"."Exm_Master_Grade" 
        WHERE "EMGR_Id" = v_EMGR_Id;

        IF (v_GredeFlag = 'M') THEN
            v_GradeMarksPercentage := v_ESTM_Marks;
        ELSIF (v_GredeFlag = 'P') THEN
            v_Subject_Percentage := (CAST((v_ESTM_Marks / NULLIF(v_EYCES_MaxMarks, 0)) * 100 AS DECIMAL(10, 2)));
            v_GradeMarksPercentage := v_Subject_Percentage;
        END IF;

        IF v_ESTM_MarksGradeFlg = 'M' THEN
            v_ESTMPS_ObtainedGrade := NULL;

            SELECT "EMGD_Name" INTO v_ESTMPS_ObtainedGrade
            FROM "Exm"."Exm_Master_Grade_Details"
            WHERE (((CAST(v_GradeMarksPercentage AS DECIMAL(10,1))) BETWEEN (CAST("EMGD_From" AS DECIMAL(10,1))) AND (CAST("EMGD_To" AS DECIMAL(10,1)))) 
                OR ((CAST(v_GradeMarksPercentage AS DECIMAL(10,1))) BETWEEN (CAST("EMGD_To" AS DECIMAL(10,1))) AND (CAST("EMGD_From" AS DECIMAL(10,1))))) 
                AND "EMGR_Id" = v_EMGR_Id;
        ELSIF v_ESTM_MarksGradeFlg = 'G' THEN
            v_ESTMPS_ObtainedGrade := v_ESTM_Grade;
        END IF;

        INSERT INTO "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", "EME_Id", 
             "ESTMPS_MaxMarks", "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg", 
             "CreatedDate", "UpdatedDate", "ESTMPS_Medical_MaxMarks")
        VALUES (p_MI_Id, p_ASMAY_Id, p_ASMCL_Id, p_ASMS_Id, v_AMST_Id, v_ISMS_Id, p_EME_Id, 
                v_EYCES_MaxMarks, v_ESTM_Marks, v_ESTMPS_ObtainedGrade, v_ESTMPS_PassFailFlg, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_EYCES_MaxMarks);

        SELECT "EYCES_SubExamFlg", "EYCES_SubSubjectFlg" 
        INTO v_EYCES_SubExamFlg, v_EYCES_SubSubjectFlg
        FROM "Exm"."Exm_Category_Class" a,
             "Exm"."Exm_Yearly_Category" b,
             "Exm"."Exm_Yearly_Category_Exams" c,
             "Exm"."Exm_Yrly_Cat_Exams_Subwise" d
        WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ASMCL_Id" = p_ASMCL_Id 
            AND a."ASMS_Id" = p_ASMS_Id AND a."ECAC_ActiveFlag" = 1 AND b."MI_Id" = a."MI_Id" 
            AND b."ASMAY_Id" = a."ASMAY_Id" AND b."EYC_ActiveFlg" = 1 AND b."EMCA_Id" = a."EMCA_Id"
            AND c."EYC_Id" = b."EYC_Id" AND c."EME_Id" = p_EME_Id AND c."EYCE_ActiveFlg" = 1 
            AND d."EYCE_Id" = c."EYCE_Id" AND d."EYCES_ActiveFlg" = 1 AND d."ISMS_Id" = v_ISMS_Id;

        IF (v_EYCES_SubExamFlg = false AND v_EYCES_SubSubjectFlg = true) 
           OR (v_EYCES_SubExamFlg = true AND v_EYCES_SubSubjectFlg = false) 
           OR (v_EYCES_SubExamFlg = true AND v_EYCES_SubSubjectFlg = true) THEN
            PERFORM "SubSubject_SubExam_New"(p_MI_Id, p_ASMAY_Id, p_ASMCL_Id, p_ASMS_Id, v_AMST_Id, p_EME_Id, v_ISMS_Id);
        END IF;
    END LOOP;

    FOR rec IN
        SELECT DISTINCT "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", 
               "ESM"."ISMS_Id", "ESM"."EME_Id"
        FROM "Exm"."Exm_Category_Class" AS "ECC"
        INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "ECC"."MI_Id" = "EYC"."MI_Id" 
            AND "ECC"."ASMAY_Id" = "EYC"."ASMAY_Id" AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" AS "ESM" ON "ESM"."ISMS_Id" = "EYCES"."ISMS_Id" 
            AND "ESM"."MI_Id" = "EYC"."MI_Id" AND "ESM"."EME_Id" = "EYCE"."EME_Id" 
            AND "ESM"."ASMAY_Id" = "ECC"."ASMAY_Id" AND "ESM"."ASMS_Id" = "ECC"."ASMS_Id" 
            AND "ESM"."ASMCL_Id" = "ECC"."ASMCL_Id"
        WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
            AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id 
            AND "EYCE"."EME_Id" = p_EME_Id
        ORDER BY "ESM"."ISMS_Id"
    LOOP
        v_MI_Id := rec."MI_Id";
        v_ASMAY_Id := rec."ASMAY_Id";
        v_ASMCL_Id := rec."ASMCL_Id";
        v_ASMS_Id := rec."ASMS_Id";
        v_ISMS_Id := rec."ISMS_Id";
        v_EME_Id := rec."EME_Id";

        SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Section_Totalmarks
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
        GROUP BY "ASMCL_Id", "ASMS_Id", "ISMS_Id";

        SELECT COUNT("AMST_Id") INTO v_Section_Totalcount
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ISMS_Id" = v_ISMS_Id 
            AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;

        v_ESTMPS_SectionAverage := v_Section_Totalmarks / NULLIF(v_Section_Totalcount, 0);

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_SectionAverage" = v_ESTMPS_SectionAverage
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

        SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Class_Totalmarks
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"