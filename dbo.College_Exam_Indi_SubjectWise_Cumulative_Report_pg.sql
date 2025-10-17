CREATE OR REPLACE FUNCTION "dbo"."College_Exam_Indi_SubjectWise_Cumulative_Report"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT,
    "@ISMS_Id" TEXT,
    "@EME_Id" TEXT,
    "@ACSS_Id" TEXT,
    "@ACST_Id" TEXT
)
RETURNS TABLE(
    "amst_id" BIGINT,
    "STUDENTNAME" TEXT,
    "AMST_DOB" TIMESTAMP,
    "AMAY_RollNo" BIGINT,
    "AMST_AdmNo123" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_SubjectCode" VARCHAR,
    "ECYSES_AplResultFlg" BOOLEAN,
    "ECYSES_MaxMarks" NUMERIC,
    "ECYSES_MinMarks" NUMERIC,
    "EMGR_Id" BIGINT,
    "ECSTMPSSS_MaxMarks" NUMERIC,
    "ECSTMPS_SemAverage" NUMERIC,
    "ECSTMPS_SectionAverage" NUMERIC,
    "ECSTMPS_SemHighest" NUMERIC,
    "ECSTMPS_SectionHighest" NUMERIC,
    "ECSTMPS_ObtainedMarks" NUMERIC,
    "ECSTMPS_ObtainedGrade" VARCHAR,
    "ECSTMPS_PassFailFlg" VARCHAR,
    "EME_ExamName" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ASA_ClassHeld" BIGINT,
    "ASA_Class_Attended" BIGINT,
    "EMGD_Remarks" TEXT,
    "ECSTMP_TotalObtMarks" NUMERIC,
    "ECSTMP_Percentage" NUMERIC,
    "ECSTMP_TotalGrade" VARCHAR,
    "ECSTMP_SemRank" INTEGER,
    "ECSTMP_SectionRank" INTEGER,
    "ECSTMP_TotalGradeRemark" TEXT,
    "ECSTMP_Result" VARCHAR,
    "ECSTMP_TotalMaxMarks" NUMERIC,
    "MI_name" VARCHAR,
    "ECYSES_SubjectOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "AMCS"."AMCST_Id" AS "amst_id",
        (CASE WHEN "AMCS"."AMCST_FirstName" = '' OR "AMCS"."AMCST_FirstName" IS NULL THEN '' ELSE "AMCS"."AMCST_FirstName" END || 
         CASE WHEN "AMCS"."AMCST_MiddleName" = '' OR "AMCS"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "AMCS"."AMCST_MiddleName" END || 
         CASE WHEN "AMCS"."AMCST_LastName" = '''' OR "AMCS"."AMCST_LastName" IS NULL THEN '''' ELSE ' ' || "AMCS"."AMCST_LastName" END) AS "STUDENTNAME",
        "AMCS"."AMCST_DOB" AS "AMST_DOB",
        "ACYS"."ACYST_RollNo" AS "AMAY_RollNo",
        "AMCS"."AMCST_AdmNo" AS "AMST_AdmNo123",
        COALESCE("AMCS"."AMCST_RegistrationNo", '0') AS "AMST_AdmNo",
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
        COALESCE("ECSMPS"."ECSTMPS_ObtainedGrade", 'A') AS "ECSTMPS_ObtainedGrade",
        "ECSMPS"."ECSTMPS_PassFailFlg",
        "EME"."EME_ExamName",
        "AMC"."AMCO_CourseName",
        "AMB"."AMB_BranchName",
        "AMS"."AMSE_SEMName",
        "ACMS"."ACMS_SectionName",
        COALESCE((SELECT SUM("ACSA"."ACSA_ClassHeld") 
                  FROM "CLG"."Adm_College_Student_Attendance" "ACSA"
                  WHERE "ACSA"."MI_Id" = "@MI_Id"::BIGINT 
                    AND "ACSA"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                    AND "ACSA"."AMCO_Id" = "@AMCO_Id"::BIGINT 
                    AND "ACSA"."AMB_Id" = "@AMB_Id"::BIGINT 
                    AND "ACSA"."AMSE_Id" = "@AMSE_Id"::BIGINT 
                    AND "ACSA"."ACMS_Id" = "@ACMS_Id"::BIGINT 
                    AND "ACSA"."ISMS_Id" = "@ISMS_Id"::BIGINT 
                    AND "ACSA"."ACSA_ActiveFlag" = 1 
                    AND "ACSA"."ACSA_AttendanceDate" BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate"), 0) AS "ASA_ClassHeld",
        COALESCE((SELECT SUM("ACSAS"."ACSAS_ClassAttended") 
                  FROM "CLG"."Adm_College_Student_Attendance_Students" "ACSAS"
                  INNER JOIN "CLG"."Adm_College_Student_Attendance" AS "ACSA" ON "ACSAS"."ACSA_Id" = "ACSA"."ACSA_Id"
                  WHERE "ACSA"."MI_Id" = "@MI_Id"::BIGINT 
                    AND "ACSA"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                    AND "ACSA"."AMCO_Id" = "@AMCO_Id"::BIGINT 
                    AND "ACSA"."AMB_Id" = "@AMB_Id"::BIGINT 
                    AND "ACSA"."AMSE_Id" = "@AMSE_Id"::BIGINT 
                    AND "ACSA"."ACMS_Id" = "@ACMS_Id"::BIGINT 
                    AND "ACSAS"."AMCST_Id" = "AMCS"."AMCST_Id" 
                    AND "ACSA"."ISMS_Id" = "@ISMS_Id"::BIGINT 
                    AND "ACSA"."ACSA_ActiveFlag" = 1 
                    AND "ACSA"."ACSA_AttendanceDate" BETWEEN "CEYCE"."ECYSE_AttendanceFromDate" AND "CEYCE"."ECYSE_AttendanceToDate"), 0) AS "ASA_Class_Attended",
        "EMGD1"."EMGD_Remarks",
        COALESCE("ECSMP"."ECSTMP_TotalObtMarks", 0) AS "ECSTMP_TotalObtMarks",
        COALESCE("ECSMP"."ECSTMP_Percentage", 0) AS "ECSTMP_Percentage",
        "ECSMP"."ECSTMP_TotalGrade",
        COALESCE("ECSMP"."ECSTMP_SemRank", 0) AS "ECSTMP_SemRank",
        COALESCE("ECSMP"."ECSTMP_SectionRank", 0) AS "ECSTMP_SectionRank",
        "EMGD2"."EMGD_Remarks" AS "ECSTMP_TotalGradeRemark",
        "ECSMP"."ECSTMP_Result" AS "ECSTMP_Result",
        COALESCE("ECSMP"."ECSTMP_TotalMaxMarks", 0) AS "ECSTMP_TotalMaxMarks",
        "MI"."MI_name",
        "CEYCES"."ECYSES_SubjectOrder"
    FROM "CLG"."Adm_Master_College_Student" AS "AMCS"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
        ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "AMCS"."AMCST_ActiveFlag" = 1 
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "ACYS"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ACYS"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "ACYS"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "ACYS"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "ACYS"."ACMS_Id" = "@ACMS_Id"::BIGINT 
        AND "AMCS"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme" AS "CEYS" 
        ON "AMCS"."ACST_Id" = "CEYS"."ACST_Id" 
        AND "CEYS"."MI_Id" = "@MI_Id"::BIGINT 
        AND "CEYS"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "CEYS"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "CEYS"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "CEYS"."ECYS_ActiveFlag" = 1 
        AND "AMCS"."ACSS_Id" = "@ACSS_Id"::BIGINT 
        AND "CEYS"."ACSS_Id" = "@ACSS_Id"::BIGINT
    INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
        ON "CEYCE"."ECYS_Id" = "CEYS"."ECYS_Id" 
        AND "AMCS"."ACST_Id" = "CEYCE"."ACST_Id" 
        AND "CEYCE"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "CEYCE"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "CEYCE"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "CEYCE"."EME_Id" = "@EME_Id"::BIGINT 
        AND "CEYCE"."ECYSE_ActiveFlg" = 1 
        AND "AMCS"."ACSS_Id" = "@ACSS_Id"::BIGINT 
        AND "CEYCE"."ACSS_Id" = "@ACSS_Id"::BIGINT
    INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
        ON "CEYCES"."ECYSE_Id" = "CEYCE"."ECYSE_Id" 
        AND "CEYCES"."ECYSES_ActiveFlg" = 1
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process" AS "ECSMP" 
        ON "AMCS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMP"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "ECSMP"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "ECSMP"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "ECSMP"."ACMS_Id" = "@ACMS_Id"::BIGINT 
        AND "ECSMP"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ECSMP"."MI_Id" = "@MI_Id"::BIGINT 
        AND "ECSMP"."EME_Id" = "@EME_Id"::BIGINT
    LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" AS "ECSMPS" 
        ON "ECSMPS"."ISMS_Id" = "CEYCES"."ISMS_Id" 
        AND "ECSMPS"."AMCST_Id" = "ECSMP"."AMCST_Id" 
        AND "ECSMPS"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "ECSMPS"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "ECSMPS"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "ECSMPS"."ACMS_Id" = "@ACMS_Id"::BIGINT 
        AND "ECSMPS"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ECSMPS"."MI_Id" = "@MI_Id"::BIGINT 
        AND "ECSMPS"."EME_Id" = "@EME_Id"::BIGINT 
        AND "ECSMPS"."ISMS_Id" = "@ISMS_Id"::BIGINT
    INNER JOIN "IVRM_Master_Subjects" AS "IMS" 
        ON "IMS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "IMS"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" 
        ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id" 
        AND "AMC"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Adm_Master_Branch" AS "AMB" 
        ON "AMB"."AMB_Id" = "ACYS"."AMB_Id" 
        AND "AMC"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Adm_Master_Semester" AS "AMS" 
        ON "AMS"."AMSE_Id" = "ACYS"."AMSE_Id" 
        AND "AMC"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "Master_Institution" AS "MI" 
        ON "MI"."MI_Id" = "@MI_Id"::BIGINT
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD1" 
        ON "EMGD1"."EMGR_Id" = "CEYCES"."EMGR_Id" 
        AND "ECSMPS"."ECSTMPS_ObtainedGrade" = "EMGD1"."EMGD_Name"
    LEFT OUTER JOIN "Exm"."Exm_Master_Grade_Details" AS "EMGD2" 
        ON "EMGD2"."EMGR_Id" = "CEYCE"."EMGR_Id" 
        AND "ECSMP"."ECSTMP_TotalGrade" = "EMGD2"."EMGD_Name"
    INNER JOIN "Exm"."Exm_Master_Exam" AS "EME" 
        ON "CEYCE"."EME_Id" = "EME"."EME_Id" 
        AND "EME"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "ACMS" 
        ON "ACMS"."ACMS_Id" = "ACYS"."ACMS_Id" 
        AND "AMC"."MI_Id" = "@MI_Id"::BIGINT
    INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" AS "ECSS" 
        ON "ECSS"."ISMS_Id" = "ECSMPS"."ISMS_Id" 
        AND "ECSS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "ECSS"."MI_Id" = "@MI_Id"::BIGINT 
        AND "ECSS"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ECSS"."AMCO_Id" = "@AMCO_Id"::BIGINT 
        AND "ECSS"."AMB_Id" = "@AMB_Id"::BIGINT 
        AND "ECSS"."AMSE_Id" = "@AMSE_Id"::BIGINT 
        AND "ECSS"."ACMS_Id" = "@ACMS_Id"::BIGINT
    GROUP BY 
        "AMCS"."AMCST_Id", "AMCS"."AMCST_FirstName", "AMCS"."AMCST_MiddleName", "AMCS"."AMCST_LastName",
        "AMCS"."AMCST_DOB", "ACYS"."ACYST_RollNo", "AMCS"."AMCST_AdmNo", "AMCS"."AMCST_RegistrationNo",
        "CEYCES"."ISMS_Id", "IMS"."ISMS_SubjectName", "IMS"."ISMS_SubjectCode", "CEYCES"."ECYSES_AplResultFlg",
        "CEYCES"."ECYSES_MaxMarks", "CEYCES"."ECYSES_MinMarks", "CEYCES"."EMGR_Id", "ECSMPS"."ECSTMPS_MaxMarks",
        "ECSMPS"."ECSTMPS_SemAverage", "ECSMPS"."ECSTMPS_SectionAverage", "ECSMPS"."ECSTMPS_SemHighest",
        "ECSMPS"."ECSTMPS_SectionHighest", "ECSMPS"."ECSTMPS_ObtainedMarks", "ECSMPS"."ECSTMPS_ObtainedGrade",
        "ECSMPS"."ECSTMPS_PassFailFlg", "EME"."EME_ExamName", "AMC"."AMCO_CourseName", "AMB"."AMB_BranchName",
        "AMS"."AMSE_SEMName", "ACMS"."ACMS_SectionName", "EMGD1"."EMGD_Remarks", "ECSMP"."ECSTMP_TotalObtMarks",
        "ECSMP"."ECSTMP_TotalMaxMarks", "ECSMP"."ECSTMP_Percentage", "ECSMP"."ECSTMP_TotalGrade",
        "ECSMP"."ECSTMP_SemRank", "ECSMP"."ECSTMP_SectionRank", "EMGD2"."EMGD_Remarks", "MI"."MI_name",
        "CEYCES"."ECYSES_SubjectOrder", "CEYCE"."ECYSE_AttendanceFromDate", "CEYCE"."ECYSE_AttendanceToDate",
        "ECSMP"."ECSTMP_Result"
    ORDER BY 
        (CASE WHEN "AMCS"."AMCST_FirstName" = '' OR "AMCS"."AMCST_FirstName" IS NULL THEN '' ELSE "AMCS"."AMCST_FirstName" END || 
         CASE WHEN "AMCS"."AMCST_MiddleName" = '' OR "AMCS"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "AMCS"."AMCST_MiddleName" END || 
         CASE WHEN "AMCS"."AMCST_LastName" = '''' OR "AMCS"."AMCST_LastName" IS NULL THEN '''' ELSE ' ' || "AMCS"."AMCST_LastName" END),
        "ACYS"."ACYST_RollNo",
        "CEYCES"."ECYSES_SubjectOrder" ASC;

END;
$$;