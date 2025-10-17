CREATE OR REPLACE FUNCTION "dbo"."Adm_CountryWise_StudentsDetails"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "IVRMMC_Id" TEXT
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
    "countryname" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT "AMS"."AMST_Id",
                     COALESCE("AMS"."AMST_FirstName", '''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''') || '' '' || COALESCE("AMS"."AMST_LastName", '''') AS studentname,
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
                     "IMC"."IVRMMC_CountryName" AS countryname
              FROM "dbo"."Adm_M_Student" "AMS"
              INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
              INNER JOIN "Adm_School_M_Academic_Year" "ASMY" ON "ASMY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
              INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
              INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
              INNER JOIN "IVRM_Master_Country" "IMC" ON "IMC"."AMST_PerCountry" = "AMS"."IVRMMC_Id"
              INNER JOIN "IVRM_Master_State" "IMS" ON "IMS"."AMST_PerState" = "AMS"."IVRMMS_Id"
              WHERE "AMS"."MI_Id" IN (' || "MI_Id" || ')
                AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
                AND "ASYS"."ASMCL_Id" IN (' || "ASMCL_Id" || ')
                AND "ASYS"."ASMS_Id" IN (' || "ASMS_Id" || ')
                AND "AMS"."IVRMMC_Id" IN (' || "IVRMMC_Id" || ')
                AND "AMST_SOL" = ''S''
                AND "AMAY_ActiveFlag" = 1
                AND "AMST_ActiveFlag" = 1
              ORDER BY "AMS"."AMST_Id"';

    RETURN QUERY EXECUTE "sql";
END;
$$;