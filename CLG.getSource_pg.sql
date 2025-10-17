CREATE OR REPLACE FUNCTION "CLG"."getSource" (
    p_AMCST_Id bigint,
    p_str text
)
RETURNS SETOF "CLG"."Adm_College_Student_Source"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "CLG"."Adm_College_Student_Source" WHERE "AMCST_Id" = $1 AND "ASRS_Id" NOT IN (' || p_str || ')'
        USING p_AMCST_Id;
END;
$$;