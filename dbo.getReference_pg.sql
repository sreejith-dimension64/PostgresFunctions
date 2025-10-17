CREATE OR REPLACE FUNCTION "dbo"."getReference"(
    "@MI_Id" bigint,
    "@AMST_Id" bigint,
    "@str" text
)
RETURNS SETOF "Adm_M_Student_Reference"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "Adm_M_Student_Reference" WHERE "MI_Id" = $1 AND "AMST_Id" = $2 AND "PAMR_Id" NOT IN (' || "@str" || ')'
        USING "@MI_Id", "@AMST_Id";
END;
$$;