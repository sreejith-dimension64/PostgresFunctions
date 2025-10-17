CREATE OR REPLACE FUNCTION "dbo"."getStudentSearchData"(
    "Where" TEXT,
    "MI_Id" TEXT
)
RETURNS SETOF "dbo"."Adm_M_Student"
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
        'SELECT * FROM "dbo"."Adm_M_Student" WHERE "MI_Id" = ' || "MI_Id" || ' AND ' || "Where";
END;
$$;