CREATE OR REPLACE FUNCTION "Classwise_Students" (
    p_YEAR BIGINT,
    p_CLASS BIGINT,
    p_MI_ID BIGINT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "studentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_Photoname" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "YSTD"."AMST_Id",
        COALESCE("STD"."AMST_FirstName", '') || ' ' || COALESCE("STD"."AMST_MiddleName", '') || ' ' || COALESCE("STD"."AMST_LastName", '') AS "studentName",
        "STD"."AMST_AdmNo",
        "STD"."AMST_Photoname",
        "CL"."ASMCL_ClassName",
        "SC"."ASMC_SectionName"
    FROM "adm_m_student" "STD"
    INNER JOIN "Adm_School_Y_Student" "YSTD" ON "YSTD"."AMST_Id" = "STD"."AMST_Id" AND "YSTD"."ASMAY_Id" = "STD"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" "CL" ON "CL"."ASMCL_Id" = "YSTD"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "SC" ON "SC"."ASMS_Id" = "YSTD"."ASMS_Id"
    WHERE "STD"."AMST_ActiveFlag" = 1 
    AND "STD"."AMST_SOL" = 'S'
    AND "STD"."MI_ID" = p_MI_ID
    AND (p_CLASS = 0 OR "YSTD"."ASMCL_Id" = p_CLASS)
    AND "YSTD"."ASMAY_Id" = p_YEAR;
END;
$$;