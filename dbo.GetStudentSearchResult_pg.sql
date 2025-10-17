CREATE OR REPLACE FUNCTION "dbo"."GetStudentSearchResult"(
    "mywhere" VARCHAR(100)
)
RETURNS SETOF "dbo"."Adm_M_Student"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 'SELECT * FROM "dbo"."Adm_M_Student" WHERE ' || "mywhere";
END;
$$;