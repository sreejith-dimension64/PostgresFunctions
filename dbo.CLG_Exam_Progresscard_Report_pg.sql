CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_Progresscard_Report"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT, 
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_EME_Id TEXT,
    p_ACST_Id TEXT,
    p_ACSS_Id TEXT,
    p_AMCST_Id TEXT
)
RETURNS TABLE (
    "AMCST_Id" INTEGER,
    "StudentName" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "AMCST_AdmNo" TEXT,
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "ISMS_SubjectCode" TEXT,
    "ECYSES_AplResultFlg" BOOLEAN,
    "ECYSES_MaxMarks" NUMERIC,
    "ECYSES_MinMarks" NUMERIC,
    "EMGR_Id" INTEGER,
    "ECSTMPS_MaxMarks" NUMERIC,
    "ECYSES_SubExamFlg" BOOLEAN,
    "ECYSES_SubSubjectFlg" BOOLEAN,
    "ECSTMPS_SemAverage" NUMERIC,
    "ECSTMPS_SectionAverage" NUMERIC,
    "ECSTMPS_SemHighest" NUMERIC,
    "ECSTMPS_SectionHighest" NUMERIC,
    "ECSTMPS_ObtainedMarks" NUMERIC,
    "ECSTMPS_ObtainedGrade" TEXT,
    "ECSTMPS_PassFailFlg" TEXT,
    "EME_ExamName" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "EMGD_Remarks" TEXT,
    "ECSTMP_TotalObtMarks" NUMERIC,
    "ECSTMP_Percentage" NUMERIC,
    "ECSTMP_TotalGrade" TEXT,
    "ECSTMP_SemRank" INTEGER,
    "ECSTMP_SectionRank" INTEGER,
    "ECSTMP_TotalGradeRemark" TEXT,
    "ECSTMP_Result" TEXT,
    "ECSTMP_TotalMaxMarks" NUMERIC,
    "MI_name" TEXT,
    "ECYSES_SubjectOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQL_QUERY TEXT;
BEGIN
    
    v_SQL_QUERY := '
    SELECT DISTINCT "AMCS"."AMCST_Id" AS "AMCST_Id",
    (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
    "AMCST_RegistrationNo","AMCST_AdmNo",
    "CEYCES"."ISMS_Id","IMS"."ISMS_SubjectName","IMS"."ISMS_SubjectCode","CEYCES"."ECYSES_AplResultFlg",
    "CEYCES"."ECYSES_MaxMarks","CEYCES"."ECYSES_MinMarks","CEYCES"."EMGR_Id",
    COALESCE("ECSMPS"."ECSTMPS_MaxMarks",0) AS "ECSTMPS_MaxMarks","ECYSES_SubExamFlg","ECYSES_SubSubjectFlg",
    COALESCE("ECSMPS"."ECSTMPS_SemAverage",0) AS "ECSTMPS_SemAverage",
    COALESCE("ECSMPS"."ECSTMPS_SectionAverage",0) AS "ECSTMPS_SectionAverage",
    ROUND(COALESCE("ECSMPS"."ECSTMPS_SemHighest",0),0) AS "ECSTMPS_SemHighest",
    ROUND(COALESCE("ECSMPS"."ECSTMPS_SectionHighest",0),0) AS "ECSTMPS_SectionHighest",
    COALESCE("ECSMPS"."ECSTMPS_ObtainedMarks",0) AS "ECSTMPS_ObtainedMarks",
    COALESCE("ECSMPS"."ECSTMPS_ObtainedGrade",''A'') AS "ECSTMPS_ObtainedGrade",
    "ECSMPS"."ECSTMPS_PassFailFlg","EME"."EME_ExamName","AMCO_CourseName",
    "AMB_BranchName","AMSE_SEMName","ACMS_SectionName","EMGD1"."EMGD_Remarks",
    COALESCE("ECSMP"."ECSTMP_TotalObtMarks",0) AS "ECSTMP_TotalObtMarks",
    COALESCE("ECSMP"."ECSTMP_Percentage",0) AS "ECSTMP_Percentage","ECSMP"."ECSTMP_TotalGrade",
    COALESCE("ECSMP"."ECSTMP_SemRank",0) AS "ECSTMP_SemRank",
    COALESCE("ECSMP"."ECSTMP_SectionRank",0) AS "ECSTMP_SectionRank",
    "EMGD2"."EMGD_Remarks" AS "ECSTMP_TotalGradeRemark","ECSMP"."ECSTMP_Result" AS "ECSTMP_Result",
    COALESCE("ECSMP"."ECSTMP_TotalMaxMarks",0) AS "ECSTMP_TotalMaxMarks","MI"."MI_name",
    "CEYCES"."ECYSES_SubjectOrder"
    FROM "CLG"."Adm_Master_College_Student" AS "AMCS"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "CEYS" ON "AMCS"."ACST_Id" = "CEYS"."ACST_Id" 
        AND "CEYS"."MI_Id" IN (' || p_MI_Id || ') 
        AND "CEYS"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "CEYS"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "CEYS"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "CEYS"."ECYS_ActiveFlag" = true 
        AND "AMCS"."ACSS_Id" IN (' || p_ACSS_Id || ') 
        AND "CEYS"."ACST_Id" = ' || p_ACST_Id || ' 
        AND "CEYS"."ACSS_Id" = ' || p_ACSS_Id || '
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" ON "CEYCE"."ECYS_Id" = "CEYS"."ECYS_Id" 
        AND "AMCS"."ACST_Id" = "CEYCE"."ACST_Id" 
        AND "CEYCE"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "CEYCE"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "CEYCE"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "CEYCE"."EME_Id" IN (' || p_EME_Id || ') 
        AND "CEYCE"."ECYSE_ActiveFlg" = true 
        AND "AMCS"."ACSS_Id" IN (' || p_ACSS_Id || ') 
        AND "CEYCE"."ACST_Id" = ' || p_ACST_Id || ' 
        AND "CEYCE"."ACSS_Id" = ' || p_ACSS_Id || '
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" ON "CEYCES"."ECYSE_Id" = "CEYCE"."ECYSE_Id" 
        AND "ECYSES_ActiveFlg" = true 
        AND "ECYSES_AplResultFlg" = true
    LEFT JOIN "CLG"."Exm_Col_Student_Marks_Process" AS "ECSMP" ON "AMCS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMP"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "ECSMP"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "ECSMP"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "ECSMP"."ACMS_Id" IN (' || p_ACMS_Id || ') 
        AND "ECSMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
        AND "ECSMP"."MI_Id" IN (' || p_MI_Id || ') 
        AND "ECSMP"."EME_Id" IN (' || p_EME_Id || ')
    LEFT JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS "ECSMPS" ON "ECSMPS"."ISMS_Id" = "CEYCES"."ISMS_Id" 
        AND "ECSMPS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMPS"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "ECSMPS"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "ECSMPS"."AMSE_Id" IN (' || p_AMSE_Id || ')
        AND "ECSMPS"."ACMS_Id" IN (' || p_ACMS_Id || ') 
        AND "ECSMPS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
        AND "ECSMPS"."MI_Id" IN (' || p_MI_Id || ') 
        AND "ECSMPS"."EME_Id" IN (' || p_EME_Id || ')
    INNER JOIN "IVRM_Master_Subjects" AS "IMS" ON "IMS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "IMS"."MI_Id" IN (' || p_MI_Id || ')    
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id" 
        AND "AMC"."MI_Id" IN (' || p_MI_Id || ') 
    INNER JOIN "CLG"."Adm_Master_Branch" AS "AMB" ON "AMB"."AMB_Id" = "ACYS"."AMB_Id" 
        AND "AMC"."MI_Id" IN (' || p_MI_Id || ') 
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMS" ON "AMS"."AMSE_Id" = "ACYS"."AMSE_Id" 
        AND "AMC"."MI_Id" IN (' || p_MI_Id || ') 
    INNER JOIN "Master_Institution" AS "MI" ON "MI"."MI_Id" IN (' || p_MI_Id || ') 
    LEFT JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD1" ON "EMGD1"."EMGR_Id" = "CEYCES"."EMGR_Id" 
        AND "ECSMPS"."ECSTMPS_ObtainedGrade" = "EMGD1"."EMGD_Name"
    LEFT JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD2" ON "EMGD2"."EMGR_Id" = "CEYCE"."EMGR_Id" 
        AND "ECSMP"."ECSTMP_TotalGrade" = "EMGD2"."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS "EME" ON "CEYCE"."EME_Id" = "EME"."EME_Id" 
        AND "EME"."MI_Id" IN (' || p_MI_Id || ')                             
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "ACMS" ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id" 
        AND "AMC"."MI_Id" IN (' || p_MI_Id || ')
    INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS "ECSS" ON "ECSS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "ECSS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "ECSS"."MI_Id" IN (' || p_MI_Id || ')
        AND "ECSS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
        AND "ECSS"."AMCO_Id" IN (' || p_AMCO_Id || ') 
        AND "ECSS"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "ECSS"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "ECSS"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "ECSS"."ACMS_Id" IN (' || p_ACMS_Id || ')
    WHERE "AMCS"."MI_Id" IN (' || p_MI_Id || ') 
        AND "ACYS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
        AND "ACYS"."AMCO_Id" IN (' || p_AMCO_Id || ')  
        AND "ACYS"."AMB_Id" IN (' || p_AMB_Id || ') 
        AND "ACYS"."AMSE_Id" IN (' || p_AMSE_Id || ') 
        AND "ACYS"."ACMS_Id" IN (' || p_ACMS_Id || ') 
        AND "AMCS"."ACST_Id" IN (' || p_ACST_Id || ') 
        AND "AMCS"."ACSS_Id" IN (' || p_ACSS_Id || ')
        AND "ECSMP"."EME_Id" IN (' || p_EME_Id || ') 
        AND "AMCS"."AMCST_Id" IN (' || p_AMCST_Id || ')';

    RETURN QUERY EXECUTE v_SQL_QUERY;

END;
$$;