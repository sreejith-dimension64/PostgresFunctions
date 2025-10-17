CREATE OR REPLACE FUNCTION "Adm_Yearwiseadmissioncount1"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT,
    "ASMCL_ID" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "Studentcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic TEXT;
BEGIN

    sqldynamic := 'SELECT B."ASMAY_Year", C."ASMCL_ClassName", COALESCE(COUNT(DISTINCT A."AMST_Id"), 0) AS "Studentcount"
    FROM "dbo"."Adm_M_Student" A
    INNER JOIN "Adm_School_M_Academic_Year" B ON B."ASMAY_Id" = A."ASMAY_Id" AND B."MI_Id" = A."MI_Id"
    INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = A."ASMCL_Id" AND C."MI_Id" = A."MI_Id"
    WHERE A."ASMAY_ID" IN (' || "ASMAY_ID" || ') AND A."MI_Id" = ' || "MI_ID" || ' AND C."ASMCL_Id" IN (' || "ASMCL_ID" || ')
    GROUP BY B."ASMAY_Year", C."ASMCL_ClassName"
    ORDER BY B."ASMAY_Year"';

    RETURN QUERY EXECUTE sqldynamic;

END;
$$;