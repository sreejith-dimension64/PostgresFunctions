CREATE OR REPLACE FUNCTION "dbo"."HL_ConsolidateAttendanceReport"(
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP
)
RETURNS void
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
    v_StartDate TIMESTAMP;
    v_EndDate TIMESTAMP;
BEGIN

    v_StartDate := p_StartDate;
    v_EndDate := p_EndDate;

    DROP TABLE IF EXISTS "dbo"."Attendance_MonthDates";
    DROP TABLE IF EXISTS "dbo"."HL_StuAttConsolidated_Temp";
    DROP TABLE IF EXISTS "dbo"."HL_ZeroAttReportsStus_Temp";
    DROP TABLE IF EXISTS "dbo"."HL_UNPIVOTStusAttList_Temp";

    v_StartDate_N := TO_CHAR(v_StartDate::DATE, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(v_EndDate::DATE, 'YYYY-MM-DD');

    CREATE TEMP TABLE "Attendance_MonthDates" AS
    WITH RECURSIVE cte AS (
        SELECT 
            1 AS "DayID",
            v_StartDate AS "FromDate",
            TO_CHAR(v_StartDate, 'Day') AS "Dayname"
        UNION ALL
        SELECT 
            cte."DayID" + 1 AS "DayID",
            (cte."FromDate" + INTERVAL '1 day')::TIMESTAMP,
            TO_CHAR(cte."FromDate" + INTERVAL '1 day', 'Day') AS "Dayname"
        FROM cte 
        WHERE (cte."FromDate" + INTERVAL '1 day') <= v_EndDate
    )
    SELECT 
        (CASE 
            WHEN EXTRACT(DAY FROM "FromDate") < 10 
            THEN TO_CHAR("FromDate", 'Month') || '_' || '0' || EXTRACT(DAY FROM "FromDate")::VARCHAR
            ELSE TO_CHAR("FromDate", 'Month') || '_' || EXTRACT(DAY FROM "FromDate")::VARCHAR 
        END) AS "MDate",
        "FromDate"
    FROM cte
    ORDER BY "MDate";

    SELECT STRING_AGG('],[' || "MDate", '' ORDER BY "MDate") INTO v_MonthDates
    FROM "dbo"."Attendance_MonthDates";
    
    v_MonthDates := ' ' || v_MonthDates || ']';

    SELECT STRING_AGG(
        'COALESCE(' || quote_ident("MDate") || ', ''N'') AS ' || quote_ident("MDate"),
        ','
    ) INTO v_PivotSelectColumnNames
    FROM (SELECT DISTINCT "MDate" FROM "Attendance_MonthDates") AS "PVSelctedColumns";

    v_Dynamic := 'CREATE TEMP TABLE "HL_StuAttConsolidated_Temp" AS
    SELECT "AMST_Id", "StudentName", ' || v_PivotSelectColumnNames || '
    FROM crosstab(
        ''SELECT DISTINCT "AMST_Id", "StudentName", "PDate", "PunchCount"
        FROM (
            SELECT 
                "AMS"."AMST_Id",
                (COALESCE("AMS"."AMST_FirstName", '''''''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''''''') || '' '' || COALESCE("AMS"."AMST_LastName", '''''''')) AS "StudentName",
                (CASE 
                    WHEN EXTRACT(DAY FROM "ASPU_PunchDate"::DATE) < 10 
                    THEN TO_CHAR("ASPU_PunchDate"::DATE, ''Month'') || ''''_'''' || ''''0'''' || EXTRACT(DAY FROM "ASPU_PunchDate"::DATE)::VARCHAR
                    ELSE TO_CHAR("ASPU_PunchDate"::DATE, ''Month'') || ''''_'''' || EXTRACT(DAY FROM "ASPU_PunchDate"::DATE)::VARCHAR 
                END) AS "PDate",
                (CASE 
                    WHEN "ASPU_ManualEntryFlg" = 1 AND "PunchCount" = 1 THEN ''''M''''
                    WHEN "ASPU_ManualEntryFlg" = 0 AND "PunchCount" = 1 THEN ''''B''''
                END) AS "PunchCount"
            FROM (
                SELECT 
                    "AMS"."AMST_Id",
                    (COALESCE("AMS"."AMST_FirstName", '''''''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''''''') || '' '' || COALESCE("AMS"."AMST_LastName", '''''''')) AS "StudentName",
                    "ASPU_PunchDate"::DATE AS "ASPU_PunchDate",
                    COALESCE("ASPU_ManualEntryFlg", 0) AS "ASPU_ManualEntryFlg",
                    COUNT(DISTINCT "ASPU_PunchDate"::DATE) AS "PunchCount"
                FROM "dbo"."Adm_Student_Punch" "ASP"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASP"."AMST_Id" 
                    AND "AMS"."AMST_ActiveFlag" = 1 
                    AND "AMS"."AMST_SOL" = ''''S''''
                    AND "ASPU_PunchDate"::DATE BETWEEN ''''' || v_StartDate_N || ''''' AND ''''' || v_EndDate_N || '''''
                GROUP BY 
                    "AMS"."AMST_Id",
                    (COALESCE("AMS"."AMST_FirstName", '''''''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''''''') || '' '' || COALESCE("AMS"."AMST_LastName", '''''''')),
                    "ASPU_PunchDate"::DATE,
                    "ASPU_ManualEntryFlg"
            ) AS "New"
        ) AS "New1"
        ORDER BY "AMST_Id", "PDate"'',
        ''SELECT DISTINCT "MDate" FROM "dbo"."Attendance_MonthDates" ORDER BY 1''
    ) AS ct("AMST_Id" BIGINT, "StudentName" TEXT, ' || REPLACE(REPLACE(v_MonthDates, '[', '"'), ']', '" TEXT') || ')';

    EXECUTE v_Dynamic;

    CREATE TEMP TABLE "HL_ZeroAttReportsStus_Temp" AS
    SELECT DISTINCT 
        "AMST_Id",
        (COALESCE("AMST_FirstName", '') || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '')) AS "StudentName"
    FROM "Adm_M_Student"
    WHERE "AMST_ActiveFlag" = 1 
        AND "AMST_SOL" = 'S'
        AND "AMST_Id" IN (
            SELECT DISTINCT "AMST_Id" 
            FROM "Adm_M_Student" 
            WHERE "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S'
            EXCEPT
            SELECT DISTINCT "AMST_Id" 
            FROM "HL_StuAttConsolidated_Temp"
        );

    v_Clcount := 0;
    SELECT COUNT("column_name") INTO v_Clcount
    FROM information_schema.columns
    WHERE "table_name" = 'HL_StuAttConsolidated_Temp';

    v_Clcount := v_Clcount - 2;

    RAISE NOTICE 'Column count: %', v_Clcount;

    IF v_Clcount = 30 THEN
        INSERT INTO "HL_StuAttConsolidated_Temp"
        SELECT "AMST_Id", "StudentName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "HL_ZeroAttReportsStus_Temp";
    ELSIF v_Clcount = 31 THEN
        INSERT INTO "HL_StuAttConsolidated_Temp"
        SELECT "AMST_Id", "StudentName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "HL_ZeroAttReportsStus_Temp";
    ELSIF v_Clcount = 29 THEN
        INSERT INTO "HL_StuAttConsolidated_Temp"
        SELECT "AMST_Id", "StudentName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "HL_ZeroAttReportsStus_Temp";
    ELSIF v_Clcount = 28 THEN
        INSERT INTO "HL_StuAttConsolidated_Temp"
        SELECT "AMST_Id", "StudentName", 'N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N','N'
        FROM "HL_ZeroAttReportsStus_Temp";
    END IF;

    v_Dynamicsql := 'CREATE TEMP TABLE "HL_UNPIVOTStusAttList_Temp" AS
    SELECT "AMST_Id", "StudentName", "MonthDates", "DrValue"
    FROM "HL_StuAttConsolidated_Temp" "ET",
    LATERAL (
        VALUES ' || (
            SELECT STRING_AGG('(' || quote_literal("MDate") || ', ' || quote_ident("MDate") || ')', ',')
            FROM "dbo"."Attendance_MonthDates"
        ) || '
    ) AS unpvt("MonthDates", "DrValue")';

    EXECUTE v_Dynamicsql;

    UPDATE "HL_UNPIVOTStusAttList_Temp" "D"
    SET "DrValue" = 'P'
    FROM "Attendance_MonthDates" "DRM"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "HD" ON "HD"."FOMHWDD_FromDate"::DATE = "DRM"."FromDate"::DATE
    WHERE "D"."MonthDates" = "DRM"."MDate"
        AND "HD"."FOHWDT_Id" IN (
            SELECT "FOHWDT_Id" 
            FROM "FO"."FO_HolidayWorkingDay_Type" 
            WHERE "FOHTWD_HolidayWDType" = 'PUBLIC HOLIDAY' AND "FOHTWD_HolidayFlag" = 1
        );

    v_Dynamicsql1 := 'SELECT "AMST_Id", "StudentName", ' || v_MonthDates || '
    FROM crosstab(
        ''SELECT "AMST_Id", "StudentName", "MonthDates", MIN("DrValue")
        FROM "HL_UNPIVOTStusAttList_Temp"
        GROUP BY "AMST_Id", "StudentName", "MonthDates"
        ORDER BY "AMST_Id", "MonthDates"'',
        ''SELECT DISTINCT "MDate" FROM "dbo"."Attendance_MonthDates" ORDER BY 1''
    ) AS ct("AMST_Id" BIGINT, "StudentName" TEXT, ' || REPLACE(REPLACE(v_MonthDates, '[', '"'), ']', '" TEXT') || ')';

    EXECUTE v_Dynamicsql1;

    DROP TABLE IF EXISTS "dbo"."HL_StuAttConsolidated_Temp";

    RETURN;
END;
$$;