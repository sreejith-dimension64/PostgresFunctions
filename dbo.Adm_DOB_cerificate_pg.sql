CREATE OR REPLACE FUNCTION "dbo"."Adm_DOB_cerificate"(
    "yearId" bigint,
    "classid" bigint,
    "sectionid" bigint,
    "studid" bigint
)
RETURNS TABLE(
    "stuFN" text,
    "stuMN" text,
    "stuLN" text,
    "AMST_AdmNo" text,
    "AMST_Sex" text,
    "dob" timestamp,
    "dobWord" text,
    "AMST_BirthPlace" text,
    "fatherName" text,
    "class" text,
    "AMST_SOL" text,
    "acadamicyear" text,
    "stuPhoto" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '')::text AS "stuFN",
        COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '')::text AS "stuMN",
        COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '')::text AS "stuLN",
        "dbo"."Adm_M_Student"."AMST_AdmNo"::text,
        "dbo"."Adm_M_Student"."AMST_Sex"::text,
        ("dbo"."Adm_M_Student"."AMST_DOB")::timestamp AS "dob",
        ("dbo"."Adm_M_Student"."AMST_DOB_Words")::text AS "dobWord",
        "dbo"."Adm_M_Student"."AMST_BirthPlace"::text,
        ("dbo"."Adm_M_Student"."AMST_FatherName")::text AS "fatherName",
        ("dbo"."Adm_School_M_Class"."ASMCL_ClassName")::text AS "class",
        "dbo"."Adm_M_Student"."AMST_SOL"::text,
        ("dbo"."Adm_School_M_Academic_Year"."ASMAY_Year")::text AS "acadamicyear",
        ("dbo"."Adm_M_Student"."AMST_Photoname")::text AS "stuPhoto"
    FROM "dbo"."Adm_School_Y_Student"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section"
        ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
        ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    WHERE ("dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "yearId")
        AND ("dbo"."Adm_M_Student"."AMST_SOL" = 'S')
        AND ("dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1)
        AND "dbo"."Adm_School_Y_Student"."amay_activeflag" = 1
        AND ("dbo"."Adm_M_Student"."AMST_Id" = "studid")
        AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = "classid")
        AND ("dbo"."Adm_School_Y_Student"."ASMS_Id" = "sectionid");
END;
$$;