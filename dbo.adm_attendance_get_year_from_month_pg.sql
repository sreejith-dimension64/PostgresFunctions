CREATE OR REPLACE FUNCTION dbo.adm_attendance_get_year_from_month(
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_fromdate TEXT,
    p_mi_id TEXT,
    p_asmay_id TEXT,
    p_month TEXT,
    p_monthid TEXT
)
RETURNS TABLE(AYear INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_startDate DATE;
    v_endDate DATE;
    v_year INTEGER;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "NewTable1New"(
        id SERIAL NOT NULL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;

    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;

    INSERT INTO "NewTable1New"("MonthId", "AYear")
    WITH RECURSIVE CTE AS (
        SELECT v_startDate::DATE AS Dates
        UNION ALL
        SELECT (Dates + INTERVAL '1 MONTH')::DATE
        FROM CTE
        WHERE Dates::DATE <= v_endDate::DATE
    )
    SELECT EXTRACT(MONTH FROM Dates)::INTEGER AS Month, 
           EXTRACT(YEAR FROM Dates)::INTEGER AS Year
    FROM CTE;

    RETURN QUERY
    SELECT "AYear"
    FROM "NewTable1New"
    WHERE "MonthId" = p_monthid::INTEGER
    LIMIT 1;

    DROP TABLE IF EXISTS "NewTable1New";
END;
$$;