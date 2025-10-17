CREATE OR REPLACE FUNCTION "dbo"."ClgEmailSmsCount" (
    p_MI_Id bigint
)
RETURNS TABLE (
    "IVRMM_Id" bigint,
    "IVRMM_ModuleName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a."IVRMM_Id", a."IVRMM_ModuleName"
    FROM "IVRM_Module" a 
    INNER JOIN "IVRM_Institution_Module" b ON a."IVRMM_Id" = b."IVRMM_Id"
    WHERE b."MI_Id" = p_MI_Id;
END;
$$;