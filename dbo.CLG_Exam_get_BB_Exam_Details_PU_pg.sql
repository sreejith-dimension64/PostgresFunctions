CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_get_BB_Exam_Details_PU"(
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_ACSS_Id bigint,
    p_MI_Id bigint,
    p_AMSE_Id bigint,
    p_EME_Id bigint,
    p_ACMS_Id bigint,
    p_ACST_Id bigint
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCST_FirstName" text,
    "AMCST_MiddleName" text,
    "AMCST_LastName" text,
    "AMCST_DOB" timestamp,
    "ACYST_RollNo" text,
    "AMCST_AdmNo" text,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" text,
    "ISMS_SubjectCode" text,
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
    "ECSTMPS_ObtainedGrade" text,
    "ECSTMPS_PassFailFlg" text,
    "EME_ExamName" text,
    "AMCO_CourseName" text,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "ACMS_SectionName" text,
    "ECSTMPSSS_ObtainedMarks" numeric,
    "EMSE_SubExamName" text,
    "EMSE_SubExamOrder" integer,
    "ASA_ClassHeld" numeric,
    "ASA_Class_Attended" numeric,
    "EMGD_Remarks" text,
    "ECSTMP_TotalObtMarks" numeric,
    "ECSTMP_Percentage" numeric,
    "ECSTMP_TotalGrade" text,
    "ECSTMP_SemRank" integer,
    "ECSTMP_SectionRank" integer,
    "EMGD_Remarks2" text,
    "ECSTMP_TotalMaxMarks" numeric,
    "MI_name" text,
    "ECYSES_SubjectOrder" integer,
    "ECYSES_MarksDisplayFlg" boolean,
    "ECYSES_GradeDisplayFlg" boolean,
    "ECSTMP_Result" text,
    "AMCST_RegistrationNo" text
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
        COALESCE("ECSMPS"."ECSTMPS_MaxMarks", 0) as "ECSTMPSSS_MaxMarks",
        COALESCE("ECSMPS"."ECSTMPS_SemAverage", 0) AS "ECSTMPS_SemAverage",
        COALESCE("ECSMPS"."ECSTMPS_SectionAverage", 0) AS "ECSTMPS_SectionAverage",
        ROUND(COALESCE("ECSMPS"."ECSTMPS_SemHighest", 0), 0) as "ECSTMPS_SemHighest",
        ROUND(COALESCE("ECSMPS"."ECSTMPS_SectionHighest", 0), 0) AS "ECSTMPS_SectionHighest",
        COALESCE("ECSMPS"."ECSTMPS_ObtainedMarks", 0) AS "ECSTMPS_ObtainedMarks",
        COALESCE("ECSMPS"."ECSTMPS_ObtainedGrade", 'A') as "ECSTMPS_ObtainedGrade",
        "ECSMPS"."ECSTMPS_PassFailFlg",
        "EME"."EME_ExamName",
        "AMCO_CourseName",
        "AMB_BranchName",
        "AMSE_SEMName",
        "ACMS_SectionName",
        COALESCE("subuj"."ECSTMPSSS_ObtainedMarks", 0) as "ECSTMPSSS_ObtainedMarks",
        COALESCE("msubsuj"."EMSE_SubExamName", '') as "EMSE_SubExamName",
        "msubsuj"."EMSE_SubExamOrder",
        COALESCE((SELECT sum("ACSA"."ACSA_ClassHeld") 
                  FROM "CLG"."Adm_College_Student_Attendance" "ACSA"  
                  WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "AMCO_Id" = p_AMCO_Id 
                    AND "AMB_Id" = p_AMB_Id 
                    AND "AMSE_Id" = p_AMSE_Id 
                    AND "ACMS_Id" = p_ACMS_Id  
                    AND "ACSA"."ACSA_AttendanceDate"::timestamp BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate"), 0) AS "ASA_ClassHeld",
        COALESCE((SELECT sum("ACSAS"."ACSAS_ClassAttended") 
                  FROM "CLG"."Adm_College_Student_Attendance_Students" "ACSAS",
                       "CLG"."Adm_College_Student_Attendance" "ACSA"
                  WHERE "ACSAS"."ACSA_Id" = "ACSA"."ACSA_Id" 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "AMCO_Id" = p_AMCO_Id 
                    AND "AMB_Id" = p_AMB_Id 
                    AND "AMSE_Id" = p_AMSE_Id 
                    AND "ACMS_Id" = p_ACMS_Id 
                    AND "ACSAS"."AMCST_Id" = "AMCS"."AMCST_Id" 
                    AND "ACSA"."ACSA_AttendanceDate"::timestamp BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate"), 0) AS "ASA_Class_Attended",
        "EMGD1"."EMGD_Remarks",
        COALESCE("ECSMP"."ECSTMP_TotalObtMarks", 0) as "ECSTMP_TotalObtMarks",
        COALESCE("ECSMP"."ECSTMP_Percentage", 0) AS "ECSTMP_Percentage",
        "ECSMP"."ECSTMP_TotalGrade",
        COALESCE("ECSMP"."ECSTMP_SemRank", 0) AS "ECSTMP_SemRank",
        COALESCE("ECSMP"."ECSTMP_SectionRank", 0) as "ECSTMP_SectionRank",
        "EMGD2"."EMGD_Remarks" as "EMGD_Remarks2",
        COALESCE("ECSMP"."ECSTMP_TotalMaxMarks", 0) AS "ECSTMP_TotalMaxMarks",
        "MI"."MI_name",
        "CEYCES"."ECYSES_SubjectOrder",
        "CEYCES"."ECYSES_MarksDisplayFlg",
        "CEYCES"."ECYSES_GradeDisplayFlg",
        "ECSMP"."ECSTMP_Result",
        COALESCE("AMCS"."AMCST_RegistrationNo", '0') as "AMCST_RegistrationNo"
    FROM "CLG"."Adm_Master_College_Student" AS "AMCS"           
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
        ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "AMCS"."AMCST_ActiveFlag" = true 
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ACYS"."AMCO_Id" = p_AMCO_Id  
        AND "ACYS"."AMB_Id" = p_AMB_Id 
        AND "ACYS"."AMSE_Id" = p_AMSE_Id 
        AND "ACYS"."ACMS_Id" = p_ACMS_Id 
        AND "AMCS"."MI_Id" = p_MI_Id                       
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "CEYS"  
        ON "AMCS"."ACST_Id" = "CEYS"."ACST_Id" 
        AND "CEYS"."MI_Id" = p_MI_Id  
        AND "CEYS"."AMCO_Id" = p_AMCO_Id 
        AND "CEYS"."AMB_Id" = p_AMB_Id 
        AND "CEYS"."AMSE_Id" = p_AMSE_Id  
        AND "CEYS"."ECYS_ActiveFlag" = true 
        AND "AMCS"."ACSS_Id" = p_ACSS_Id 
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
        ON "CEYCE"."ECYS_Id" = "CEYS"."ECYS_Id" 
        AND "AMCS"."ACST_Id" = "CEYCE"."ACST_Id" 
        AND "CEYCE"."AMCO_Id" = p_AMCO_Id 
        AND "CEYCE"."AMB_Id" = p_AMB_Id 
        AND "CEYCE"."AMSE_Id" = p_AMSE_Id 
        AND "CEYCE"."EME_Id" = p_EME_Id 
        AND "CEYCE"."ECYSE_ActiveFlg" = true 
        AND "AMCS"."ACSS_Id" = p_ACSS_Id 
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES"  
        ON "CEYCES"."ECYSE_Id" = "CEYCE"."ECYSE_Id" 
        AND "ECYSES_ActiveFlg" = true 
        AND "ECYSES_AplResultFlg" = true
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process" AS "ECSMP" 
        ON "AMCS"."AMCST_Id" = "ECSMP"."AMCST_Id"  
        AND "ECSMP"."AMCO_Id" = p_AMCO_Id 
        AND "ECSMP"."AMB_Id" = p_AMB_Id 
        AND "ECSMP"."AMSE_Id" = p_AMSE_Id  
        AND "ECSMP"."ACMS_Id" = p_ACMS_Id 
        AND "ECSMP"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSMP"."MI_Id" = p_MI_Id 
        AND "ECSMP"."EME_Id" = p_EME_Id    
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS "ECSMPS" 
        ON "ECSMPS"."ISMS_Id" = "CEYCES"."ISMS_Id" 
        AND "ECSMPS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMPS"."AMCO_Id" = p_AMCO_Id 
        AND "ECSMPS"."AMB_Id" = p_AMB_Id 
        AND "ECSMPS"."AMSE_Id" = p_AMSE_Id  
        AND "ECSMPS"."ACMS_Id" = p_ACMS_Id 
        AND "ECSMPS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSMPS"."MI_Id" = p_MI_Id 
        AND "ECSMPS"."EME_Id" = p_EME_Id
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Pro_Sub_SubSubject" "subuj" 
        ON "subuj"."ECSTMPS_Id" = "ECSMPS"."ECSTMPS_Id"
    LEFT OUTER JOIN "exm"."Exm_Master_SubExam" "msubsuj" 
        ON "msubsuj"."EMSE_Id" = "subuj"."EMSE_Id"
    INNER JOIN "IVRM_Master_Subjects" AS "IMS" 
        ON "IMS"."ISMS_Id" = "ECSMPS"."ISMS_Id"  
        AND "IMS"."MI_Id" = p_MI_Id   
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" 
        ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Branch" AS "AMB" 
        ON "AMB"."AMB_Id" = "ACYS"."AMB_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMS" 
        ON "AMS"."AMSE_Id" = "ACYS"."AMSE_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "Master_Institution" AS "MI" 
        ON "MI"."MI_Id" = p_MI_Id
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD1" 
        ON "EMGD1"."EMGR_Id" = "CEYCES"."EMGR_Id" 
        AND "ECSMPS"."ECSTMPS_ObtainedGrade" = "EMGD1"."EMGD_Name"
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD2" 
        ON "EMGD2"."EMGR_Id" = "CEYCE"."EMGR_Id" 
        AND "ECSMP"."ECSTMP_TotalGrade" = "EMGD2"."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS "EME" 
        ON "CEYCE"."EME_Id" = "EME"."EME_Id" 
        AND "EME"."MI_Id" = p_MI_Id                             
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "ACMS" 
        ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id" 
        AND "AMC"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS "ECSS" 
        ON "ECSS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "ECSS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "ECSS"."MI_Id" = p_MI_Id 
        AND "ECSS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ECSS"."AMCO_Id" = p_AMCO_Id 
        AND "ECSS"."AMB_Id" = p_AMB_Id 
        AND "ECSS"."AMSE_Id" = p_AMSE_Id 
        AND "ECSS"."AMSE_Id" = p_AMSE_Id 
        AND "ECSS"."ACMS_Id" = p_ACMS_Id
    ORDER BY "ACYST_RollNo", "ECYSES_SubjectOrder", "msubsuj"."EMSE_SubExamOrder" ASC;
    
    RETURN;
END;
$$;