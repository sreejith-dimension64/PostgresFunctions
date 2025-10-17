CREATE OR REPLACE FUNCTION "dbo"."IVRM_Interaction_StudentList"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@ASMCL_Id" VARCHAR(20),
    "@ASMS_Id" VARCHAR(20)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "studentName" TEXT,
    "AMST_AdmNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMS"."AMST_Id",
        "AMS"."ASMCL_Id",
        "AMS"."ASMS_Id",
        (CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
        CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' OR "AMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMST_MiddleName" END ||
        CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '' OR "AMST_LastName" = '0' THEN '' ELSE ' ' || "AMST_LastName" END) AS "studentName",
        "ADM"."AMST_AdmNo"
    FROM "Adm_M_Student" "ADM"
    INNER JOIN "Adm_School_Y_Student" "AMS" ON "AMS"."AMST_Id" = "ADM"."AMST_Id" AND "AMS"."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Academic_Year" "AMY" ON "AMY"."ASMAY_Id" = "AMS"."ASMAY_Id" AND "AMY"."ASMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" "AMC" ON "AMC"."ASMCL_Id" = "AMS"."ASMCL_Id" AND "AMC"."ASMCL_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Section" "AMSC" ON "AMSC"."ASMS_Id" = "AMS"."ASMS_Id" AND "AMC"."ASMCL_ActiveFlag" = 1
    WHERE "ADM"."AMST_ActiveFlag" = 1 
        AND "ADM"."AMST_SOL" = 'S' 
        AND "ADM"."MI_Id" = "@MI_Id" 
        AND "AMS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "AMS"."ASMCL_Id" = "@ASMCL_Id" 
        AND "AMS"."ASMS_Id" = "@ASMS_Id"
    ORDER BY "studentName";
    
    RETURN;
END;
$$;