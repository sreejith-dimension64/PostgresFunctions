CREATE OR REPLACE FUNCTION "dbo"."ISM_bwDates"
(
    p_startDate TIMESTAMP,
    p_endDate TIMESTAMP
)
RETURNS TABLE
(
    "NOOFDAYS" BIGINT,
    "WORKINGHOURS" NUMERIC,
    "DayName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS temp_dates1;

    CREATE TEMP TABLE temp_dates1
    (
        "Date" DATE,
        "DayName" TEXT
    );

    WITH RECURSIVE dates AS 
    (
        SELECT p_startDate as "Date", TO_CHAR(p_startDate, 'Day') AS "DayName"
        UNION ALL
        SELECT "Date" + INTERVAL '1 day', TO_CHAR("Date" + INTERVAL '1 day', 'Day') AS "DayName"
        FROM dates 
        WHERE "Date" < p_endDate
    )
    INSERT INTO temp_dates1
    SELECT CAST("Date" AS DATE) as "Date", TRIM("DayName") as "DayName"
    FROM dates 
    WHERE CAST("Date" AS DATE) NOT IN (
        SELECT DISTINCT CAST("FOMHWDD_FromDate" AS DATE)
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" 
        WHERE "FOMHWDD_FromDate" BETWEEN p_startDate AND p_endDate 
        AND "FOHWDT_Id" = 1 
        AND "HRMLY_Id" = 18
    );

    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT AS "NOOFDAYS",
        (COUNT(*) * "ISMMWD_Hours")::NUMERIC AS "WORKINGHOURS",
        A."DayName"
    FROM temp_dates1 AS A
    INNER JOIN "FO"."FO_Master_Day" AS B ON SUBSTRING(A."DayName", 1, 3) = B."FOMD_DayName"
    INNER JOIN "ISM_Master_WorkingDays" AS C ON C."FOMD_Id" = B."FOMD_Id"
    WHERE B."MI_Id" = 4
    GROUP BY A."DayName", "ISMMWD_Hours";

END;
$$;