CREATE OR REPLACE FUNCTION "dbo"."adm_statewise_report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_ID" TEXT,
    "IVRMMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "acadamicyear" VARCHAR,
    "AMST_Sex" VARCHAR,
    "dob" VARCHAR,
    "street" VARCHAR,
    "area" VARCHAR,
    "city" VARCHAR,
    "pincode" VARCHAR,
    "statename" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT a."AMST_Id",
        (a."AMST_FirstName" || '' '' || a."AMST_MiddleName" || '' '' || a."AMST_LastName") AS studentname,
        cls."ASMCL_ClassName" AS classname,
        sec."ASMC_SectionName" AS sectionname,
        a."AMST_AdmNo",
        c."ASMAY_Year" AS acadamicyear,
        a."AMST_Sex",
        TO_CHAR(a."AMST_DOB", ''DD/MM/YYYY'') AS dob,
        a."AMST_PerStreet" AS street,
        a."AMST_PerArea" AS area,
        a."AMST_PerCity" AS city,
        a."AMST_PerPincode" AS pincode,
        st."IVRMMS_Name" AS statename
    FROM "dbo"."Adm_M_Student" a
    INNER JOIN "dbo"."Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" cls ON b."ASMCL_Id" = cls."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" sec ON b."ASMS_Id" = sec."ASMS_Id"
    LEFT JOIN "dbo"."IVRM_Master_Country" con ON a."AMST_PerCountry" = con."IVRMMC_Id"
    LEFT JOIN "dbo"."IVRM_Master_State" st ON a."AMST_PerState" = st."IVRMMS_Id"
    WHERE a."MI_Id" IN (' || "MI_Id" || ')
        AND b."ASMAY_Id" = ' || "ASMAY_Id" || '
        AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ')
        AND b."ASMS_Id" IN (' || "ASMS_ID" || ')
        AND st."IVRMMS_Id" IN (' || "IVRMMS_Id" || ')
        AND a."AMST_SOL" = ''S''
        AND b."AMAY_ActiveFlag" = 1
        AND a."AMST_ActiveFlag" = 1
    ORDER BY studentname, classname, sectionname, statename';

    RETURN QUERY EXECUTE "sql";
END;
$$;