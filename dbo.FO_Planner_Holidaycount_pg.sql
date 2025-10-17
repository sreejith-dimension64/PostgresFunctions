CREATE OR REPLACE FUNCTION "dbo"."FO_Planner_Holidaycount"(
    "Plstart" TIMESTAMP,
    "Plend" TIMESTAMP,
    "MI_Id" BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    "FOMHWDD_FromDate" DATE;
    "FOMHWDD_ToDate" DATE;
    "daydiff" INTEGER;
    "Rcount" INTEGER;
    "i" INTEGER;
    "j" INTEGER;
    "dcount" INTEGER;
    "dcount_new" INTEGER;
    "DayName" VARCHAR(50);
    "Holidayscount" INTEGER;
    holiday_rec RECORD;
BEGIN
    -- Exec FO_Planner_Holidaycount '2020-03-16','2020-03-21',17

    "daydiff" := 0;
    "dcount" := 0;
    "dcount_new" := 0;
    "Holidayscount" := 0;

    DROP TABLE IF EXISTS "PlannerDates_Temp";

    CREATE TEMP TABLE "PlannerDates_Temp"(
        "id" SERIAL NOT NULL,
        "PDate" DATE
    );

    WITH CTE AS (
        SELECT CAST("Plstart" AS DATE) AS "Dates"
        UNION ALL
        SELECT CAST("Dates" + INTERVAL '1 day' AS DATE) AS "Dates" 
        FROM CTE 
        WHERE CAST("Dates" AS DATE) < CAST("Plend" AS DATE)
    )
    INSERT INTO "PlannerDates_Temp"("PDate")
    SELECT "Dates" FROM CTE WHERE TO_CHAR("Dates", 'Day') NOT LIKE 'Sunday%';

    FOR holiday_rec IN
        SELECT 
            CAST("FOMHWDD_FromDate" AS DATE) AS "FromDate",
            CAST("FOMHWDD_ToDate" AS DATE) AS "ToDate",
            CAST("FOMHWDD_ToDate" AS DATE) - CAST("FOMHWDD_FromDate" AS DATE) AS "daydiff"
        FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
        INNER JOIN "HR_Master_LeaveYear" b ON a."HRMLY_Id" = b."HRMLY_Id"
        INNER JOIN "fo"."FO_HolidayWorkingDay_Type" c ON a."MI_Id" = c."MI_Id"
        WHERE a."FOHWDT_Id" = c."FOHWDT_Id" 
            AND "FOHTWD_HolidayWDTypeFlag" = 'PH' 
            AND "FOMHWDD_Name" != 'Sunday'
            AND CAST(CURRENT_TIMESTAMP AS DATE) BETWEEN CAST(b."HRMLY_FromDate" AS DATE) AND CAST(b."HRMLY_ToDate" AS DATE)
            AND a."MI_Id" = "MI_Id"
            AND (CAST("FOMHWDD_FromDate" AS DATE) BETWEEN "Plstart" AND "Plend")
    LOOP
        "FOMHWDD_FromDate" := holiday_rec."FromDate";
        "FOMHWDD_ToDate" := holiday_rec."ToDate";
        "daydiff" := holiday_rec."daydiff";

        RAISE NOTICE 'FromDate %', "FOMHWDD_FromDate";
        RAISE NOTICE 'ToDate %', "FOMHWDD_ToDate";
        RAISE NOTICE 'daydiff %', "daydiff";

        SELECT COUNT(*) INTO "dcount"
        FROM "PlannerDates_Temp"
        WHERE "PDate" BETWEEN "FOMHWDD_FromDate" AND "FOMHWDD_ToDate";

        "Holidayscount" := "Holidayscount" + "dcount";

        RAISE NOTICE '@Holidayscount: %', "Holidayscount";

    END LOOP;

    RETURN "Holidayscount";

END;
$$;