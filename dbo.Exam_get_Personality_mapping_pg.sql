CREATE OR REPLACE FUNCTION "dbo"."Exam_get_Personality_mapping"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "AMST_LastName" varchar,
    "AMST_AdmNo" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "ASMCL_Id" bigint,
    "asms_id" bigint,
    "ASMAY_Id" bigint,
    "Per_Id" bigint,
    "Month_Id" bigint,
    "Remarks_Id" bigint,
    "Per_Name" varchar,
    "Month_name" varchar,
    "Remarks_Name" varchar
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
        f."Per_Id",
        f."Month_Id",
        f."Remarks_Id",
        g."Per_Name",
        h."Month_name",
        i."Remarks_Name"
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
    LEFT OUTER JOIN "exm"."Exm_M_Personality_Mapping" f ON a."AMST_Id" = f."AMST_Id"
    LEFT OUTER JOIN "exm"."Exm_M_Personality" g ON g."Per_Id" = f."Per_Id"
    LEFT OUTER JOIN "IVRM_Master_month" h ON h."IMM_Id" = f."Month_Id"
    LEFT OUTER JOIN "exm"."Exm_M_Progresscard_Remarks" i ON i."Remarks_Id" = f."Remarks_Id";
END;
$$;