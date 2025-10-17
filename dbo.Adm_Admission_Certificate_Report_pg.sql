CREATE OR REPLACE FUNCTION "dbo"."Adm_Admission_Certificate_Report"(
    "@MI_Id" TEXT,
    "@Amst_Id" TEXT,
    "@Asmay_Id" TEXT
)
RETURNS TABLE (
    stuname TEXT,
    "AMST_Id" BIGINT,
    admno TEXT,
    phone TEXT,
    fname TEXT,
    mothername TEXT,
    classname TEXT,
    sectionname TEXT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    acadamicyear TEXT,
    "amsT_Sex" TEXT,
    "stuMT" TEXT,
    dob TIMESTAMP,
    dobw TEXT,
    "AMST_AdmNo" TEXT,
    stuaddress TEXT,
    photopath TEXT,
    street TEXT,
    area TEXT,
    city TEXT,
    pincode TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN "Adm_M_Student"."AMST_FirstName" IS NULL OR "Adm_M_Student"."AMST_FirstName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FirstName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MiddleName" IS NULL OR "Adm_M_Student"."AMST_MiddleName" = '' OR "Adm_M_Student"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MiddleName" END ||
        CASE WHEN "Adm_M_Student"."AMST_LastName" IS NULL OR "Adm_M_Student"."AMST_LastName" = '' OR "Adm_M_Student"."AMST_LastName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_LastName" END AS stuname,
        
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo" AS admno,
        "Adm_M_Student"."AMST_MobileNo" AS phone,
        
        CASE WHEN "Adm_M_Student"."AMST_FatherName" IS NULL OR "Adm_M_Student"."AMST_FatherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FatherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_FatherSurname" IS NULL OR "Adm_M_Student"."AMST_FatherSurname" = '' OR "Adm_M_Student"."AMST_FatherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_FatherSurname" END AS fname,
        
        CASE WHEN "Adm_M_Student"."AMST_MotherName" IS NULL OR "Adm_M_Student"."AMST_MotherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_MotherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MotherSurname" IS NULL OR "Adm_M_Student"."AMST_MotherSurname" = '' OR "Adm_M_Student"."AMST_MotherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MotherSurname" END AS mothername,
        
        "Adm_School_M_Class"."ASMCL_ClassName" AS classname,
        "Adm_School_M_Section"."ASMC_SectionName" AS sectionname,
        "Adm_School_M_Academic_Year"."ASMAY_Id",
        "Adm_School_M_Class"."ASMCL_Id",
        "Adm_School_M_Academic_Year"."ASMAY_Year" AS acadamicyear,
        "Adm_M_Student"."AMST_Sex" AS "amsT_Sex",
        "Adm_M_Student"."AMST_MotherTongue" AS "stuMT",
        TO_TIMESTAMP("Adm_M_Student"."AMST_DOB", 'DD/MM/YYYY') AS dob,
        "Adm_M_Student"."AMST_DOB_Words" AS dobw,
        "Adm_M_Student"."AMST_AdmNo" AS "AMST_AdmNo",
        
        (COALESCE("Adm_M_Student"."AMST_PerStreet", '') || ',' || COALESCE("Adm_M_Student"."AMST_PerArea", '') || ',' || 
         COALESCE("Adm_M_Student"."AMST_PerCity", '') || ',' || COALESCE("IVRM_Master_State"."ivrmms_name", '') || ',' || 
         COALESCE("IVRM_Master_Country"."IVRMMC_CountryName", '')) AS stuaddress,
        
        "Adm_M_Student"."AMST_Photoname" AS photopath,
        "Adm_M_Student"."AMST_PerStreet" AS street,
        "Adm_M_Student"."AMST_PerArea" AS area,
        "Adm_M_Student"."AMST_PerCity" AS city,
        "Adm_M_Student"."AMST_PerPincode" AS pincode
    FROM              
        "Adm_M_Student"
        LEFT OUTER JOIN "IVRM_Master_State" ON "Adm_M_Student"."AMST_PerState" = "IVRM_Master_State"."IVRMMS_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_PerCountry"
    WHERE 
        "Adm_School_Y_Student"."AMST_Id" = "@Amst_Id"::BIGINT
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "@Asmay_Id"::BIGINT
        AND "Adm_M_Student"."MI_Id" = "@MI_Id"::BIGINT;
END;
$$;