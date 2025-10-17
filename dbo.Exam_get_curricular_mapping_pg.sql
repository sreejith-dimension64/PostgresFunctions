CREATE OR REPLACE FUNCTION "dbo"."Exam_get_curricular_mapping"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMCL_Id" bigint,
    "asms_id" bigint,
    "ASMAY_Id" bigint,
    "C_Id" bigint,
    "Month_Id" bigint,
    "EMGR_Id" bigint,
    "C_Name" VARCHAR,
    "Month_name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."AMST_Id", 
        b."AMST_FirstName",
        b."AMST_MiddleName",
        b."AMST_LastName",
        b."AMST_AdmNo",
        c."ASMCL_ClassName",
        d."ASMC_SectionName",
        a."ASMCL_Id",
        a."asms_id",
        a."ASMAY_Id",
        f."C_Id",
        f."Month_Id",
        f."EMGR_Id",
        g."C_Name",
        h."Month_name"
    FROM "Adm_M_Student" AS b 
    JOIN "Adm_School_Y_Student" AS a ON 
        b."MI_Id" = "@MI_Id" 
        AND a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."ASMAY_Id" = b."ASMAY_Id" 
        AND a."AMAY_ActiveFlag" = 1 
        AND b."AMST_ActiveFlag" = 1 
        AND a."ASMCL_Id" = "@ASMCL_Id" 
        AND a."ASMS_Id" = "@ASMS_Id" 
        AND b."AMST_SOL" = 'S' 
        AND a."AMST_Id" = b."AMST_Id"
    JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
    JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
    LEFT OUTER JOIN "exm"."Exm_M_Curricular_Mapping" f ON a."AMST_Id" = f."AMST_Id"
    LEFT OUTER JOIN "exm"."Exm_M_Co_Curricular" g ON g."C_Id" = f."C_Id"
    LEFT OUTER JOIN "IVRM_Master_month" h ON h."IMM_Id" = f."Month_Id";
    
    RETURN;
END;
$$;