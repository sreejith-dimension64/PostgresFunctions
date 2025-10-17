CREATE OR REPLACE FUNCTION "dbo"."ISM_ConsolidateDailyReport_Modify"(
    p_HRME_Id TEXT,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_MonthDates TEXT;
    v_Dynamic TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_PivotSelectColumnNames TEXT;
    v_UpdateDynamic TEXT;
    v_Dynamicsql TEXT;
    v_Dynamicsql1 TEXT;
    v_Clcount INT;
    v_SqlDynamic TEXT;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "dbo"."DR_MonthDates";
    DROP TABLE IF EXISTS "dbo"."ISM_EmpsDrConsolidated_Temp";
    DROP TABLE IF EXISTS "dbo"."ISM_ZeroDrReportsEmps_Temp";
    DROP TABLE IF EXISTS "dbo"."ISM_UNPIVOTEmpsDrList_Temp";

    v_StartDate_N := TO_CHAR(p_StartDate::DATE, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(p_EndDate::DATE, 'YYYY-MM-DD');

    CREATE TEMP TABLE "DR_MonthDates" AS
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            p_StartDate AS "FromDate",
            TO_CHAR(p_StartDate, 'Day') AS "Dayname"
        UNION ALL
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') <= p_EndDate
    )
    SELECT 
        CASE 
            WHEN EXTRACT(DAY FROM "FromDate") < 10 THEN 
                TO_CHAR("FromDate", 'Month') || '_' || '0' || EXTRACT(DAY FROM "FromDate")::VARCHAR
            ELSE 
                TO_CHAR("FromDate", 'Month') || '_' || EXTRACT(DAY FROM "FromDate")::VARCHAR
        END AS "MDate",
        "FromDate"
    FROM cte
    ORDER BY "MDate";

    SELECT STRING_AGG('"' || "MDate" || '"', '],[') INTO v_MonthDates
    FROM "dbo"."DR_MonthDates";
    v_MonthDates := ']' || v_MonthDates || ']';

    SELECT STRING_AGG(
        'COALESCE(' || '"' || "MDate" || '"' || ', ''N'') AS ' || '"' || "MDate" || '"',
        ','
    ) INTO v_PivotSelectColumnNames
    FROM (SELECT DISTINCT "MDate" FROM "DR_MonthDates") AS "PVSelctedColumns";

    v_Dynamic := 'CREATE TEMP TABLE "ISM_EmpsDrConsolidated_Temp" AS
    SELECT "HRME_Id", "EmployeeName", ' || v_PivotSelectColumnNames || '
    FROM (
        SELECT DISTINCT "HRME_Id", "EmployeeName",
        CASE 
            WHEN EXTRACT(DAY FROM "ISMDRPT_Date") < 10 THEN 
                TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || ''0'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
            ELSE 
                TO_CHAR("ISMDRPT_Date", ''Month'') || ''_'' || EXTRACT(DAY FROM "ISMDRPT_Date")::VARCHAR
        END AS "HDate",
        CASE 
            WHEN "ISMDRPT_OrdersDateFlg" = 1 AND "ISMDRPT_BlockedFlag" = 0 AND "DRCount" = 1 THEN ''O''
            WHEN ("ISMDRPT_OrdersDateFlg" = 1 OR "ISMDRPT_OrdersDateFlg" = 0) AND "ISMDRPT_BlockedFlag" = 1 AND "DRCount" = 1 THEN ''B''
            WHEN "DRCount" = 1 AND "ISMDRPT_HalfDayFlag" = 0 THEN ''Y''
            WHEN "DRCount" = 0 THEN ''N''
            WHEN "ISMDRPT_HalfDayFlag" = 1 AND "DRCount" = 1 THEN ''H''
        END AS "DRCount"
        FROM (
            SELECT 
                "HRE"."HRME_Id",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeLastName", '''')) AS "EmployeeName",
                "ISMDRPT_Date"::DATE AS "ISMDRPT_Date",
                COALESCE("ISMDRPT_OrdersDateFlg", 0) AS "ISMDRPT_OrdersDateFlg",
                COALESCE("ISMDRPT_BlockedFlag", 0) AS "ISMDRPT_BlockedFlag",
                COALESCE("ISMDRPT_HalfDayFlag", 0) AS "ISMDRPT_HalfDayFlag",
                COUNT(DISTINCT "ISMDRPT_Date") AS "DRCount"
            FROM "dbo"."ISM_DailyReport" "DR"
            INNER JOIN "HR_Master_Employee" "HRE" ON 
                "HRE"."HRME_Id" = "DR"."HRME_Id" 
                AND "HRE"."HRME_ActiveFlag" = 1 
                AND "HRE"."HRME_LeftFlag" = 0 
                AND "HRME_ExcPunch" = 0 
                AND "HRME_ExcDR" = 0
            WHERE "HRE"."HRME_Id" IN (
                SELECT DISTINCT "HRME_Id" 
                FROM "HR_Master_Employee" 
                WHERE "HRME_ActiveFlag" = 1 
                    AND "HRME_LeftFlag" = 0 
                    AND "HRME_ExcPunch" = 0 
                    AND "HRME_ExcDR" = 0
                    AND "HRME_Id" IN (' || p_HRME_Id || ')
            )
            AND "ISMDRPT_Date"::DATE BETWEEN ''' || v_StartDate_N || '''::DATE AND ''' || v_EndDate_N || '''::DATE
            GROUP BY 
                "HRE"."HRME_Id",
                (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeMiddleName", '''') || '' '' || 
                 COALESCE("HRE"."HRME_EmployeeLastName", '''')),
                "ISMDRPT_Date"::DATE,
                "ISMDRPT_OrdersDateFlg",
                "ISMDRPT_BlockedFlag",
                "ISMDRPT_HalfDayFlag"
        ) AS "New"
        ORDER BY "HRME_Id", "HDate"
    ) AS "New1"
    PIVOT (
        MIN("DRCount") FOR "HDate" IN (' || v_MonthDates || ')
    ) AS "PVT"';

    EXECUTE v_Dynamic;

    v_SqlDynamic := 'CREATE TEMP TABLE "ISM_ZeroDrReportsEmps_Temp" AS
    SELECT DISTINCT 
        "HRME_Id",
        (COALESCE("HRME_EmployeeFirstName", '''') || '' '' || 
         COALESCE("HRME_EmployeeMiddleName", '''') || '' '' || 
         COALESCE("HRME_EmployeeLastName", '''')) AS "EmployeeName"
    FROM "HR_Master_Employee"
    WHERE "HRME_ActiveFlag" = 1 
        AND "HRME_LeftFlag" = 0 
        AND "HRME_ExcPunch" = 0 
        AND "HRME_ExcDR" = 0
        AND "HRME_Id" IN (
            SELECT DISTINCT "HRME_Id" 
            FROM "HR_Master_Employee" 
            WHERE "HRME_ActiveFlag" = 1 
                AND "HRME_LeftFlag" = 0 
                AND "HRME_ExcPunch" = 0 
                AND "HRME_ExcDR" = 0
                AND "HRME_Id" IN (' || p_HRME_Id || ')
            EXCEPT
            SELECT DISTINCT "HRME_Id" 
            FROM "ISM_EmpsDrConsolidated_Temp"
        )
        AND "HRME_Id" IN (' || p_HRME_Id || ')';

    EXECUTE v_SqlDynamic;

    v_Clcount := 0;
    SELECT COUNT("column_name") INTO v_Clcount
    FROM information_schema.columns
    WHERE "table_name" = 'ISM_EmpsDrConsolidated_Temp';

    v_Clcount := v_Clcount - 2;

    RAISE NOTICE '%', v_Clcount;

    IF v_Clcount = 30 THEN
        INSERT INTO "ISM_EmpsDrConsolidated_Temp"
        SELECT "HRME_Id", "EmployeeName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "ISM_ZeroDrReportsEmps_Temp";
    ELSIF v_Clcount = 31 THEN
        INSERT INTO "ISM_EmpsDrConsolidated_Temp"
        SELECT "HRME_Id", "EmployeeName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "ISM_ZeroDrReportsEmps_Temp";
    ELSIF v_Clcount = 29 THEN
        INSERT INTO "ISM_EmpsDrConsolidated_Temp"
        SELECT "HRME_Id", "EmployeeName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "ISM_ZeroDrReportsEmps_Temp";
    ELSE
        IF v_Clcount = 28 THEN
            INSERT INTO "ISM_EmpsDrConsolidated_Temp"
            SELECT "HRME_Id", "EmployeeName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
            FROM "ISM_ZeroDrReportsEmps_Temp";
        END IF;
    END IF;

    v_Dynamicsql := 'CREATE TEMP TABLE "ISM_UNPIVOTEmpsDrList_Temp" AS
    SELECT "HRME_Id", "EmployeeName", "MonthDates", "DrValue"
    FROM "ISM_EmpsDrConsolidated_Temp" "ET"
    UNPIVOT ("DrValue" FOR "MonthDates" IN (' || v_MonthDates || ')) AS "Schoolunpivot"';

    EXECUTE v_Dynamicsql;

    UPDATE "ISM_UNPIVOTEmpsDrList_Temp" "D"
    SET "DrValue" = 'P'
    FROM "DR_MonthDates" "DRM"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "HD" 
        ON "HD"."FOMHWDD_FromDate"::DATE = "DRM"."FromDate"::DATE
    WHERE "D"."MonthDates" = "DRM"."MDate"
        AND "FOHWDT_Id" IN (
            SELECT "FOHWDT_Id" 
            FROM "FO"."FO_HolidayWorkingDay_Type" 
            WHERE "FOHTWD_HolidayWDType" = 'PUBLIC HOLIDAY' 
                AND "FOHTWD_HolidayFlag" = 1
        );

    v_Dynamicsql1 := 'SELECT "HRME_Id", "EmployeeName", ' || v_MonthDates || '
    FROM "ISM_UNPIVOTEmpsDrList_Temp" "ET"
    PIVOT (MIN("DrValue") FOR "MonthDates" IN (' || v_MonthDates || ')) AS "Schpivot"';

    EXECUTE v_Dynamicsql1;

    DROP TABLE IF EXISTS "dbo"."ISM_EmpsDrConsolidated_Temp";

END;
$$;