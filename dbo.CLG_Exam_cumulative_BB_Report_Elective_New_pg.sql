CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_cumulative_BB_Report_Elective_New"(
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_ACSS_Id bigint,
    p_MI_Id bigint,
    p_AMSE_Id bigint,
    p_EME_Id bigint,
    p_ACMS_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCST_FirstName" character varying,
    "AMCST_MiddleName" character varying,
    "AMCST_LastName" character varying,
    "AMCST_DOB" timestamp,
    "ACYST_RollNo" bigint,
    "AMCST_AdmNo" character varying,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" character varying,
    "ISMS_SubjectCode" character varying,
    "ECYSES_AplResultFlg" boolean,
    "ECYSES_MaxMarks" numeric,
    "ECYSES_MinMarks" numeric,
    "EMGR_Id" bigint,
    "ECSTMPSSS_MaxMarks" numeric,
    "ECSTMPS_SemAverage" numeric,
    "ECSTMPS_SectionAverage" numeric,
    "ECSTMPS_SemHighest" numeric,
    "ECSTMPS_SectionHighest" numeric,
    "ECSTMPS_ObtainedMarks" numeric,
    "ECSTMPS_ObtainedGrade" character varying,
    "ECSTMPS_PassFailFlg" character varying,
    "EME_ExamName" character varying,
    "AMCO_CourseName" character varying,
    "AMB_BranchName" character varying,
    "AMSE_SEMName" character varying,
    "ACMS_SectionName" character varying,
    "ASA_ClassHeld" bigint,
    "ASA_Class_Attended" bigint,
    "EMGD_Remarks" character varying,
    "ESTMP_TotalObtMarks" numeric,
    "ESTMP_Percentage" numeric,
    "ECSTMP_TotalGrade" character varying,
    "ECSTMP_SemRank" integer,
    "ECSTMP_SectionRank" integer,
    "ECSTMP_TotalGradeRemark" character varying,
    "ECSTMP_Result" character varying,
    "ECSTMP_TotalMaxMarks" numeric,
    "MI_name" character varying,
    "ECYSES_SubjectOrder" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMCS"."AMCST_Id",
        "AMCS"."AMCST_FirstName",
        "AMCS"."AMCST_MiddleName",
        "AMCS"."AMCST_LastName",
        "AMCS"."AMCST_DOB",
        "ACYS"."ACYST_RollNo",
        "AMCS"."AMCST_AdmNo",
        "CEYCES"."ISMS_Id",
        "IMS"."ISMS_SubjectName",
        "IMS"."ISMS_SubjectCode",
        "CEYCES"."ECYSES_AplResultFlg",
        "CEYCES"."ECYSES_MaxMarks",
        "CEYCES"."ECYSES_MinMarks",
        "CEYCES"."EMGR_Id",
        COALESCE("ECSMPS"."ECSTMPS_MaxMarks", 0) AS "ECSTMPSSS_MaxMarks",
        COALESCE("ECSMPS"."ECSTMPS_SemAverage", 0) AS "ECSTMPS_SemAverage",
        COALESCE("ECSMPS"."ECSTMPS_SectionAverage", 0) AS "ECSTMPS_SectionAverage",
        ROUND(COALESCE("ECSMPS"."ECSTMPS_SemHighest", 0), 0) AS "ECSTMPS_SemHighest",
        ROUND(COALESCE("ECSMPS"."ECSTMPS_SectionHighest", 0), 0) AS "ECSTMPS_SectionHighest",
        COALESCE("ECSMPS"."ECSTMPS_ObtainedMarks", 0) AS "ECSTMPS_ObtainedMarks",
        "ECSMPS"."ECSTMPS_ObtainedGrade",
        "ECSMPS"."ECSTMPS_PassFailFlg",
        "EME"."EME_ExamName",
        "AMC"."AMCO_CourseName",
        "AMB"."AMB_BranchName",
        "AMS"."AMSE_SEMName",
        "ACMS"."ACMS_SectionName",
        (SELECT SUM("ACSA"."ACSA_ClassHeld") 
         FROM "CLG"."Adm_College_Student_Attendance" "ACSA"  
         WHERE "MI_Id" = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "AMCO_Id" = p_AMCO_Id 
           AND "AMB_Id" = p_AMB_Id 
           AND "AMSE_Id" = p_AMSE_Id 
           AND "ACMS_Id" = p_ACMS_Id  
           AND "ACSA"."ACSA_AttendanceDate"::timestamp BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate") AS "ASA_ClassHeld",
        (SELECT SUM("ACSAS"."ACSAS_ClassAttended") 
         FROM "CLG"."Adm_College_Student_Attendance_Students" "ACSAS", 
              "CLG"."Adm_College_Student_Attendance" AS "ACSA"
         WHERE "ACSAS"."ACSA_Id" = "ACSA"."ACSA_Id" 
           AND "MI_Id" = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "AMCO_Id" = p_AMCO_Id 
           AND "AMB_Id" = p_AMB_Id 
           AND "AMSE_Id" = p_AMSE_Id 
           AND "ACMS_Id" = p_ACMS_Id 
           AND "ACSAS"."AMCST_Id" = "AMCS"."AMCST_Id" 
           AND "ACSA"."ACSA_AttendanceDate"::timestamp BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate") AS "ASA_Class_Attended",
        "EMGD1"."EMGD_Remarks",
        COALESCE("ECSMP"."ECSTMP_TotalObtMarks", 0) AS "ESTMP_TotalObtMarks",
        COALESCE("ECSMP"."ECSTMP_Percentage", 0) AS "ESTMP_Percentage",
        "ECSMP"."ECSTMP_TotalGrade",
        COALESCE("ECSMP"."ECSTMP_SemRank", 0) AS "ECSTMP_SemRank",
        COALESCE("ECSMP"."ECSTMP_SectionRank", 0) AS "ECSTMP_SectionRank",
        "EMGD2"."EMGD_Remarks" AS "ECSTMP_TotalGradeRemark",
        "ECSMP"."ECSTMP_Result" AS "ECSTMP_Result",
        COALESCE("ECSMP"."ECSTMP_TotalMaxMarks", 0) AS "ECSTMP_TotalMaxMarks",
        "MI"."MI_name",
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "CLG"."Adm_Master_College_Student" AS "AMCS"         
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "AMCS"."AMCST_ActiveFlag" = true 
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ACYS"."AMCO_Id" = p_AMCO_Id  
        AND "ACYS"."AMB_Id" = p_AMB_Id 
        AND "ACYS"."AMSE_Id" = p_AMSE_Id 
        AND "ACYS"."ACMS_Id" = p_ACMS_Id 
        AND "AMCS"."MI_Id" = p_MI_Id                       
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "CEYS" ON "CEYS"."MI_Id" = p_MI_Id  
        AND "CEYS"."AMCO_Id" = p_AMCO_Id 
        AND "CEYS"."AMB_Id" = p_AMB_Id 
        AND "CEYS"."AMSE_Id" = p_AMSE_Id  
        AND "CEYS"."ECYS_ActiveFlag" = true 
        AND "AMCS"."ACSS_Id" = p_ACSS_Id 
        AND "AMCS"."ACST_Id" = "CEYS"."ACST_Id"
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" ON "CEYCE"."ECYS_Id" = "CEYS"."ECYS_Id" 
        AND "CEYCE"."AMCO_Id" = p_AMCO_Id 
        AND "CEYCE"."AMB_Id" = p_AMB_Id 
        AND "CEYCE"."AMSE_Id" = p_AMSE_Id 
        AND "CEYCE"."EME_Id" = p_EME_Id 
        AND "CEYCE"."ECYSE_ActiveFlg" = true 
        AND "AMCS"."ACSS_Id" = p_ACSS_Id 
        AND "AMCS"."ACST_Id" = "CEYCE"."ACST_Id"
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" ON "CEYCES"."ECYSE_Id" = "CEYCE"."ECYSE_Id" 
        AND "ECYSES_ActiveFlg" = true 
        AND "ECYSES_AplResultFlg" = false
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process" AS "ECSMP" ON "AMCS"."AMCST_Id" = "ECSMP"."AMCST_Id"  
        AND "ECSMP"."AMCO_Id" = p_AMCO_Id 
        AND "ECSMP"."AMB_Id" = p_AMB_Id 
        AND "ECSMP"."AMSE_Id" = p_AMSE_Id  
        AND "ECSMP"."ACMS_Id" = p_ACMS_Id 
        AND "ECSMP"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSMP"."MI_Id" = p_MI_Id 
        AND "ECSMP"."EME_Id" = p_EME_Id   
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS "ECSMPS" ON "ECSMPS"."ISMS_Id" = "CEYCES"."ISMS_Id" 
        AND "ECSMPS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMPS"."AMCO_Id" = p_AMCO_Id 
        AND "ECSMPS"."AMB_Id" = p_AMB_Id 
        AND "ECSMPS"."AMSE_Id" = p_AMSE_Id  
        AND "ECSMPS"."ACMS_Id" = p_ACMS_Id 
        AND "ECSMPS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSMPS"."MI_Id" = p_MI_Id 
        AND "ECSMPS"."EME_Id" = p_EME_Id
    INNER JOIN "IVRM_Master_Subjects" AS "IMS" ON "IMS"."ISMS_Id" = "ECSMPS"."ISMS_Id"  
        AND "IMS"."MI_Id" = p_MI_Id   
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Branch" AS "AMB" ON "AMB"."AMB_Id" = "ACYS"."AMB_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMS" ON "AMS"."AMSE_Id" = "ACYS"."AMSE_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "Master_Institution" AS "MI" ON "MI"."MI_Id" = p_MI_Id
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD1" ON "EMGD1"."EMGR_Id" = "CEYCES"."EMGR_Id" 
        AND "ECSMPS"."ECSTMPS_ObtainedGrade" = "EMGD1"."EMGD_Name"
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD2" ON "EMGD2"."EMGR_Id" = "CEYCE"."EMGR_Id" 
        AND "ECSMP"."ECSTMP_TotalGrade" = "EMGD2"."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS "EME" ON "CEYCE"."EME_Id" = "EME"."EME_Id" 
        AND "EME"."MI_Id" = p_MI_Id                             
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "ACMS" ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS "ECSS" ON "ECSS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "ECSS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "ECSS"."MI_Id" = p_MI_Id 
        AND "ECSS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSS"."AMCO_Id" = p_AMCO_Id 
        AND "ECSS"."AMB_Id" = p_AMB_Id 
        AND "ECSS"."AMSE_Id" = p_AMSE_Id 
        AND "ECSS"."AMSE_Id" = p_AMSE_Id 
        AND "ECSS"."ACMS_Id" = p_ACMS_Id
    GROUP BY "AMCS"."AMCST_Id", "AMCS"."AMCST_FirstName", "AMCS"."AMCST_MiddleName", "AMCS"."AMCST_LastName", "AMCS"."AMCST_DOB", "ACYS"."ACYST_RollNo", "AMCS"."AMCST_AdmNo", "CEYCES"."ISMS_Id", "IMS"."ISMS_SubjectName", "IMS"."ISMS_SubjectCode", "CEYCES"."ECYSES_AplResultFlg", "CEYCES"."ECYSES_MaxMarks", "CEYCES"."ECYSES_MinMarks", "CEYCES"."EMGR_Id", "ECSMPS"."ECSTMPS_MaxMarks", "ECSMPS"."ECSTMPS_SemAverage", "ECSMPS"."ECSTMPS_SectionAverage", "ECSMPS"."ECSTMPS_SemHighest", "ECSMPS"."ECSTMPS_SectionHighest", "ECSMPS"."ECSTMPS_ObtainedMarks", "ECSMPS"."ECSTMPS_ObtainedGrade", "ECSMPS"."ECSTMPS_PassFailFlg", "EME"."EME_ExamName", "AMC"."AMCO_CourseName", "AMB"."AMB_BranchName", "AMS"."AMSE_SEMName", "ACMS"."ACMS_SectionName", "EMGD1"."EMGD_Remarks", "ECSMP"."ECSTMP_TotalObtMarks", "ECSMP"."ECSTMP_TotalMaxMarks", "ECSMP"."ECSTMP_Percentage", "ECSMP"."ECSTMP_TotalGrade", "ECSMP"."ECSTMP_SemRank", "ECSMP"."ECSTMP_SectionRank", "EMGD2"."EMGD_Remarks", "ECSMP"."ECSTMP_TotalObtMarks", "MI"."MI_name", "CEYCES"."ECYSES_SubjectOrder", "CEYCE"."ECYSE_AttendanceFromDate", "CEYCE"."ECYSE_AttendanceToDate", "ECSMP"."ECSTMP_Result"
    ORDER BY "ACYST_RollNo", "ECYSES_SubjectOrder" ASC;
END;
$$;