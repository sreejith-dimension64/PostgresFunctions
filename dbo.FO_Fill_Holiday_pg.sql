CREATE OR REPLACE FUNCTION "dbo"."FO_Fill_Holiday"("Year" integer)
RETURNS TABLE("Date" varchar(10), "Dayname" text)
LANGUAGE plpgsql
AS $$
DECLARE
    "FirstDateOfYear" TIMESTAMP;
    "LastDateOfYear" TIMESTAMP;
BEGIN
    SELECT MAKE_DATE(1900, 1, 1) + (("Year" - 1900) * INTERVAL '1 year') INTO "FirstDateOfYear";
    SELECT MAKE_DATE(1900, 1, 1) + (("Year" - 1900 + 1) * INTERVAL '1 year') INTO "LastDateOfYear";
    
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
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') < "LastDateOfYear"
    )
    SELECT 
        TO_CHAR("FromDate", 'DD/MM/YYYY') AS "Date",
        "Dayname"
    FROM cte;
    
    RETURN;
END;
$$;