CREATE OR REPLACE FUNCTION "dbo"."IndExamMarksCalculation"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id int,
    p_ESTMP_PublishToStudentFlg int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_PTS int := 0;
    v_ESTMP_TotalMaxMarks decimal(10,2);
    v_ESTMP_TotalObtMarks decimal(10,2);
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
    v_ESTMMSMarksCount int;
    v_EYCES_SubExamFlg boolean;
    v_EYCES_SubSubjectFlg boolean;
    v_PercentageRoundoff boolean;
    v_EMGD_Id int;
    v_ESTMP_Percentage_New decimal(18,2);
    v_ClassRankFlg int;
    v_SecRankFlg int;
    v_AMST_IdMSub bigint;
    v_ESTMPS_TotalMaxMarks_Msub decimal(10,2);
    v_ESTMPS_TotalMaxMarks_STSub decimal(10,2);
    v_MStudentObtainedMarkssub decimal(10,2);
    v_ESTMPS_TotalMaxMarks_Rsub decimal(10,2);
    v_AMST_IdMSsub bigint;
    v_ESTMPS_Idsub int;
    v_ESTMPSSS_MaxMarkssub decimal(10,2);
    v_ESTMPS_MaxMarkssub decimal(10,2);
    v_AllSubjectAbsentFlg boolean;
    v_AMST_IdU bigint;
    v_EME_IdU bigint;
    v_SubjectCountU bigint;
    v_AbsentcountU bigint;
    v_MedicalcountU bigint;
    v_SportscountU bigint;
    v_ODcountU bigint;
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_ASMCL_Id bigint;
    v_ASMS_Id bigint;
    v_EME_Id int;
    rec_exmsubjectdetails RECORD;
    rec_exmsubjectwisecalc RECORD;
    rec_studentmarksprocess RECORD;
    rec_studentsub RECORD;
    rec_subsubjectsmedical RECORD;
    rec_allsubabsent RECORD;
BEGIN

    DROP TABLE IF EXISTS "Exm_Student_Marks_Process_PS_Temp";
    
    CREATE TEMP TABLE "Exm_Student_Marks_Process_PS_Temp" AS
    SELECT * FROM "Exm"."Exm_Student_Marks_Process" 
    WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
    AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id;

    SELECT "ESTMP_PublishToStudentFlg" INTO v_PTS
    FROM "Exm"."Exm_Student_Marks_Process" 
    WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
    AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id LIMIT 1;
    
    v_PTS := COALESCE(v_PTS, 0);

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='Exm' AND table_name='Exm_Student_Marks_Pro_Sub_SubSubject') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" 
        WHERE "ESTMPS_Id" IN(
            SELECT "ESMPS"."ESTMPS_Id" FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
            AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id
        );
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='Exm' AND table_name='Exm_Student_Marks_Process_Subjectwise') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
        AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='Exm' AND table_name='Exm_Student_Marks_Process') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
        AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id;
    END IF;

    BEGIN

        DROP TABLE IF EXISTS "#Exmsubjectdetails";

        SELECT "ExmConfig_RankingMethod", "ExmConfig_ClassRankFlg", "ExmConfig_SecRankFlg" 
        INTO v_ExmConfig_RankingMethod, v_ClassRankFlg, v_SecRankFlg
        FROM "Exm"."Exm_Configuration" WHERE "MI_Id"=p_MI_Id LIMIT 1;

        IF (v_ExmConfig_RankingMethod='Dense') THEN
            v_Rank := 0;
        ELSE
            v_Rank := 1;
        END IF;

        CREATE TEMP TABLE "#Exmsubjectdetails" AS
        SELECT DISTINCT "ESM"."AMST_Id", "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", 
               "ESM"."ASMS_Id", "ESM"."ISMS_Id", "ESM"."EME_Id", "EYCES_AplResultFlg",
               COALESCE("EYCES_MarksEntryMax",0) AS "EYCES_MarksEntryMax",
               COALESCE("EYCES_MaxMarks",0) AS "EYCES_MaxMarks",
               COALESCE("EYCES_MinMarks",0) AS "EYCES_MinMarks",
               "EYCES"."EMGR_Id", COALESCE("ESM"."ESTM_Marks",0) AS "ESTM_Marks",
               "ESM"."ESTM_MarksGradeFlg", "ESTM_Grade", "ESTM_Flg"
        FROM "Adm_M_Student" AS f
        INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
            AND h."ASMAY_Id" = p_ASMAY_Id AND h."ASMCL_Id" = p_ASMCL_Id 
            AND h."ASMS_Id" = p_ASMS_Id AND f."mi_id"=p_MI_Id
        INNER JOIN "Exm"."Exm_Category_Class" AS "ECC" ON "ECC"."MI_Id"=p_MI_Id 
            AND "ECC"."ASMAY_Id"=p_ASMAY_Id AND "ECC"."ASMCL_Id"=h."ASMCL_Id" 
            AND "ECC"."ASMS_Id"=h."ASMS_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "EYC"."MI_Id"=p_MI_Id 
            AND "EYC"."ASMAY_Id"=p_ASMAY_Id AND "ECC"."EMCA_Id"="EYC"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id"="EYC"."EYC_Id" 
            AND "EYCE"."EME_Id"=p_EME_Id
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id"="EYCE"."EYCE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" AS "ESM" ON "ESM"."AMST_Id"=f."AMST_Id" 
            AND "ESM"."ISMS_Id"="EYCES"."ISMS_Id" AND "ESM"."MI_Id"="EYC"."MI_Id"
            AND "ESM"."EME_Id"="EYCE"."EME_Id" AND "ESM"."ASMAY_Id"="ECC"."ASMAY_Id" 
            AND "ESM"."ASMS_Id"="ECC"."ASMS_Id" AND "ESM"."ASMCL_Id"="ECC"."ASMCL_Id"
            AND "ESM"."MI_Id" = p_MI_Id AND "ESM"."ASMAY_Id" = p_ASMAY_Id 
            AND "ESM"."ASMCL_Id" = p_ASMCL_Id AND "ESM"."ASMS_Id" = p_ASMS_Id 
            AND "ESM"."EME_Id"=p_EME_Id
        WHERE "EYC"."MI_Id"=p_MI_Id AND "EYC"."ASMAY_Id"=p_ASMAY_Id 
            AND "ECC"."ASMCL_Id"=p_ASMCL_Id AND "ECC"."ASMS_Id"=p_ASMS_Id 
            AND "EYCE"."EME_Id"=p_EME_Id
            AND "ECC"."ECAC_ActiveFlag"=true AND "EYC_ActiveFlg"=true 
            AND "EYCE_ActiveFlg"=true AND "EYCES_ActiveFlg"=true AND "ESTM_ActiveFlg"=true
        ORDER BY "ESM"."AMST_Id";

        FOR rec_exmsubjectdetails IN 
            SELECT * FROM "#Exmsubjectdetails"
        LOOP
            v_AMST_Id := rec_exmsubjectdetails."AMST_Id";
            v_MI_Id := rec_exmsubjectdetails."MI_Id";
            v_ASMAY_Id := rec_exmsubjectdetails."ASMAY_Id";
            v_ASMCL_Id := rec_exmsubjectdetails."ASMCL_Id";
            v_ASMS_Id := rec_exmsubjectdetails."ASMS_Id";
            v_ISMS_Id := rec_exmsubjectdetails."ISMS_Id";
            v_EME_Id := rec_exmsubjectdetails."EME_Id";
            v_EYCES_AplResultFlg := rec_exmsubjectdetails."EYCES_AplResultFlg";
            v_EYCES_MarksEntryMax := rec_exmsubjectdetails."EYCES_MarksEntryMax";
            v_EYCES_MaxMarks := rec_exmsubjectdetails."EYCES_MaxMarks";
            v_EYCES_MinMarks := rec_exmsubjectdetails."EYCES_MinMarks";
            v_EMGR_Id := rec_exmsubjectdetails."EMGR_Id";
            v_ESTM_Marks := rec_exmsubjectdetails."ESTM_Marks";
            v_ESTM_MarksGradeFlg := rec_exmsubjectdetails."ESTM_MarksGradeFlg";
            v_ESTM_Grade := rec_exmsubjectdetails."ESTM_Grade";
            v_ESTM_Flg := rec_exmsubjectdetails."ESTM_Flg";

            IF v_ESTM_MarksGradeFlg='M' THEN
                IF(v_EYCES_MaxMarks>v_EYCES_MarksEntryMax) THEN
                    v_Ratio := (v_EYCES_MaxMarks/NULLIF(v_EYCES_MarksEntryMax,0));
                    v_ESTM_Marks := v_ESTM_Marks*v_Ratio;
                ELSIF(v_EYCES_MaxMarks<v_EYCES_MarksEntryMax) THEN
                    v_Ratio := (v_EYCES_MarksEntryMax/NULLIF(v_EYCES_MaxMarks,0));
                    v_ESTM_Marks := v_ESTM_Marks/NULLIF(v_Ratio,0);
                ELSIF(v_EYCES_MaxMarks=v_EYCES_MarksEntryMax) THEN
                    v_ESTM_Marks := v_ESTM_Marks;
                END IF;
            ELSIF v_ESTM_MarksGradeFlg='G' THEN
                SELECT ((("EMGD_From"+"EMGD_To")/2)) INTO v_ESTM_Marks
                FROM "Exm"."Exm_Master_Grade_Details"
                WHERE ("EMGD_Name"=v_ESTM_Grade) AND "EMGD_ActiveFlag"=true 
                    AND "EMGR_Id"=v_EMGR_Id LIMIT 1;
            END IF;

            SELECT "ExmConfig_RoundoffFlag" INTO v_RoundOffFlg
            FROM "Exm"."Exm_Configuration" WHERE "MI_Id"=p_MI_Id LIMIT 1;
            
            IF (v_RoundOffFlg=true) THEN
                v_ESTM_Marks := ROUND(v_ESTM_Marks,0);
            ELSE
                v_ESTM_Marks := v_ESTM_Marks;
            END IF;

            IF((v_EYCES_AplResultFlg=true OR v_EYCES_AplResultFlg=false) 
                AND (v_EYCES_MinMarks>v_ESTM_Marks)) THEN
                v_ESTMPS_PassFailFlg := 'Fail';
            ELSE
                v_ESTMPS_PassFailFlg := 'Pass';
            END IF;

            IF(v_ESTM_Flg='AB') THEN
                SELECT COUNT("ESTMSS_Marks") INTO v_ESTMMSMarksCount
                FROM "Exm"."Exm_Student_Marks" "ESM"
                INNER JOIN "Exm"."Exm_Student_Marks_SubSubject" "ESMS" 
                    ON "ESMS"."ESTM_Id"="ESM"."ESTM_Id"
                WHERE "ESM"."MI_Id"=p_MI_Id AND "ESM"."ASMAY_Id"=p_ASMAY_Id 
                    AND "ESM"."ASMCL_Id"=p_ASMCL_Id AND "ESM"."ASMS_Id"=p_ASMS_Id 
                    AND "ESM"."AMST_Id"=v_AMST_Id AND "ESM"."EME_Id"=p_EME_Id 
                    AND "ESM"."ISMS_Id"=v_ISMS_Id AND "ESM"."ESTM_ActiveFlg"=true;

                IF (v_ESTMMSMarksCount=0) THEN
                    v_ESTMPS_PassFailFlg := 'AB';
                END IF;
            END IF;

            IF(v_ESTM_Flg='L') THEN
                v_ESTMPS_PassFailFlg := 'L';
            ELSIF(v_ESTM_Flg='M') THEN
                v_ESTMPS_PassFailFlg := 'M';
            ELSIF(v_ESTM_Flg='OD') THEN
                v_ESTMPS_PassFailFlg := 'OD';
            END IF;

            v_ESTM_Marks := v_ESTM_Marks;

            SELECT "EMGR_MarksPerFlag" INTO v_GredeFlag 
            FROM "Exm"."Exm_Master_Grade" WHERE "EMGR_Id"=v_EMGR_Id LIMIT 1;

            IF(v_GredeFlag='M') THEN
                v_GradeMarksPercentage := v_ESTM_Marks;
            ELSIF(v_GredeFlag='P') THEN
                v_Subject_Percentage := (CAST((v_ESTM_Marks/NULLIF(v_EYCES_MaxMarks,0))*100 AS DECIMAL(10,2)));
                v_GradeMarksPercentage := v_Subject_Percentage;
            END IF;

            v_ESTMPS_Percentage := 0;

            IF(v_GredeFlag='M' OR v_GredeFlag='P') THEN
                v_ESTMPS_Percentage := (CAST((v_ESTM_Marks/NULLIF(v_EYCES_MaxMarks,0))*100 AS DECIMAL(10,2)));
            ELSE
                v_ESTMPS_Percentage := 0;
            END IF;

            IF v_ESTM_MarksGradeFlg='M' THEN
                v_EMGD_Id := NULL;
                v_ESTMPS_ObtainedGrade := NULL;

                SELECT "EMGD_Name", "EMGD_Id" INTO v_ESTMPS_ObtainedGrade, v_EMGD_Id
                FROM "Exm"."Exm_Master_Grade_Details" 
                WHERE ((v_GradeMarksPercentage::decimal BETWEEN "EMGD_From" AND "EMGD_To")) 
                    AND "EMGR_Id"=v_EMGR_Id LIMIT 1;
            ELSIF v_ESTM_MarksGradeFlg='G' THEN
                v_ESTMPS_ObtainedGrade := v_ESTM_Grade;
                SELECT "EMGD_Id" INTO v_EMGD_Id FROM "Exm"."Exm_Master_Grade_Details" 
                WHERE "EMGD_Name"=v_ESTM_Grade AND "EMGR_Id"=v_EMGR_Id LIMIT 1;
            END IF;

            INSERT INTO "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            ("MI_Id","ASMAY_Id","ASMCL_Id","ASMS_Id","AMST_Id","ISMS_Id","EME_Id",
             "ESTMPS_MaxMarks","ESTMPS_ObtainedMarks","ESTMPS_ObtainedGrade",
             "ESTMPS_PassFailFlg","CreatedDate","UpdatedDate","ESTMPS_Medical_MaxMarks",
             "ESTMPS_AplResultFlg","EMGD_Id","ESTMPS_Percentage")
            VALUES(p_MI_Id,p_ASMAY_Id,p_ASMCL_Id,p_ASMS_Id,v_AMST_Id,v_ISMS_Id,p_EME_Id,
                   v_EYCES_MaxMarks,v_ESTM_Marks,v_ESTMPS_ObtainedGrade,v_ESTMPS_PassFailFlg,
                   CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,v_EYCES_MaxMarks,v_EYCES_AplResultFlg,
                   v_EMGD_Id,v_ESTMPS_Percentage);

            SELECT "EYCES_SubExamFlg", "EYCES_SubSubjectFlg" 
            INTO v_EYCES_SubExamFlg, v_EYCES_SubSubjectFlg
            FROM "Exm"."Exm_Category_Class" a
            INNER JOIN "Exm"."Exm_Yearly_Category" b ON b."EMCA_Id"=a."EMCA_Id" 
                AND b."MI_Id"=a."MI_Id" AND b."ASMAY_Id"=a."ASMAY_Id" 
                AND b."EYC_ActiveFlg"=true AND a."ECAC_ActiveFlag"=true
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id"=b."EYC_Id" 
                AND c."EYCE_ActiveFlg"=true
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" d ON d."EYCE_Id"=c."EYCE_Id" 
                AND d."EYCES_ActiveFlg"=true
            WHERE a."MI_Id"=p_MI_Id AND a."ASMAY_Id"=p_ASMAY_Id 
                AND a."ASMCL_Id"=p_ASMCL_Id AND a."ASMS_Id"=p_ASMS_Id 
                AND c."EME_Id"=p_EME_Id AND d."ISMS_Id"=v_ISMS_Id LIMIT 1;

            IF (v_EYCES_SubExamFlg=false AND v_EYCES_SubSubjectFlg=true) 
                OR (v_EYCES_SubExamFlg=true AND v_EYCES_SubSubjectFlg=false) 
                OR (v_EYCES_SubExamFlg=true AND v_EYCES_SubSubjectFlg=true) THEN
                PERFORM "SubSubject_SubExam_New"(p_MI_Id, p_ASMAY_Id, p_ASMCL_Id, 
                    p_ASMS_Id, v_AMST_Id, p_EME_Id, v_ISMS_Id);
            END IF;

        END LOOP;

        FOR rec_exmsubjectwisecalc IN
            SELECT DISTINCT "ESM"."MI_Id","ESM"."ASMAY_Id","ESM"."ASMCL_Id",
                   "ESM"."ASMS_Id","ESM"."ISMS_Id","ESM"."EME_Id"
            FROM "Exm"."Exm_Category_Class" AS "ECC"
            INNER JOIN "Exm"."Exm_Yearly_Category" AS "EYC" ON "ECC"."MI_Id"="EYC"."MI_Id" 
                AND "ECC"."ASMAY_Id"="EYC"."ASMAY_Id" AND "ECC"."EMCA_Id"="EYC"."EMCA_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" AS "EYCE" ON "EYCE"."EYC_Id"="EYC"."EYC_Id"
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS "EYCES" ON "EYCES"."EYCE_Id"="EYCE"."EYCE_Id"
            INNER JOIN "Exm"."Exm_Student_Marks" AS "ESM" ON "ESM"."ISMS_Id"="EYCES"."ISMS_Id" 
                AND "ESM"."MI_Id"="EYC"."MI_Id" AND "ESM"."EME_Id"="EYCE"."EME_Id" 
                AND "ESM"."ASMAY_Id"="ECC"."ASMAY_Id" AND "ESM"."ASMS_Id"="ECC"."ASMS_Id" 
                AND "ESM"."ASMCL_Id"="ECC"."ASMCL_Id"
            WHERE "EYC"."MI_Id"=p_MI_Id AND "EYC"."ASMAY_Id"=p_ASMAY_Id 
                AND "ECC"."ASMCL_Id"=p_ASMCL_Id AND "ECC"."ASMS_Id"=p_ASMS_Id 
                AND "EYCE"."EME_Id"=p_EME_Id AND "ESM"."ESTM_ActiveFlg"=true
            ORDER BY "ESM"."ISMS_Id"
        LOOP
            v_MI_Id := rec_exmsubjectwisecalc."MI_Id";
            v_ASMAY_Id := rec_exmsubjectwisecalc."ASMAY_Id";
            v_ASMCL_Id := rec_exmsubjectwisecalc."ASMCL_Id";
            v_ASMS_Id := rec_exmsubjectwisecalc."ASMS_Id";
            v_ISMS_Id := rec_exmsubjectwisecalc."ISMS_Id";
            v_EME_Id := rec_exmsubjectwisecalc."EME_Id";

            SELECT SUM(COALESCE("ESTMPS_ObtainedMarks",0)) INTO v_Section_Totalmarks
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
                AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id AND "ISMS_Id"=v_ISMS_Id
            GROUP BY "ASMCL_Id","ASMS_Id","ISMS_Id";

            SELECT COUNT("AMST_Id") INTO v_Section_Totalcount
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ISMS_Id"=v_ISMS_Id 
                AND "ASMCL_Id"=p_ASMCL_Id AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id;

            v_ESTMPS_SectionAverage := v_Section_Totalmarks/NULLIF(v_Section_Totalcount,0);

            UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            SET "ESTMPS_SectionAverage"=v_ESTMPS_SectionAverage 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
                AND "ASMS_Id"=p_ASMS_Id AND "EME_Id"=p_EME_Id AND "ISMS_Id"=v_ISMS_Id;

            SELECT SUM(COALESCE("ESTMPS_ObtainedMarks",0)) INTO v_Class_Totalmarks
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id AND "ASMCL_Id"=p_ASMCL_Id 
                AND "EME_Id"=p_EME_Id AND "ISMS_Id"=v_ISMS_Id
            GROUP BY "ASMCL_Id","