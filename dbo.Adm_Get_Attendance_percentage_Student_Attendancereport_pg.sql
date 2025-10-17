CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Attendance_percentage_Student_Attendancereport"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "MONTHId" TEXT
)
RETURNS TABLE(
    "girlstotal" NUMERIC,
    "girlsatt" NUMERIC,
    "boystotal" NUMERIC,
    "boysatt" NUMERIC,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "girlsper" NUMERIC(18,2),
    "boysper" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "startDate" DATE;
    "endDate" DATE;
    "year" BIGINT;
BEGIN

    CREATE TEMP TABLE "NewTablemonthd"(
        "id" SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO "startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "MI_Id" AND "ASMAY_Id" = "ASMAY_Id"::BIGINT;
    
    SELECT "ASMAY_To_Date" INTO "endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "MI_Id" AND "ASMAY_Id" = "ASMAY_Id"::BIGINT;

    WITH RECURSIVE "CTE" AS (
        SELECT "startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE
        FROM "CTE"
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "endDate"::DATE
    )
    INSERT INTO "NewTablemonthd"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INT, EXTRACT(YEAR FROM "Dates")::INT
    FROM "CTE";

    SELECT "AYear" INTO "year" 
    FROM "NewTablemonthd" 
    WHERE "monthid" = "MONTHId"::INT;

    RETURN QUERY
    SELECT 
        SUM("a"."girslstotal") AS "girlstotal",
        SUM("a"."girlsatt") AS "girlsatt",
        SUM("a"."boystotal") AS "boystotal",
        SUM("a"."boysatt") AS "boysatt",
        "a"."ASMAY_Id",
        "a"."ASMCL_Id",
        "a"."ASMS_Id",
        CAST(CASE WHEN SUM("a"."girslstotal") > 0 THEN (SUM("a"."girlsatt") / SUM("a"."girslstotal") * 100) ELSE 0 END AS NUMERIC(18,2)) AS "girlsper",
        CAST(CASE WHEN SUM("a"."boystotal") > 0 THEN (SUM("a"."boysatt") / SUM("a"."boystotal") * 100) ELSE 0 END AS NUMERIC(18,2)) AS "boysper"
    FROM (
        SELECT 
            0::NUMERIC AS "girslstotal",
            0::NUMERIC AS "girlsatt",
            SUM("a"."ASA_ClassHeld") AS "boystotal",
            SUM("b"."ASA_Class_Attended") AS "boysatt",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."amst_id" = "c"."AMST_Id"
        WHERE "c"."ASMAY_Id" = "ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = "MONTHId"::INT 
            AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = "year" 
            AND "d"."AMST_Sex" = 'Male'
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"

        UNION

        SELECT 
            SUM("a"."ASA_ClassHeld") AS "girslstotal",
            SUM("b"."ASA_Class_Attended") AS "girlsatt",
            0::NUMERIC AS "boystotal",
            0::NUMERIC AS "boysatt",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."amst_id" = "c"."AMST_Id"
        WHERE "c"."ASMAY_Id" = "ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = "MONTHId"::INT 
            AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = "year" 
            AND "d"."AMST_Sex" = 'Female'
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"
    ) "a"
    GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id";

END;
$$;