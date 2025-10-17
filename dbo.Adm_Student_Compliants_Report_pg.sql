CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Compliants_Report"(
    "@MI_Id" TEXT,
    "@FromDate" TEXT,
    "@ToDate" TEXT
)
RETURNS TABLE(
    "AMST_FirstName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_id" BIGINT,
    "ASMS_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_Id" BIGINT,
    "ASCOMP_Complaints" TEXT,
    "ASCOMP_Date" VARCHAR,
    "ASMAY_Year" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        (CASE WHEN c."AMST_FirstName" IS NULL OR c."AMST_FirstName" = '' THEN '' ELSE c."AMST_FirstName" END ||
        CASE WHEN c."AMST_MiddleName" IS NULL OR c."AMST_MiddleName" = '' OR c."AMST_MiddleName" = '0' THEN '' ELSE ' ' || c."AMST_MiddleName" END ||
        CASE WHEN c."AMST_LastName" IS NULL OR c."AMST_LastName" = '' OR c."AMST_LastName" = '0' THEN '' ELSE ' ' || c."AMST_LastName" END)::TEXT AS "AMST_FirstName",
        c."AMST_AdmNo",
        b."ASMCL_id",
        b."ASMS_Id",
        d."ASMCL_ClassName",
        e."ASMC_SectionName",
        fd."AMST_Id",
        fd."ASCOMP_Complaints",
        TO_CHAR(fd."ASCOMP_Date", 'DD/MM/YYYY') AS "ASCOMP_Date",
        a."ASMAY_Year"
    FROM "dbo"."Adm_School_M_Academic_Year" a
    INNER JOIN "dbo"."Adm_School_Y_Student" b ON a."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "dbo"."Adm_M_Student" c ON b."AMST_Id" = c."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "dbo"."Adm_Student_Complaints" fd ON b."AMST_Id" = fd."AMST_Id"
    WHERE a."Is_Active" = 1 
    AND b."AMAY_ActiveFlag" = 1
    AND fd."MI_Id" = "@MI_Id"
    AND fd."ASCOMP_Date" BETWEEN CAST("@FromDate" AS DATE) AND CAST("@ToDate" AS DATE)
    AND fd."ASCOMP_Date" BETWEEN a."ASMAY_From_Date" AND a."ASMAY_To_Date";
END;
$$;