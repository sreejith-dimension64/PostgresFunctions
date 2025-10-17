CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_Get_CumulativeReport_Format2"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_ACMS_Id" TEXT,
    "p_EME_Id" TEXT,
    "p_ACST_Id" TEXT,
    "p_ACSS_Id" TEXT,
    "p_FLAG" TEXT,
    "p_AMCST_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SQL_QUERY" TEXT;
BEGIN
    
    IF "p_FLAG" = '1' THEN
        "v_SQL_QUERY" := '
        SELECT DISTINCT B."AMCST_Id", 
            (COALESCE(A."AMCST_FirstName",'''') || '' '' || COALESCE(A."AMCST_MiddleName",'''') || '' '' || COALESCE(A."AMCST_LastName",'''')) AS studentname, 
            A."AMCST_AdmNo", A."AMCST_RegistrationNo", B."ACYST_RollNo", 
            TO_CHAR(A."AMCST_Date", ''DD/MM/YYYY'') AS DOJ, 
            "AMCST_SOL", "AMCST_Sex"
        FROM "CLG"."Adm_Master_College_Student" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_SchemeType" F ON F."ACST_Id" = A."ACST_Id"
        INNER JOIN "CLG"."Adm_College_SubjectScheme" G ON G."ACSS_Id" = A."ACSS_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" H ON H."ACMS_Id" = B."ACMS_Id"
        WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
        AND B."AMCO_Id" = ' || "p_AMCO_Id" || ' AND B."AMB_Id" = ' || "p_AMB_Id" || ' 
        AND B."AMSE_Id" = ' || "p_AMSE_Id" || ' AND B."ACMS_Id" = ' || "p_ACMS_Id" || ' 
        AND A."ACSS_Id" = ' || "p_ACSS_Id" || ' AND A."ACST_Id" = ' || "p_ACST_Id" || '';

        RETURN QUERY EXECUTE "v_SQL_QUERY";
        
    ELSIF "p_FLAG" = '2' THEN
        RETURN QUERY
        SELECT C."ISMS_Id", D."ISMS_SubjectName", C."ECYSES_AplResultFlg", C."ECYSES_SubExamFlg", 
            C."ECYSES_SubSubjectFlg", C."ECYSES_MarksDisplayFlg", C."ECYSES_GradeDisplayFlg", 
            C."ECYSES_SubjectOrder", F."EMSS_SubSubjectName", G."EMSE_SubExamName", E."EMSS_Id", E."EMSE_Id"
        FROM "CLG"."Exm_Col_Yearly_Scheme" A 
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" B ON A."ECYS_Id" = B."ECYS_Id"
        INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" C ON C."ECYSE_Id" = B."ECYSE_Id"
        INNER JOIN "IVRM_Master_Subjects" D ON D."ISMS_Id" = C."ISMS_Id"
        LEFT JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise_Sub" E ON E."ECYSES_Id" = C."ECYSES_Id" AND E."ECYSESSS_ActiveFlg" = 1
        LEFT JOIN "Exm"."Exm_Master_SubSubject" F ON F."EMSS_Id" = E."EMSS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" G ON G."EMSE_Id" = E."EMSE_Id"
        WHERE A."MI_Id" = "p_MI_Id"::INTEGER AND A."AMCO_Id" = "p_AMCO_Id"::INTEGER 
        AND A."AMB_Id" = "p_AMB_Id"::INTEGER AND A."AMSE_Id" = "p_AMSE_Id"::INTEGER 
        AND A."ACSS_Id" = "p_ACSS_Id"::INTEGER AND A."ACST_Id" = "p_ACST_Id"::INTEGER
        AND B."AMCO_Id" = "p_AMCO_Id"::INTEGER AND B."AMB_Id" = "p_AMB_Id"::INTEGER 
        AND B."AMSE_Id" = "p_AMSE_Id"::INTEGER AND B."ACSS_Id" = "p_ACSS_Id"::INTEGER 
        AND B."ACST_Id" = "p_ACST_Id"::INTEGER AND B."EME_Id" = "p_EME_Id"::INTEGER
        AND A."ECYS_ActiveFlag" = 1 AND B."ECYSE_ActiveFlg" = 1 AND C."ECYSES_ActiveFlg" = 1
        ORDER BY "ECYSES_SubjectOrder";

    ELSIF "p_FLAG" = '3' THEN
        "v_SQL_QUERY" := '
        SELECT DISTINCT AMCS."AMCST_Id" AS "AMCST_Id",
        CEYCES."ISMS_Id", IMS."ISMS_SubjectName", IMS."ISMS_SubjectCode", CEYCES."ECYSES_AplResultFlg", 
        CEYCES."ECYSES_MaxMarks", CEYCES."ECYSES_MinMarks", CEYCES."EMGR_Id",
        COALESCE(ECSMPS."ECSTMPS_MaxMarks", 0) AS "ECSTMPS_MaxMarks", "ECYSES_SubExamFlg", "ECYSES_SubSubjectFlg",
        ECSMSS."EMSS_Id", "EMSE_Id", "ECSTMPSSS_MaxMarks", "ECSTMPSSS_ObtainedMarks", "ECSTMPSSS_ObtainedGrade", 
        "ECSTMPSSS_PassFailFlg",
        COALESCE(ECSMPS."ECSTMPS_SemAverage", 0) AS "ECSTMPS_SemAverage", 
        COALESCE(ECSMPS."ECSTMPS_SectionAverage", 0) AS "ECSTMPS_SectionAverage",
        ROUND(COALESCE(ECSMPS."ECSTMPS_SemHighest", 0)::NUMERIC, 0) AS "ECSTMPS_SemHighest", 
        ROUND(COALESCE(ECSMPS."ECSTMPS_SectionHighest", 0)::NUMERIC, 0) AS "ECSTMPS_SectionHighest",
        COALESCE(ECSMPS."ECSTMPS_ObtainedMarks", 0) AS "ECSTMPS_ObtainedMarks",
        COALESCE(ECSMPS."ECSTMPS_ObtainedGrade", ''A'') AS "ECSTMPS_ObtainedGrade", 
        ECSMPS."ECSTMPS_PassFailFlg", EME."EME_ExamName", "AMCO_CourseName",
        "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", EMGD1."EMGD_Remarks", 
        COALESCE(ECSMP."ECSTMP_TotalObtMarks", 0) AS "ECSTMP_TotalObtMarks",
        COALESCE(ECSMP."ECSTMP_Percentage", 0) AS "ECSTMP_Percentage", ECSMP."ECSTMP_TotalGrade",
        COALESCE(ECSMP."ECSTMP_SemRank", 0) AS "ECSTMP_SemRank", 
        COALESCE(ECSMP."ECSTMP_SectionRank", 0) AS "ECSTMP_SectionRank",
        EMGD2."EMGD_Remarks" AS "ECSTMP_TotalGradeRemark", ECSMP."ECSTMP_Result" AS "ECSTMP_Result",
        COALESCE(ECSMP."ECSTMP_TotalMaxMarks", 0) AS "ECSTMP_TotalMaxMarks", MI."MI_name", 
        CEYCES."ECYSES_SubjectOrder"
        FROM "CLG"."Adm_Master_College_Student" AS AMCS
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS ACYS ON ACYS."AMCST_Id" = AMCS."AMCST_Id"
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS CEYS ON AMCS."ACST_Id" = CEYS."ACST_Id" 
        AND CEYS."MI_Id" IN (' || "p_MI_Id" || ') AND CEYS."AMCO_Id" IN (' || "p_AMCO_Id" || ') 
        AND CEYS."AMB_Id" IN (' || "p_AMB_Id" || ') AND CEYS."AMSE_Id" IN (' || "p_AMSE_Id" || ') 
        AND CEYS."ECYS_ActiveFlag" = 1 AND AMCS."ACSS_Id" IN (' || "p_ACSS_Id" || ') 
        AND CEYS."ACST_Id" = ' || "p_ACST_Id" || ' AND CEYS."ACSS_Id" = ' || "p_ACSS_Id" || '
        INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS CEYCE ON CEYCE."ECYS_Id" = CEYS."ECYS_Id" 
        AND AMCS."ACST_Id" = CEYCE."ACST_Id" AND CEYCE."AMCO_Id" IN (' || "p_AMCO_Id" || ') 
        AND CEYCE."AMB_Id" IN (' || "p_AMB_Id" || ') AND CEYCE."AMSE_Id" IN (' || "p_AMSE_Id" || ') 
        AND CEYCE."EME_Id" IN (' || "p_EME_Id" || ') AND CEYCE."ECYSE_ActiveFlg" = 1 
        AND AMCS."ACSS_Id" IN (' || "p_ACSS_Id" || ') AND CEYCE."ACST_Id" = ' || "p_ACST_Id" || ' 
        AND CEYCE."ACSS_Id" = ' || "p_ACSS_Id" || '
        INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS CEYCES ON CEYCES."ECYSE_Id" = CEYCE."ECYSE_Id" 
        AND "ECYSES_ActiveFlg" = 1 AND "ECYSES_AplResultFlg" = 1
        LEFT JOIN "CLG"."Exm_Col_Student_Marks_Process" AS ECSMP ON AMCS."AMCST_Id" = ECSMP."AMCST_Id" 
        AND ECSMP."AMCO_Id" IN (' || "p_AMCO_Id" || ') AND ECSMP."AMB_Id" IN (' || "p_AMB_Id" || ') 
        AND ECSMP."AMSE_Id" IN (' || "p_AMSE_Id" || ') AND ECSMP."ACMS_Id" IN (' || "p_ACMS_Id" || ') 
        AND ECSMP."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') AND ECSMP."MI_Id" IN (' || "p_MI_Id" || ') 
        AND ECSMP."EME_Id" IN (' || "p_EME_Id" || ')
        LEFT JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS ECSMPS 
        ON ECSMPS."ISMS_Id" = CEYCES."ISMS_Id" AND ECSMPS."AMCST_Id" = ECSMP."AMCST_Id" 
        AND ECSMPS."AMCO_Id" IN (' || "p_AMCO_Id" || ') AND ECSMPS."AMB_Id" IN (' || "p_AMB_Id" || ') 
        AND ECSMPS."AMSE_Id" IN (' || "p_AMSE_Id" || ') AND ECSMPS."ACMS_Id" IN (' || "p_ACMS_Id" || ') 
        AND ECSMPS."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') AND ECSMPS."MI_Id" IN (' || "p_MI_Id" || ') 
        AND ECSMPS."EME_Id" IN (' || "p_EME_Id" || ')
        LEFT JOIN "CLG"."Exm_Col_Student_Marks_Pro_Sub_SubSubject" AS ECSMSS 
        ON ECSMSS."ECSTMPS_Id" = ECSMPS."ECSTMPS_Id"
        INNER JOIN "IVRM_Master_Subjects" AS IMS ON IMS."ISMS_Id" = ECSMPS."ISMS_Id" 
        AND IMS."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "CLG"."Adm_Master_Course" AS AMC ON AMC."AMCO_Id" = ACYS."AMCO_Id" 
        AND AMC."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "CLG"."Adm_Master_Branch" AS AMB ON AMB."AMB_Id" = ACYS."AMB_Id" 
        AND AMC."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "CLG"."Adm_Master_Semester" AS AMS ON AMS."AMSE_Id" = ACYS."AMSE_Id" 
        AND AMC."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "Master_Institution" AS MI ON MI."MI_Id" IN (' || "p_MI_Id" || ')
        LEFT JOIN "Exm"."Exm_Master_Grade_Details" AS EMGD1 ON EMGD1."EMGR_Id" = CEYCES."EMGR_Id" 
        AND ECSMPS."ECSTMPS_ObtainedGrade" = EMGD1."EMGD_Name"
        LEFT JOIN "Exm"."Exm_Master_Grade_Details" AS EMGD2 ON EMGD2."EMGR_Id" = CEYCE."EMGR_Id" 
        AND ECSMP."ECSTMP_TotalGrade" = EMGD2."EMGD_Name"
        INNER JOIN "Exm"."Exm_Master_Exam" AS EME ON CEYCE."EME_Id" = EME."EME_Id" 
        AND EME."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "CLG"."Adm_College_Master_Section" AS ACMS ON ACMS."ACMS_Id" = ACYS."ACMS_Id" 
        AND AMC."MI_Id" IN (' || "p_MI_Id" || ')
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS ECSS ON ECSS."ISMS_Id" = ECSMPS."ISMS_Id" 
        AND ECSS."AMCST_Id" = AMCS."AMCST_Id" AND ECSS."MI_Id" IN (' || "p_MI_Id" || ')
        AND ECSS."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') AND ECSS."AMCO_Id" IN (' || "p_AMCO_Id" || ') 
        AND ECSS."AMB_Id" IN (' || "p_AMB_Id" || ') AND ECSS."AMSE_Id" IN (' || "p_AMSE_Id" || ') 
        AND ECSS."AMSE_Id" IN (' || "p_AMSE_Id" || ') AND ECSS."ACMS_Id" IN (' || "p_ACMS_Id" || ')
        WHERE AMCS."MI_Id" IN (' || "p_MI_Id" || ') AND ACYS."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
        AND ACYS."AMCO_Id" IN (' || "p_AMCO_Id" || ') AND ACYS."AMB_Id" IN (' || "p_AMB_Id" || ') 
        AND ACYS."AMSE_Id" IN (' || "p_AMSE_Id" || ') AND ACYS."ACMS_Id" IN (' || "p_ACMS_Id" || ') 
        AND AMCS."ACST_Id" IN (' || "p_ACST_Id" || ') AND AMCS."ACSS_Id" IN (' || "p_ACSS_Id" || ')
        AND ECSMP."EME_Id" IN (' || "p_EME_Id" || ') AND AMCS."AMCST_Id" IN (' || "p_AMCST_Id" || ')';

        RETURN QUERY EXECUTE "v_SQL_QUERY";

    ELSIF "p_FLAG" = '4' THEN
        "v_SQL_QUERY" := '
        SELECT DISTINCT A."AMCST_Id",
        "CSTMP_TotalMaxMarks", "ECSTMP_TotalObtMarks", "ECSTMP_Percentage", "ECSTMP_TotalGrade", 
        "ECSTMP_SemRank", "ECSTMP_SectionRank", "ECSTMP_Result"
        FROM "CLG"."Exm_Col_Student_Marks_Process" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_ID" = A."EME_Id"
        WHERE B."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND B."AMCO_Id" = ' || "p_AMCO_Id" || ' 
        AND B."AMB_Id" = ' || "p_AMB_Id" || ' AND B."AMSE_Id" = ' || "p_AMSE_Id" || ' 
        AND B."ACMS_Id" = ' || "p_ACMS_Id" || ' AND B."AMCST_Id" IN (' || "p_AMCST_Id" || ') 
        AND A."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND A."AMCO_Id" = ' || "p_AMCO_Id" || ' 
        AND A."AMB_Id" = ' || "p_AMB_Id" || ' AND A."AMSE_Id" = ' || "p_AMSE_Id" || ' 
        AND A."ACMS_Id" = ' || "p_ACMS_Id" || ' AND A."AMCST_Id" IN (' || "p_AMCST_Id" || ')
        AND A."EME_Id" = ' || "p_EME_Id" || ' AND C."ACSS_Id" = ' || "p_ACSS_Id" || ' 
        AND C."ACST_Id" = ' || "p_ACST_Id" || '';

        RETURN QUERY EXECUTE "v_SQL_QUERY";

    END IF;

    RETURN;
END;
$$;