CREATE OR REPLACE FUNCTION "dbo"."Exam_BGHS_Student_SubjectWise_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" TEXT,
    "rollno" BIGINT,
    "classname" TEXT,
    "sectionname" TEXT,
    "fathername" TEXT,
    "mothername" TEXT,
    "dob" TEXT,
    "mobileno" BIGINT,
    "address" TEXT,
    "photoname" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "EYCES_SubjectOrder" INT,
    "EYCES_AplResultFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    /* ********************* GET STUDENT DETAILS ************* */
    IF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END || 
             CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
             CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END)::TEXT AS studentname,
            A."AMST_AdmNo"::TEXT AS admno,
            B."AMAY_RollNo" AS rollno,
            D."ASMCL_ClassName"::TEXT AS classname,
            E."ASMC_SectionName"::TEXT AS sectionname,
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END || 
             CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END)::TEXT AS fathername,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END || 
             CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END)::TEXT AS mothername,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY')::TEXT AS dob,
            A."AMST_MobileNo" AS mobileno,
            (CASE WHEN A."AMST_PerStreet" IS NULL OR A."AMST_PerStreet" = '' THEN '' ELSE A."AMST_PerStreet" END || 
             CASE WHEN A."AMST_PerArea" IS NULL OR A."AMST_PerArea" = '' THEN '' ELSE ',' || A."AMST_PerArea" END || 
             CASE WHEN A."AMST_PerCity" IS NULL OR A."AMST_PerCity" = '' THEN '' ELSE ',' || A."AMST_PerCity" END || 
             CASE WHEN A."AMST_PerAdd3" IS NULL OR A."AMST_PerAdd3" = '' THEN '' ELSE ',' || A."AMST_PerAdd3" END)::TEXT AS address,
            A."AMST_Photoname"::TEXT AS photoname,
            NULL::BIGINT AS "ISMS_Id",
            NULL::TEXT AS "ISMS_SubjectName",
            NULL::INT AS "EYCES_SubjectOrder",
            NULL::BOOLEAN AS "EYCES_AplResultFlg"
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
        AND B."AMAY_ActiveFlag" = 1 
        AND A."AMST_SOL" = 'S' 
        AND A."AMST_ActiveFlag" = 1
        ORDER BY rollno;

    /* ****** GET THE STUDENT WISE SUBJECT LIST ********* */
    ELSIF "@FLAG" = '2' THEN
        RETURN QUERY EXECUTE 
        'SELECT DISTINCT 
            A."AMST_Id",
            NULL::TEXT AS studentname,
            NULL::TEXT AS admno,
            NULL::BIGINT AS rollno,
            NULL::TEXT AS classname,
            NULL::TEXT AS sectionname,
            NULL::TEXT AS fathername,
            NULL::TEXT AS mothername,
            NULL::TEXT AS dob,
            NULL::BIGINT AS mobileno,
            NULL::TEXT AS address,
            NULL::TEXT AS photoname,
            B."ISMS_Id",
            B."ISMS_SubjectName"::TEXT,
            M."EYCES_SubjectOrder",
            M."EYCES_AplResultFlg"
        FROM "EXM"."Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" 
            AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = true 
            AND H."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND H."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND H."ASMS_Id" = ' || "@ASMS_Id" || '
        INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" 
            AND J."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND J."EYC_ActiveFlg" = true
        INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = true
        INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" 
            AND M."EYCES_ActiveFlg" = true
        WHERE C."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND A."ASMAY_Id" = ' || "@ASMAY_Id" || '
        AND A."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND C."ASMCL_Id" = ' || "@ASMCL_Id" || ' 
        AND A."ASMS_Id" = ' || "@ASMS_Id" || ' AND C."ASMS_Id" = ' || "@ASMS_Id" || '
        AND A."ESTSU_ActiveFlg" = true AND B."ISMS_ActiveFlag" = true 
        AND K."EME_Id" IN (' || "@EME_Id" || ')
        ORDER BY "EYCES_SubjectOrder"';

    END IF;

    RETURN;

END;
$$;