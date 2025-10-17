CREATE OR REPLACE FUNCTION "dbo"."CLG_IVRS_FLOW"(
    p_operation VARCHAR(50),
    p_Tpin VARCHAR(20),
    p_exeid VARCHAR(10),
    p_miid VARCHAR(10)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_content VARCHAR(500);
    v_content1 VARCHAR(500);
    v_cchrme VARCHAR(500);
    v_query TEXT;
    v_dynamic TEXT;
    v_content_LE TEXT;
    v_ASMAY_Id VARCHAR(20);
BEGIN

    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "dbo"."Adm_School_M_Academic_Year" a 
    WHERE CURRENT_TIMESTAMP BETWEEN a."ASMAY_From_Date" AND a."ASMAY_To_Date" 
    AND "MI_Id" = p_miid;

    IF p_operation = 'check_tpin' THEN
        v_query := 'SELECT * FROM "ivr_authentication" WHERE "IVRA_TPIN" = ''' || p_Tpin || '''';
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'get_stu_details' THEN
        v_query := '
        SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "Student_Name",
        "AMCST_RegistrationNo" AS "Student_RegistrationNo",
        TO_CHAR("CLG"."Adm_Master_College_Student"."AMCST_DOB", ''DD/MM/YYYY'') AS "Student_DOB",
        "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "CourseName",
        "AMB_BranchName" AS "BranchName",
        "AMSE_SEMName" AS "SEMName",
        "ACMS_SectionName" AS "Section_Name"
        FROM "CLG"."Adm_Master_Course"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Adm_Master_Course"."MI_Id" = ''' || p_miid || '''
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "CLG"."Adm_Master_College_Student"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id"
        WHERE "CLG"."Adm_Master_College_Student"."AMCST_TPINNO" = ''' || p_Tpin || ''' 
        AND "CLG"."Adm_Master_College_Student"."MI_ID" = ''' || p_miid || ''' 
        AND "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" = 1
        AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" IN (
            SELECT DISTINCT "ASMAY_ID" FROM "Adm_School_M_Academic_Year"
            WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
            AND "Adm_School_M_Academic_Year"."MI_Id" = ''' || p_miid || '''
        )
        GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName",
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year", "AMCST_RegistrationNo",
        "CLG"."Adm_Master_College_Student"."AMCST_DOB", "CLG"."Adm_Master_Course"."AMCO_CourseName",
        "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"';
        
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'get_student_fee' THEN
        v_query := '
        SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "Student_Name",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_PaidAmount") AS "Paid_Amount",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") AS "Charges",
        SUM("CLG"."Fee_College_Student_Status"."FCSS_ToBePaid") AS "Year_Due",
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year"
        FROM "CLG"."Adm_Master_Course"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Adm_Master_Course"."MI_Id" = ''' || p_miid || '''
        INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Fee_College_Student_Status"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id"
        AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "CLG"."Fee_College_Student_Status"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "CLG"."Adm_Master_College_Student"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id"
        WHERE "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag" = 1
        AND "CLG"."Adm_Master_College_Student"."AMCST_TPINNO" = ''' || p_Tpin || ''' 
        AND "CLG"."Adm_Master_College_Student"."MI_ID" = ''' || p_miid || '''
        AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" IN (
            SELECT DISTINCT "ASMAY_ID" FROM "Adm_School_M_Academic_Year"
            WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date"
        )
        GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", 
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year", "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"';
        
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'get_student_ExamList' THEN
        v_query := '
        SELECT DISTINCT E."EME_ExamName", E."EME_Id"
        FROM "Adm_School_M_Academic_Year" a
        INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."MI_Id" = ''' || p_miid || '''
        INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" c ON c."ASMAY_Id" = ''' || v_ASMAY_Id || '''
        INNER JOIN "Exm"."Exm_Master_Exam" E ON E."EME_Id" = c."EME_Id" AND E."MI_Id" = ''' || p_miid || '''
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = c."ISMS_Id"
        WHERE a."ASMAY_Id" = ''' || v_ASMAY_Id || ''' 
        AND a."mi_id" = ''' || p_miid || ''' 
        AND a."Is_Active" = 1 
        AND b."AMCST_TPINNO" = ''' || p_Tpin || ''' 
        AND c."AMCST_Id" = b."AMCST_Id"
        AND c."EME_Id" IN (
            SELECT DISTINCT EME."EME_Id"
            FROM "CLG"."Exm_Col_Yearly_Scheme" AS CEYC
            INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS CEYCE ON CEYCE."ECYS_Id" = CEYC."ECYS_Id" 
            AND CEYCE."AMCO_Id" = CEYC."AMCO_Id" AND CEYCE."AMB_Id" = CEYC."AMB_Id" 
            AND CEYCE."AMSE_Id" = CEYC."AMSE_Id" AND CEYCE."ECYSE_ActiveFlg" = 1 
            AND CEYC."ECYS_ActiveFlag" = 1 AND CEYCE."ACSS_Id" = CEYC."ACSS_Id" 
            AND CEYCE."ACST_Id" = CEYC."ACST_Id" AND CEYC."MI_Id" = ''' || p_miid || '''
            INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS CEYCES ON CEYCES."ECYSE_Id" = CEYCES."ECYSE_Id" 
            AND CEYCES."ECYSES_ActiveFlg" = 1
            INNER JOIN "CLG"."Exm_Col_Student_Marks" AS CESM ON CESM."ISMS_Id" = CEYCES."ISMS_Id" 
            AND CESM."MI_Id" = ''' || p_miid || ''' AND CESM."AMSE_Id" = CEYCE."AMSE_Id" 
            AND CESM."AMB_Id" = CEYCE."AMB_Id" AND CESM."AMCO_Id" = CEYCE."AMCO_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" EME ON EME."EME_Id" = CEYCE."EME_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = CESM."AMCST_Id"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id"
            INNER JOIN "ivrm_master_subjects" c ON c."ISMS_Id" = CESM."ISMS_Id"
            INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id"
            AND "CLG"."Adm_Master_Course"."AMCO_Id" = CESM."AMCO_Id"
            AND "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = CESM."AMCST_Id" 
            AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ''' || v_ASMAY_Id || '''
            AND EME."EME_Id" = CESM."EME_Id"
            WHERE "CLG"."Adm_Master_College_Student"."AMCST_TPINNO" = ''' || p_Tpin || ''' 
            AND EME."MI_ID" = ''' || p_miid || '''
        ) 
        AND c."asmay_id" = ''' || v_ASMAY_Id || '''';
        
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'get_student_coe' THEN
        v_query := '
        SELECT b."COEME_EventName", a."COEE_EStartDate", a."COEE_EEndDate", b."COEME_EventDesc"
        FROM "coe"."COE_Events" a 
        INNER JOIN "coe"."COE_Master_Events" b ON a."COEME_Id" = b."COEME_Id"
        WHERE a."mi_id" = ''' || p_miid || ''' 
        AND b."COEME_ActiveFlag" = 1 
        AND a."COEE_EStartDate" >= CURRENT_TIMESTAMP';
        
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'Exam_Marks_Overall' THEN
        v_query := '
        SELECT DISTINCT b."ISMS_Id", c."ISMS_SubjectName", b."ECSTMPS_MaxMarks", 
        b."ECSTMPS_ObtainedMarks", b."ECSTMPS_ObtainedGrade"
        FROM "CLG"."Adm_Master_College_Student" a
        INNER JOIN "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "ivrm_master_subjects" c ON c."isms_id" = b."isms_id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON b."ASMAY_Id" = d."ASMAY_Id"
        WHERE CURRENT_TIMESTAMP BETWEEN d."ASMAY_From_Date" AND d."ASMAY_To_Date"
        AND a."mi_id" = ''' || p_miid || ''' 
        AND d."Is_Active" = 1
        AND a."AMCST_TPINNO" = ''' || p_Tpin || ''' 
        AND b."EME_Id" = ''' || p_exeid || '''';
        
        RETURN QUERY EXECUTE v_query;

    ELSIF p_operation = 'Attendance' THEN
        RETURN QUERY
        SELECT "AMCST_Id", "MONTH", "PresentDays", "TotalDays" 
        FROM (
            SELECT DISTINCT c."AMCST_Id",
            TO_CHAR("ACSA_AttendanceDate", 'Month') AS "MONTH",
            SUM("ACSAS_ClassAttended") AS "PresentDays",
            SUM("ACSA_ClassHeld") AS "TotalDays",
            "IVRM_Month_Id"
            FROM "CLG"."Adm_College_Student_Attendance" a
            INNER JOIN "CLG"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" c ON c."AMCST_Id" = b."AMCST_Id"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = c."AMCST_Id" 
            AND b."AMCST_Id" = d."AMCST_Id"
            INNER JOIN "IVRM_Month" M ON M."IVRM_Month_Name" = TO_CHAR("ACSA_AttendanceDate", 'Month')
            WHERE c."MI_Id" = p_miid 
            AND d."ASMAY_Id" = v_ASMAY_Id 
            AND a."ASMAY_Id" = v_ASMAY_Id 
            AND c."AMCST_TPINNO" = p_Tpin
            GROUP BY "ACSA_AttendanceDate", c."AMCST_Id", "IVRM_Month_Id"
            ORDER BY "IVRM_Month_Id"
            LIMIT 100
        ) AS b;

    ELSIF p_operation = 'Routedetails' THEN
        RETURN QUERY
        SELECT 'BOMMNALLI/ADGODI/BEGUR MAIN ROAD/KUDLU GATE/SILK BOARD FLYOVER/MADIWALA POLICE STATION'::TEXT AS "TRMR_RouteName",
        'KA-51-AB-4246'::TEXT AS "TRMV_VehicleNo";

    ELSIF p_operation = 'Librarydue' THEN
        RETURN QUERY
        SELECT 'Harry Potter and the Philosopher'::TEXT AS "BookName";

    END IF;

    RETURN;

END;
$$;