CREATE OR REPLACE FUNCTION "dbo"."ISM_ConsolidateDailyReport_Test"(
    p_HRME_Id TEXT,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "EmployeeName" VARCHAR
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
    v_StartDate TIMESTAMP;
    v_EndDate TIMESTAMP;
    rec RECORD;
BEGIN
    -- Exec ISM_ConsolidateDailyReport_Test '50,67','2019-07-01','2019-07-20'

    DROP TABLE IF EXISTS "dbo"."DR_MonthDates";

    v_StartDate := p_StartDate;
    v_EndDate := p_EndDate;

    v_StartDate_N := TO_CHAR(p_StartDate, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(p_EndDate, 'YYYY-MM-DD');

    CREATE TEMP TABLE "DR_MonthDates" AS
    WITH RECURSIVE cte AS 
    (
        SELECT 1 AS "DayID", p_StartDate AS "FromDate", TO_CHAR(p_StartDate, 'Dy') AS "Dayname"
        UNION ALL
        SELECT cte."DayID" + 1 AS "DayID", 
               (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
               TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Dy') AS "Dayname"
        FROM cte  
        WHERE (cte."FromDate" + INTERVAL '1 day') <= p_EndDate
    )
    SELECT 
        (CASE 
            WHEN EXTRACT(DAY FROM "FromDate") < 10 
            THEN TO_CHAR("FromDate", 'Month') || '_' || '0' || EXTRACT(DAY FROM "FromDate")::VARCHAR(60)
            ELSE TO_CHAR("FromDate", 'Month') || '_' || EXTRACT(DAY FROM "FromDate")::VARCHAR(60)
        END) AS "MDate"
    FROM cte  
    ORDER BY "MDate";
 
    SELECT STRING_AGG('],' || "MDate", '' ORDER BY "MDate") INTO v_MonthDates
    FROM "DR_MonthDates";
    
    v_MonthDates := SUBSTRING(v_MonthDates FROM 3);

    SELECT STRING_AGG(
        'COALESCE(' || '"' || "MDate" || '"' || ', ''N'') AS ' || '"' || "MDate" || '"',
        ','
        ORDER BY "MDate"
    ) INTO v_PivotSelectColumnNames
    FROM (SELECT DISTINCT "MDate" FROM "DR_MonthDates") AS "PVSelctedColumns";

    v_Dynamic := 'SELECT "HRME_Id", "EmployeeName", ' || v_PivotSelectColumnNames || ' FROM (
    SELECT DISTINCT "HRME_Id", "EmployeeName",
    (CASE 
        WHEN EXTRACT(DAY FROM "ISMDRPT_Date") < 10 
        THEN TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || ''0'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR(60)
        ELSE TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR(60)
    END) AS "HDate",
    (CASE 
        WHEN "ISMDRPT_OrdersDateFlg" = 1 AND "DRCount" = 1 THEN ''O''  
        WHEN "ISMDRPT_BlockedFlag" = 1 AND "DRCount" = 1 THEN ''B''  
        WHEN "DRCount" = 1 THEN ''Y''  
        WHEN "DRCount" = 0 THEN ''N'' 
    END) AS "DRCount"
    FROM (
        SELECT 
            "HRE"."HRME_Id",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRE"."HRME_EmployeeLastName", '''')) AS "EmployeeName",
            "DR"."ISMDRPT_Date"::DATE AS "ISMDRPT_Date",
            "ISMDRPT_OrdersDateFlg",
            "ISMDRPT_BlockedFlag",
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
            (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRE"."HRME_EmployeeLastName", '''')),
            "DR"."ISMDRPT_Date"::DATE,
            "ISMDRPT_OrdersDateFlg",
            "ISMDRPT_BlockedFlag"
    ) AS "New" 
    ORDER BY "HRME_Id", "HDate"
) AS "New1" 
CROSSTAB(
    ''SELECT "HRME_Id", "EmployeeName", "HDate", "DRCount" FROM temp_pivot_data ORDER BY 1, 3'',
    ''SELECT DISTINCT "MDate" FROM "DR_MonthDates" ORDER BY 1''
) AS ct("HRME_Id" INTEGER, "EmployeeName" VARCHAR, ' || v_MonthDates || ')';

    RETURN QUERY EXECUTE v_Dynamic;

    DROP TABLE IF EXISTS "DR_MonthDates";

END;
$$;