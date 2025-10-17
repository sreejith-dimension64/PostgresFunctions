CREATE OR REPLACE FUNCTION "dbo"."FO_Fill_HolidayWorkingDay"(
    p_MI_Id bigint,
    p_Year integer
)
RETURNS TABLE(
    "Date" varchar(10),
    "Dayname" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FirstDateOfYear TIMESTAMP;
    v_LastDateOfYear TIMESTAMP;
BEGIN

    SELECT "HRMLY_FromDate", "HRMLY_ToDate"
    INTO v_FirstDateOfYear, v_LastDateOfYear
    FROM "HR_Master_LeaveYear"
    WHERE "HRMLY_ActiveFlag" = 1 
        AND "MI_Id" = p_MI_Id 
        AND "HRMLY_Id" = p_Year;

    RETURN QUERY
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            v_FirstDateOfYear AS "FromDate",
            TO_CHAR(v_FirstDateOfYear, 'Day') AS "Dayname"
        
        UNION ALL
        
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte
        WHERE (cte."FromDate" + INTERVAL '1 day') <= v_LastDateOfYear
    )
    SELECT 
        TO_CHAR("FromDate", 'DD/MM/YYYY') AS "Date",
        TRIM("Dayname") AS "Dayname"
    FROM cte;

END;
$$;