CREATE OR REPLACE FUNCTION "dbo"."Fo_Emp_Log_Report"(
    "date" VARCHAR(10),
    "month" VARCHAR(2),
    "year" VARCHAR(4),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "miid" BIGINT,
    "multiplehrmeid" VARCHAR(2000),
    "punchtype" VARCHAR(10)
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "ecode" VARCHAR(50),
    "ename" VARCHAR(250),
    "depname" VARCHAR(250),
    "desgname" VARCHAR(250),
    "gtype" VARCHAR(250),
    "punchdate" DATE,
    "punchday" VARCHAR(50),
    "intime" VARCHAR(50),
    "outtime" VARCHAR(50),
    "workingtime" VARCHAR(50),
    "lateby" VARCHAR(50),
    "earlyby" VARCHAR(50),
    "intemperature" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_content VARCHAR(500);
    v_content1 VARCHAR(500);
    v_cchrme VARCHAR(500);
    v_query TEXT;
    v_dynamic TEXT;
    v_content_LE TEXT;
    v_dt DATE;
    v_COUNT INT;
    v_HRME_Id BIGINT;
    v_HRMD_ID BIGINT;
    v_ecode VARCHAR(50);
    v_ename VARCHAR(250);
    v_punchINtime VARCHAR(50);
    v_punchOUTtime VARCHAR(50);
    v_lateby VARCHAR(50);
    v_earlyby VARCHAR(50);
    v_depname VARCHAR(250);
    v_desgname VARCHAR(250);
    v_gtype VARCHAR(250);
    v_Temperature VARCHAR(250);
    v_TatalWorkingHours VARCHAR(50);
    v_query1 TEXT;
    rec_employee RECORD;
    rec_dates RECORD;
BEGIN

    IF "fromdate" != '' AND "todate" != '' THEN
        v_content := ' CAST("punchdate" AS VARCHAR) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    ELSIF "month" != '' AND "year" != '' THEN
        v_content := ' EXTRACT(MONTH FROM "punchdate")::VARCHAR = ''' || "month" || ''' AND EXTRACT(YEAR FROM "punchdate")::VARCHAR = ''' || "year" || '''';
        
        "fromdate" := TO_CHAR(TO_DATE("year" || '-' || "month" || '-01', 'YYYY-MM-DD'), 'YYYY-MM-DD');
        "todate" := TO_CHAR((DATE_TRUNC('MONTH', TO_DATE("year" || '-' || "month" || '-01', 'YYYY-MM-DD')) + INTERVAL '1 MONTH - 1 day')::DATE, 'YYYY-MM-DD');
    ELSIF "date" != '' THEN
        v_content := ' CAST("punchdate" AS VARCHAR) = ''' || "date" || '''';
        "fromdate" := "date";
        "todate" := "date";
    ELSE
        v_content := '';
    END IF;

    IF "fromdate" != '' AND "todate" != '' THEN
        v_content1 := ' CAST("FOEP_PunchDate" AS VARCHAR) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    ELSIF "month" != '' AND "year" != '' THEN
        v_content1 := ' EXTRACT(MONTH FROM "FOEP_PunchDate")::VARCHAR = ''' || "month" || ''' AND EXTRACT(YEAR FROM "FOEP_PunchDate")::VARCHAR = ''' || "year" || '''';
    ELSIF "date" != '' THEN
        v_content1 := ' CAST("FOEP_PunchDate" AS VARCHAR) = ''' || "date" || '''';
    ELSE
        v_content := '';
    END IF;

    IF "fromdate" != '' AND "todate" != '' THEN
        v_content_LE := ' CAST("FOEP_PunchDate" AS VARCHAR) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    END IF;

    IF "punchtype" = 'punch' THEN

        DROP TABLE IF EXISTS "temp_employeeswithoutLogs";
        DROP TABLE IF EXISTS "employeelist";

        CREATE TEMP TABLE "temp_employeeswithoutLogs" (
            "HRME_Id" BIGINT,
            "ecode" VARCHAR(50),
            "ename" VARCHAR(250),
            "depname" VARCHAR(250),
            "desgname" VARCHAR(250),
            "gtype" VARCHAR(250),
            "punchdate" DATE,
            "punchday" VARCHAR(50),
            "intime" VARCHAR(50),
            "outtime" VARCHAR(50),
            "workingtime" VARCHAR(50),
            "lateby" VARCHAR(50),
            "earlyby" VARCHAR(50),
            "intemperature" VARCHAR(50)
        );

        v_query1 := 'CREATE TEMP TABLE "employeelist" AS SELECT "HRME_Id", a."HRMD_Id", "HRME_EmployeeCode", 
        COALESCE("HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRME_EmployeeLastName", '''') AS "HRME_EmployeeFirstName",
        "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType"
        FROM "HR_Master_Employee" a
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id"
        INNER JOIN "HR_Master_GroupType" d ON a."HRMGT_Id" = d."HRMGT_Id"
        WHERE "HRME_ActiveFlag" = TRUE AND "HRME_LeftFlag" = FALSE AND a."MI_Id" = ' || "miid"::VARCHAR || ' AND "HRME_Id" IN (' || "multiplehrmeid" || ')';
        
        EXECUTE v_query1;

        FOR rec_employee IN 
            SELECT * FROM "employeelist"
        LOOP
            v_HRME_Id := rec_employee."HRME_Id";
            v_HRMD_Id := rec_employee."HRMD_Id";
            v_ecode := rec_employee."HRME_EmployeeCode";
            v_ename := rec_employee."HRME_EmployeeFirstName";
            v_depname := rec_employee."HRMD_DepartmentName";
            v_desgname := rec_employee."HRMDES_DesignationName";
            v_gtype := rec_employee."HRMGT_EmployeeGroupType";

            FOR rec_dates IN 
                SELECT dt FROM "dbo"."alldates"("fromdate"::DATE, "todate"::DATE) AS dt
            LOOP
                v_dt := rec_dates.dt;
                v_punchINtime := '00:00';
                v_punchOUTtime := '00:00';
                v_lateby := '00:00';
                v_earlyby := '00:00';
                v_Temperature := '-';

                SELECT COALESCE((SELECT MIN(c."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed 
                    WHERE "FOEPD_InOutFlg" = 'I' AND ed."foep_id" = b."FOEP_Id" LIMIT 1), '00:00'),
                    COALESCE((SELECT MAX(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed 
                    WHERE "FOEPD_InOutFlg" = 'O' AND ed."foep_id" = b."FOEP_Id" LIMIT 1), '00:00'),
                    COALESCE((SELECT "FOEPD_Temperature" FROM "fo"."FO_Emp_Punch_details" ed 
                    WHERE "FOEPD_InOutFlg" = 'I' AND ed."foep_id" = b."FOEP_Id" LIMIT 1), '-')
                INTO v_punchINtime, v_punchOUTtime, v_Temperature
                FROM "FO"."FO_Emp_Punch" b
                INNER JOIN "FO"."FO_Emp_Punch_Details" c ON c."FOEP_Id" = b."FOEP_Id"
                WHERE b."HRME_Id" = v_HRME_Id AND CAST(b."FOEP_PunchDate" AS DATE) = v_dt
                GROUP BY b."FOEP_PunchDate", b."HRME_Id", b."FOEP_Id"
                LIMIT 1;

                SELECT DISTINCT (CASE WHEN "dbo"."getonlymin"(j."FOEPD_PunchTime") > "dbo"."getonlymin"(c."FOEST_IHalfLoginTime") + "dbo"."getonlymin"(c."FOEST_DelayPerShiftHrMin") 
                    THEN (CASE WHEN "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime") + "dbo"."getonlymin"(c."FOEST_DelayPerShiftHrMin"))), j."FOEPD_PunchTime") <= '00:00' 
                    THEN '00:00' ELSE "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime") + "dbo"."getonlymin"(c."FOEST_DelayPerShiftHrMin"))), j."FOEPD_PunchTime") END) 
                    ELSE '00:00' END)
                INTO v_lateby
                FROM "FO"."FO_Emp_Punch_Details" a
                INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
                INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
                INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
                INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
                INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
                INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
                INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
                INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
                WHERE j."FOEPD_InOutFlg" = 'I' AND j."FOEPD_Flag" = 1 
                    AND j."FOEPD_Id" IN (SELECT "FOEPD_Id" FROM "fo"."FO_Emp_Punch_details" ed 
                        WHERE ed."foep_id" = b."FOEP_Id" ORDER BY "dbo"."getonlymin"("FOEPD_PunchTime") ASC LIMIT 1)
                    AND c."FOHWDT_Id" = d."FOHWDT_Id"
                    AND f."MI_Id" = "miid" AND f."HRME_Id" = v_HRME_Id AND CAST("FOEP_PunchDate" AS DATE) = v_dt
                GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName",
                    "HRMGT_EmployeeGroupType", "FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
                    b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", c."FOEST_IIHalfLogoutTime"
                LIMIT 1;

                SELECT DISTINCT "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IIHalfLogoutTime"))), j."FOEPD_PunchTime")
                INTO v_earlyby
                FROM "FO"."FO_Emp_Punch_Details" a
                INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
                INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
                INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
                INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
                INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
                INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
                INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
                INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
                WHERE j."FOEPD_InOutFlg" = 'O' AND j."FOEPD_Flag" = 1 
                    AND j."FOEPD_Id" IN (SELECT "FOEPD_Id" FROM "fo"."FO_Emp_Punch_details" ed 
                        WHERE ed."foep_id" = b."FOEP_Id" ORDER BY "dbo"."getonlymin"("FOEPD_PunchTime") ASC LIMIT 1)
                    AND c."FOHWDT_Id" = d."FOHWDT_Id"
                    AND f."MI_Id" = "miid" AND f."HRME_Id" = v_HRME_Id AND CAST("FOEP_PunchDate" AS DATE) = v_dt
                GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName",
                    "HRMGT_EmployeeGroupType", "FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
                    b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", c."FOEST_IIHalfLogoutTime"
                LIMIT 1;

                SELECT (CASE WHEN v_punchOUTtime = '00:00' THEN '00:00' ELSE ("dbo"."getdatediff"(v_punchINtime, v_punchOUTtime)) END)
                INTO v_TatalWorkingHours;

                v_punchOUTtime := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_punchOUTtime END);
                v_TatalWorkingHours := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_TatalWorkingHours END);
                v_lateby := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_lateby END);
                v_earlyby := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_earlyby END);
                v_Temperature := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_Temperature END);
                v_punchINtime := (CASE WHEN v_punchINtime = '00:00' THEN 'A' ELSE v_punchINtime END);

                SELECT ((SELECT COUNT(*) FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = "miid" AND b."FOHTWD_HolidayFlag" = 1 AND v_dt BETWEEN a."FOMHWDD_FromDate" AND a."FOMHWDD_ToDate"
                    AND "FOHTWD_HolidayWDTypeFlag" = 'WE' AND "HRMD_ID" = v_HRMD_ID) +
                    (SELECT COUNT(*) FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = "miid" AND b."FOHTWD_HolidayFlag" = 1 AND v_dt BETWEEN a."FOMHWDD_FromDate" AND a."FOMHWDD_ToDate"
                    AND "FOHTWD_HolidayWDTypeFlag" = 'PH'))
                INTO v_COUNT;

                IF v_punchINtime = 'A' THEN
                    IF v_COUNT > 0 THEN
                        v_punchOUTtime := 'H';
                        v_TatalWorkingHours := 'H';
                        v_lateby := 'H';
                        v_earlyby := 'H';
                        v_Temperature := 'H';
                        v_punchINtime := 'H';
                    END IF;
                END IF;

                INSERT INTO "temp_employeeswithoutLogs" VALUES(
                    v_HRME_Id, v_ecode, v_ename, v_depname, v_desgname, v_gtype, v_dt, 
                    TO_CHAR(v_dt, 'Day'), v_punchINtime, v_punchOUTtime, v_TatalWorkingHours, 
                    COALESCE(v_lateby, '00:00'), COALESCE(v_earlyby, '00:00'), v_Temperature
                );

            END LOOP;

        END LOOP;

        RETURN QUERY SELECT * FROM "temp_employeeswithoutLogs";

    ELSIF "punchtype" = 'late' THEN

        v_query := 'SELECT DISTINCT c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode" AS ecode,
            (COALESCE(f."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(f."HRME_EmployeeLastName", '''')) AS ename,
            g."HRMD_DepartmentName" AS depname, h."HRMDES_DesignationName" AS desgname, i."HRMGT_EmployeeGroupType" AS gtype,
            (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS intime,
            b."FOEP_Id", c."FOEST_IHalfLoginTime" AS actualtime, c."FOEST_DelayPerShiftHrMin" AS relaxtime,
            "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
            CAST(b."FOEP_PunchDate" AS DATE) AS punchdate
            FROM "fo"."FO_Emp_Punch_Details" a
            INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id" AND b."MI_Id" = ' || "miid"::VARCHAR || ' AND a."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id" AND j."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id" AND c."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id" AND f."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id" AND g."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id" AND h."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id" AND i."MI_Id" = ' || "miid"::VARCHAR || '
            INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE) AND d."MI_Id" = ' || "miid"::VARCHAR || '
            WHERE (SELECT "dbo"."getonlymin"(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) > "dbo"."getonlymin"("FOEST_IHalfLoginTime") + "dbo"."getonlymin"("FOEST_DelayPerShiftHrMin")
            AND j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1
            AND f."MI_Id" = ' || "miid"::VARCHAR || ' AND ' || v_content1 || ' AND f."HRME_Id" IN (' || "multiplehrmeid" || ') AND c."FOHWDT_Id" = d."FOHWDT_Id"
            GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType",
            "FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin",
            j."FOEPD_PunchTime", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

        RETURN QUERY EXECUTE v_query;

    ELSIF "punchtype" = 'early' THEN

        v_query := 'WITH cte AS (
            SELECT DISTINCT Oa.*, CAST(ob.punchdate AS VARCHAR) AS punchdate, ob.outtime, ob.actualtime, ob.relaxtime, ob.earlyby
            FROM (
                SELECT a."HRME_Id", a."HRME_EmployeeCode" AS ecode,
                (COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''')) AS ename,
                b."HRMD_DepartmentName" AS depname, c."HRMDES_DesignationName" AS desgname, d."HRMGT_EmployeeGroupType" AS gtype
                FROM "HR_Master_Employee" a, "HR_Master_Department" b, "HR_Master_Designation" c, "HR_Master_GroupType" d
                WHERE a."HRMD_Id" = b."HRMD_Id" AND a."HRMGT_Id" = d."HRMGT_Id" AND a."HRMDES_Id" = c."HRMDES_Id" 
                AND a."MI_Id" = ' || "miid"::VARCHAR || ' AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
            ) Oa,
            (
                SELECT b."HRME_Id", b."FOEP_PunchDate" AS punchdate, a.outtime, c."FOEST_IIHalfLogoutTime" AS actualtime,
                c."FOEST_EarlyPerShiftHrMin" AS relaxtime,
                "dbo"."getdatediff"(a.outtime, c."FOEST_IIHalfLogoutTime") AS earlyby
                FROM (
                    SELECT MAX("FOEPD_PunchTime") AS outtime, "FOEP_Id" 
                    FROM "fo"."FO_Emp_Punch_Details"
                    WHERE "FOEPD_InOutFlg" = ''O'' AND "FOEPD_Flag" = 1 
                    GROUP BY "FOEP_Id"
                ) a, "fo"."FO_Emp_Punch" b, "fo"."FO_Emp_Shifts_Timings" c, "fo"."FO_Master_HolidayWorkingDay_Dates" x
                WHERE a."FOEP_Id" = b."FOEP_Id" AND x."FOHWDT_Id" = c."FOHWDT_Id" 
                AND CAST(x."FOMHWDD_FromDate" AS VARCHAR) = CAST(b."FOEP_PunchDate" AS VARCHAR)
                AND b."HRME_Id" = c."HRME_Id" AND b."FOEP_Flag" = 1 AND b."MI_Id" = ' || "miid"::VARCHAR || '
                AND a.outtime < CAST(c."FOEST_IIHalfLogoutTime" AS TIMESTAMP) - c."FOEST_EarlyPerShiftHrMin"
            ) Ob
            WHERE Oa."HRME_Id" = Ob."HRME_Id"
        )
        SELECT "HRME_Id", ecode, ename, depname, desgname, gtype, punchdate, outtime, actualtime, relaxtime,
        (CASE WHEN EXTRACT(EPOCH FROM (actualtime::TIMESTAMP - outtime::TIMESTAMP))/60 > CAST(RIGHT(relaxtime, 2) AS INT) 
        THEN earlyby ELSE '''' END) AS earlyby
        FROM cte WHERE ' || v_content || ' ORDER BY "HRME_Id", punchdate';

        RETURN QUERY EXECUTE v_query;

    ELSIF "punchtype" = 'LIEO' THEN

        v_dynamic := 'SELECT DISTINCT f."HRME_Id", f."HRME_EmployeeCode" AS ecode,
            (COALESCE(f."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(f."HRME_EmployeeLastName", '''')) AS ename,
            g."HRMD_DepartmentName" AS depname, h."HRMDES_DesignationName" AS desgname, i."HRMGT_EmployeeGroupType" AS gtype,
            CAST(b."FOEP_PunchDate" AS DATE) AS punchdate, (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS punchtime,
            c."FOEST_IHalfLoginTime" AS actualtime, c."FOEST_DelayPerShiftHrMin" AS relaxtime,
            "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime") + "dbo"."getonlymin"(c."FOEST_DelayPerShiftHrMin"))), j."FOEPD_PunchTime") AS lateby,
            ''00:00'' AS earlyby, j."FOEPD_InOutFlg"
            FROM "FO"."FO_Emp_Punch_Details" a
            INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
            INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
            INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
            INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
            INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
            INNER