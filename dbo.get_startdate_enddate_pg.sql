CREATE OR REPLACE FUNCTION "dbo"."get_startdate_enddate"(
    p_monthid bigint,
    p_miid text,
    p_asmayid text
)
RETURNS TABLE(startdate date, enddate date)
LANGUAGE plpgsql
AS $$
DECLARE
    v_year bigint;
    v_startDate date;
    v_endDate date;
    v_temp_table_exists boolean;
BEGIN
    v_year := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

    CREATE TEMP TABLE IF NOT EXISTS "NewTable"(
        id SERIAL NOT NULL,
        "MonthId" int,
        "AYear" int
    ) ON COMMIT DROP;

    DELETE FROM "NewTable";

    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid;
    
    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid;

    INSERT INTO "NewTable"("MonthId", "AYear")
    WITH RECURSIVE CTE AS (
        SELECT v_startDate::date AS Dates
        UNION ALL
        SELECT (Dates + INTERVAL '1 month')::date 
        FROM CTE 
        WHERE (Dates + INTERVAL '1 month')::date <= v_endDate::date
    )
    SELECT EXTRACT(MONTH FROM Dates)::int, EXTRACT(YEAR FROM Dates)::int 
    FROM CTE;

    SELECT "AYear" INTO v_year 
    FROM "NewTable" 
    WHERE "MonthId" = p_monthid;

    RETURN QUERY
    SELECT 
        (DATE '1900-01-01' + (v_year - 1900) * INTERVAL '1 year' + (p_monthid - 1) * INTERVAL '1 month')::date AS startdate,
        (DATE '1900-01-01' + (v_year - 1900) * INTERVAL '1 year' + p_monthid * INTERVAL '1 month' - INTERVAL '1 day')::date AS enddate;

    DROP TABLE IF EXISTS "NewTable";
END;
$$;