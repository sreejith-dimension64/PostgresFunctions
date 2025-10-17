CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Attendance_percentage_Student_Attendancereport_bkp"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@MONTHId" TEXT
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
    "v_startDate" DATE;
    "v_endDate" DATE;
    "v_year" BIGINT;
    "v_monthid_int" INTEGER;
BEGIN
    CREATE TEMP TABLE "#NewTablemonthd"(
        "id" SERIAL NOT NULL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    ) ON COMMIT DROP;

    "v_monthid_int" := "@MONTHId"::INTEGER;

    SELECT "ASMAY_From_Date" INTO "v_startDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT;

    SELECT "ASMAY_To_Date" INTO "v_endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT;

    WITH RECURSIVE CTE AS (
        SELECT "v_startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 MONTH')::DATE
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 MONTH')::DATE <= "v_endDate"::DATE
    )
    INSERT INTO "#NewTablemonthd"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INTEGER AS "Month",
           EXTRACT(YEAR FROM "Dates")::INTEGER AS "Year"
    FROM CTE;

    SELECT "AYear" INTO "v_year"
    FROM "#NewTablemonthd" 
    WHERE "monthid" = "v_monthid_int";

    RETURN QUERY
    SELECT 
        SUM("girslstotal") AS "girlstotal",
        SUM("girlsatt") AS "girlsatt",
        SUM("boystotal") AS "boystotal",
        SUM("boysatt") AS "boysatt",
        "a"."ASMAY_Id",
        "a"."ASMCL_Id",
        "a"."ASMS_Id",
        CAST((SUM("girlsatt") / NULLIF(SUM("girslstotal"), 0) * 100) AS NUMERIC(18,2)) AS "girlsper",
        CAST((SUM("boysatt") / NULLIF(SUM("boystotal"), 0) * 100) AS NUMERIC(18,2)) AS "boysper"
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
        WHERE "c"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "@MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = "v_monthid_int" 
            AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = "v_year" 
            AND "d"."AMST_Sex" = 'Male'
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"

        UNION

        SELECT 
            SUM("a"."ASA_ClassHeld") AS "girslstotal",
            SUM("b"."ASA_Class_Attended") AS "girlsatt",
            SUM("a"."ASA_ClassHeld") AS "boystotal",
            SUM("b"."ASA_Class_Attended") AS "boysatt",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."amst_id" = "c"."AMST_Id"
        WHERE "c"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "@MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = "v_monthid_int" 
            AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = "v_year" 
            AND "d"."AMST_Sex" = 'Female'
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"
    ) "a"
    GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id";

    RETURN;
END;
$$;