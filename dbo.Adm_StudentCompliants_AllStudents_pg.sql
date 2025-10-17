CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentCompliants_AllStudents"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT
)
RETURNS TABLE (
    "amsT_FirstName" TEXT,
    "amsT_AdmNo" VARCHAR,
    "asmcL_id" BIGINT,
    "asmS_Id" BIGINT,
    "asmcL_ClassName" VARCHAR,
    "asmC_SectionName" VARCHAR,
    "amsT_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        CASE WHEN c."AMST_FirstName" IS NULL OR c."AMST_FirstName" = '' THEN '' ELSE c."AMST_FirstName" END ||
        CASE WHEN c."AMST_MiddleName" IS NULL OR c."AMST_MiddleName" = '' OR c."AMST_MiddleName" = '0' THEN '' ELSE ' ' || c."AMST_MiddleName" END ||
        CASE WHEN c."AMST_LastName" IS NULL OR c."AMST_LastName" = '' OR c."AMST_LastName" = '0' THEN '' ELSE ' ' || c."AMST_LastName" END AS "amsT_FirstName",
        c."AMST_AdmNo" AS "amsT_AdmNo",
        b."ASMCL_Id" AS "asmcL_id",
        b."ASMS_Id" AS "asmS_Id",
        d."ASMCL_ClassName" AS "asmcL_ClassName",
        e."ASMC_SectionName" AS "asmC_SectionName",
        fd."AMST_Id" AS "amsT_Id"
    FROM "dbo"."Adm_School_M_Academic_Year" a
    INNER JOIN "dbo"."Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "dbo"."Adm_M_Student" c ON b."AMST_Id" = c."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "dbo"."Adm_Student_Complaints" fd ON b."AMST_Id" = fd."AMST_Id"
    WHERE b."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND a."Is_Active" = 1
        AND c."AMST_SOL" = 'S'
        AND d."ASMCL_ActiveFlag" = 1
        AND e."ASMC_ActiveFlag" = 1
        AND b."AMAY_ActiveFlag" = 1
        AND fd."MI_Id" = "@MI_Id"::BIGINT
        AND fd."ASCOMP_Date" BETWEEN a."ASMAY_From_Date" AND a."ASMAY_To_Date";
END;
$$;