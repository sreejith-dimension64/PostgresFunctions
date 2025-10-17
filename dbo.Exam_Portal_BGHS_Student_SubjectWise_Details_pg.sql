CREATE OR REPLACE FUNCTION "dbo"."Exam_Portal_BGHS_Student_SubjectWise_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" TEXT,
    "rollno" TEXT,
    "classname" TEXT,
    "sectionname" TEXT,
    "fathername" TEXT,
    "mothername" TEXT,
    "dob" TEXT,
    "mobileno" TEXT,
    "address" TEXT,
    "photoname" TEXT,
    "HRME_Id" BIGINT,
    "clastechname" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_hrme_id BIGINT;
    v_emp_name TEXT;
    v_sql TEXT;
BEGIN

    /* ********************* GET STUDENT DETAILS ************* */
    IF "@FLAG" = '1' THEN
    
        SELECT "a"."HRME_Id",
               (CASE WHEN "B"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END || 
                CASE WHEN "B"."HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "B"."HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
        INTO v_hrme_id, v_emp_name
        FROM "IVRM_Master_ClassTeacher" "a" 
        INNER JOIN "HR_Master_Employee" "b" ON "a"."HRME_Id" = "b"."HRME_Id"
        WHERE "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
          AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
          AND "a"."MI_Id" = "@MI_Id"::BIGINT
          AND "a"."IMCT_ActiveFlag" = 1 
          AND "b"."HRME_ActiveFlag" = 1 
          AND "b"."HRME_LeftFlag" = 0
        LIMIT 1;

        RETURN QUERY
        SELECT DISTINCT "A"."AMST_Id",
               (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END || 
                CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
                CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' THEN '' ELSE ' ' || "AMST_LastName" END)::TEXT,
               "AMST_AdmNo"::TEXT,
               "AMAY_RollNo"::TEXT,
               "ASMCL_ClassName"::TEXT,
               "ASMC_SectionName"::TEXT,
               (CASE WHEN "AMST_FatherName" IS NULL OR "AMST_FatherName" = '' THEN '' ELSE "AMST_FatherName" END || 
                CASE WHEN "AMST_FatherSurname" IS NULL OR "AMST_FatherSurname" = '' THEN '' ELSE ' ' || "AMST_FatherSurname" END)::TEXT,
               (CASE WHEN "AMST_MotherName" IS NULL OR "AMST_MotherName" = '' THEN '' ELSE "AMST_MotherName" END || 
                CASE WHEN "AMST_MotherSurname" IS NULL OR "AMST_MotherSurname" = '' THEN '' ELSE ' ' || "AMST_MotherSurname" END)::TEXT,
               TO_CHAR("amst_dob", 'DD/MM/YYYY')::TEXT,
               "AMST_MobileNo"::TEXT,
               (CASE WHEN "AMST_PerStreet" IS NULL OR "AMST_PerStreet" = '' THEN '' ELSE "AMST_PerStreet" END || 
                CASE WHEN "AMST_PerArea" IS NULL OR "AMST_PerArea" = '' THEN '' ELSE ',' || "AMST_PerArea" END || 
                CASE WHEN "AMST_PerCity" IS NULL OR "AMST_PerCity" = '' THEN '' ELSE ',' || "AMST_PerCity" END || 
                CASE WHEN "AMST_PerAdd3" IS NULL OR "AMST_PerAdd3" = '' THEN '' ELSE ',' || "AMST_PerAdd3" END)::TEXT,
               "AMST_Photoname"::TEXT,
               v_hrme_id,
               v_emp_name::TEXT,
               NULL::BIGINT,
               NULL::TEXT,
               NULL::INTEGER,
               NULL::BOOLEAN
        FROM "Adm_M_Student" "A" 
        INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id" = "B"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id" = "B"."ASMS_Id"
        LEFT JOIN "IVRM_Master_Country" "F" ON "F"."IVRMMC_Id" = "A"."AMST_PerCountry"
        LEFT JOIN "IVRM_Master_State" "G" ON "G"."IVRMMC_Id" = "F"."IVRMMC_Id" AND "G"."IVRMMS_Id" = "A"."AMST_PerState"
        WHERE "A"."MI_Id" = "@MI_Id"::BIGINT 
          AND "B"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
          AND "B"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND "B"."ASMS_Id" = "@ASMS_Id"::BIGINT 
          AND "B"."AMST_Id" = "@AMST_Id"::BIGINT
        ORDER BY "AMAY_RollNo";

    /* ****** GET THE STUDENT WISE SUBJECT LIST ********* */
    ELSIF "@FLAG" = '2' THEN
    
        v_sql := '
        SELECT DISTINCT "A"."AMST_Id",
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::TEXT,
               NULL::BIGINT,
               NULL::TEXT,
               "B"."ISMS_Id",
               "B"."ISMS_SubjectName",
               "m"."EYCES_SubjectOrder",
               "M"."EYCES_AplResultFlg"
        FROM "EXM"."Exm_Studentwise_Subjects" "A" 
        INNER JOIN "IVRM_Master_Subjects" "B" ON "A"."ISMS_Id" = "B"."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" "C" ON "C"."AMST_Id" = "A"."AMST_Id"
        INNER JOIN "Adm_M_Student" "D" ON "D"."AMST_Id" = "C"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "E" ON "E"."ASMAY_Id" = "C"."ASMAY_Id" AND "E"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "F" ON "F"."ASMCL_Id" = "C"."ASMCL_Id" AND "F"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "G" ON "G"."ASMS_Id" = "C"."ASMS_Id" AND "G"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "EXM"."Exm_Category_Class" "H" ON "H"."ASMAY_Id" = "E"."ASMAY_Id" AND "H"."ASMCL_Id" = "F"."ASMCL_Id" AND "H"."ASMS_Id" = "G"."ASMS_Id" AND "H"."ECAC_ActiveFlag" = 1 
        AND "H"."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND "H"."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "H"."ASMS_Id" = ' || "@ASMS_Id" || '
        INNER JOIN "EXM"."Exm_Master_Category" "I" ON "I"."EMCA_Id" = "H"."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" "J" ON "J"."ASMAY_Id" = "E"."ASMAY_Id" AND "J"."EMCA_Id" = "I"."EMCA_Id" AND "J"."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "J"."EYC_ActiveFlg" = 1 
        INNER JOIN "EXM"."Exm_Yearly_Category_Exams" "K" ON "K"."EYC_Id" = "J"."EYC_Id" AND "K"."EYCE_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Master_Exam" "L" ON "L"."EME_Id" = "K"."EME_Id"
        INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" "M" ON "M"."EYCE_Id" = "K"."EYCE_Id" AND "M"."ISMS_Id" = "B"."ISMS_Id" AND "M"."EYCES_ActiveFlg" = 1
        WHERE "A"."AMST_Id" = ' || "@AMST_Id" || ' AND "C"."AMST_Id" = ' || "@AMST_Id" || ' AND "C"."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "A"."ASMAY_Id" = ' || "@ASMAY_Id" || '
        AND "A"."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND "C"."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND "A"."ASMS_Id" = ' || "@ASMS_Id" || ' AND "C"."ASMS_Id" = ' || "@ASMS_Id" || ' 
        AND "A"."ESTSU_ActiveFlg" = 1 AND "B"."ISMS_ActiveFlag" = 1 AND "K"."EME_Id" IN (' || "@EME_Id" || ')
        ORDER BY "EYCES_SubjectOrder"';

        RETURN QUERY EXECUTE v_sql;

    END IF;

    RETURN;

END;
$$;