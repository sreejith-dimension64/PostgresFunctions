CREATE OR REPLACE FUNCTION "CLG"."getReference"(
    p_AMCST_Id bigint,
    p_str text
)
RETURNS SETOF "CLG"."Adm_College_Student_Reference"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "CLG"."Adm_College_Student_Reference" WHERE "AMCST_Id" = $1 AND "ASRR_Id" NOT IN (' || p_str || ')'
        USING p_AMCST_Id;
END;
$$;