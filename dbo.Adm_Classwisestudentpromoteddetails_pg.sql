CREATE OR REPLACE FUNCTION "dbo"."Adm_Classwisestudentpromoteddetails"(
    p_promotedyear TEXT,
    p_promotedclass TEXT,
    p_presentyear TEXT,
    p_presentclass TEXT,
    p_presentsection TEXT,
    p_miid TEXT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "asysT_Id" BIGINT,
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "asmcL_Id" BIGINT,
    "asmcL_ClassName" VARCHAR,
    "asmS_Id" BIGINT,
    "asmC_SectionName" VARCHAR,
    "amaY_RollNo" BIGINT,
    "asmaY_Id" BIGINT,
    "asmaY_Year" VARCHAR,
    "amsT_AdmNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        a."AMST_Id" AS "amsT_Id",
        b."ASYST_Id" AS "asysT_Id",
        b."AMST_FirstName" AS "amsT_FirstName",
        b."AMST_MiddleName" AS "amsT_MiddleName",
        b."AMST_LastName" AS "amsT_LastName",
        a."ASMCL_Id" AS "asmcL_Id",
        c."ASMCL_ClassName" AS "asmcL_ClassName",
        a."ASMS_Id" AS "asmS_Id",
        d."ASMC_SectionName" AS "asmC_SectionName",
        a."AMAY_RollNo" AS "amaY_RollNo",
        a."ASMAY_Id" AS "asmaY_Id",
        e."ASMAY_Year" AS "asmaY_Year",
        b."AMST_AdmNo" AS "amsT_AdmNo"
    FROM "Adm_School_Y_Student" a 
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
    WHERE b."MI_Id" = p_miid::BIGINT 
        AND a."ASMAY_Id" = p_presentyear::BIGINT 
        AND a."ASMCL_Id" = p_presentclass::BIGINT 
        AND a."ASMS_Id" = p_presentsection::BIGINT 
        AND b."AMST_SOL" = 'S' 
        AND b."AMST_ActiveFlag" = 1 
        AND a."AMAY_ActiveFlag" = 1 
        AND a."AMST_Id" NOT IN (
            SELECT DISTINCT "Adm_M_Student"."AMST_Id" 
            FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
            WHERE "dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_promotedyear::BIGINT 
                AND "dbo"."Adm_School_Y_Student"."ASMCL_Id" = p_promotedclass::BIGINT 
                AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S' 
                AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1 
                AND "dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        );

END;
$$;