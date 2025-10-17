CREATE OR REPLACE FUNCTION "dbo"."ISM_ConsolidateDailyReport"(
    p_HRME_Id TEXT,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP
)
RETURNS TABLE (
    "HRME_Id" VARCHAR,
    "EmployeeName" VARCHAR,
    "DynamicColumns" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_MonthDates TEXT;
    v_Dynamic TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_PivotSelectColumnNames TEXT;
    v_UpdateDynamic TEXT;
BEGIN
    -- Drop temporary table if exists
    DROP TABLE IF EXISTS "DR_MonthDates";

    -- Convert dates to strings
    v_StartDate_N := TO_CHAR(p_StartDate::DATE, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(p_EndDate::DATE, 'YYYY-MM-DD');

    -- Create temporary table with date ranges
    CREATE TEMP TABLE "DR_MonthDates" AS
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            p_StartDate AS "FromDate",
            TO_CHAR(p_StartDate, 'Day') AS "Dayname"
        UNION ALL
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP AS "FromDate",
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') <= p_EndDate
    )
    SELECT 
        CASE 
            WHEN EXTRACT(DAY FROM "FromDate") < 10 
            THEN TO_CHAR("FromDate", 'Month') || '_' || '0' || EXTRACT(DAY FROM "FromDate")::VARCHAR
            ELSE TO_CHAR("FromDate", 'Month') || '_' || EXTRACT(DAY FROM "FromDate")::VARCHAR
        END AS "MDate"
    FROM cte
    ORDER BY "MDate";

    -- Build comma-separated list of month dates for PIVOT
    SELECT STRING_AGG('"' || "MDate" || '"', ',' ORDER BY "MDate")
    INTO v_MonthDates
    FROM "DR_MonthDates";

    -- Build pivot select column names
    SELECT STRING_AGG(
        'COALESCE(' || '"' || "MDate" || '"' || ', ''N'') AS ' || '"' || "MDate" || '"',
        ','
        ORDER BY "MDate"
    )
    INTO v_PivotSelectColumnNames
    FROM (SELECT DISTINCT "MDate" FROM "DR_MonthDates") AS "PVSelctedColumns";

    -- Build and execute dynamic SQL
    v_Dynamic := 'SELECT "HRME_Id", "EmployeeName", ' || v_PivotSelectColumnNames || ' FROM (
    SELECT DISTINCT "HRME_Id", "EmployeeName",
    (CASE WHEN EXTRACT(DAY FROM "ISMDRPT_Date") < 10 
          THEN TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || ''0'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
          ELSE TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR 
     END) AS "HDate",
    (CASE WHEN "ISMDRPT_OrdersDateFlg" = 1 AND "DRCount" = 1 THEN ''O''
          WHEN "ISMDRPT_BlockedFlag" = 1 AND "DRCount" = 1 THEN ''B''
          WHEN "DRCount" = 1 THEN ''Y''
          WHEN "DRCount" = 0 THEN ''N'' 
     END) AS "DRCount"
    FROM (
        SELECT 
            "HRE"."HRME_Id",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
             COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
             COALESCE("HRE"."HRME_EmployeeLastName", '''')) AS "EmployeeName",
            "DR"."ISMDRPT_Date"::DATE AS "ISMDRPT_Date",
            "DR"."ISMDRPT_OrdersDateFlg",
            "DR"."ISMDRPT_BlockedFlag",
            COUNT(DISTINCT "DR"."ISMDRPT_Date") AS "DRCount"
        FROM "dbo"."ISM_DailyReport" "DR"
        INNER JOIN "dbo"."HR_Master_Employee" "HRE" 
            ON "HRE"."HRME_Id" = "DR"."HRME_Id" 
            AND "HRE"."HRME_ActiveFlag" = 1 
            AND "HRE"."HRME_LeftFlag" = 0
        WHERE "HRE"."HRME_Id" IN (
            SELECT DISTINCT "HRME_Id" 
            FROM "dbo"."HR_Master_Employee" 
            WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
        )
        AND "DR"."ISMDRPT_Date"::DATE BETWEEN ''' || v_StartDate_N || '''::DATE AND ''' || v_EndDate_N || '''::DATE
        GROUP BY 
            "HRE"."HRME_Id",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
             COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
             COALESCE("HRE"."HRME_EmployeeLastName", '''')),
            "DR"."ISMDRPT_Date"::DATE,
            "DR"."ISMDRPT_OrdersDateFlg",
            "DR"."ISMDRPT_BlockedFlag"
    ) AS "New"
    ORDER BY "HRME_Id", "HDate"
    ) AS "New1"
    ) AS "source_data"
    CROSS JOIN LATERAL (
        SELECT ' || v_PivotSelectColumnNames || '
        FROM CROSSTAB(
            ''SELECT "HRME_Id"::TEXT || ''|'' || "EmployeeName", "HDate", "DRCount" 
              FROM source_data 
              ORDER BY 1, 2'',
            ''SELECT DISTINCT "MDate" FROM "DR_MonthDates" ORDER BY 1''
        ) AS ct("key" TEXT, ' || v_MonthDates || ' TEXT)
    ) AS pivoted';

    -- For PostgreSQL, we need to use crosstab from tablefunc extension
    -- Simplified approach: return the unpivoted data
    RETURN QUERY EXECUTE 
    'SELECT "HRME_Id"::VARCHAR, "EmployeeName"::VARCHAR, 
            STRING_AGG("HDate" || '':'' || "DRCount", '', '' ORDER BY "HDate") AS "DynamicColumns"
     FROM (
        SELECT DISTINCT "HRME_Id", "EmployeeName",
        (CASE WHEN EXTRACT(DAY FROM "ISMDRPT_Date") < 10 
              THEN TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || ''0'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
              ELSE TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR 
         END) AS "HDate",
        (CASE WHEN "ISMDRPT_OrdersDateFlg" = 1 AND "DRCount" = 1 THEN ''O''
              WHEN "ISMDRPT_BlockedFlag" = 1 AND "DRCount" = 1 THEN ''B''
              WHEN "DRCount" = 1 THEN ''Y''
              WHEN "DRCount" = 0 THEN ''N'' 
         END) AS "DRCount"
        FROM (
            SELECT 
                "HRE"."HRME_Id",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeLastName", '''')) AS "EmployeeName",
                "DR"."ISMDRPT_Date"::DATE AS "ISMDRPT_Date",
                "DR"."ISMDRPT_OrdersDateFlg",
                "DR"."ISMDRPT_BlockedFlag",
                COUNT(DISTINCT "DR"."ISMDRPT_Date") AS "DRCount"
            FROM "dbo"."ISM_DailyReport" "DR"
            INNER JOIN "dbo"."HR_Master_Employee" "HRE" 
                ON "HRE"."HRME_Id" = "DR"."HRME_Id" 
                AND "HRE"."HRME_ActiveFlag" = 1 
                AND "HRE"."HRME_LeftFlag" = 0
            WHERE "HRE"."HRME_Id" IN (
                SELECT DISTINCT "HRME_Id" 
                FROM "dbo"."HR_Master_Employee" 
                WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
            )
            AND "DR"."ISMDRPT_Date"::DATE BETWEEN $1::DATE AND $2::DATE
            GROUP BY 
                "HRE"."HRME_Id",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeLastName", '''')),
                "DR"."ISMDRPT_Date"::DATE,
                "DR"."ISMDRPT_OrdersDateFlg",
                "DR"."ISMDRPT_BlockedFlag"
        ) AS "New"
        ORDER BY "HRME_Id", "HDate"
    ) AS "New1"
    GROUP BY "HRME_Id", "EmployeeName"
    ORDER BY "HRME_Id"'
    USING v_StartDate_N, v_EndDate_N;

    DROP TABLE IF EXISTS "DR_MonthDates";
END;
$$;