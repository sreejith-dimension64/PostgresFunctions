CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Attendance_Month_Datewise_Namebinding"(
    "month" VARCHAR,
    "ASMAY_Id" VARCHAR,
    "mi_id" VARCHAR
)
RETURNS TABLE(
    "day" INTEGER,
    "date" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Query" TEXT;
    "Year" INTEGER := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    "sqlquery" TEXT;
    "cursorValue" VARCHAR;
    "Cl" VARCHAR;
    "C2" VARCHAR;
    "query1" TEXT;
    "cols" VARCHAR;
    "monthyearsd" VARCHAR;
    "monthyearsd1" VARCHAR;
    "startDate" DATE;
    "endDate" DATE;
BEGIN

    CREATE TEMP TABLE IF NOT EXISTS "NewTablemonth1111"(
        "id" SERIAL NOT NULL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO "startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INTEGER AND "ASMAY_Id" = "ASMAY_Id"::INTEGER;
    
    SELECT "ASMAY_To_Date" INTO "endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INTEGER AND "ASMAY_Id" = "ASMAY_Id"::INTEGER;

    WITH RECURSIVE CTE AS (
        SELECT "startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE 
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "endDate"::DATE
    )
    INSERT INTO "NewTablemonth1111"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INTEGER, EXTRACT(YEAR FROM "Dates")::INTEGER 
    FROM CTE;

    SELECT "AYear" INTO "Year" 
    FROM "NewTablemonth1111" 
    WHERE "MonthId" = "month"::INTEGER;

    RETURN QUERY
    WITH RECURSIVE tally("N") AS (
        SELECT 1
        UNION ALL
        SELECT "N" + 1
        FROM tally
        WHERE "N" < EXTRACT(DAY FROM (DATE_TRUNC('MONTH', MAKE_DATE("Year", "month"::INTEGER, 1)) + INTERVAL '1 month' - INTERVAL '1 day'))
    )
    SELECT 
        "N"::INTEGER AS "day",
        REPLACE(TO_CHAR(MAKE_DATE("Year", "month"::INTEGER, "N"), 'DD-MM-YYYY'), ' ', '-') AS "date"
    FROM tally;

    DROP TABLE IF EXISTS "NewTablemonth1111";

END;
$$;