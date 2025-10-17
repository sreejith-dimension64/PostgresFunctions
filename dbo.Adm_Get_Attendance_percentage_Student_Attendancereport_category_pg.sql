CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Attendance_percentage_Student_Attendancereport_category"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@MONTHId" TEXT,
    "@AMC_Id" VARCHAR(20)
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
BEGIN
    CREATE TEMP TABLE "#NewTablemonthd"(
        "id" SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO "v_startDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT;

    SELECT "ASMAY_To_Date" INTO "v_endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT;

    WITH RECURSIVE CTE AS (
        SELECT "v_startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "v_endDate"::DATE
    )
    INSERT INTO "#NewTablemonthd"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INT AS "Month", 
           EXTRACT(YEAR FROM "Dates")::INT AS "Year"
    FROM CTE;

    SELECT "AYear" INTO "v_year"
    FROM "#NewTablemonthd" 
    WHERE "monthid" = "@monthid"::INT;

    RETURN QUERY
    SELECT 
        SUM("girslstotal") AS "girlstotal",
        SUM("girlsatt") AS "girlsatt",
        SUM("boystotal") AS "boystotal",
        SUM("boysatt") AS "boysatt",
        "a"."ASMAY_Id",
        "a"."ASMCL_Id",
        "a"."ASMS_Id",
        CAST(CASE WHEN SUM(NULLIF("girslstotal", 0)) IS NOT NULL AND SUM(NULLIF("girslstotal", 0)) <> 0 
             THEN (SUM("girlsatt") / SUM(NULLIF("girslstotal", 0)) * 100) 
             ELSE NULL END AS NUMERIC(18,2)) AS "girlsper",
        CAST(CASE WHEN SUM(NULLIF("boystotal", 0)) IS NOT NULL AND SUM(NULLIF("boystotal", 0)) <> 0 
             THEN (SUM("boysatt") / SUM(NULLIF("boystotal", 0)) * 100) 
             ELSE NULL END AS NUMERIC(18,2)) AS "boysper"
    FROM (
        SELECT 
            0 AS "girslstotal",
            0 AS "girlsatt",
            SUM("a"."ASA_ClassHeld") AS "boystotal",
            SUM("b"."ASA_Class_Attended") AS "boysatt",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."amst_id" = "c"."AMST_Id"
        INNER JOIN "dbo"."Adm_M_Category" ON "Adm_M_Category"."amc_id" = "d"."amc_id"
        WHERE "c"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "@MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "ASA_FromDate") = "@MONTHId"::INT 
            AND EXTRACT(YEAR FROM "ASA_FromDate") = "v_year" 
            AND "AMST_Sex" = 'Male' 
            AND "dbo"."Adm_M_Category"."AMC_Id" = "@AMC_Id"::BIGINT
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"

        UNION

        SELECT 
            SUM("a"."ASA_ClassHeld") AS "girslstotal",
            SUM("b"."ASA_Class_Attended") AS "girlsatt",
            0 AS "boystotal",
            0 AS "boysatt",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."amst_id" = "c"."AMST_Id"
        INNER JOIN "dbo"."Adm_M_Category" ON "Adm_M_Category"."amc_id" = "d"."amc_id"
        WHERE "c"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "c"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "c"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."MI_Id" = "@MI_Id"::BIGINT
            AND EXTRACT(MONTH FROM "ASA_FromDate") = "@MONTHId"::INT 
            AND EXTRACT(YEAR FROM "ASA_FromDate") = "v_year" 
            AND "AMST_Sex" = 'Female' 
            AND "dbo"."Adm_M_Category"."AMC_Id" = "@AMC_Id"::BIGINT
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id"
    ) "a"
    GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id";

END;
$$;