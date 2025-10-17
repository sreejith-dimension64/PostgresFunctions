CREATE OR REPLACE FUNCTION "dbo"."getStudentSearchData1"(
    "p_Where" TEXT,
    "p_MI_Id" TEXT
)
RETURNS TABLE (
    "amsT_RegistrationNo" VARCHAR,
    "AMST_Id" BIGINT,
    "amsT_FirstName" TEXT,
    "amsT_Date" VARCHAR,
    "amsT_DOB" VARCHAR,
    "amsT_Sex" VARCHAR,
    "amsT_MotherName" TEXT,
    "amsT_FatherName" TEXT,
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
    "asmC_SectionName" VARCHAR,
    "AMST_Photoname" VARCHAR,
    "addressd1" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_asmay_id" TEXT;
    "v_sql" TEXT;
BEGIN
    SELECT "ASMAY_Id" INTO "v_asmay_id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "mi_id" = "p_MI_Id"
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date"
    AND "Is_Active" = TRUE
    LIMIT 1;

    "v_sql" := 'SELECT "a"."amsT_RegistrationNo", 
        "b"."AMST_Id" as "AMST_Id", 
        CASE WHEN "a"."AMST_FirstName" IS NULL OR "a"."AMST_FirstName" = '''' THEN '''' ELSE "a"."AMST_FirstName" END ||
        CASE WHEN "a"."AMST_MiddleName" IS NULL OR "a"."AMST_MiddleName" = '''' OR "a"."AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "a"."AMST_MiddleName" END ||
        CASE WHEN "a"."AMST_LastName" IS NULL OR "a"."AMST_LastName" = '''' OR "a"."AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "a"."AMST_LastName" END AS "amsT_FirstName",
        TO_CHAR("a"."amsT_Date", ''DD/MM/YYYY'') AS "amsT_Date",
        TO_CHAR("a"."amsT_DOB", ''DD/MM/YYYY'') AS "amsT_DOB",
        "a"."amsT_Sex",
        CASE WHEN "a"."amsT_MotherName" IS NULL OR "a"."amsT_MotherName" = '''' THEN '''' ELSE "a"."amsT_MotherName" END ||
        CASE WHEN "a"."AMST_MotherSurname" IS NULL OR "a"."AMST_MotherSurname" = '''' OR "a"."AMST_MotherSurname" = ''0'' THEN '''' ELSE '' '' || "a"."AMST_MotherSurname" END AS "amsT_MotherName",
        CASE WHEN "a"."amsT_FatherName" IS NULL OR "a"."amsT_FatherName" = '''' THEN '''' ELSE "a"."amsT_FatherName" END ||
        CASE WHEN "a"."AMST_FatherSurname" IS NULL OR "a"."AMST_FatherSurname" = '''' OR "a"."AMST_FatherSurname" = ''0'' THEN '''' ELSE '' '' || "a"."AMST_FatherSurname" END AS "amsT_FatherName",
        "a"."amsT_emailId",
        "a"."amsT_MobileNo",
        "a"."amsT_StuBankAccNo",
        "a"."amsT_AadharNo",
        "a"."amsT_AdmNo",
        "a"."amsT_BirthCertNO",
        "a"."amsT_BloodGroup",
        "a"."amsT_FatherAadharNo",
        "a"."amsT_FatherBankAccNo",
        "c"."ASMCL_ClassName" AS "asmcL_ClassName",
        "d"."ASMC_SectionName" AS "asmC_SectionName",
        "a"."AMST_Photoname",
        TRIM(LEADING '','' FROM 
            COALESCE('','' || NULLIF("a"."AMST_PerStreet", ''''), '''') ||
            COALESCE('','' || NULLIF("a"."AMST_PerArea", ''''), '''') ||
            COALESCE('','' || NULLIF("a"."AMST_PerCity", ''''), '''') ||
            COALESCE('','' || NULLIF("ms"."ivrmms_name", ''''), '''') ||
            COALESCE('','' || NULLIF("mc"."IVRMMC_CountryName", ''''), '''')
        ) AS "addressd1"
    FROM "Adm_M_Student" "a"
    INNER JOIN "Adm_School_Y_Student" "b" ON "a"."amst_id" = "b"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" "c" ON "c"."ASMCL_Id" = "b"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "d" ON "d"."ASMS_Id" = "b"."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "e" ON "e"."ASMAY_Id" = "b"."ASMAY_Id"
    LEFT OUTER JOIN "IVRM_Master_Country" "mc" ON "mc"."IVRMMC_Id" = "a"."AMST_PerCountry"
    LEFT OUTER JOIN "IVRM_Master_State" "ms" ON "ms"."ivrmmc_id" = "mc"."IVRMMC_Id" AND "ms"."IVRMMS_Id" = "a"."AMST_PerState"
    WHERE "b"."asmay_id" = ' || "v_asmay_id" || ' AND "a"."MI_Id" = ' || "p_MI_Id" || ' AND ' || "p_Where";

    RETURN QUERY EXECUTE "v_sql";
    
END;
$$;