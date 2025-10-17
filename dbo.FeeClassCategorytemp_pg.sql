CREATE OR REPLACE FUNCTION "dbo"."FeeClassCategorytemp" (
    p_ASMAY_ID bigint,
    p_MI_Id bigint
)
RETURNS TABLE (
    "ASMCL_Id" bigint
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT cls."ASMCL_Id" 
    FROM "Adm_School_M_Class_Category" cat
    INNER JOIN "Adm_School_M_Class" cls ON cat."ASMCL_Id" = cls."ASMCL_Id"
    WHERE cat."MI_Id" = p_MI_Id 
        AND cat."ASMAY_Id" = p_ASMAY_ID 
        AND cls."ASMCL_ActiveFlag" = 1;
END;
$$;