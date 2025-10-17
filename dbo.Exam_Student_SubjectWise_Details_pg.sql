CREATE OR REPLACE FUNCTION "dbo"."Exam_Student_SubjectWise_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_hrme_id BIGINT;
    v_emp_name TEXT;
BEGIN

    /* ********************* GET STUDENT DETAILS ************* */
    IF "@FLAG" = '1' THEN
    
        SELECT "HRME_Id",
               (CASE WHEN B."HRME_EmployeeFirstName" IS NULL OR B."HRME_EmployeeFirstName"='' THEN '' ELSE B."HRME_EmployeeFirstName" END || 
                CASE WHEN B."HRME_EmployeeMiddleName" IS NULL OR B."HRME_EmployeeMiddleName"='' THEN '' ELSE ' ' || B."HRME_EmployeeMiddleName" END ||
                CASE WHEN B."HRME_EmployeeLastName" IS NULL OR B."HRME_EmployeeLastName"='' THEN '' ELSE ' ' || B."HRME_EmployeeLastName" END)
        INTO v_hrme_id, v_emp_name
        FROM "IVRM_Master_ClassTeacher" a 
        INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
        WHERE a."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
          AND a."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND a."ASMS_Id" = "@ASMS_Id"::BIGINT 
          AND a."MI_Id" = "@MI_Id"::BIGINT
          AND a."IMCT_ActiveFlag" = 1 
          AND b."HRME_ActiveFlag" = 1 
          AND b."HRME_LeftFlag" = 0
        LIMIT 1;

        RETURN QUERY
        SELECT DISTINCT A."AMST_Id",
               (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName"='' THEN '' ELSE A."AMST_FirstName" END || 
                CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName"='' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
                CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName"='' THEN '' ELSE ' ' || A."AMST_LastName" END) AS studentname,
               A."AMST_AdmNo" AS admno,
               B."AMAY_RollNo" AS rollno,
               D."ASMCL_ClassName" AS classname,
               E."ASMC_SectionName" AS sectionname,
               (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName"='' THEN '' ELSE A."AMST_FatherName" END || 
                CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname"='' THEN '' ELSE ' ' || A."AMST_FatherSurname" END) AS fathername,
               (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName"='' THEN '' ELSE A."AMST_MotherName" END || 
                CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname"='' THEN '' ELSE ' ' || A."AMST_MotherSurname" END) AS mothername,
               TO_CHAR(A."AMST_DOB", 'DD/MM/YYYY') AS dob,
               A."AMST_MobileNo" AS mobileno,
               A."AMST_DOB" AS "amsT_DOB",
               (CASE WHEN A."AMST_PerStreet" IS NULL OR A."AMST_PerStreet"='' THEN '' ELSE A."AMST_PerStreet" END || 
                CASE WHEN A."AMST_PerArea" IS NULL OR A."AMST_PerArea"='' THEN '' ELSE ',' || A."AMST_PerArea" END || 
                CASE WHEN A."AMST_PerCity" IS NULL OR A."AMST_PerCity"='' THEN '' ELSE ',' || A."AMST_PerCity" END || 
                CASE WHEN A."AMST_PerAdd3" IS NULL OR A."AMST_PerAdd3"='' THEN '' ELSE ',' || A."AMST_PerAdd3" END) AS address,
               A."AMST_Photoname" AS photoname,
               v_hrme_id AS "HRME_Id",
               v_emp_name AS clastechname
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "IVRM_Master_Country" F ON F."IVRMMC_Id" = A."AMST_PerCountry"
        LEFT JOIN "IVRM_Master_State" G ON G."IVRMMC_Id" = F."IVRMMC_Id" AND G."IVRMMS_Id" = A."AMST_PerState"
        WHERE A."MI_Id" = "@MI_Id"::BIGINT 
          AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
          AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND B."ASMS_Id" = "@ASMS_Id"::BIGINT
        ORDER BY rollno;

    /* ****** GET THE STUDENT WISE SUBJECT LIST ********* */
    ELSIF "@FLAG" = '2' THEN
    
        v_sql := '
        SELECT DISTINCT A."AMST_Id", B."ISMS_Id", B."ISMS_SubjectName", m."EYCES_SubjectOrder", M."EYCES_AplResultFlg"
        FROM "Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1 
        AND H."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND H."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND H."ASMS_Id" = ' || "@ASMS_Id" || '
        INNER JOIN "Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND J."EYC_ActiveFlg" = 1 
        INNER JOIN "Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1
        INNER JOIN "Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" AND M."EYCES_ActiveFlg" = 1
        WHERE C."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND A."ASMAY_Id" = ' || "@ASMAY_Id" || '
        AND A."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND C."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND A."ASMS_Id" = ' || "@ASMS_Id" || ' AND C."ASMS_Id" = ' || "@ASMS_Id" || ' 
        AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1 AND k."EME_Id" IN (' || "@EME_Id" || ')
        ORDER BY "EYCES_SubjectOrder"';
        
        RETURN QUERY EXECUTE v_sql;

    /* ****** GET THE STUDENT EXAM WISE SUBJECT LIST WITH MAX MARKS , MIN MARKS  ********* */
    ELSIF "@FLAG" = '3' THEN
    
        v_sql := '
        SELECT DISTINCT A."AMST_Id", B."ISMS_Id", B."ISMS_SubjectName", m."EYCES_SubjectOrder", M."EYCES_AplResultFlg", 
               M."EYCES_MaxMarks", M."EYCES_MinMarks", K."EME_Id", M."EYCES_MarksDisplayFlg", M."EYCES_GradeDisplayFlg"
        FROM "Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1 
        AND H."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND H."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND H."ASMS_Id" = ' || "@ASMS_Id" || '
        INNER JOIN "Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND J."EYC_ActiveFlg" = 1 
        INNER JOIN "Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1
        INNER JOIN "Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" AND M."EYCES_ActiveFlg" = 1
        WHERE C."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND A."ASMAY_Id" = ' || "@ASMAY_Id" || '
        AND A."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND C."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND A."ASMS_Id" = ' || "@ASMS_Id" || ' AND C."ASMS_Id" = ' || "@ASMS_Id" || ' 
        AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1 AND k."EME_Id" IN (' || "@EME_Id" || ')
        ORDER BY "EYCES_SubjectOrder"';
        
        RETURN QUERY EXECUTE v_sql;

    /* ****** GET THE STUDENT EXAM WISE SUM OF MAX MARKS , MIN MARKS AND OBTAINED MARKS ********* */
    ELSIF "@FLAG" = '4' THEN
    
        v_sql := '
        SELECT DISTINCT A."AMST_Id", K."EME_Id", SUM(M."EYCES_MaxMarks") AS "EYCES_MaxMarks", SUM(M."EYCES_MinMarks") AS "EYCES_MinMarks",
               (SELECT "ESTMP_TotalObtMarks" FROM "Exm_Student_Marks_process" 
                WHERE "ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "ASMCL_Id" = ' || "@ASMCL_Id" || ' AND "ASMS_Id" = ' || "@ASMS_Id" || '
                AND "AMST_Id" = A."AMST_Id" AND K."EME_Id" = "EME_Id") AS "ESTMP_TotalObtMarks"
        FROM "Exm_Studentwise_Subjects" A
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id" AND A."ASMAY_Id" = C."ASMAY_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1 
        AND H."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND H."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND H."ASMS_Id" = ' || "@ASMS_Id" || '
        INNER JOIN "Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id" AND I."EMCA_ActiveFlag" = 1
        INNER JOIN "Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND J."EYC_ActiveFlg" = 1 
        INNER JOIN "Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1 
        INNER JOIN "Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" AND M."EYCES_ActiveFlg" = 1
        WHERE C."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND A."ASMAY_Id" = ' || "@ASMAY_Id" || '
        AND A."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND C."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND A."ASMS_Id" = ' || "@ASMS_Id" || ' AND C."ASMS_Id" = ' || "@ASMS_Id" || ' 
        AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1 AND k."EME_Id" IN (' || "@EME_Id" || ')
        AND M."EYCES_AplResultFlg" = 1 
        GROUP BY A."AMST_Id", K."EME_Id"
        ORDER BY A."AMST_Id"';
        
        RETURN QUERY EXECUTE v_sql;

    END IF;

    RETURN;

END;
$$;