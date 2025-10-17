CREATE OR REPLACE FUNCTION "dbo"."CLG_IndSubjects_SubsExmMarksCalculation"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint,
    p_ACMS_Id bigint,
    p_EME_Id int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_CESTMP_TotalMaxMarks decimal(10,2);
    v_CESTMP_TotalObtMarks decimal(10,2);
    v_CEYCES_Id int;
    v_CEYCE_Id int;
    v_CISMS_Id decimal(10,2);
    v_CEYCES_AplResultFlg boolean;
    v_CEYCES_MarksEntryMax decimal(10,2);
    v_CEYCES_MaxMarks decimal(10,2);
    v_CEYCES_MinMarks decimal(10,2);
    v_CEMGR_Id int;
    v_CESTM_Marks decimal(10,2);
    v_CESTM_MarksGradeFlg char(1);
    v_CESTMP_Result varchar(30);
    v_AMCST_Id bigint;
    v_CESTMP_Percentage decimal(10,2);
    v_CESTMPS_ObtainedGrade varchar(30);
    v_CExm_Grade int;
    v_CESTMP_TotalGrade varchar(30);
    v_CESTMPS_Percentage decimal(10,2);
    v_CESTMPS_MaxMarks decimal(10,2);
    v_CSubject_Percentage decimal(10,2);
    v_CClass_Totalmarks decimal(10,2);
    v_CClass_Totalcount int;
    v_CSection_Totalmarks decimal(10,2);
    v_CSection_Totalcount int;
    v_CFailCount int;
    v_CESTMPS_PassFailFlg varchar(30);
    v_CESTMPS_ClassAverage decimal(10,2);
    v_CESTMPS_SectionAverage decimal(10,2);
    v_CESTMPS_ClassHighest decimal(10,2);
    v_CESTMPS_SectionHighest decimal(10,2);
    v_CESTMP_ClassRank int;
    v_CECSTMP_SectionRank int;
    v_CESTM_Flg varchar(10);
    v_CAbsentcount int;
    v_CSportscount int;
    v_CMedicalcount int;
    v_CNormalclassrank int;
    v_CNormalSectionrank int;
    v_CExmConfig_RankingMethod varchar(50);
    v_CRank int;
    v_CRatio decimal(10,2);
    v_CGredeFlag varchar(5);
    v_CGradeMarksPercentage decimal(10,2);
    v_CRoundOffFlg boolean;
    v_CESTM_Grade varchar(10);
    v_CTotalMinMarks decimal(10,2);
    v_CESTMP_MaxMarks decimal(10,2);
    v_CESTMP_ObtainedMarks decimal(10,2);
    v_CEYCES_SubExamFlg boolean;
    v_CEYCES_SubSubjectFlg boolean;
    v_Cpassfailflag varchar(50);
    v_Cpassfail varchar(50);
    v_CODcount int;
    v_CAMST_Id_New bigint;
    v_CMedicalMaxMarksSum decimal(10,2);
    v_CMI_Id bigint;
    v_CASMAY_Id bigint;
    v_CAMCO_Id bigint;
    v_CAMB_Id bigint;
    v_CAMSE_Id bigint;
    v_CACMS_Id bigint;
    v_CEME_Id bigint;
    rec_exmsubjectdetails RECORD;
    rec_examsubjectwisecalc RECORD;
    rec_studentmarksprocess RECORD;
BEGIN

    v_CMedicalMaxMarksSum := 0;

    SELECT "ExmConfig_RankingMethod" INTO v_CExmConfig_RankingMethod 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id 
    LIMIT 1;

    IF (v_CExmConfig_RankingMethod = 'Dense') THEN
        v_CRank := 0;
    ELSE
        v_CRank := 1;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'CLG' 
        AND tablename = 'Exm_Col_Student_Marks_Pro_Sub_SubSubject'
    ) THEN
        DELETE FROM "CLG"."Exm_Col_Student_Marks_Pro_Sub_SubSubject" 
        WHERE "ECSTMPS_Id" IN (
            SELECT "ECSMPS"."ECSTMPS_Id" 
            FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" "ECSMPS" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
            AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id 
            AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = p_ACMS_Id 
            AND "EME_Id" = p_EME_Id
        );
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'CLG' 
        AND tablename = 'Exm_Col_Student_Marks_Process_Subjectwise'
    ) THEN
        DELETE FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id 
        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = p_ACMS_Id 
        AND "EME_Id" = p_EME_Id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_tables 
        WHERE schemaname = 'CLG' 
        AND tablename = 'Exm_Col_Student_Marks_Process'
    ) THEN
        DELETE FROM "CLG"."Exm_Col_Student_Marks_Process" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id 
        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = p_ACMS_Id 
        AND "EME_Id" = p_EME_Id;
    END IF;

    FOR rec_exmsubjectdetails IN 
        SELECT DISTINCT "CESM"."AMCST_Id", "CESM"."MI_Id", "CECSS"."ASMAY_Id", 
            "CESM"."AMCO_Id", "CESM"."AMB_Id", "CESM"."AMSE_Id", "CESM"."ACMS_Id",
            "CESM"."ISMS_Id", "CESM"."EME_Id", "CEYCES"."ECYSES_AplResultFlg", 
            "CEYCES"."ECYSES_MarksEntryMax", "CEYCES"."ECYSES_MaxMarks", 
            "CEYCES"."ECYSES_MinMarks", "CEYCES"."EMGR_Id", "CESM"."ECSTM_Marks", 
            "CESM"."ECSTM_MarksGradeFlg", "CESM"."ECSTM_Grade", "CESM"."ECSTM_Flg"
        FROM "CLG"."Adm_Master_College_Student" AS "AMCS"         
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
            ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
            AND "AMCS"."AMCST_ActiveFlag" = true 
            AND "AMCS"."AMCST_SOL" = 'S' 
            AND "ACYS"."ACYST_ActiveFlag" = true 
            AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ACYS"."AMCO_Id" = p_AMCO_Id 
            AND "ACYS"."AMB_Id" = p_AMB_Id 
            AND "ACYS"."AMSE_Id" = p_AMSE_Id 
            AND "ACYS"."ACMS_Id" = p_ACMS_Id 
            AND "AMCS"."MI_Id" = p_MI_Id                       
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "CEYS" 
            ON "CEYS"."MI_Id" = p_MI_Id 
            AND "CEYS"."AMCO_Id" = p_AMCO_Id 
            AND "CEYS"."AMB_Id" = p_AMB_Id 
            AND "CEYS"."AMSE_Id" = p_AMSE_Id 
            AND "CEYS"."ECYS_ActiveFlag" = true 
            AND "AMCS"."ACSS_Id" = "CEYS"."ACSS_Id" 
            AND "AMCS"."ACST_Id" = "CEYS"."ACST_Id"
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
            ON "CEYCE"."ECYS_Id" = "CEYS"."ECYS_Id" 
            AND "CEYCE"."AMCO_Id" = p_AMCO_Id 
            AND "CEYCE"."AMB_Id" = p_AMB_Id 
            AND "CEYCE"."AMSE_Id" = p_AMSE_Id 
            AND "CEYCE"."EME_Id" = p_EME_Id 
            AND "CEYCE"."ECYSE_ActiveFlg" = true 
            AND "AMCS"."ACSS_Id" = "CEYCE"."ACSS_Id" 
            AND "AMCS"."ACST_Id" = "CEYCE"."ACST_Id"
        INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
            ON "CEYCES"."ECYSE_Id" = "CEYCES"."ECYSE_Id" 
            AND "ECYSES_ActiveFlg" = true
        INNER JOIN "CLG"."Exm_Col_Student_Marks" AS "CESM" 
            ON "CESM"."AMCST_Id" = "AMCS"."AMCST_Id" 
            AND "CESM"."ISMS_Id" = "CEYCES"."ISMS_Id" 
            AND "CESM"."MI_Id" = "CEYS"."MI_Id" 
            AND "CESM"."EME_Id" = "CEYCE"."EME_Id" 
            AND "CESM"."ACMS_Id" = p_ACMS_Id 
            AND "CESM"."AMSE_Id" = p_AMSE_Id 
            AND "CESM"."AMB_Id" = p_AMB_Id 
            AND "CESM"."AMCO_Id" = p_AMCO_Id
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS "CECSS" 
            ON "CECSS"."ISMS_Id" = "CEYCES"."ISMS_Id" 
            AND "CECSS"."AMCST_Id" = "AMCS"."AMCST_Id" 
            AND "CECSS"."MI_Id" = p_MI_Id 
            AND "CECSS"."ASMAY_Id" = p_ASMAY_Id 
            AND "CECSS"."AMSE_Id" = p_AMSE_Id 
            AND "CECSS"."AMB_Id" = p_AMB_Id 
            AND "CECSS"."AMCO_Id" = p_AMCO_Id
        WHERE "CEYS"."MI_Id" = p_MI_Id 
            AND "CECSS"."ASMAY_Id" = p_ASMAY_Id 
            AND "CESM"."AMCO_Id" = p_AMCO_Id 
            AND "CESM"."AMB_Id" = p_AMB_Id 
            AND "CESM"."AMSE_Id" = p_AMSE_Id 
            AND "CESM"."ACMS_Id" = p_ACMS_Id 
            AND "CESM"."EME_Id" = p_EME_Id 
        ORDER BY "CESM"."AMCST_Id"
    LOOP
        v_AMCST_Id := rec_exmsubjectdetails."AMCST_Id";
        v_CMI_Id := rec_exmsubjectdetails."MI_Id";
        v_CASMAY_Id := rec_exmsubjectdetails."ASMAY_Id";
        v_CAMCO_Id := rec_exmsubjectdetails."AMCO_Id";
        v_CAMB_Id := rec_exmsubjectdetails."AMB_Id";
        v_CAMSE_Id := rec_exmsubjectdetails."AMSE_Id";
        v_CACMS_Id := rec_exmsubjectdetails."ACMS_Id";
        v_CISMS_Id := rec_exmsubjectdetails."ISMS_Id";
        v_CEME_Id := rec_exmsubjectdetails."EME_Id";
        v_CEYCES_AplResultFlg := rec_exmsubjectdetails."ECYSES_AplResultFlg";
        v_CEYCES_MarksEntryMax := rec_exmsubjectdetails."ECYSES_MarksEntryMax";
        v_CEYCES_MaxMarks := rec_exmsubjectdetails."ECYSES_MaxMarks";
        v_CEYCES_MinMarks := rec_exmsubjectdetails."ECYSES_MinMarks";
        v_CEMGR_Id := rec_exmsubjectdetails."EMGR_Id";
        v_CESTM_Marks := rec_exmsubjectdetails."ECSTM_Marks";
        v_CESTM_MarksGradeFlg := rec_exmsubjectdetails."ECSTM_MarksGradeFlg";
        v_CESTM_Grade := rec_exmsubjectdetails."ECSTM_Grade";
        v_CESTM_Flg := rec_exmsubjectdetails."ECSTM_Flg";

        IF v_CESTM_MarksGradeFlg = 'M' THEN
            IF (v_CEYCES_MaxMarks > v_CEYCES_MarksEntryMax) THEN
                v_CRatio := (v_CEYCES_MaxMarks / NULLIF(v_CEYCES_MarksEntryMax, 0));
                v_CESTM_Marks := v_CESTM_Marks * v_CRatio;
            ELSIF (v_CEYCES_MaxMarks < v_CEYCES_MarksEntryMax) THEN
                v_CRatio := (v_CEYCES_MarksEntryMax / NULLIF(v_CEYCES_MaxMarks, 0));
                v_CESTM_Marks := v_CESTM_Marks / NULLIF(v_CRatio, 0);
            ELSIF (v_CEYCES_MaxMarks = v_CEYCES_MarksEntryMax) THEN 
                v_CESTM_Marks := v_CESTM_Marks;
            END IF;
        ELSIF v_CESTM_MarksGradeFlg = 'G' THEN
            SELECT (("EMGD_From" + "EMGD_To") / 2) INTO v_CESTM_Marks 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE ("EMGD_Name" = v_CESTM_Grade) 
            AND "EMGD_ActiveFlag" = true 
            AND "EMGR_Id" = v_CEMGR_Id
            LIMIT 1;
        END IF;

        SELECT "ExmConfig_RoundoffFlag" INTO v_CRoundOffFlg 
        FROM "Exm"."Exm_Configuration" 
        WHERE "MI_Id" = p_MI_Id 
        LIMIT 1;

        IF (v_CRoundOffFlg = true) THEN
            v_CESTM_Marks := ROUND(v_CESTM_Marks, 0);
        ELSIF (v_CRoundOffFlg = false) THEN
            v_CESTM_Marks := v_CESTM_Marks;
        END IF;

        IF ((v_CEYCES_AplResultFlg = true OR v_CEYCES_AplResultFlg = false) 
            AND (v_CEYCES_MinMarks > v_CESTM_Marks)) THEN
            v_CESTMPS_PassFailFlg := 'Fail';
        ELSE 
            v_CESTMPS_PassFailFlg := 'Pass';
        END IF;
  
        IF (v_CESTM_Flg = 'AB') THEN 
            v_CESTMPS_PassFailFlg := 'AB';
        ELSIF (v_CESTM_Flg = 'L') THEN 
            v_CESTMPS_PassFailFlg := 'L';
        ELSIF (v_CESTM_Flg = 'M') THEN 
            v_CESTMPS_PassFailFlg := 'M';
        ELSIF (v_CESTM_Flg = 'OD') THEN 
            v_CESTMPS_PassFailFlg := 'OD';
        END IF;
  
        v_CESTM_Marks := v_CESTM_Marks;
 
        SELECT "EMGR_MarksPerFlag" INTO v_CGredeFlag 
        FROM "Exm"."Exm_Master_Grade" 
        WHERE "EMGR_Id" = v_CEMGR_Id;
     
        IF (v_CGredeFlag = 'M') THEN
            v_CGradeMarksPercentage := v_CESTM_Marks;
        ELSIF (v_CGredeFlag = 'P') THEN
            v_CSubject_Percentage := (CAST((v_CESTM_Marks / NULLIF(v_CEYCES_MaxMarks, 0)) * 100 AS DECIMAL(10,2)));
            v_CGradeMarksPercentage := v_CSubject_Percentage;
        END IF;

        IF v_CESTM_MarksGradeFlg = 'M' THEN
            v_CESTMPS_ObtainedGrade := NULL;

            SELECT "EMGD_Name" INTO v_CESTMPS_ObtainedGrade 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE (((CAST(v_CGradeMarksPercentage AS DECIMAL(10,2))) 
                BETWEEN (CAST("EMGD_From" AS DECIMAL(10,2))) 
                AND (CAST("EMGD_To" AS DECIMAL(10,2)))) 
                OR ((CAST(v_CGradeMarksPercentage AS DECIMAL(10,2))) 
                BETWEEN (CAST("EMGD_To" AS DECIMAL(10,2))) 
                AND (CAST("EMGD_From" AS DECIMAL(10,2))))) 
            AND "EMGR_Id" = v_CEMGR_Id
            LIMIT 1;
        ELSIF v_CESTM_MarksGradeFlg = 'G' THEN
            v_CESTMPS_ObtainedGrade := v_CESTM_Grade;
        END IF;

        INSERT INTO "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" (
            "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", 
            "AMCST_Id", "ISMS_Id", "EME_Id", "ECSTMPS_MaxMarks", 
            "ECSTMPS_ObtainedMarks", "ECSTMPS_ObtainedGrade", 
            "ECSTMPS_PassFailFlg", "ECSTMPS_AplResultFlg", 
            "CreatedDate", "UpdatedDate"
        )
        VALUES (
            v_CMI_Id, v_CASMAY_Id, v_CAMCO_Id, v_CAMB_Id, v_CAMSE_Id, 
            v_CACMS_Id, v_AMCST_Id, v_CISMS_Id, v_CEME_Id, 
            v_CEYCES_MaxMarks, v_CESTM_Marks, v_CESTMPS_ObtainedGrade, 
            v_CESTMPS_PassFailFlg, v_CEYCES_AplResultFlg, 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );

        SELECT "ECYSES_SubExamFlg", "ECYSES_SubSubjectFlg" 
        INTO v_CEYCES_SubExamFlg, v_CEYCES_SubSubjectFlg 
        FROM "CLG"."Exm_Col_Yearly_Scheme" AS "CEYC"  
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
            ON "CEYCE"."ECYS_Id" = "CEYC"."ECYS_Id" 
            AND "CEYCE"."AMCO_Id" = p_AMCO_Id 
            AND "CEYCE"."AMB_Id" = p_AMB_Id 
            AND "CEYCE"."AMSE_Id" = p_AMSE_Id 
            AND "EME_Id" = p_EME_Id 
            AND "ECYSE_ActiveFlg" = true 
            AND "CEYC"."ECYS_ActiveFlag" = true 
            AND "CEYCE"."ACSS_Id" = "CEYC"."ACSS_Id" 
            AND "CEYCE"."ACST_Id" = "CEYC"."ACST_Id"
            AND "CEYC"."MI_Id" = p_MI_Id 
            AND "CEYC"."AMCO_Id" = p_AMCO_Id 
            AND "CEYC"."AMB_Id" = p_AMB_Id 
            AND "CEYC"."AMSE_Id" = p_AMSE_Id 
        INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
            ON "CEYCES"."ECYSE_Id" = "CEYCES"."ECYSE_Id" 
            AND "ECYSES_ActiveFlg" = true
        WHERE "CEYC"."MI_Id" = p_MI_Id 
            AND "CEYC"."AMCO_Id" = p_AMCO_Id 
            AND "CEYC"."AMB_Id" = p_AMB_Id 
            AND "CEYC"."AMSE_Id" = p_AMSE_Id 
            AND "CEYCE"."EME_Id" = p_EME_Id 
            AND "CEYCES"."ISMS_Id" = v_CISMS_Id
        LIMIT 1;
  
        IF (v_CEYCES_SubExamFlg = false AND v_CEYCES_SubSubjectFlg = true) 
            OR (v_CEYCES_SubExamFlg = true AND v_CEYCES_SubSubjectFlg = false) 
            OR (v_CEYCES_SubExamFlg = true AND v_CEYCES_SubSubjectFlg = true) THEN
            PERFORM "CLG_SubSubject_SubExam"(
                v_CMI_Id, v_CASMAY_Id, v_CAMCO_Id, v_CAMB_Id, 
                v_CAMSE_Id, v_CACMS_Id, v_AMCST_Id, v_CEME_Id, v_CISMS_Id
            );
        END IF;

    END LOOP;

    FOR rec_examsubjectwisecalc IN 
        SELECT DISTINCT "CESM"."MI_Id", "CESM"."AMCO_Id", "CESM"."AMB_Id", 
            "CESM"."AMSE_Id", "CESM"."ACMS_Id", "CESM"."ISMS_Id", "CESM"."EME_Id"
        FROM "CLG"."Exm_Col_Yearly_Scheme" AS "CEYC"    
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
            ON "CEYCE"."ECYS_Id" = "CEYC"."ECYS_Id" 
            AND "CEYCE"."AMCO_Id" = p_AMCO_Id 
            AND "CEYCE"."AMB_Id" = p_AMB_Id 
            AND "CEYCE"."AMSE_Id" = p_AMSE_Id 
            AND "EME_Id" = p_EME_Id 
            AND "ECYSE_ActiveFlg" = true 
            AND "CEYC"."ECYS_ActiveFlag" = true 
            AND "CEYCE"."ACSS_Id" = "CEYC"."ACSS_Id" 
            AND "CEYCE"."ACST_Id" = "CEYC"."ACST_Id"
            AND "CEYC"."MI_Id" = p_MI_Id 
            AND "CEYC"."AMCO_Id" = p_AMCO_Id 
            AND "CEYC"."AMB_Id" = p_AMB_Id 
            AND "CEYC"."AMSE_Id" = p_AMSE_Id  
        INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
            ON "CEYCES"."ECYSE_Id" = "CEYCES"."ECYSE_Id" 
            AND "ECYSES_ActiveFlg" = true
        INNER JOIN "CLG"."Exm_Col_Student_Marks" AS "CESM" 
            ON "CESM"."ISMS_Id" = "CEYCES"."ISMS_Id" 
            AND "CESM"."MI_Id" = p_MI_Id 
            AND "CESM"."EME_Id" = p_EME_Id 
            AND "CESM"."ACMS_Id" = p_ACMS_Id 
            AND "CESM"."AMSE_Id" = p_AMSE_Id 
            AND "CESM"."AMB_Id" = p_AMB_Id 
            AND "CESM"."AMCO_Id" = p_AMCO_Id
        WHERE "CEYC"."MI_Id" = p_MI_Id 
            AND "CESM"."AMCO_Id" = p_AMCO_Id 
            AND "CESM"."AMB_Id" = p_AMB_Id 
            AND "CESM"."AMSE_Id" = p_AMSE_Id 
            AND "CESM"."ACMS_Id" = p_ACMS_Id 
            AND "CESM"."EME_Id" = p_EME_Id 
        ORDER BY "CESM"."ISMS_Id"
    LOOP
        v_CMI_Id := rec_examsubjectwisecalc."MI_Id";
        v_CAMCO_Id := rec_examsubjectwisecalc."AMCO_Id";
        v_CAMB_Id := rec_examsubjectwisecalc."AMB_Id";
        v_CAMSE_Id := rec_examsubjectwisecalc."AMSE_Id";
        v_CACMS_Id := rec_examsubjectwisecalc."ACMS_Id";
        v_CISMS_Id := rec_examsubjectwisecalc."ISMS_Id";
        v_CEME_Id := rec_examsubjectwisecalc."EME_Id";

        SELECT SUM("ECSTMPS_ObtainedMarks") INTO v_CSection_Totalmarks 
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = v_CMI_Id 
            AND "ASMAY_Id" = v_CASMAY_Id 
            AND "ACMS_Id" = v_CACMS_Id 
            AND "AMSE_Id" = v_CAMSE_Id 
            AND "AMB_Id" = v_CAMB_Id 
            AND "AMCO_Id" = v_CAMCO_Id 
            AND "EME_Id" = v_CEME_Id 
            AND "ISMS_Id" = v_CISMS_Id 
        GROUP BY "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", "ISMS_Id";
  
        SELECT COUNT("AMCST_Id") INTO v_CSection_Totalcount 
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = v_CMI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ACMS_Id" = v_CACMS_Id 
            AND "AMSE_Id" = v_CAMSE_I