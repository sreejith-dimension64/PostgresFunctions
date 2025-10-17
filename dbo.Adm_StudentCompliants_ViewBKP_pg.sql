CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentCompliants_ViewBKP"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE (
    "AMST_FirstName" TEXT,
    "ASCOMP_Complaints" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASCOMP_Id" BIGINT,
    "ASCOMP_Date" TIMESTAMP,
    "ASMAY_Year" VARCHAR,
    "ASMCL_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMS_Id" BIGINT,
    "ASMC_SectionName" VARCHAR,
    "ASCOMP_Subject" VARCHAR,
    "ASCOMP_FileName" VARCHAR,
    "ASCOMP_FilePath" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (CASE WHEN "f"."AMST_FirstName" IS NULL OR "f"."AMST_FirstName" = '' THEN '' ELSE "f"."AMST_FirstName" END ||
        CASE WHEN "f"."AMST_MiddleName" IS NULL OR "f"."AMST_MiddleName" = '' OR "f"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "f"."AMST_MiddleName" END ||
        CASE WHEN "f"."AMST_LastName" IS NULL OR "f"."AMST_LastName" = '' OR "f"."AMST_LastName" = '0' THEN '' ELSE ' ' || "f"."AMST_LastName" END)::TEXT AS "AMST_FirstName",
        "a"."ASCOMP_Complaints",
        "f"."AMST_AdmNo",
        "a"."ASCOMP_Id",
        "a"."ASCOMP_Date",
        "c"."ASMAY_Year",
        "b"."ASMCL_Id",
        "d"."ASMCL_ClassName",
        "b"."ASMS_Id",
        "e"."ASMC_SectionName",
        "a"."ASCOMP_Subject",
        "a"."ASCOMP_FileName",
        "a"."ASCOMP_FilePath"
    FROM "Adm_Student_Complaints" "a"
    INNER JOIN "Adm_M_Student" "f" ON "a"."AMST_Id" = "f"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" "d" ON "b"."ASMCL_Id" = "d"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "e" ON "b"."ASMS_Id" = "e"."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "c" ON "b"."ASMAY_Id" = "c"."ASMAY_Id"
    WHERE ("a"."ASCOMP_Date" BETWEEN "c"."ASMAY_From_Date" AND "c"."ASMAY_To_Date") 
        AND "b"."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND "a"."AMST_Id" = "@AMST_Id"::BIGINT
        AND "a"."ASCOMP_ActiveFlg" = 1;
END;
$$;