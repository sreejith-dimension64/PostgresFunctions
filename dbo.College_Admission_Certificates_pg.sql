CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Certificates"(
    "report_name" VARCHAR(50),
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMSE_ID" BIGINT,
    "ACMS_ID" BIGINT,
    "AMB_Id" BIGINT,
    "AMCST_ID" BIGINT,
    "param" VARCHAR(50)
)
RETURNS TABLE(
    "Student_Name" TEXT,
    "coursename" TEXT,
    "coustart" TEXT,
    "couend" TEXT,
    "syslabus" TEXT,
    "admissionno" VARCHAR,
    "Dob" TIMESTAMP,
    "dobw" VARCHAR,
    "nationality" VARCHAR,
    "fathername" VARCHAR,
    "mothername" VARCHAR,
    "religion" VARCHAR,
    "caste" VARCHAR,
    "doj" TIMESTAMP,
    "languages" TEXT,
    "optionals" TEXT,
    "feedue" TEXT,
    "AMCST_Id" BIGINT,
    "fatheredu" VARCHAR,
    "motheredu" VARCHAR,
    "gendar" VARCHAR,
    "address" VARCHAR,
    "mobile" VARCHAR,
    "district" VARCHAR,
    "taluk" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "report_name" = 'conductcer' THEN
        RETURN QUERY
        SELECT 
            (COALESCE("AMCST_FirstName",' ') || COALESCE("AMCST_MiddleName",'') || COALESCE("AMCST_LastName",''))::TEXT AS "Student_Name",
            'BCOM'::TEXT AS "coursename",
            '2018'::TEXT AS "coustart",
            '2020'::TEXT AS "couend",
            NULL::TEXT AS "syslabus",
            NULL::VARCHAR AS "admissionno",
            NULL::TIMESTAMP AS "Dob",
            NULL::VARCHAR AS "dobw",
            NULL::VARCHAR AS "nationality",
            NULL::VARCHAR AS "fathername",
            NULL::VARCHAR AS "mothername",
            NULL::VARCHAR AS "religion",
            NULL::VARCHAR AS "caste",
            NULL::TIMESTAMP AS "doj",
            NULL::TEXT AS "languages",
            NULL::TEXT AS "optionals",
            NULL::TEXT AS "feedue",
            NULL::BIGINT AS "AMCST_Id",
            NULL::VARCHAR AS "fatheredu",
            NULL::VARCHAR AS "motheredu",
            NULL::VARCHAR AS "gendar",
            NULL::VARCHAR AS "address",
            NULL::VARCHAR AS "mobile",
            NULL::VARCHAR AS "district",
            NULL::VARCHAR AS "taluk"
        FROM "clg"."Adm_Master_College_Student";
        
    ELSIF "report_name" = 'coursecer' THEN
        RETURN QUERY
        SELECT 
            (COALESCE("AMCST_FirstName",' ') || COALESCE("AMCST_MiddleName",'') || COALESCE("AMCST_LastName",''))::TEXT AS "Student_Name",
            'BCOM'::TEXT AS "coursename",
            '2018'::TEXT AS "coustart",
            '2020'::TEXT AS "couend",
            'University'::TEXT AS "syslabus",
            NULL::VARCHAR AS "admissionno",
            NULL::TIMESTAMP AS "Dob",
            NULL::VARCHAR AS "dobw",
            NULL::VARCHAR AS "nationality",
            NULL::VARCHAR AS "fathername",
            NULL::VARCHAR AS "mothername",
            NULL::VARCHAR AS "religion",
            NULL::VARCHAR AS "caste",
            NULL::TIMESTAMP AS "doj",
            NULL::TEXT AS "languages",
            NULL::TEXT AS "optionals",
            NULL::TEXT AS "feedue",
            NULL::BIGINT AS "AMCST_Id",
            NULL::VARCHAR AS "fatheredu",
            NULL::VARCHAR AS "motheredu",
            NULL::VARCHAR AS "gendar",
            NULL::VARCHAR AS "address",
            NULL::VARCHAR AS "mobile",
            NULL::VARCHAR AS "district",
            NULL::VARCHAR AS "taluk"
        FROM "clg"."Adm_Master_College_Student";
        
    ELSIF "report_name" = 'tetransfer' THEN
        RETURN QUERY
        SELECT 
            (COALESCE(a."AMCST_FirstName",' ') || COALESCE(a."AMCST_MiddleName",'') || COALESCE(a."AMCST_LastName",''))::TEXT AS "Student_Name",
            NULL::TEXT AS "coursename",
            NULL::TEXT AS "coustart",
            NULL::TEXT AS "couend",
            NULL::TEXT AS "syslabus",
            a."AMCST_AdmNo"::VARCHAR AS "admissionno",
            a."AMCST_DOB" AS "Dob",
            a."AMCST_DOBin_words"::VARCHAR AS "dobw",
            a."AMCST_Nationality"::VARCHAR AS "nationality",
            a."AMCST_FatherName"::VARCHAR AS "fathername",
            a."AMCST_MotherName"::VARCHAR AS "mothername",
            b."IVRMMR_Name"::VARCHAR AS "religion",
            c."IMC_CasteName"::VARCHAR AS "caste",
            a."AMCST_Date" AS "doj",
            'English'::TEXT AS "languages",
            'Telugu'::TEXT AS "optionals",
            'YES'::TEXT AS "feedue",
            NULL::BIGINT AS "AMCST_Id",
            NULL::VARCHAR AS "fatheredu",
            NULL::VARCHAR AS "motheredu",
            NULL::VARCHAR AS "gendar",
            NULL::VARCHAR AS "address",
            NULL::VARCHAR AS "mobile",
            NULL::VARCHAR AS "district",
            NULL::VARCHAR AS "taluk"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "IVRM_Master_Religion" b ON a."IVRMMR_Id" = b."IVRMMR_Id" AND b."Is_Active" = 1
        INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IMC_Id" AND a."AMCST_Id" = "AMCST_ID";
        
    ELSIF "report_name" = 'district' THEN
        RETURN QUERY
        SELECT 
            (COALESCE(a."AMCST_FirstName",' ') || COALESCE(a."AMCST_MiddleName",'') || COALESCE(a."AMCST_LastName",''))::TEXT AS "Student_Name",
            NULL::TEXT AS "coursename",
            NULL::TEXT AS "coustart",
            NULL::TEXT AS "couend",
            NULL::TEXT AS "syslabus",
            NULL::VARCHAR AS "admissionno",
            a."AMCST_DOB" AS "Dob",
            NULL::VARCHAR AS "dobw",
            NULL::VARCHAR AS "nationality",
            a."AMCST_FatherName"::VARCHAR AS "fathername",
            a."AMCST_MotherName"::VARCHAR AS "mothername",
            NULL::VARCHAR AS "religion",
            NULL::VARCHAR AS "caste",
            NULL::TIMESTAMP AS "doj",
            NULL::TEXT AS "languages",
            NULL::TEXT AS "optionals",
            NULL::TEXT AS "feedue",
            a."AMCST_Id" AS "AMCST_Id",
            a."AMCST_FatherEducation"::VARCHAR AS "fatheredu",
            a."AMCST_MotherEducation"::VARCHAR AS "motheredu",
            a."AMCST_Sex"::VARCHAR AS "gendar",
            a."AMCST_PerAdd3"::VARCHAR AS "address",
            a."AMCST_MobileNo"::VARCHAR AS "mobile",
            a."AMCST_District"::VARCHAR AS "district",
            a."AMCST_Taluk"::VARCHAR AS "taluk"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE a."AMCST_District" = "param"
        LIMIT 100;
        
    ELSIF "report_name" = 'taluk' THEN
        RETURN QUERY
        SELECT 
            (COALESCE(a."AMCST_FirstName",' ') || COALESCE(a."AMCST_MiddleName",'') || COALESCE(a."AMCST_LastName",''))::TEXT AS "Student_Name",
            NULL::TEXT AS "coursename",
            NULL::TEXT AS "coustart",
            NULL::TEXT AS "couend",
            NULL::TEXT AS "syslabus",
            NULL::VARCHAR AS "admissionno",
            a."AMCST_DOB" AS "Dob",
            NULL::VARCHAR AS "dobw",
            NULL::VARCHAR AS "nationality",
            a."AMCST_FatherName"::VARCHAR AS "fathername",
            a."AMCST_MotherName"::VARCHAR AS "mothername",
            NULL::VARCHAR AS "religion",
            NULL::VARCHAR AS "caste",
            NULL::TIMESTAMP AS "doj",
            NULL::TEXT AS "languages",
            NULL::TEXT AS "optionals",
            NULL::TEXT AS "feedue",
            a."AMCST_Id" AS "AMCST_Id",
            a."AMCST_FatherEducation"::VARCHAR AS "fatheredu",
            a."AMCST_MotherEducation"::VARCHAR AS "motheredu",
            a."AMCST_Sex"::VARCHAR AS "gendar",
            a."AMCST_PerAdd3"::VARCHAR AS "address",
            a."AMCST_MobileNo"::VARCHAR AS "mobile",
            a."AMCST_District"::VARCHAR AS "district",
            a."AMCST_Taluk"::VARCHAR AS "taluk"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE a."AMCST_Taluk" = "param"
        LIMIT 100;
        
    END IF;
    
    RETURN;
END;
$$;