CREATE OR REPLACE FUNCTION "dbo"."EmpWiseDRReports_Count"(
    "HRME_Id" TEXT,
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    column_data JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "MonthDates" TEXT;
    "Dynamic" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
    "PivotSelectColumnNames" TEXT;
    v_rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "DR_MonthDates";

    CREATE TEMP TABLE "DR_MonthDates" (
        "MDate" VARCHAR(60)
    );

    "StartDate_N" := TO_CHAR("StartDate"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("EndDate"::DATE, 'YYYY-MM-DD');

    INSERT INTO "DR_MonthDates" ("MDate")
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            "StartDate" AS "FromDate",
            TO_CHAR("StartDate", 'Day') AS "Dayname"
        UNION ALL
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') <= "EndDate"
    )
    SELECT 
        CASE 
            WHEN EXTRACT(DAY FROM "FromDate") < 10 THEN 
                TO_CHAR("FromDate", 'Month') || '_' || '0' || EXTRACT(DAY FROM "FromDate")::VARCHAR
            ELSE 
                TO_CHAR("FromDate", 'Month') || '_' || EXTRACT(DAY FROM "FromDate")::VARCHAR
        END AS "MDate"
    FROM cte
    ORDER BY "FromDate";

    SELECT STRING_AGG('"' || "MDate" || '"', ',' ORDER BY "MDate")
    INTO "MonthDates"
    FROM "DR_MonthDates";

    SELECT STRING_AGG(
        'COALESCE(''' || "MDate" || ''', 0) AS "' || "MDate" || '"', 
        ','
        ORDER BY "MDate"
    )
    INTO "PivotSelectColumnNames"
    FROM (SELECT DISTINCT "MDate" FROM "DR_MonthDates") AS "PVSelctedColumns";

    "Dynamic" := 'SELECT "HRME_Id"::INTEGER, ' || "PivotSelectColumnNames" || ' FROM (
        SELECT DISTINCT "HRME_Id"::INTEGER,
            (CASE 
                WHEN EXTRACT(DAY FROM "ISMDRPT_Date") < 10 THEN 
                    TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || ''0'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
                ELSE 
                    TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
            END) AS "HDate",
            "DRCount"
        FROM (
            SELECT 
                "HRME_Id",
                "ISMDRPT_Date"::DATE AS "ISMDRPT_Date",
                COUNT(DISTINCT "ISMDRPT_Date") AS "DRCount"
            FROM "dbo"."ISM_DailyReport"
            WHERE "HRME_Id"::TEXT IN (' || "HRME_Id" || ')
                AND "ISMDRPT_Date"::DATE BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || '''
            GROUP BY "HRME_Id", "ISMDRPT_Date"::DATE
        ) AS "New"
        ORDER BY "HRME_Id", "HDate"
        LIMIT 100
    ) AS "New1"
    PIVOT (
        COUNT("DRCount")
        FOR "HDate" IN (' || "MonthDates" || ')
    ) AS "PVT"';

    RETURN QUERY EXECUTE "Dynamic";

    DROP TABLE IF EXISTS "DR_MonthDates";
END;
$$;