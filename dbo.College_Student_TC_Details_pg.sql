CREATE OR REPLACE FUNCTION "dbo"."College_Student_TC_Details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_FLAG" TEXT,
    "p_AMCST_Id" TEXT
)
RETURNS TABLE(
    "studentname" TEXT,
    "admno" TEXT,
    "regno" TEXT,
    "coursename" TEXT,
    "branchname" TEXT,
    "semestername" TEXT,
    "sectionname" TEXT,
    "fathername" TEXT,
    "mothername" TEXT,
    "doa" DATE,
    "studentphoto" TEXT,
    "castename" TEXT,
    "dob" DATE,
    "dobinwords" TEXT,
    "mothertounge" TEXT,
    "nationality" TEXT,
    "mobileno" TEXT,
    "emailid" TEXT,
    "ifsccode" TEXT,
    "birthplace" TEXT,
    "aadharno" TEXT,
    "age" INTEGER,
    "gender" TEXT,
    "tc_data" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF "p_FLAG" = 'S' OR "p_FLAG" = 'D' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "B"."AMCST_FirstName" IS NULL OR "B"."AMCST_FirstName" = '' THEN '' ELSE "B"."AMCST_FirstName" END ||
            CASE WHEN "B"."AMCST_MiddleName" IS NULL OR "B"."AMCST_MiddleName" = '' THEN '' ELSE ' ' || "B"."AMCST_MiddleName" END ||
            CASE WHEN "B"."AMCST_LastName" IS NULL OR "B"."AMCST_LastName" = '' THEN '' ELSE ' ' || "B"."AMCST_LastName" END)::TEXT AS "studentname",
            "B"."AMCST_AdmNo"::TEXT AS "admno",
            "B"."AMCST_RegistrationNo"::TEXT AS "regno",
            "C"."AMCO_CourseName"::TEXT AS "coursename",
            "D"."AMB_BranchName"::TEXT AS "branchname",
            "E"."AMSE_SEMName"::TEXT AS "semestername",
            "F"."ACMS_SectionName"::TEXT AS "sectionname",
            (CASE WHEN "B"."AMCST_FatherSurname" IS NULL OR "B"."AMCST_FatherSurname" = '' THEN '' ELSE "B"."AMCST_FatherSurname" END ||
            CASE WHEN "B"."AMCST_FatherName" IS NULL OR "B"."AMCST_FatherName" = '' THEN '' ELSE ' ' || "B"."AMCST_FatherName" END)::TEXT AS "fathername",
            (CASE WHEN "B"."AMCST_MotherSurname" IS NULL OR "B"."AMCST_MotherSurname" = '' THEN '' ELSE "B"."AMCST_MotherSurname" END ||
            CASE WHEN "B"."AMCST_MotherName" IS NULL OR "B"."AMCST_MotherName" = '' THEN '' ELSE ' ' || "B"."AMCST_MotherName" END)::TEXT AS "mothername",
            CAST("B"."AMCST_Date" AS DATE) AS "doa",
            "B"."AMCST_StudentPhoto"::TEXT AS "studentphoto",
            COALESCE("H"."IMC_CasteName", '')::TEXT AS "castename",
            CAST("B"."AMCST_DOB" AS DATE) AS "dob",
            COALESCE("B"."AMCST_DOBin_words", '')::TEXT AS "dobinwords",
            COALESCE("B"."AMCST_MotherTongue", '')::TEXT AS "mothertounge",
            "I"."IVRMMC_Nationality"::TEXT AS "nationality",
            "B"."AMCST_MobileNo"::TEXT AS "mobileno",
            "B"."AMCST_emailId"::TEXT AS "emailid",
            "B"."AMCST_StuBankIFSCCode"::TEXT AS "ifsccode",
            "B"."AMCST_BirthPlace"::TEXT AS "birthplace",
            "B"."AMCST_AadharNo"::TEXT AS "aadharno",
            EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "B"."AMCST_DOB"))::INTEGER AS "age",
            "B"."AMCST_Sex"::TEXT AS "gender",
            NULL::TEXT AS "tc_data"
        FROM "clg"."Adm_College_Yearly_Student" "A"
        INNER JOIN "CLG"."Adm_Master_College_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "C" ON "C"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "D" ON "D"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "E" ON "E"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "F" ON "F"."ACMS_Id" = "A"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "G" ON "G"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" "I" ON "I"."IVRMMC_Id" = "B"."AMCST_Nationality"
        LEFT JOIN "IVRM_Master_Caste" "H" ON "H"."IMC_Id" = "B"."IMC_Id"
        WHERE "A"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "A"."AMCST_Id"::TEXT = "p_AMCST_Id" 
            AND "B"."AMCST_ActiveFlag" = TRUE 
            AND "B"."AMCST_SOL" = "p_FLAG" 
            AND "A"."ACYST_ActiveFlag" = TRUE;

    ELSIF "p_FLAG" = 'L' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "B"."AMCST_FirstName" IS NULL OR "B"."AMCST_FirstName" = '' THEN '' ELSE "B"."AMCST_FirstName" END ||
            CASE WHEN "B"."AMCST_MiddleName" IS NULL OR "B"."AMCST_MiddleName" = '' THEN '' ELSE ' ' || "B"."AMCST_MiddleName" END ||
            CASE WHEN "B"."AMCST_LastName" IS NULL OR "B"."AMCST_LastName" = '' THEN '' ELSE ' ' || "B"."AMCST_LastName" END)::TEXT AS "studentname",
            "B"."AMCST_AdmNo"::TEXT AS "admno",
            "B"."AMCST_RegistrationNo"::TEXT AS "regno",
            "C"."AMCO_CourseName"::TEXT AS "coursename",
            "D"."AMB_BranchName"::TEXT AS "branchname",
            "E"."AMSE_SEMName"::TEXT AS "semestername",
            "F"."ACMS_SectionName"::TEXT AS "sectionname",
            (CASE WHEN "B"."AMCST_FatherSurname" IS NULL OR "B"."AMCST_FatherSurname" = '' THEN '' ELSE "B"."AMCST_FatherSurname" END ||
            CASE WHEN "B"."AMCST_FatherName" IS NULL OR "B"."AMCST_FatherName" = '' THEN '' ELSE ' ' || "B"."AMCST_FatherName" END)::TEXT AS "fathername",
            (CASE WHEN "B"."AMCST_MotherSurname" IS NULL OR "B"."AMCST_MotherSurname" = '' THEN '' ELSE "B"."AMCST_MotherSurname" END ||
            CASE WHEN "B"."AMCST_MotherName" IS NULL OR "B"."AMCST_MotherName" = '' THEN '' ELSE ' ' || "B"."AMCST_MotherName" END)::TEXT AS "mothername",
            CAST("B"."AMCST_Date" AS DATE) AS "doa",
            "B"."AMCST_StudentPhoto"::TEXT AS "studentphoto",
            COALESCE("H"."IMC_CasteName", '')::TEXT AS "castename",
            CAST("B"."AMCST_DOB" AS DATE) AS "dob",
            COALESCE("B"."AMCST_DOBin_words", '')::TEXT AS "dobinwords",
            COALESCE("B"."AMCST_MotherTongue", '')::TEXT AS "mothertounge",
            "I"."IVRMMC_Nationality"::TEXT AS "nationality",
            "B"."AMCST_MobileNo"::TEXT AS "mobileno",
            "B"."AMCST_emailId"::TEXT AS "emailid",
            "B"."AMCST_StuBankIFSCCode"::TEXT AS "ifsccode",
            "B"."AMCST_BirthPlace"::TEXT AS "birthplace",
            "B"."AMCST_AadharNo"::TEXT AS "aadharno",
            EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "B"."AMCST_DOB"))::INTEGER AS "age",
            "B"."AMCST_Sex"::TEXT AS "gender",
            ROW("K".*)::TEXT AS "tc_data"
        FROM "clg"."Adm_College_Yearly_Student" "A"
        INNER JOIN "CLG"."Adm_Master_College_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "C" ON "C"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "D" ON "D"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "E" ON "E"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "F" ON "F"."ACMS_Id" = "A"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "G" ON "G"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" "I" ON "I"."IVRMMC_Id" = "B"."AMCST_Nationality"
        INNER JOIN "CLG"."Adm_College_Student_TC" "K" ON "K"."AMCST_Id" = "A"."AMCST_Id" 
            AND "K"."ASMAY_Id" = "A"."ASMAY_Id" 
            AND "K"."AMCO_Id" = "A"."AMCO_Id" 
            AND "K"."AMB_Id" = "A"."AMB_Id"
            AND "K"."AMSE_Id" = "A"."AMSE_Id" 
            AND "K"."ACMS_Id" = "A"."ACMS_Id" 
            AND "K"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "K"."AMCST_Id"::TEXT = "p_AMCST_Id"
        LEFT JOIN "IVRM_Master_Caste" "H" ON "H"."IMC_Id" = "B"."IMC_Id"
        WHERE "A"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "A"."AMCST_Id"::TEXT = "p_AMCST_Id" 
            AND "B"."AMCST_ActiveFlag" = FALSE 
            AND "B"."AMCST_SOL" = "p_FLAG" 
            AND "A"."ACYST_ActiveFlag" = FALSE;

    ELSIF "p_FLAG" = 'T' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "B"."AMCST_FirstName" IS NULL OR "B"."AMCST_FirstName" = '' THEN '' ELSE "B"."AMCST_FirstName" END ||
            CASE WHEN "B"."AMCST_MiddleName" IS NULL OR "B"."AMCST_MiddleName" = '' THEN '' ELSE ' ' || "B"."AMCST_MiddleName" END ||
            CASE WHEN "B"."AMCST_LastName" IS NULL OR "B"."AMCST_LastName" = '' THEN '' ELSE ' ' || "B"."AMCST_LastName" END)::TEXT AS "studentname",
            "B"."AMCST_AdmNo"::TEXT AS "admno",
            "B"."AMCST_RegistrationNo"::TEXT AS "regno",
            "C"."AMCO_CourseName"::TEXT AS "coursename",
            "D"."AMB_BranchName"::TEXT AS "branchname",
            "E"."AMSE_SEMName"::TEXT AS "semestername",
            "F"."ACMS_SectionName"::TEXT AS "sectionname",
            (CASE WHEN "B"."AMCST_FatherSurname" IS NULL OR "B"."AMCST_FatherSurname" = '' THEN '' ELSE "B"."AMCST_FatherSurname" END ||
            CASE WHEN "B"."AMCST_FatherName" IS NULL OR "B"."AMCST_FatherName" = '' THEN '' ELSE ' ' || "B"."AMCST_FatherName" END)::TEXT AS "fathername",
            (CASE WHEN "B"."AMCST_MotherSurname" IS NULL OR "B"."AMCST_MotherSurname" = '' THEN '' ELSE "B"."AMCST_MotherSurname" END ||
            CASE WHEN "B"."AMCST_MotherName" IS NULL OR "B"."AMCST_MotherName" = '' THEN '' ELSE ' ' || "B"."AMCST_MotherName" END)::TEXT AS "mothername",
            CAST("B"."AMCST_Date" AS DATE) AS "doa",
            "B"."AMCST_StudentPhoto"::TEXT AS "studentphoto",
            COALESCE("H"."IMC_CasteName", '')::TEXT AS "castename",
            CAST("B"."AMCST_DOB" AS DATE) AS "dob",
            COALESCE("B"."AMCST_DOBin_words", '')::TEXT AS "dobinwords",
            COALESCE("B"."AMCST_MotherTongue", '')::TEXT AS "mothertounge",
            "I"."IVRMMC_Nationality"::TEXT AS "nationality",
            "B"."AMCST_MobileNo"::TEXT AS "mobileno",
            "B"."AMCST_emailId"::TEXT AS "emailid",
            "B"."AMCST_StuBankIFSCCode"::TEXT AS "ifsccode",
            "B"."AMCST_BirthPlace"::TEXT AS "birthplace",
            "B"."AMCST_AadharNo"::TEXT AS "aadharno",
            EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "B"."AMCST_DOB"))::INTEGER AS "age",
            "B"."AMCST_Sex"::TEXT AS "gender",
            ROW("K".*)::TEXT AS "tc_data"
        FROM "clg"."Adm_College_Yearly_Student" "A"
        INNER JOIN "CLG"."Adm_Master_College_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" "C" ON "C"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "D" ON "D"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "E" ON "E"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "F" ON "F"."ACMS_Id" = "A"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "G" ON "G"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" "I" ON "I"."IVRMMC_Id" = "B"."AMCST_Nationality"
        INNER JOIN "CLG"."Adm_College_Student_TC" "K" ON "K"."AMCST_Id" = "A"."AMCST_Id" 
            AND "K"."ASMAY_Id" = "A"."ASMAY_Id" 
            AND "K"."AMCO_Id" = "A"."AMCO_Id" 
            AND "K"."AMB_Id" = "A"."AMB_Id"
            AND "K"."AMSE_Id" = "A"."AMSE_Id" 
            AND "K"."ACMS_Id" = "A"."ACMS_Id" 
            AND "K"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "K"."AMCST_Id"::TEXT = "p_AMCST_Id"
        LEFT JOIN "IVRM_Master_Caste" "H" ON "H"."IMC_Id" = "B"."IMC_Id"
        WHERE "A"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "A"."AMCST_Id"::TEXT = "p_AMCST_Id" 
            AND "B"."AMCST_ActiveFlag" = TRUE 
            AND "B"."AMCST_SOL" = "p_FLAG" 
            AND "A"."ACYST_ActiveFlag" = TRUE;

    END IF;

    RETURN;

END;
$$;