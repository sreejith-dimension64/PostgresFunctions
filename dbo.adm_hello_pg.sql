CREATE OR REPLACE FUNCTION "dbo"."adm_hello" (
    "@mi_id" bigint, 
    "@yearid" bigint,
    "@sectionid" bigint,
    "@classid" bigint
)
RETURNS TABLE (
    "studentName" text,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "AMST_Id" bigint,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "mi_id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        COALESCE("a"."AMST_FirstName", '') || ' ' || COALESCE("a"."AMST_MiddleName", '') || ' ' || COALESCE("a"."AMST_LastName", '') AS "studentName",
        "c"."ASMCL_ClassName",
        "d"."ASMC_SectionName",
        "a"."AMST_Id",
        "b"."ASMAY_Id",
        "b"."ASMCL_Id",
        "b"."ASMS_Id",
        "a"."mi_id"
    FROM "adm_m_student" "a"
    INNER JOIN "adm_school_y_student" "b" ON "b"."amst_id" = "a"."amst_id"
    INNER JOIN "Adm_School_M_Class" "c" ON "b"."asmcl_id" = "c"."asmcl_id"
    INNER JOIN "Adm_School_M_Section" "d" ON "b"."ASMS_Id" = "d"."ASMS_Id"
    WHERE "a"."MI_Id" = "@mi_id" 
        AND "b"."ASMAY_Id" = "@yearid" 
        AND "b"."ASMCL_Id" = "@classid" 
        AND "b"."ASMS_Id" = "@sectionid";
END;
$$;