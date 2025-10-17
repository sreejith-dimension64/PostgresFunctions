CREATE OR REPLACE FUNCTION "dbo"."Chairman_Castewise_total_student"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_ASMCL_Id INT,
    p_ASMS_Id INT
)
RETURNS TABLE(
    castid INT,
    caste VARCHAR,
    total BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."imc_id" AS castid,
        c."IMC_CasteName" AS caste,
        COUNT(a."amst_id") AS total
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id"
    INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."AMST_SOL" = 'S' 
        AND a."AMST_ActiveFlag" = 1 
        AND b."AMAY_ActiveFlag" = 1 
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND b."ASMS_Id" = p_ASMS_Id 
        AND b."ASMCL_Id" = p_ASMCL_Id
    GROUP BY c."imc_id", c."IMC_CasteName"
    ORDER BY c."IMC_CasteName";
END;
$$;