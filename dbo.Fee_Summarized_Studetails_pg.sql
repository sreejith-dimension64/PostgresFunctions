CREATE OR REPLACE FUNCTION "dbo"."Fee_Summarized_Studetails" (
    "@mi_id" BIGINT,
    "@amay_id" BIGINT,
    "@asmcl_id" BIGINT,
    "@asms_id" BIGINT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "StudentName" TEXT,
    "AMAY_RollNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMS"."AMST_Id",
        "AMS"."AMST_AdmNo",
        (COALESCE("AMS"."AMST_FirstName", '') || '' || COALESCE("AMS"."AMST_MiddleName", '') || '' || COALESCE("AMS"."AMST_LastName", '')) AS "StudentName",
        "ASYS"."AMAY_RollNo",
        "ASMC"."ASMCL_ClassName",
        "ASMS"."ASMC_SectionName"
    FROM "dbo"."Fee_Y_Payment" "FYP"
    INNER JOIN "dbo"."Adm_M_Student" "AMS" 
        ON "AMS"."MI_Id" = "FYP"."MI_Id" 
        AND "FYP"."ASMAY_Id" = "AMS"."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" "ASYS" 
        ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" 
        AND "ASYS"."ASMCL_Id" = "AMS"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" "ASMC" 
        ON "ASMC"."ASMCL_Id" = "AMS"."ASMCL_Id" 
        AND "AMS"."MI_Id" = "ASMC"."MI_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" "ASMS" 
        ON "ASMS"."MI_Id" = "AMS"."MI_Id" 
        AND "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
    WHERE "AMS"."MI_Id" = "@mi_id" 
        AND "ASYS"."ASMAY_Id" = "@amay_id" 
        AND "ASYS"."ASMCL_Id" = "@asmcl_id" 
        AND "ASYS"."ASMS_Id" = "@asms_id";
END;
$$;