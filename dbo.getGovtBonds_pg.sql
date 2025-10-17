CREATE OR REPLACE FUNCTION "dbo"."getGovtBonds"(
    "MI_Id" bigint,
    "AMST_Id" bigint,
    "str" text
)
RETURNS SETOF "Adm_Master_Student_Bonds"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT * FROM "Adm_Master_Student_Bonds" WHERE "MI_Id" = %s AND "AMST_Id" = %s AND "IMGB_Id" NOT IN (%s)',
        "MI_Id",
        "AMST_Id",
        "str"
    );
END;
$$;