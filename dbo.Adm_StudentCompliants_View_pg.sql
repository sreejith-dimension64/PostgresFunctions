CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentCompliants_View"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE (
    "AMST_FirstName" TEXT,
    "ASCOMP_Complaints" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASCOMP_Id" INTEGER,
    "ASCOMP_Date" TIMESTAMP,
    "ASMAY_Year" VARCHAR,
    "ASMCL_Id" INTEGER,
    "ASMCL_ClassName" VARCHAR,
    "ASMS_Id" INTEGER,
    "ASMC_SectionName" VARCHAR,
    "ASCOMP_Subject" TEXT,
    "ASCOMP_FileName" TEXT,
    "ASCOMP_FilePath" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE WHEN f."AMST_FirstName" IS NULL OR f."AMST_FirstName" = '' THEN '' ELSE f."AMST_FirstName" END ||
        CASE WHEN f."AMST_MiddleName" IS NULL OR f."AMST_MiddleName" = '' OR f."AMST_MiddleName" = '0' THEN '' ELSE ' ' || f."AMST_MiddleName" END ||
        CASE WHEN f."AMST_LastName" IS NULL OR f."AMST_LastName" = '' OR f."AMST_LastName" = '0' THEN '' ELSE ' ' || f."AMST_LastName" END AS "AMST_FirstName",
        a."ASCOMP_Complaints"::TEXT,
        f."AMST_AdmNo",
        a."ASCOMP_Id",
        a."ASCOMP_Date",
        c."ASMAY_Year",
        b."ASMCL_Id",
        d."ASMCL_ClassName",
        b."ASMS_Id",
        e."ASMC_SectionName",
        a."ASCOMP_Subject"::TEXT,
        a."ASCOMP_FileName"::TEXT,
        a."ASCOMP_FilePath"::TEXT
    FROM "dbo"."Adm_Student_Complaints" a
    INNER JOIN "dbo"."Adm_M_Student" f ON a."AMST_Id" = f."AMST_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
    WHERE (a."ASCOMP_Date" BETWEEN c."ASMAY_From_Date" AND c."ASMAY_To_Date")
        AND b."ASMAY_Id" = p_ASMAY_Id::INTEGER
        AND a."AMST_Id" = p_AMST_Id::INTEGER;
END;
$$;