CREATE OR REPLACE FUNCTION "dbo"."Adm_ClasswiseActivedeactiveleftcount"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT,
    "ASMCL_Id" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "Totalstudentcount" BIGINT,
    "Active" BIGINT,
    "DeActive" BIGINT,
    "LeftStudents" BIGINT,
    "TransferStudents" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
BEGIN

    "sqldynamic" := 'SELECT DISTINCT "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", 
    COUNT(DISTINCT "ASYS"."AMST_ID") AS "Totalstudentcount",
    COALESCE(COUNT(CASE WHEN "AMS"."AMST_Sol" = ''S'' THEN 1 END), 0) AS "Active",
    COALESCE(COUNT(CASE WHEN "AMS"."AMST_Sol" = ''D'' THEN 1 END), 0) AS "DeActive",
    COALESCE(COUNT(CASE WHEN "AMS"."AMST_Sol" = ''L'' THEN 1 END), 0) AS "LeftStudents",
    COALESCE(COUNT(CASE WHEN "AMS"."AMST_Sol" = ''T'' THEN 1 END), 0) AS "TransferStudents"
    FROM "dbo"."Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = "ASMAY"."MI_Id"
    WHERE "AMS"."MI_Id" = ' || "MI_ID" || ' AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_ID" || ') AND "ASYS"."ASMCL_Id" IN (' || "ASMCL_Id" || ')
    GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName"
    ORDER BY "ASMC"."ASMCL_ClassName"';

    RETURN QUERY EXECUTE "sqldynamic";

END;
$$;