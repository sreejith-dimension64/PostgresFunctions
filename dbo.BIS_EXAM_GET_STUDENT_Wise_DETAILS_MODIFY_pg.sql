CREATE OR REPLACE FUNCTION "dbo"."BIS_EXAM_GET_STUDENT_Wise_DETAILS_MODIFY"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_AMST_Id TEXT,
    p_EME_Id TEXT
)
RETURNS SETOF record
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id TEXT;
    v_EMCA_Id TEXT;
    v_AttendanceFromDate VARCHAR(10);
    v_AttendanceToDate VARCHAR(10);
    v_EME_ExamName TEXT;
    v_SQL_QUERY TEXT;
BEGIN
    
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT 
        AND "ECAC_ActiveFlag" = 1;
    
    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id::BIGINT 
        AND "EYC_ActiveFlg" = 1;
    
    SELECT TO_CHAR("EYCE_AttendanceFromDate", 'YYYY-MM-DD'), 
           TO_CHAR("EYCE_AttendanceToDate", 'YYYY-MM-DD') 
    INTO v_AttendanceFromDate, v_AttendanceToDate 
    FROM "Exm"."Exm_Yearly_Category_Exams" 
    WHERE "EME_Id" = p_EME_Id::BIGINT 
        AND "EYC_Id" = v_EYC_Id::BIGINT 
        AND "EYCE_ActiveFlg" = 1;
    
    SELECT "EME_ExamName" INTO v_EME_ExamName 
    FROM "Exm"."Exm_Master_Exam" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "EME_Id" = p_EME_Id::BIGINT 
        AND "EME_ActiveFlag" = 1;
    
    /* STUDENT DETAILS */
    IF p_FLAG = '1' THEN
        
        v_SQL_QUERY := 'SELECT A."AMST_Id", 
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '''' THEN '''' ELSE A."AMST_FirstName" END ||   
            CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '''' THEN '''' ELSE '' '' || A."AMST_MiddleName" END ||  
            CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '''' THEN '''' ELSE '' '' || A."AMST_LastName" END) AS studentname,   
            A."AMST_AdmNo" AS admno, B."AMAY_RollNo" AS rollno, D."ASMCL_ClassName" AS classname, E."ASMC_SectionName" AS sectionname,  
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '''' THEN '''' ELSE A."AMST_FatherName" END ||   
            CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '''' THEN '''' ELSE '' '' || A."AMST_FatherSurname" END) AS fathername,  
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '''' THEN '''' ELSE A."AMST_MotherName" END ||   
            CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '''' THEN '''' ELSE '' '' || A."AMST_MotherSurname" END) AS mothername,  
            TO_CHAR(A."AMST_DOB", ''DD/MM/YYYY'') AS dob, A."AMST_MobileNo" AS mobileno, C."ASMAY_Year", 
            (''' || v_EME_ExamName || ' '' || C."ASMAY_Year") AS ExamNameYear,
            ''' || v_EME_ExamName || ''' AS ExamName
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
            WHERE A."MI_Id" = ' || p_MI_Id || ' 
                AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND B."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND B."ASMS_Id" = ' || p_ASMS_Id || ' 
                AND A."AMST_Id" IN (' || p_AMST_Id || ')';
        
        RETURN QUERY EXECUTE v_SQL_QUERY;
        
    /* STUDENT WISE SUBJECT DETAILS */
    ELSIF p_FLAG = '2' THEN
        
        v_SQL_QUERY := 'SELECT DISTINCT SMPS."AMST_Id", SMPS."ISMS_Id", IMS."ISMS_SubjectName",
            EYCES."EYCES_SubjectOrder", EYCES."EYCES_AplResultFlg", SMPS."ESTMPS_MaxMarks", SMPS."ESTMPS_ObtainedMarks", 
            SMPS."ESTMPS_ObtainedGrade", SMPS."ESTMPS_PassFailFlg", SMPS."ESTMPS_ClassRank",
            SMPS."ESTMPS_SectionRank", SMPS."ESTMPS_Percentage"
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" SMPS
            INNER JOIN "IVRM_Master_Subjects" IMS ON SMPS."ISMS_Id" = IMS."ISMS_Id" AND IMS."MI_Id" = ' || p_MI_Id || '
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" EYCES ON EYCES."ISMS_Id" = SMPS."ISMS_Id" 
                AND EYCES."ISMS_Id" = IMS."ISMS_Id" AND EYCES."EYCES_ActiveFlg" = 1
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" EYCE ON EYCE."EYCE_Id" = EYCES."EYCE_Id" 
                AND EYCE."EME_Id" = ' || p_EME_Id || '
            WHERE EYCE."EYC_Id" = ' || v_EYC_Id || ' 
                AND SMPS."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND SMPS."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND SMPS."ASMS_Id" = ' || p_ASMS_Id || ' 
                AND SMPS."EME_Id" = ' || p_EME_Id || '
                AND SMPS."AMST_Id" IN (' || p_AMST_Id || ') 
                AND SMPS."MI_Id" = ' || p_MI_Id || '
            ORDER BY EYCES."EYCES_SubjectOrder"';
        
        RETURN QUERY EXECUTE v_SQL_QUERY;
        
    /* STUDENT WISE ATTENDANCE */
    ELSIF p_FLAG = '3' THEN
        
        v_SQL_QUERY := 'SELECT SUM(A."ASA_ClassHeld") AS TOTALWORKINGDAYS, 
            SUM(B."ASA_Class_Attended") AS PRESENTDAYS,
            CAST(SUM(B."ASA_Class_Attended") * 100.0 / SUM(A."ASA_ClassHeld") AS DECIMAL(18,2)) AS ATTENDANCEPERCENTAGE, 
            B."AMST_Id"
            FROM "Adm_Student_Attendance" A 
            INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
            INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id"
            WHERE A."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND A."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND A."ASMS_Id" = ' || p_ASMS_Id || ' 
                AND A."ASA_Activeflag" = 1 
                AND A."MI_Id" = ' || p_MI_Id || '  
                AND C."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND C."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND C."ASMS_Id" = ' || p_ASMS_Id || '  
                AND B."AMST_Id" IN (' || p_AMST_Id || ')
                AND ((A."ASA_FromDate"::DATE >= ''' || v_AttendanceFromDate || '''::DATE 
                    AND A."ASA_FromDate"::DATE <= ''' || v_AttendanceToDate || '''::DATE) 
                OR (A."ASA_ToDate"::DATE >= ''' || v_AttendanceFromDate || '''::DATE 
                    AND A."ASA_ToDate"::DATE <= ''' || v_AttendanceToDate || '''::DATE))
            GROUP BY B."AMST_Id"';
        
        RETURN QUERY EXECUTE v_SQL_QUERY;
        
    ELSIF p_FLAG = '4' THEN
        
        v_SQL_QUERY := 'SELECT DISTINCT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", "EME_Id", 
            "ESTMPS_MaxMarks", "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg", 
            "ESTMPS_AplResultFlg", "ESTMPS_ClassRank", "ESTMPS_SectionRank" 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = ' || p_MI_Id || ' 
                AND "ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND "ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND "ASMS_Id" = ' || p_ASMS_Id || ' 
                AND "EME_Id" = ' || p_EME_Id || ' 
                AND "AMST_Id" IN (' || p_AMST_Id || ')';
        
        RETURN QUERY EXECUTE v_SQL_QUERY;
        
    END IF;
    
    RETURN;
    
END;
$$;