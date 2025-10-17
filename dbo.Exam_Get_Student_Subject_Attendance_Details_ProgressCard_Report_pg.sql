CREATE OR REPLACE FUNCTION "dbo"."Exam_Get_Student_Subject_Attendance_Details_ProgressCard_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_EME_Id" TEXT,
    "p_FLAG" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SQLQUERY" TEXT;
    "v_ORDERFLAG" TEXT;
    "v_SQLQUERYA" TEXT;
BEGIN

    /* STUDENT DETAILS  */
    IF "p_FLAG" = '1' THEN
    
        SELECT "ExmConfig_Recordsearchtype" INTO "v_ORDERFLAG"
        FROM "Exm"."Exm_Configuration" 
        WHERE "MI_Id" = "p_MI_Id"::BIGINT;

        IF ("v_ORDERFLAG" = 'Name') THEN
            "v_ORDERFLAG" := 'studentname';
        ELSIF ("v_ORDERFLAG" = 'AdmNo') THEN
            "v_ORDERFLAG" := 'AMST_AdmNo';
        ELSIF ("v_ORDERFLAG" = 'RollNo') THEN
            "v_ORDERFLAG" := 'AMAY_RollNo';
        ELSIF ("v_ORDERFLAG" = 'RegNo') THEN
            "v_ORDERFLAG" := 'AMST_RegistrationNo';
        ELSE
            "v_ORDERFLAG" := 'studentname';
        END IF;

        "v_SQLQUERY" := '
        SELECT DISTINCT A."AMST_Id",
        (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName"='''' THEN '''' ELSE "AMST_FirstName" END || 
        CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName"='''' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
        CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName"='''' THEN '''' ELSE '' '' || "AMST_LastName" END) AS studentname,
        "AMST_AdmNo", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName",
        (CASE WHEN "AMST_FatherName" IS NULL OR "AMST_FatherName"='''' THEN '''' ELSE "AMST_FatherName" END || 
        CASE WHEN "AMST_FatherSurname" IS NULL OR "AMST_FatherSurname"='''' THEN '''' ELSE '' '' || "AMST_FatherSurname" END) AS fathername,
        (CASE WHEN "AMST_MotherName" IS NULL OR "AMST_MotherName"='''' THEN '''' ELSE "AMST_MotherName" END || 
        CASE WHEN "AMST_MotherSurname" IS NULL OR "AMST_MotherSurname"='''' THEN '''' ELSE '' '' || "AMST_MotherSurname" END) AS mothername,
        TO_CHAR("amst_dob", ''DD/MM/YYYY'') AS dob, "AMST_MobileNo" AS mobileno,
        (CASE WHEN "AMST_PerStreet" IS NULL OR "AMST_PerStreet"='''' THEN '''' ELSE "AMST_PerStreet" END || 
        CASE WHEN "AMST_PerArea" IS NULL OR "AMST_PerArea"='''' THEN '''' ELSE '','' || "AMST_PerArea" END || 
        CASE WHEN "AMST_PerCity" IS NULL OR "AMST_PerCity"='''' THEN '''' ELSE '','' || "AMST_PerCity" END || 
        CASE WHEN "AMST_PerAdd3" IS NULL OR "AMST_PerAdd3"='''' THEN '''' ELSE '','' || "AMST_PerAdd3" END) AS address
        FROM "Adm_School_Y_Student" A 
        INNER JOIN "Adm_M_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = A."ASMS_Id"
        WHERE A."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND A."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND A."ASMS_Id" = ' || "p_ASMS_Id" || ' AND B."MI_Id" = ' || "p_MI_Id" || '
        AND A."AMAY_ActiveFlag" = 1 AND B."AMST_SOL" = ''S'' AND B."AMST_ActiveFlag" = 1
        ORDER BY ' || "v_ORDERFLAG";

        RETURN QUERY EXECUTE "v_SQLQUERY";

    /* STUDENT WISE SUBJECT DETAILS  */
    ELSIF "p_FLAG" = '2' THEN

        "v_SQLQUERY" := 'SELECT DISTINCT A."AMST_Id", B."ISMS_Id", B."ISMS_SubjectName", "EYCES_SubjectOrder", M."EYCES_AplResultFlg", M."EYCES_SubExamFlg", M."EYCES_SubSubjectFlg"
        FROM "EXM"."Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1
        AND H."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND H."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND H."ASMS_Id" = ' || "p_ASMS_Id" || '
        INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND J."EYC_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" AND M."EYCES_ActiveFlg" = 1
        WHERE C."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND A."ASMAY_Id" = ' || "p_ASMAY_Id" || '
        AND A."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND C."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND A."ASMS_Id" = ' || "p_ASMS_Id" || ' AND C."ASMS_Id" = ' || "p_ASMS_Id" || ' AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1
        AND K."EME_Id" IN (' || "p_EME_Id" || ')
        ORDER BY "EYCES_SubjectOrder"';

        RETURN QUERY EXECUTE "v_SQLQUERY";

    /* STUDENT WISE ATTENDANCE DETAILS */
    ELSIF "p_FLAG" = '3' THEN

        "v_SQLQUERYA" := '
        SELECT SUM("ASA_ClassHeld") AS TOTALWORKINGDAYS, SUM("ASA_Class_Attended") AS PRESENTDAYS,
        CAST(SUM("ASA_Class_Attended") * 100.0 / NULLIF(SUM("ASA_ClassHeld"), 0) AS DECIMAL(18,2)) AS ATTENDANCEPERCENTAGE,
        B."AMST_Id", J."EME_Id"
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id"
        INNER JOIN "Exm"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Yearly_Category" I ON I."EMCA_Id" = H."EMCA_Id" AND I."EYC_ActiveFlg" = 1
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" J ON J."EYC_Id" = I."EYC_Id" AND J."EYCE_ActiveFlg" = 1
        WHERE A."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND A."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND A."ASMS_Id" = ' || "p_ASMS_Id" || ' AND A."ASA_Activeflag" = 1 AND A."MI_Id" = ' || "p_MI_Id" || '
        AND C."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND C."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND C."ASMS_Id" = ' || "p_ASMS_Id" || ' AND C."AMAY_ActiveFlag" = 1 AND D."AMST_SOL" = ''S'' AND D."AMST_ActiveFlag" = 1
        AND H."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND H."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND H."ASMS_Id" = ' || "p_ASMS_Id" || ' AND J."EME_Id" IN(' || "p_EME_Id" || ')
        AND ((A."ASA_FromDate" BETWEEN J."EYCE_AttendanceFromDate" AND J."EYCE_AttendanceToDate") OR (A."ASA_ToDate" BETWEEN J."EYCE_AttendanceFromDate" AND J."EYCE_AttendanceToDate"))
        GROUP BY B."AMST_Id", J."EME_Id"';

        RETURN QUERY EXECUTE "v_SQLQUERYA";

    ELSIF "p_FLAG" = '4' THEN
    
        RETURN QUERY EXECUTE
        'SELECT DISTINCT e."ISMS_Id", g."emss_id" AS ssubj, g."EMSS_SubSubjectName", f."EYCESSS_MaxMarks", g."EMSS_Order", J."EMSE_Id", J."EMSE_SubExamName", J."EMSE_SubExamOrder", "EYCES_SubjectOrder"
        FROM "exm"."Exm_Yearly_Category_Exams" a
        INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EYC_Id" = b."EYC_Id"
        INNER JOIN "exm"."Exm_Master_Category" c ON c."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "exm"."Exm_Category_Class" d ON d."EMCA_Id" = c."EMCA_Id" AND d."ASMAY_Id" = ' || "p_ASMAY_Id"::BIGINT || '
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = a."EYCE_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" f ON f."EYCES_Id" = e."EYCES_Id"
        INNER JOIN "IVRM_Master_Subjects" h ON h."ISMS_Id" = e."ISMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" i ON i."EME_Id" = a."EME_Id"
        LEFT JOIN "exm"."Exm_Master_SubSubject" g ON g."EMSS_Id" = f."EMSS_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" J ON J."EMSE_ID" = F."EMSE_Id"
        WHERE a."EME_Id" = ' || "p_EME_Id"::BIGINT || ' AND i."EME_Id" = ' || "p_EME_Id"::BIGINT || ' AND b."ASMAY_Id" = ' || "p_ASMAY_Id"::BIGINT || ' AND d."ASMAY_Id" = ' || "p_ASMAY_Id"::BIGINT || ' AND d."ASMCL_Id" = ' || "p_ASMCL_Id"::BIGINT || ' AND d."ASMS_Id" = ' || "p_ASMS_Id"::BIGINT || '
        AND d."MI_Id" = ' || "p_MI_Id"::BIGINT || ' AND d."ECAC_ActiveFlag" = 1 AND b."EYC_ActiveFlg" = 1 
        ORDER BY "EYCES_SubjectOrder", "EMSS_Order", "EMSE_SubExamOrder"';

    END IF;

    RETURN;

END;
$$;