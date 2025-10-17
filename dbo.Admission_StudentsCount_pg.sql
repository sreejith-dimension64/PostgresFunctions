CREATE OR REPLACE FUNCTION "dbo"."Admission_StudentsCount"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "FromDate" VARCHAR(10),
    "ToDate" VARCHAR(10)
)
RETURNS TABLE(
    "MI_Name" VARCHAR,
    "ASMAY_Year" VARCHAR,
    "ActiveCount" BIGINT,
    "LeftCount" BIGINT,
    "DeactiveCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Dynamic1" TEXT;
    "Dynamic2" TEXT;
    "Dynamic3" TEXT;
BEGIN

    DROP TABLE IF EXISTS "Adm_School_ActiveStudentsCount_Temp";
    DROP TABLE IF EXISTS "Adm_School_LeftStudentsCount_Temp";
    DROP TABLE IF EXISTS "Adm_School_DeactiveStudentsCount_Temp";

    "Dynamic1" := '
    CREATE TEMP TABLE "Adm_School_ActiveStudentsCount_Temp" AS
    SELECT "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year", COUNT(DISTINCT "ASYS"."AMST_Id") AS "ActiveCount"
    FROM "Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
    WHERE "AMS"."AMST_ActiveFlag" = 1 AND "ASYS"."AMAY_ActiveFlag" = 1 AND "AMS"."AMST_SOL" = ''S''
    AND "MI"."MI_Id" IN (' || "MI_Id" || ') AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
    GROUP BY "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year"';

    "Dynamic2" := '
    CREATE TEMP TABLE "Adm_School_LeftStudentsCount_Temp" AS
    SELECT "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year", COUNT(DISTINCT "ASYS"."AMST_Id") AS "LeftCount"
    FROM "Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
    WHERE "AMS"."AMST_ActiveFlag" = 0 AND "ASYS"."AMAY_ActiveFlag" = 0 AND "AMS"."AMST_SOL" = ''L''
    AND "MI"."MI_Id" IN (' || "MI_Id" || ') AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
    GROUP BY "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year"';

    "Dynamic3" := '
    CREATE TEMP TABLE "Adm_School_DeactiveStudentsCount_Temp" AS
    SELECT "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year", COUNT(DISTINCT "ASYS"."AMST_Id") AS "DeactiveCount"
    FROM "Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id"
    WHERE "AMS"."AMST_ActiveFlag" = 1 AND "ASYS"."AMAY_ActiveFlag" = 1 AND "AMS"."AMST_SOL" = ''D''
    AND "MI"."MI_Id" IN (' || "MI_Id" || ') AND "ASYS"."ASMAY_Id" IN (' || "ASMAY_Id" || ')
    GROUP BY "MI"."MI_Id", "MI"."MI_Name", "ASMAY"."ASMAY_Year"';

    EXECUTE "Dynamic1";
    EXECUTE "Dynamic2";
    EXECUTE "Dynamic3";

    RETURN QUERY
    SELECT "A"."MI_Name", "A"."ASMAY_Year", 
           COALESCE("A"."ActiveCount", 0) AS "ActiveCount",
           COALESCE("B"."LeftCount", 0) AS "LeftCount",
           COALESCE("C"."DeactiveCount", 0) AS "DeactiveCount"
    FROM "Adm_School_ActiveStudentsCount_Temp" "A"
    LEFT JOIN "Adm_School_LeftStudentsCount_Temp" "B" ON "A"."MI_Id" = "B"."MI_Id" AND "A"."ASMAY_Year" = "B"."ASMAY_Year"
    LEFT JOIN "Adm_School_DeactiveStudentsCount_Temp" "C" ON "C"."MI_Id" = "A"."MI_Id" AND "C"."ASMAY_Year" = "A"."ASMAY_Year"
    ORDER BY "A"."MI_Name", "A"."ASMAY_Year";

END;
$$;