CREATE OR REPLACE FUNCTION "dbo"."Adm_EndorsementData"(
    "yearId" TEXT,
    "classid" TEXT,
    "studid" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE (
    "studentnam" TEXT,
    "fatherName" TEXT,
    "mothername" TEXT,
    "class" TEXT,
    "section" TEXT,
    "AMST_Id" TEXT,
    "admno" TEXT,
    "admdate" TIMESTAMP,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "acadamicyear" TEXT,
    "joinedyear" TIMESTAMP,
    "leftyear" TIMESTAMP,
    "joinedclass" TEXT,
    "gender" TEXT,
    "stuMT" TEXT,
    "dob" TIMESTAMP,
    "dobwords" TEXT,
    "admNo" TEXT,
    "PASP_ProspectusNo" TEXT,
    "addressd1" TEXT,
    "photopath" TEXT,
    "street" TEXT,
    "area" TEXT,
    "city" TEXT,
    "pincode" TEXT,
    "caste" TEXT,
    "religion" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN "Adm_M_Student"."AMST_FirstName" IS NULL OR "Adm_M_Student"."AMST_FirstName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FirstName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MiddleName" IS NULL OR "Adm_M_Student"."AMST_MiddleName" = '' OR "Adm_M_Student"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MiddleName" END ||
        CASE WHEN "Adm_M_Student"."AMST_LastName" IS NULL OR "Adm_M_Student"."AMST_LastName" = '' OR "Adm_M_Student"."AMST_LastName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_LastName" END AS "studentnam",
        
        CASE WHEN "Adm_M_Student"."AMST_FatherName" IS NULL OR "Adm_M_Student"."AMST_FatherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FatherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_FatherSurname" IS NULL OR "Adm_M_Student"."AMST_FatherSurname" = '' OR "Adm_M_Student"."AMST_FatherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_FatherSurname" END AS "fatherName",
        
        CASE WHEN "Adm_M_Student"."AMST_MotherName" IS NULL OR "Adm_M_Student"."AMST_MotherName" = '' THEN '' ELSE "Adm_M_Student"."AMST_MotherName" END ||
        CASE WHEN "Adm_M_Student"."AMST_MotherSurname" IS NULL OR "Adm_M_Student"."AMST_MotherSurname" = '' OR "Adm_M_Student"."AMST_MotherSurname" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MotherSurname" END AS "mothername",
        
        "Adm_School_M_Class"."ASMCL_ClassName" AS "class",
        "Adm_School_M_Section"."ASMC_SectionName" AS "section",
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo" AS "admno",
        "Adm_M_Student"."AMST_Date" AS "admdate",
        "Adm_School_M_Academic_Year"."ASMAY_Id",
        "Adm_School_M_Class"."ASMCL_Id",
        "Adm_School_M_Academic_Year"."ASMAY_Year" AS "acadamicyear",
        "Adm_School_M_Academic_Year"."ASMAY_From_Date" AS "joinedyear",
        "Adm_School_M_Academic_Year"."ASMAY_To_Date" AS "leftyear",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "joinedclass",
        "Adm_M_Student"."AMST_Sex" AS "gender",
        "Adm_M_Student"."AMST_MotherTongue" AS "stuMT",
        TO_TIMESTAMP("Adm_M_Student"."AMST_DOB", 'DD/MM/YYYY') AS "dob",
        "Adm_M_Student"."AMST_DOB_Words" AS "dobwords",
        "Adm_M_Student"."AMST_AdmNo" AS "admNo",
        "PSR"."PASP_ProspectusNo",
        (COALESCE("Adm_M_Student"."AMST_PerStreet", '') || ',' || COALESCE("Adm_M_Student"."AMST_PerArea", '') || ',' || COALESCE("Adm_M_Student"."AMST_PerCity", '') || ',' || COALESCE("IVRM_Master_State"."ivrmms_name", '') || ',' || COALESCE("IVRM_Master_Country"."IVRMMC_CountryName", '')) AS "addressd1",
        "Adm_M_Student"."AMST_Photoname" AS "photopath",
        "Adm_M_Student"."AMST_PerStreet" AS "street",
        "Adm_M_Student"."AMST_PerArea" AS "area",
        "Adm_M_Student"."AMST_PerCity" AS "city",
        "Adm_M_Student"."AMST_PerPincode" AS "pincode",
        "IVRM_Master_Caste"."IMC_CasteName" AS "caste",
        "IVRM_Master_Religion"."IVRMMR_Name" AS "religion"
    FROM "Adm_M_Student"
    LEFT OUTER JOIN "IVRM_Master_State" ON "Adm_M_Student"."AMST_PerState" = "IVRM_Master_State"."IVRMMS_Id"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_PerCountry"
    LEFT OUTER JOIN "ivrm_master_caste" ON "ivrm_master_caste"."imc_id" = "Adm_M_Student"."ic_id"
    LEFT OUTER JOIN "IVRM_Master_Religion" ON "IVRM_Master_Religion"."IVRMMR_Id" = "Adm_M_Student"."IVRMMR_Id"
    INNER JOIN "Adm_Master_Student_PA" "AMPA" ON "AMPA"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "PA_School_Application_Prospectus" "PAAP" ON "PAAP"."PASR_Id" = "AMPA"."PASR_Id"
    INNER JOIN "Preadmission_School_Prospectus" "PSR" ON "PSR"."PASP_Id" = "PAAP"."PASP_Id"
    WHERE "Adm_School_Y_Student"."AMST_Id" = "studid" 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "yearId" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."ASMCL_Id" = "classid";
    
    RETURN;
END;
$$;