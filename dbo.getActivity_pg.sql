CREATE OR REPLACE FUNCTION "dbo"."getActivity"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_str text
)
RETURNS SETOF "Adm_M_Student_Activity"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "Adm_M_Student_Activity" WHERE "MI_Id"=' || p_MI_Id || 
        ' AND "AMST_Id"=' || p_AMST_Id || 
        ' AND "AMA_Id" NOT IN (' || p_str || ')';
END;
$$;