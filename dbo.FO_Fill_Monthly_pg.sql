CREATE OR REPLACE FUNCTION "dbo"."FO_Fill_Monthly"(
    "Year" int,
    "FirstDateOfYear" timestamp,
    "LastDateOfYear" timestamp
)
RETURNS TABLE("Date" date, "Dayname" text)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '%', "FirstDateOfYear";
    RAISE NOTICE '%', "LastDateOfYear";
    
    RETURN QUERY
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            "FirstDateOfYear" AS "FromDate",
            TO_CHAR("FirstDateOfYear", 'Day') AS "Dayname"
        UNION ALL
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::timestamp AS "FromDate",
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') <= "LastDateOfYear"
    )
    SELECT 
        cte."FromDate"::date AS "Date",
        cte."Dayname"
    FROM cte;
END;
$$;