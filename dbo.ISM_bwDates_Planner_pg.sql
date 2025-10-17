CREATE OR REPLACE FUNCTION "dbo"."ISM_bwDates_Planner"(
    "MI_Id" VARCHAR(100),
    "HRMLY_Id" VARCHAR(100),
    "startDate" TIMESTAMP,
    "endDate" TIMESTAMP,
    "HRME_Id" BIGINT
)
RETURNS TABLE(
    "NOOFDAYS" BIGINT,
    "WORKINGHOURS" BIGINT,
    "DayName" VARCHAR(100),
    "PDates" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "FromDate" DATE;
    "ToDate" DATE;
    "Rcount" INT;
    "v_NOOFDAYS" BIGINT;
    "v_WORKINGHOURS" BIGINT;
    "v_DayName" VARCHAR(100);
    "v_PDates" DATE;
    plannerdates_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS temp_dates1;
    DROP TABLE IF EXISTS "EmpPlannerDates_Temp";

    CREATE TEMP TABLE "EmpPlannerDates_Temp" (
        "NOOFDAYS" BIGINT,
        "WORKINGHOURS" BIGINT,
        "DayName" VARCHAR(100),
        "PDates" DATE
    );

    CREATE TEMP TABLE temp_dates1 AS
    WITH RECURSIVE dates AS (
        SELECT "startDate"::DATE AS "Date", TO_CHAR("startDate", 'Day') AS "DayName"
        UNION ALL
        SELECT ("Date" + INTERVAL '1 day')::DATE, TO_CHAR("Date" + INTERVAL '1 day', 'Day')
        FROM dates
        WHERE "Date" < "endDate"::DATE
    )
    SELECT "Date"::DATE AS "Date", TRIM("DayName") AS "DayName"
    FROM dates
    WHERE "Date"::DATE NOT IN (
        SELECT DISTINCT "FOMHWDD_FromDate"::DATE
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates"
        WHERE "FOMHWDD_FromDate" BETWEEN "startDate" AND "endDate"
        AND "FOHWDT_Id" = 1
        AND "HRMLY_Id" = "ISM_bwDates_Planner"."HRMLY_Id"
    );

    FOR plannerdates_rec IN
        SELECT COUNT(*) AS "NOOFDAYS",
               (COUNT(*) * "C"."ISMMWD_Hours") AS "WORKINGHOURS",
               "A"."DayName",
               "A"."Date" AS "PDates"
        FROM temp_dates1 AS "A"
        INNER JOIN "FO"."FO_Master_Day" AS "B" ON SUBSTRING("A"."DayName", 1, 3) = "B"."FOMD_DayName"
        INNER JOIN "ISM_Master_WorkingDays" AS "C" ON "C"."FOMD_Id" = "B"."FOMD_Id"
        WHERE "B"."MI_Id" = "ISM_bwDates_Planner"."MI_Id"
        GROUP BY "A"."DayName", "C"."ISMMWD_Hours", "A"."Date"
    LOOP
        "v_NOOFDAYS" := plannerdates_rec."NOOFDAYS";
        "v_WORKINGHOURS" := plannerdates_rec."WORKINGHOURS";
        "v_DayName" := plannerdates_rec."DayName";
        "v_PDates" := plannerdates_rec."PDates";

        SELECT COUNT(*) INTO "Rcount"
        FROM "HR_Emp_Leave_Trans" "LT"
        INNER JOIN "HR_Emp_Leave_Trans_Details" "LTD" ON "LT"."HRELT_Id" = "LTD"."HRELT_Id"
        WHERE "LT"."MI_Id" = "ISM_bwDates_Planner"."MI_Id"
        AND "LT"."HRMLY_Id" = "ISM_bwDates_Planner"."HRMLY_Id"
        AND "LT"."HRME_Id" = "ISM_bwDates_Planner"."HRME_Id"
        AND "LTD"."HRELTD_LWPFlag" = 0
        AND "v_PDates" BETWEEN "LTD"."HRELTD_FromDate" AND "LTD"."HRELTD_ToDate";

        IF ("Rcount" = 0) THEN
            INSERT INTO "EmpPlannerDates_Temp" VALUES("v_NOOFDAYS", "v_WORKINGHOURS", "v_DayName", "v_PDates");
        END IF;

    END LOOP;

    RETURN QUERY
    SELECT "EmpPlannerDates_Temp"."NOOFDAYS",
           "EmpPlannerDates_Temp"."WORKINGHOURS",
           "EmpPlannerDates_Temp"."DayName",
           "EmpPlannerDates_Temp"."PDates"
    FROM "EmpPlannerDates_Temp"
    ORDER BY "EmpPlannerDates_Temp"."PDates";

END;
$$;