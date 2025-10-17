CREATE OR REPLACE FUNCTION "dbo"."AlumnistudentlatterReport"(
    "MI_Id" TEXT,
    "year" TEXT,
    "clas" TEXT,
    "Flag" VARCHAR(30)
)
RETURNS TABLE (
    "amsT_RegistrationNo" VARCHAR,
    "amsT_FirstName" TEXT,
    "amsT_Date" VARCHAR,
    "amsT_DOB" VARCHAR,
    "amsT_Sex" VARCHAR,
    "amsT_MotherName" TEXT,
    "amsT_FatherName" TEXT,
    "AMST_PerStreet" VARCHAR,
    "AMST_PerArea" VARCHAR,
    "AMST_PerCity" VARCHAR,
    "AMST_PerPincode" VARCHAR,
    "amsT_emailId" VARCHAR,
    "amsT_MobileNo" VARCHAR,
    "amsT_StuBankAccNo" VARCHAR,
    "amsT_AadharNo" VARCHAR,
    "amsT_AdmNo" VARCHAR,
    "amsT_BirthCertNO" VARCHAR,
    "amsT_BloodGroup" VARCHAR,
    "amsT_FatherAadharNo" VARCHAR,
    "amsT_FatherBankAccNo" VARCHAR,
    "asmcL_ClassName" VARCHAR,
    "Country" VARCHAR,
    "State" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT "ALMST_RegistrationNo" as "amsT_RegistrationNo", 
        CASE WHEN "ALMST_FirstName" is null or "ALMST_FirstName" = '''' then '''' else "ALMST_FirstName" end ||
        CASE WHEN "ALMST_MiddleName" is null or "ALMST_MiddleName" = '''' or "ALMST_MiddleName" = ''0'' then '''' ELSE '' '' || "ALMST_MiddleName" END ||
        CASE WHEN "ALMST_LastName" is null or "ALMST_LastName" = '''' or "ALMST_LastName" = ''0'' then '''' ELSE '' '' || "ALMST_LastName" END as "amsT_FirstName",
        TO_CHAR("ALMST_Date", ''DD/MM/YYYY'') as "amsT_Date", 
        TO_CHAR("ALMST_DOB", ''DD/MM/YYYY'') as "amsT_DOB", 
        "ALMST_Sex" as "amsT_Sex", 
        CASE WHEN "ALMST_MotherName" is null or "ALMST_MotherName" = '''' then '''' else "ALMST_MotherName" end ||
        CASE WHEN "ALMST_MotherSurname" is null or "ALMST_MotherSurname" = '''' or "ALMST_MotherSurname" = ''0'' then '''' ELSE '' '' || "ALMST_MotherSurname" END as "amsT_MotherName",
        CASE WHEN "ALMST_FatherName" is null or "ALMST_FatherName" = '''' then '''' else "ALMST_FatherName" end ||
        CASE WHEN "ALMST_FatherSurname" is null or "ALMST_FatherSurname" = '''' or "ALMST_FatherSurname" = ''0'' then '''' ELSE '' '' || "ALMST_FatherSurname" END as "amsT_FatherName",
        a."ALMST_PerStreet" as "AMST_PerStreet",
        a."ALMST_PerArea" as "AMST_PerArea",
        a."ALMST_PerCity" as "AMST_PerCity",
        a."ALMST_PerPincode" as "AMST_PerPincode",
        "ALMST_emailId" as "amsT_emailId",
        "ALMST_MobileNo" as "amsT_MobileNo",
        "ALMST_StuBankAccNo" as "amsT_StuBankAccNo",
        "ALMST_AadharNo" as "amsT_AadharNo",
        "ALMST_AdmNo" as "amsT_AdmNo",
        "ALMST_BirthCertNO" as "amsT_BirthCertNO",
        "ALMST_BloodGroup" as "amsT_BloodGroup",
        "ALMST_FatherAadharNo" as "amsT_FatherAadharNo",
        "ALMST_FatherBankAccNo" as "amsT_FatherBankAccNo",
        "ASMCL_ClassName" as "asmcL_ClassName",
        co."IVRMMC_CountryName" as "Country",
        st."IVRMMS_Name" as "State"
    FROM "ALU"."Alumni_Master_Student" a
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id_Left"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id_Left"
    LEFT JOIN "IVRM_Master_Country" co ON a."ALMST_ConCountryId" = co."IVRMMC_Id"
    LEFT JOIN "IVRM_Master_State" st ON a."ALMST_ConState" = st."IVRMMS_Id"
    WHERE a."MI_Id" = ' || "MI_Id" || ' AND a."ASMAY_Id_Left" = ' || "year" || ' AND a."ASMCL_Id_Left" = ' || "clas";

    RETURN QUERY EXECUTE "sql";
END;
$$;