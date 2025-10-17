CREATE OR REPLACE FUNCTION "Adm_Get_Classlist"(
    p_ASMAY_Id bigint,
    p_MI_Id bigint
)
RETURNS TABLE(
    "asmcL_Id" bigint,
    "asmcL_ClassName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."ASMCL_Id" AS "asmcL_Id",
        c."ASMCL_ClassName" AS "asmcL_ClassName"
    FROM "Adm_School_M_Class_Category" a 
    INNER JOIN "Adm_M_Category" b ON a."AMC_Id" = b."AMC_Id"
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
    WHERE a."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id;
END;
$$;