CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_Month_DateList"(
    "asmay_id" TEXT, 
    "mi_id" TEXT, 
    "month" TEXT
)
RETURNS TABLE(
    "day" INTEGER,
    "date" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "Query" TEXT;
    "Year" INTEGER := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    "sqlquery" TEXT;
    "cursorValue" TEXT;
    "Cl" TEXT;
    "C2" TEXT;
    "query1" TEXT;
    "cols" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd1" TEXT;
    "startDate" DATE;
    "endDate" DATE;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "NewTablemonthcollege";
    
    CREATE TEMP TABLE "NewTablemonthcollege"(
        "id" SERIAL NOT NULL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    );

    SELECT "ASMAY_From_Date" INTO "startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INTEGER AND "ASMAY_Id" = "asmay_id"::INTEGER;
    
    SELECT "ASMAY_To_Date" INTO "endDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INTEGER AND "ASMAY_Id" = "asmay_id"::INTEGER;

    WITH RECURSIVE "CTE" AS (
        SELECT "startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE 
        FROM "CTE" 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "endDate"::DATE
    )
    INSERT INTO "NewTablemonthcollege"("MonthId", "AYear")
    SELECT 
        EXTRACT(MONTH FROM "Dates")::INTEGER AS "Month",
        EXTRACT(YEAR FROM "Dates")::INTEGER AS "Year"
    FROM "CTE";

    SELECT "AYear" INTO "Year" 
    FROM "NewTablemonthcollege" 
    WHERE "MonthId" = "month"::INTEGER
    LIMIT 1;

    RETURN QUERY
    WITH "N"("N") AS (
        SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1)) "M"("N")
    ),
    "tally"("N") AS (
        SELECT ROW_NUMBER() OVER(ORDER BY "N"."N") 
        FROM "N", "N" "a"
    )
    SELECT 
        "tally"."N"::INTEGER AS "day",
        REPLACE(
            TO_CHAR(
                MAKE_DATE("Year", "month"::INTEGER, "tally"."N"::INTEGER),
                'DD-MM-YYYY'
            ),
            ' ',
            '-'
        ) AS "date"
    FROM "tally"
    WHERE "tally"."N" <= EXTRACT(DAY FROM (
        DATE_TRUNC('MONTH', MAKE_DATE("Year", "month"::INTEGER, 1)) + INTERVAL '1 MONTH - 1 day'
    ))::INTEGER;

    DROP TABLE IF EXISTS "NewTablemonthcollege";

END;
$$;