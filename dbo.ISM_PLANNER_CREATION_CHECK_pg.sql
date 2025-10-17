CREATE OR REPLACE FUNCTION "dbo"."ISM_PLANNER_CREATION_CHECK"(
    "MI_Id" VARCHAR(100),
    "HRMLY_Id" VARCHAR(100),
    "HRME_Id" bigint
)
RETURNS TABLE(
    "NOOFDAYS" bigint,
    "WORKINGHOURS" bigint,
    "DayName" varchar(100),
    "PDates" date
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "startDate" TIMESTAMP;
    "endDate" TIMESTAMP;
    "FromDate" date;
    "ToDate" date;
    "Rcount" int;
    "NOOFDAYS" bigint;
    "WORKINGHOURS" bigint;
    "DayName" varchar(100);
    "PDates" date;
    rec RECORD;
BEGIN

    SELECT CURRENT_DATE + (2 - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER) INTO "startDate";
    SELECT CURRENT_DATE + (8 - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER) INTO "endDate";

    DROP TABLE IF EXISTS temp_dates1new;
    DROP TABLE IF EXISTS "EmpPlannerDates_Tempnew";

    CREATE TEMP TABLE "EmpPlannerDates_Tempnew" (
        "NOOFDAYS" bigint,
        "WORKINGHOURS" bigint,
        "DayName" varchar(100),
        "PDates" date
    );

    CREATE TEMP TABLE temp_dates1new AS
    WITH RECURSIVE dates AS (
        SELECT "startDate"::DATE as "Date", TO_CHAR("startDate", 'Day') AS "DayName"
        UNION ALL
        SELECT ("Date" + INTERVAL '1 day')::DATE, TO_CHAR(("Date" + INTERVAL '1 day'), 'Day')
        FROM dates 
        WHERE "Date" < "endDate"::DATE
    )
    SELECT "Date", "DayName" 
    FROM dates 
    WHERE "Date" NOT IN (
        SELECT DISTINCT "FOMHWDD_FromDate"::DATE  
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" 
        WHERE "FOMHWDD_FromDate" BETWEEN "startDate" AND "endDate"  
        AND "FOHWDT_Id" = 1 
        AND "HRMLY_Id" = "ISM_PLANNER_CREATION_CHECK"."HRMLY_Id"
    );

    FOR rec IN 
        SELECT COUNT(*) AS "NOOFDAYS",
               (COUNT(*) * "ISMMWD_Hours") AS "WORKINGHOURS",
               A."DayName" AS "DayName",
               A."Date" as "PDates" 
        FROM temp_dates1new AS A
        INNER JOIN "FO"."FO_Master_Day" AS B ON SUBSTRING(TRIM(A."DayName"), 1, 3) = B."FOMD_DayName"
        INNER JOIN "ISM_Master_WorkingDays" AS C ON C."FOMD_Id" = B."FOMD_Id" 
        WHERE B."MI_Id" = "ISM_PLANNER_CREATION_CHECK"."MI_Id"
        GROUP BY A."DayName", "ISMMWD_Hours", A."Date"
    LOOP
        SELECT COUNT(*) INTO "Rcount"
        FROM "HR_Emp_Leave_Trans" LT 
        INNER JOIN "HR_Emp_Leave_Trans_Details" LTD ON LT."HRELT_Id" = LTD."HRELT_Id" 
        WHERE LT."MI_Id" = "ISM_PLANNER_CREATION_CHECK"."MI_Id" 
        AND "HRMLY_Id" = "ISM_PLANNER_CREATION_CHECK"."HRMLY_Id" 
        AND LT."HRME_Id" = "ISM_PLANNER_CREATION_CHECK"."HRME_Id" 
        AND "HRELTD_LWPFlag" = 0
        AND rec."PDates" BETWEEN "HRELTD_FromDate" AND "HRELTD_ToDate";

        IF ("Rcount" = 0) THEN
            INSERT INTO "EmpPlannerDates_Tempnew" VALUES(rec."NOOFDAYS", rec."WORKINGHOURS", rec."DayName", rec."PDates");
        END IF;
    END LOOP;

    RETURN QUERY 
    SELECT E."NOOFDAYS", E."WORKINGHOURS", E."DayName", E."PDates" 
    FROM "EmpPlannerDates_Tempnew" E 
    ORDER BY E."PDates" DESC 
    LIMIT 1;

END;
$$;