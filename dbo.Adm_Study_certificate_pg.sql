CREATE OR REPLACE FUNCTION "dbo"."Adm_Study_certificate"(
    "yearId" bigint,
    "classid" bigint,
    "sectionid" bigint,
    "studid" bigint
)
RETURNS TABLE(
    "stuFN" VARCHAR,
    "stuMN" VARCHAR,
    "stuLN" VARCHAR,
    "AMST_Id" bigint,
    "fatherName" VARCHAR,
    "class" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "acadamicyear" VARCHAR,
    "AMST_Sex" VARCHAR,
    "stuMT" VARCHAR,
    "admNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ("Adm_M_Student"."AMST_FirstName")::"varchar" AS "stuFN",
        ("Adm_M_Student"."AMST_MiddleName")::"varchar" AS "stuMN",
        ("Adm_M_Student"."AMST_LastName")::"varchar" AS "stuLN",
        "Adm_M_Student"."AMST_Id",
        ("Adm_M_Student"."AMST_FatherName")::"varchar" AS "fatherName",
        ("Adm_School_M_Class"."ASMCL_ClassName")::"varchar" AS "class",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Adm_School_M_Academic_Year"."ASMAY_Id",
        "Adm_School_M_Class"."ASMCL_Id",
        ("Adm_School_M_Academic_Year"."ASMAY_Year")::"varchar" AS "acadamicyear",
        "Adm_M_Student"."AMST_Sex",
        ("Adm_M_Student"."AMST_MotherTongue")::"varchar" AS "stuMT",
        ("Adm_M_Student"."AMST_AdmNo")::"varchar" AS "admNo"
    FROM "dbo"."Adm_School_Y_Student"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
        ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" 
        ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    WHERE "Adm_School_Y_Student"."AMST_Id" = "studid" 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "yearId";
END;
$$;