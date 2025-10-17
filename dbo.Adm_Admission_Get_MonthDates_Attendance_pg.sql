CREATE OR REPLACE FUNCTION "dbo"."Adm_Admission_Get_MonthDates_Attendance"(
    p_mi_id TEXT, 
    p_asmay_id TEXT,
    p_monthid TEXT
)
RETURNS TABLE(day INT, date VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE
    v_startDate DATE;
    v_endDate DATE;
    v_fromdate DATE;
    v_todate DATE;
    v_year VARCHAR(200);
    v_monthid_int INT;
    v_year_int INT;
    temp_date DATE;
BEGIN
    -- Create temporary table to store month data
    CREATE TEMP TABLE IF NOT EXISTS "NewTablemonth_New_att"(
        id SERIAL NOT NULL,
        "MonthId_New" INT,
        "AYear_New" INT
    ) ON COMMIT DROP;

    -- Get start and end dates
    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;
    
    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;

    -- Insert month and year data using recursive CTE
    WITH RECURSIVE CTE AS (
        SELECT v_startDate::DATE AS Dates
        UNION ALL
        SELECT (Dates + INTERVAL '1 month')::DATE
        FROM CTE
        WHERE Dates::DATE <= v_endDate::DATE
    )
    INSERT INTO "NewTablemonth_New_att"("MonthId_New", "AYear_New")
    SELECT EXTRACT(MONTH FROM Dates)::INT, EXTRACT(YEAR FROM Dates)::INT FROM CTE;

    -- Get year for the specified month
    SELECT "AYear_New" INTO v_year 
    FROM "NewTablemonth_New_att" 
    WHERE "MonthId_New" = p_monthid::INT;

    v_monthid_int := p_monthid::INT;
    v_year_int := v_year::INT;

    -- Drop calender table if exists
    DROP TABLE IF EXISTS "dbo"."calender";

    -- Return calendar days for the specified month and year
    RETURN QUERY
    WITH N(N) AS (
        SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1)) M(N)
    ),
    tally(N) AS (
        SELECT ROW_NUMBER() OVER(ORDER BY N.N) 
        FROM N, N a
    )
    SELECT 
        N::INT AS day,
        REPLACE(TO_CHAR(MAKE_DATE(v_year_int, v_monthid_int, N::INT), 'DD/MM/YYYY'), ' ', '-') AS date
    FROM tally
    WHERE N <= EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE(v_year_int, v_monthid_int, 1)) + INTERVAL '1 month' - INTERVAL '1 day')::DATE);

    -- Clean up temp table
    DROP TABLE IF EXISTS "NewTablemonth_New_att";
    
END;
$$;