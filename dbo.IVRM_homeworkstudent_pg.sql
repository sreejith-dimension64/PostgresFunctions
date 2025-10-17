CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeworkstudent"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@IHW_Id" bigint,
    "@AMST_Id" bigint,
    "@Parameter" text
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentname" text,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."AMST_Id",
        (COALESCE(b."AMST_FirstName", '') || COALESCE(b."AMST_MiddleName", '') || COALESCE(b."AMST_LastName", '')) as studentname,
        d."ASMCL_ClassName",
        e."ASMC_SectionName"
    FROM "Adm_M_Student" b
    INNER JOIN "Adm_School_Y_Student" c ON b."AMST_Id" = c."AMST_Id"
    INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = c."ASMCL_Id" AND d."MI_Id" = "@MI_Id"
    INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = c."ASMS_Id" AND e."MI_Id" = "@MI_Id"
    WHERE c."ASMAY_Id" = "@ASMAY_Id" 
        AND c."AMST_Id" = "@AMST_Id" 
        AND b."MI_Id" = "@MI_Id" 
        AND c."AMAY_ActiveFlag" = 1 
        AND b."AMST_ActiveFlag" = 1 
        AND b."AMST_SOL" = 'S';
END;
$$;