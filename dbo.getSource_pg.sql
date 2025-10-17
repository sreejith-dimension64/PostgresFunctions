CREATE OR REPLACE FUNCTION "dbo"."getSource"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_str text
)
RETURNS SETOF "Adm_M_Student_Source"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "Adm_M_Student_Source" WHERE "MI_Id" = $1 AND "AMST_Id" = $2 AND "PAMS_Id" NOT IN (' || p_str || ')'
        USING p_MI_Id, p_AMST_Id;
END;
$$;