CREATE OR REPLACE FUNCTION "dbo"."ADILE_Exam_Get_Overall_Cumulative_Report_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "@EYC_Id" BIGINT;
    "@EMCA_Id" BIGINT;
    "@ROUNDOFF_FLAG" BOOLEAN;
    "@EMPLOYEENAME" TEXT;
BEGIN
    DROP TABLE IF EXISTS exam_Mark;
    DROP TABLE IF EXISTS exam_Mark2;
    DROP TABLE IF EXISTS exam_Mark3;
    
    SELECT "ExmConfig_RoundoffFlag" INTO "@ROUNDOFF_FLAG" 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT;

    SELECT DISTINCT "EMCA_Id" INTO "@EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND "ECAC_ActiveFlag" = 1;
        
    SELECT DISTINCT "EYC_Id" INTO "@EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "EYC_ActiveFlg" = 1 
        AND "EMCA_Id" = "@EMCA_Id";

    IF "@FLAG" = '1' THEN
        "@EMPLOYEENAME" := '';
        
        SELECT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
        INTO "@EMPLOYEENAME"
        FROM "IVRM_Master_ClassTeacher" A 
        INNER JOIN "HR_Master_Employee" B ON A."HRME_Id" = B."HRME_Id"
        WHERE A."IMCT_ActiveFlag" = 1 
            AND B."HRME_ActiveFlag" = 1 
            AND B."HRME_LeftFlag" = 0 
            AND A."ASMAY_Id" = "@ASMAY_Id"::BIGINT
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND A."MI_Id" = "@MI_Id"::BIGINT
        LIMIT 1;

        RETURN QUERY
        SELECT DISTINCT A."AMST_Id",
            (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
             CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
             CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' THEN '' ELSE ' ' || "AMST_LastName" END) AS studentname,
            "AMST_AdmNo" AS admno,
            "AMAY_RollNo" AS rollno,
            "ASMCL_ClassName" AS classname,
            "ASMC_SectionName" AS sectionname,
            "AMST_RegistrationNo" AS regno,
            (CASE WHEN "AMST_FatherName" IS NULL OR "AMST_FatherName" = '' THEN '' ELSE "AMST_FatherName" END ||
             CASE WHEN "AMST_FatherSurname" IS NULL OR "AMST_FatherSurname" = '' THEN '' ELSE ' ' || "AMST_FatherSurname" END) AS fathername,
            (CASE WHEN "AMST_MotherName" IS NULL OR "AMST_MotherName" = '' THEN '' ELSE "AMST_MotherName" END ||
             CASE WHEN "AMST_MotherSurname" IS NULL OR "AMST_MotherSurname" = '' THEN '' ELSE ' ' || "AMST_MotherSurname" END) AS mothername,
            REPLACE(TO_CHAR("amst_dob", 'DD/MM/YYYY'), '/', '.') AS dob,
            "AMST_MobileNo" AS mobileno,
            (CASE WHEN "AMST_PerStreet" IS NULL OR "AMST_PerStreet" = '' THEN '' ELSE "AMST_PerStreet" END ||
             CASE WHEN "AMST_PerArea" IS NULL OR "AMST_PerArea" = '' THEN '' ELSE ',' || "AMST_PerArea" END ||
             CASE WHEN "AMST_PerCity" IS NULL OR "AMST_PerCity" = '' THEN '' ELSE ',' || "AMST_PerCity" END ||
             CASE WHEN "AMST_PerAdd3" IS NULL OR "AMST_PerAdd3" = '' THEN '' ELSE ',' || "AMST_PerAdd3" END) AS address,
            "AMST_Photoname" AS photoname,
            COALESCE(I."SPCCMH_HouseName", '') AS "SPCCMH_HouseName",
            "@EMPLOYEENAME" AS Classteacher
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "SPC"."SPCC_Student_House" H ON H."AMST_Id" = A."AMST_Id" 
            AND H."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND H."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND H."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND H."SPCCMH_ActiveFlag" = 1
        LEFT JOIN "SPC"."SPCC_Master_House" I ON I."SPCCMH_Id" = H."SPCCMH_Id" 
            AND I."SPCCMH_ActiveFlag" = 1 
            AND I."MI_Id" = "@MI_Id"::BIGINT
        WHERE A."MI_Id" = "@MI_Id"::BIGINT 
            AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND B."ASMS_Id" = "@ASMS_Id"::BIGINT
        ORDER BY rollno;
        
    ELSIF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT a."AMST_Id",
            a."ISMS_Id" AS "ISMS_Id_Old",
            "ISMS_SubjectName" AS "ISMS_SubjectName_Old",
            "EME_ExamName" AS "EMPSG_GroupName",
            "ESTMPS_MaxMarks" AS "ESTMPPSG_GroupMaxMarks",
            "ESTMPS_ObtainedMarks" AS "ESTMPPSG_GroupObtMarks_Old",
            "EYCES_SubjectOrder" AS "EMPS_SubjOrder",
            "EYCES_AplResultFlg" AS "EMPS_AppToResultFlg",
            COALESCE("ESTMPS_ObtainedGrade", '') AS "ESTMPPSG_GroupObtGrade",
            REPLACE("ESTMPS_GradePoints", '.00', '') AS "ESTMPPSG_GradePoints",
            "EME_ExamOrder" AS grporder,
            "ESTMPS_PassFailFlg" AS "ESTMPPS_PassFailFlg",
            "EME_ExamName" AS "EMPSG_DisplayName",
            0::BIGINT AS "ESG_Id",
            "ISMS_OrderFlag" AS subjectgrporder,
            ''::TEXT AS complusoryflag,
            a."ISMS_Id" AS "ISMS_Id",
            a."EME_Id"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" a
        INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" e ON e."ASMAY_Id" = a."ASMAY_Id" AND e."EMCA_Id" = "@EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" f ON f."EME_Id" = b."EME_Id" AND f."EYC_Id" = e."EYC_Id" AND f."EYC_Id" = "@EYC_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" g ON g."EYCE_Id" = f."EYCE_Id" AND g."ISMS_Id" = a."ISMS_Id"
        WHERE b."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
            AND A."MI_Id" = "@MI_Id"::BIGINT 
            AND A."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND a."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[]);
            
    ELSIF "@FLAG" = '3' THEN
        RETURN QUERY
        SELECT d."ISMS_Id",
            "ISMS_SubjectName",
            "ISMS_SubjectCode",
            "EYCES_MarksDisplayFlg",
            "EYCES_GradeDisplayFlg",
            "EYCES_SubjectOrder",
            E."AMST_Id",
            "ISMS_SubjectName" AS "ISMS_SubjectNameNew",
            "ISMS_IVRSSubjectName"
        FROM "exm"."Exm_Yearly_Category" a
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" E ON E."ASMAY_Id" = a."ASMAY_Id" 
            AND E."ISMS_Id" = c."ISMS_Id" 
            AND b."EME_Id" = E."EME_Id"
        WHERE a."EYC_Id" = "@EYC_Id" 
            AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND a."EMCA_Id" = "@EMCA_Id"
            AND b."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
            AND E."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND E."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND E."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND E."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
            AND E."AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
        GROUP BY d."ISMS_Id", "ISMS_SubjectName", "ISMS_SubjectCode", "EYCES_MarksDisplayFlg", 
                 "EYCES_GradeDisplayFlg", "EYCES_SubjectOrder", E."AMST_Id", "ISMS_IVRSSubjectName"
        ORDER BY "EYCES_SubjectOrder";
        
    ELSIF "@FLAG" = '4' THEN
        RETURN QUERY
        SELECT DISTINCT A."AMST_Id",
            A."ISMS_Id",
            CASE WHEN C."EMSS_SubSubjectName" IS NULL THEN D."EMSE_SubExamName" ELSE C."EMSS_SubSubjectName" END AS "EMSS_SubSubjectName",
            CASE WHEN C."EMSS_Id" IS NULL THEN D."EMSE_Id" ELSE C."EMSS_Id" END AS "EMSS_Id"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" B ON A."ESTMPS_Id" = B."ESTMPS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubSubject" C ON C."EMSS_Id" = B."EMSS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" D ON B."EMSE_Id" = D."EMSE_Id"
        WHERE A."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND A."AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
            AND A."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[]);
            
    ELSIF "@FLAG" = '5' THEN
        RETURN QUERY
        SELECT A."AMST_Id",
            A."ISMS_Id",
            B."ESTMPSSS_ObtainedMarks",
            B."ESTMPSSS_ObtainedGrade",
            B."ESTMPSSS_MaxMarks",
            B."ESTMPSSS_PassFailFlg",
            CASE WHEN C."EMSS_SubSubjectName" IS NULL THEN D."EMSE_SubExamName" ELSE C."EMSS_SubSubjectName" END AS "EMSS_SubSubjectName",
            CASE WHEN C."EMSS_Id" IS NULL THEN D."EMSE_Id" ELSE C."EMSS_Id" END AS "EMSS_Id",
            "EME_Id"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" B ON A."ESTMPS_Id" = B."ESTMPS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubSubject" C ON C."EMSS_Id" = B."EMSS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" D ON B."EMSE_Id" = D."EMSE_Id"
        WHERE A."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND A."AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
            AND A."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[]);
            
    ELSIF "@FLAG" = '6' THEN
        RETURN QUERY
        SELECT "AMST_Id",
            "EMER_Remarks",
            "EME_ID" AS "EME_Id"
        FROM "Exm"."Exm_Student_ProgressCard_Remarks"
        WHERE "MI_Id" = "@MI_Id"::BIGINT 
            AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "ASMS_Id" = "@ASMS_Id"::BIGINT
            AND "AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
            AND "EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
            AND "EMER_ActiveFlag" = 1;
            
    ELSIF "@FLAG" = '7' THEN
        CREATE TEMP TABLE exam_Mark AS
        SELECT DISTINCT h."AMST_Id",
            a."EME_Id",
            "EME_ExamName",
            G."EYCE_AttendanceFromDate",
            G."EYCE_AttendanceToDate"
        FROM "Exm"."Exm_Yearly_Category" e
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" g ON g."EYC_Id" = e."EYC_Id"
        INNER JOIN "exm"."Exm_Master_Exam" a ON a."EME_Id" = g."EME_Id"
        INNER JOIN "Adm_School_Y_Student" h ON h."ASMAY_Id" = e."ASMAY_Id"
        WHERE a."MI_Id" = "@MI_Id"::BIGINT 
            AND e."EYC_Id" = "@EYC_Id" 
            AND H."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND H."ASMCL_Id" = "@ASMCL_Id"::BIGINT
            AND H."AMST_Id" = ANY(STRING_TO_ARRAY("@AMST_Id", ',')::BIGINT[])
            AND H."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND e."EYC_ActiveFlg" = 1 
            AND g."EYCE_ActiveFlg" = 1
            AND h."AMAY_ActiveFlag" = 1 
            AND a."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[]);

        CREATE TEMP TABLE exam_Mark2 AS
        SELECT temp."AMST_Id",
            temp."EME_Id",
            temp."EME_ExamName",
            temp."EYCE_AttendanceFromDate",
            temp."EYCE_AttendanceToDate",
            SUM("ASA_ClassHeld") AS "TOTALWORKINGDAYS",
            SUM("ASA_Class_Attended") AS "TOTALPRESENTDAYS",
            ROUND(CAST(SUM("ASA_Class_Attended") * 100.0 / SUM(k."ASA_ClassHeld") AS NUMERIC), 1) AS "TOTALAttendancePercentage"
        FROM exam_Mark temp
        LEFT JOIN "Adm_Student_Attendance_Students" j ON j."AMST_Id" = temp."AMST_Id"
        LEFT JOIN "Adm_Student_Attendance" k ON k."ASA_Id" = j."ASA_Id"
            AND "ASA_Activeflag" = 1
            AND ((k."ASA_FromDate" BETWEEN temp."EYCE_AttendanceFromDate" AND temp."EYCE_AttendanceToDate")
                OR (k."ASA_ToDate" BETWEEN temp."EYCE_AttendanceFromDate" AND temp."EYCE_AttendanceToDate"))
        WHERE K."ASA_FromDate" IS NOT NULL
        GROUP BY temp."AMST_Id", temp."EME_Id", temp."EME_ExamName", temp."EYCE_AttendanceFromDate", temp."EYCE_AttendanceToDate";

        CREATE TEMP TABLE exam_Mark3 AS
        SELECT "EME_Id",
            "EME_ExamName",
            "EYCE_AttendanceFromDate",
            "EYCE_AttendanceToDate",
            SUM("TOTALWORKINGDAYS") OVER (PARTITION BY "AMST_Id" ORDER BY "EYCE_AttendanceFromDate", "EYCE_AttendanceToDate") AS "TOTALWORKINGDAYS",
            SUM("TOTALPRESENTDAYS") OVER (PARTITION BY "AMST_Id" ORDER BY "EYCE_AttendanceFromDate", "EYCE_AttendanceToDate") AS "TOTALPRESENTDAYS",
            "TOTALAttendancePercentage"
        FROM exam_Mark2;

        RETURN QUERY
        SELECT * FROM exam_Mark3;
        
    ELSIF "@FLAG" = '8' THEN
        RETURN QUERY
        SELECT "EME_Id",
            "EMGD_Remarks",
            "EMGD_Id"
        FROM "Exm"."Exm_Yearly_Category_Exams" a
        INNER JOIN "Exm"."Exm_Master_Grade_Details" b ON a."EMGR_Id" = b."EMGR_Id"
        WHERE a."EYC_Id" = "@EYC_Id" 
            AND a."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[]);
    END IF;
    
    RETURN;
END;
$$;