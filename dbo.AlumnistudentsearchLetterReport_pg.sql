CREATE OR REPLACE FUNCTION "dbo"."AlumnistudentsearchLetterReport"(
    "MI_Id" TEXT,
    "year" TEXT,
    "clas" TEXT,
    "AMST_IDs" TEXT,
    "Flag" TEXT
)
RETURNS TABLE(
    "ASMAY_Id_Left" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMCL_Id_Left" BIGINT,
    "amsT_RegistrationNo" VARCHAR,
    "amsT_Id" BIGINT,
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
    "amsT_MobileNo" BIGINT,
    "amsT_StuBankAccNo" VARCHAR,
    "amsT_AadharNo" BIGINT,
    "amsT_AdmNo" VARCHAR,
    "amsT_BirthCertNO" VARCHAR,
    "amsT_BloodGroup" VARCHAR,
    "amsT_FatherAadharNo" BIGINT,
    "amsT_FatherBankAccNo" VARCHAR,
    "asmcL_ClassName" VARCHAR,
    "Country" VARCHAR,
    "State" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Flag" = 'Alumni' THEN
    
        RETURN QUERY EXECUTE 
        'SELECT a."ASMAY_Id_Left", c."ASMCL_ClassName", a."ASMCL_Id_Left", 
                a."ALMST_RegistrationNo" as "amsT_RegistrationNo",
                a."AMST_Id" as "amsT_Id",
                (CASE WHEN a."ALMST_FirstName" IS NULL OR a."ALMST_FirstName" = '''' THEN '''' ELSE a."ALMST_FirstName" END ||
                CASE WHEN a."ALMST_MiddleName" IS NULL OR a."ALMST_MiddleName" = '''' OR a."ALMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_MiddleName" END ||
                CASE WHEN a."ALMST_LastName" IS NULL OR a."ALMST_LastName" = '''' OR a."ALMST_LastName" = ''0'' THEN '''' ELSE '' '' || a."ALMST_LastName" END) as "amsT_FirstName",
                TO_CHAR(a."ALMST_Date", ''DD/MM/YYYY'') as "amsT_Date",
                TO_CHAR(a."ALMST_DOB", ''DD/MM/YYYY'') as "amsT_DOB",
                a."ALMST_Sex" as "amsT_Sex",
                (CASE WHEN a."ALMST_MotherName" IS NULL OR a."ALMST_MotherName" = '''' THEN '''' ELSE a."ALMST_MotherName" END ||
                CASE WHEN a."ALMST_MotherSurname" IS NULL OR a."ALMST_MotherSurname" = '''' OR a."ALMST_MotherSurname" = ''0'' THEN '''' ELSE '' '' || a."ALMST_MotherSurname" END) as "amsT_MotherName",
                (CASE WHEN a."ALMST_FatherName" IS NULL OR a."ALMST_FatherName" = '''' THEN '''' ELSE a."ALMST_FatherName" END ||
                CASE WHEN a."ALMST_FatherSurname" IS NULL OR a."ALMST_FatherSurname" = '''' OR a."ALMST_FatherSurname" = ''0'' THEN '''' ELSE '' '' || a."ALMST_FatherSurname" END) as "amsT_FatherName",
                a."ALMST_PerStreet" as "AMST_PerStreet",
                a."ALMST_PerArea" as "AMST_PerArea",
                a."ALMST_PerCity" as "AMST_PerCity",
                a."ALMST_PerPincode" as "AMST_PerPincode",
                a."ALMST_emailId" as "amsT_emailId",
                a."ALMST_MobileNo" as "amsT_MobileNo",
                a."ALMST_StuBankAccNo" as "amsT_StuBankAccNo",
                a."ALMST_AadharNo" as "amsT_AadharNo",
                REPLACE(a."ALMST_AdmNo", ''-left'', '''') as "amsT_AdmNo",
                a."ALMST_BirthCertNO" as "amsT_BirthCertNO",
                a."ALMST_BloodGroup" as "amsT_BloodGroup",
                a."ALMST_FatherAadharNo" as "amsT_FatherAadharNo",
                a."ALMST_FatherBankAccNo" as "amsT_FatherBankAccNo",
                c."ASMCL_ClassName" as "asmcL_ClassName",
                co."IVRMMC_CountryName" as "Country",
                st."IVRMMS_Name" as "State"
        FROM "ALU"."Alumni_Master_Student" a
        INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id_Left"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id_Left"
        LEFT JOIN "IVRM_Master_Country" co ON a."ALMST_ConCountryId" = co."IVRMMC_Id"
        LEFT JOIN "IVRM_Master_State" st ON a."ALMST_ConState" = st."IVRMMS_Id"
        WHERE a."MI_Id" = ' || "MI_Id" || ' 
          AND a."ASMAY_Id_Left" = ' || "year" || ' 
          AND a."ASMCL_Id_Left" = ' || "clas" || ' 
          AND a."AMST_Id" IN (' || "AMST_IDs" || ')';
    
    ELSIF "Flag" = 'Regular' THEN
    
        RETURN QUERY EXECUTE
        'SELECT NULL::BIGINT as "ASMAY_Id_Left",
                C."ASMCL_ClassName",
                NULL::BIGINT as "ASMCL_Id_Left",
                B."AMST_RegistrationNo" as "amsT_RegistrationNo",
                A."AMST_Id" as "amsT_Id",
                (CASE WHEN B."AMST_FirstName" IS NULL OR B."AMST_FirstName" = '''' THEN '''' ELSE B."AMST_FirstName" END ||
                CASE WHEN B."AMST_MiddleName" IS NULL OR B."AMST_MiddleName" = '''' OR B."AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || B."AMST_MiddleName" END ||
                CASE WHEN B."AMST_LastName" IS NULL OR B."AMST_LastName" = '''' OR B."AMST_LastName" = ''0'' THEN '''' ELSE '' '' || B."AMST_LastName" END) as "amsT_FirstName",
                TO_CHAR(B."AMST_Date", ''DD/MM/YYYY'') as "amsT_Date",
                TO_CHAR(B."AMST_DOB", ''DD/MM/YYYY'') as "amsT_DOB",
                B."AMST_Sex" as "amsT_Sex",
                (CASE WHEN B."AMST_MotherName" IS NULL OR B."AMST_MotherName" = '''' THEN '''' ELSE B."AMST_MotherName" END ||
                CASE WHEN B."AMST_MotherSurname" IS NULL OR B."AMST_MotherSurname" = '''' OR B."AMST_MotherSurname" = ''0'' THEN '''' ELSE '' '' || B."AMST_MotherSurname" END) as "amsT_MotherName",
                (CASE WHEN B."AMST_FatherName" IS NULL OR B."AMST_FatherName" = '''' THEN '''' ELSE B."AMST_FatherName" END ||
                CASE WHEN B."AMST_FatherSurname" IS NULL OR B."AMST_FatherSurname" = '''' OR B."AMST_FatherSurname" = ''0'' THEN '''' ELSE '' '' || B."AMST_FatherSurname" END) as "amsT_FatherName",
                B."AMST_PerStreet" as "AMST_PerStreet",
                B."AMST_PerArea" as "AMST_PerArea",
                B."AMST_PerCity" as "AMST_PerCity",
                B."AMST_PerPincode" as "AMST_PerPincode",
                B."AMST_emailId" as "amsT_emailId",
                B."AMST_MobileNo" as "amsT_MobileNo",
                B."AMST_StuBankAccNo" as "amsT_StuBankAccNo",
                B."AMST_AadharNo" as "amsT_AadharNo",
                B."AMST_AdmNo" as "amsT_AdmNo",
                B."AMST_BirthCertNO" as "amsT_BirthCertNO",
                B."AMST_BloodGroup" as "amsT_BloodGroup",
                B."AMST_FatherAadharNo" as "amsT_FatherAadharNo",
                B."AMST_FatherBankAccNo" as "amsT_FatherBankAccNo",
                C."ASMCL_ClassName" as "asmcL_ClassName",
                co."IVRMMC_CountryName" as "Country",
                st."IVRMMS_Name" as "State"
        FROM "Adm_School_Y_Student" A 
        INNER JOIN "Adm_M_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" D ON D."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = A."ASMAY_Id"
        LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id" = B."AMST_PerCountry"
        LEFT JOIN "IVRM_Master_State" st ON st."IVRMMS_Id" = B."AMST_PerState" AND st."IVRMMC_Id" = co."IVRMMC_Id"
        WHERE A."ASMAY_Id" = ' || "year" || ' 
          AND A."ASMCL_Id" = ' || "clas" || ' 
          AND A."AMAY_ActiveFlag" = 1 
          AND B."AMST_SOL" = ''S'' 
          AND B."AMST_ActiveFlag" = 1
          AND A."AMST_Id" IN (' || "AMST_IDs" || ')';
    
    END IF;

END;
$$;