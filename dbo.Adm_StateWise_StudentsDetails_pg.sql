CREATE OR REPLACE FUNCTION "dbo"."Adm_StateWise_StudentsDetails"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "IVRMMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "classname" TEXT,
    "sectionname" TEXT,
    "AMST_AdmNo" TEXT,
    "acadamicyear" TEXT,
    "AMST_Sex" TEXT,
    "dob" TEXT,
    "street" TEXT,
    "area" TEXT,
    "city" TEXT,
    "pincode" TEXT,
    "countryname" TEXT,
    "statename" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    sql_query TEXT;
BEGIN
    sql_query := 'SELECT "AMS"."AMST_Id",
COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''') AS studentname,
"ASMC"."ASMCL_ClassName" AS classname,
"ASMS"."ASMC_SectionName" AS sectionname,
"AMS"."AMST_AdmNo",
"ASMY"."ASMAY_Year" AS acadamicyear,
"AMS"."AMST_Sex",
TO_CHAR("AMS"."AMST_DOB", ''DD/MM/YYYY'') AS dob,
"AMS"."AMST_PerStreet" AS street,
"AMS"."AMST_PerArea" AS area,
"AMS"."AMST_PerCity" AS city,
"AMS"."AMST_PerPincode" AS pincode,
"IMC"."IVRMMC_CountryName" AS countryname,
"st"."IVRMMS_Name" AS statename
FROM "dbo"."Adm_M_Student" "AMS"
INNER JOIN "dbo"."Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMY" ON "ASMY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
INNER JOIN "dbo"."Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
INNER JOIN "dbo"."Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
INNER JOIN "dbo"."IVRM_Master_Country" "IMC" ON "IMC"."AMST_PerCountry" = "AMS"."IVRMMC_Id"
INNER JOIN "dbo"."IVRM_Master_State" "st" ON "AMS"."AMST_PerState" = "st"."IVRMMS_Id"
WHERE "AMS"."MI_Id" IN (' || "MI_Id" || ') 
AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_Id" || ') 
AND "ASYS"."ASMCL_Id" IN (' || "ASMCL_Id" || ') 
AND "ASYS"."ASMS_Id" IN (' || "ASMS_Id" || ') 
AND "AMS"."IVRMMS_Id" IN (' || "IVRMMS_Id" || ')
AND "AMS"."AMST_SOL" = ''S'' 
AND "ASYS"."AMAY_ActiveFlag" = 1 
AND "AMS"."AMST_ActiveFlag" = 1';

    RETURN QUERY EXECUTE sql_query;
END;
$$;