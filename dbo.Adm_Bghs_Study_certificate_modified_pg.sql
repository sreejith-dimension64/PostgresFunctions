CREATE OR REPLACE FUNCTION "dbo"."Adm_Bghs_Study_certificate_modified"(
    p_yearId TEXT,
    p_classid TEXT,
    p_sectionid TEXT,
    p_studid TEXT,
    p_mi_id TEXT
)
RETURNS TABLE(
    studentnam TEXT,
    "AMST_Id" TEXT,
    admno TEXT,
    admdate TIMESTAMP,
    fatherName TEXT,
    mothername TEXT,
    class TEXT,
    section TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    acadamicyear TEXT,
    "AMST_Sex" TEXT,
    stuMT TEXT,
    dob TIMESTAMP,
    dobwords TEXT,
    admNo TEXT,
    addressd1 TEXT,
    photopath TEXT,
    street TEXT,
    area TEXT,
    city TEXT,
    pincode TEXT,
    caste TEXT,
    religion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        (CASE WHEN "Adm_M_Student"."AMST_FirstName" IS NULL OR "Adm_M_Student"."AMST_FirstName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FirstName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MiddleName" IS NULL OR "Adm_M_Student"."AMST_MiddleName" = '' OR "Adm_M_Student"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MiddleName" END ||
        CASE WHEN "Adm_M_Student"."AMST_LastName" IS NULL OR "Adm_M_Student"."AMST_LastName" = '' OR "Adm_M_Student"."AMST_LastName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_LastName" END)::TEXT AS studentnam,
        "Adm_M_Student"."AMST_Id"::TEXT,
        "Adm_M_Student"."AMST_AdmNo"::TEXT AS admno,
        "Adm_M_Student"."AMST_Date"::TIMESTAMP AS admdate,
        (CASE WHEN "Adm_M_Student"."AMST_FatherName" IS NULL OR "Adm_M_Student"."AMST_FatherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FatherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_FatherSurname" IS NULL OR "Adm_M_Student"."AMST_FatherSurname" = '' OR "Adm_M_Student"."AMST_FatherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_FatherSurname" END)::TEXT AS fatherName,
        (CASE WHEN "Adm_M_Student"."AMST_MotherName" IS NULL OR "Adm_M_Student"."AMST_MotherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_MotherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MotherSurname" IS NULL OR "Adm_M_Student"."AMST_MotherSurname" = '' OR "Adm_M_Student"."AMST_MotherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MotherSurname" END)::TEXT AS mothername,
        "Adm_School_M_Class"."ASMCL_ClassName"::TEXT AS class,
        "Adm_School_M_Section"."ASMC_SectionName"::TEXT AS section,
        "Adm_School_M_Academic_Year"."ASMAY_Id"::TEXT,
        "Adm_School_M_Class"."ASMCL_Id"::TEXT,
        "Adm_School_M_Academic_Year"."ASMAY_Year"::TEXT AS acadamicyear,
        "Adm_M_Student"."AMST_Sex"::TEXT,
        "Adm_M_Student"."AMST_MotherTongue"::TEXT AS stuMT,
        TO_TIMESTAMP("Adm_M_Student"."AMST_DOB", 'DD/MM/YYYY')::TIMESTAMP AS dob,
        "Adm_M_Student"."AMST_DOB_Words"::TEXT AS dobwords,
        "Adm_M_Student"."AMST_AdmNo"::TEXT AS admNo,
        (COALESCE("Adm_M_Student"."AMST_PerStreet", '') || ',' || COALESCE("Adm_M_Student"."AMST_PerArea", '') || ',' || COALESCE("Adm_M_Student"."AMST_PerCity", '') || ',' || COALESCE("IVRM_Master_State"."ivrmms_name", '') || ',' || COALESCE("IVRM_Master_Country"."IVRMMC_CountryName", ''))::TEXT AS addressd1,
        "Adm_M_Student"."AMST_Photoname"::TEXT AS photopath,
        "Adm_M_Student"."AMST_PerStreet"::TEXT AS street,
        "Adm_M_Student"."AMST_PerArea"::TEXT AS area,
        "Adm_M_Student"."AMST_PerCity"::TEXT AS city,
        "Adm_M_Student"."AMST_PerPincode"::TEXT AS pincode,
        "IVRM_Master_Caste"."IMC_CasteName"::TEXT AS caste,
        "IVRM_Master_Religion"."IVRMMR_Name"::TEXT AS religion
    FROM "Adm_M_Student"
    LEFT OUTER JOIN "IVRM_Master_State" ON "Adm_M_Student"."AMST_PerState" = "IVRM_Master_State"."IVRMMS_Id"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_PerCountry"
    LEFT OUTER JOIN "ivrm_master_caste" ON "ivrm_master_caste"."imc_id" = "Adm_M_Student"."ic_id"
    LEFT OUTER JOIN "IVRM_Master_Religion" ON "IVRM_Master_Religion"."IVRMMR_Id" = "Adm_M_Student"."IVRMMR_Id"
    WHERE "Adm_School_Y_Student"."AMST_Id" = p_studid 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_yearId 
        AND "Adm_M_Student"."MI_Id" = p_mi_id;

END;
$$;