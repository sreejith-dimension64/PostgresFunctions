CREATE OR REPLACE FUNCTION "dbo"."dynamicparamgen"(
    "class" VARCHAR,
    "year" VARCHAR,
    "att" VARCHAR,
    "tableparam" VARCHAR(5000)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "value" VARCHAR(5000);
    "pivot" VARCHAR(5000);
    "sqlText" TEXT;
BEGIN
    "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."adm_M_student" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id" WHERE "asmay_id" = 10';
    
    RETURN QUERY EXECUTE "sqlText";
    
    RETURN;
END;
$$;