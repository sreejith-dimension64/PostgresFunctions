CREATE OR REPLACE FUNCTION "dbo"."Employee_Log_Report_Total_GIS"(
    p_MI_id BIGINT,
    p_HRME_Id TEXT,
    p_Month VARCHAR(50),
    p_Year VARCHAR(50)
)
RETURNS TABLE(
    "Hrme_id" BIGINT,
    "HRME_EmployeeCode" VARCHAR,
    "EmployeeName" TEXT,
    "TPDays" BIGINT,
    "LateDays" BIGINT,
    "PHDay" BIGINT,
    "WeekOffDay" BIGINT,
    "AbsentDays" BIGINT,
    "TotalWrkingHours" VARCHAR(50),
    "TotalOvertimeHours" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Monthid BIGINT;
    v_FOMHWDD_FromDate TIMESTAMP;
    v_HRMEID BIGINT;
    v_punchcount BIGINT;
    v_leaveappyedcount BIGINT;
    v_hrme_record RECORD;
BEGIN

    SELECT "IVRM_Month_Id" INTO v_Monthid 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Name" = p_Month;

    DROP TABLE IF EXISTS temp_LeaveDetails;
    CREATE TEMP TABLE temp_LeaveDetails (
        "Hrme_id" BIGINT,
        "TPDays" BIGINT,
        "LateDays" BIGINT,
        "PHDay" BIGINT,
        "WeekOffDay" BIGINT,
        "AbsentDays" BIGINT,
        "TotalWrkingHours" VARCHAR(50),
        "TotalOvertimeHours" VARCHAR(50)
    );

    DROP TABLE IF EXISTS temp_leavetemp;
    CREATE TEMP TABLE temp_leavetemp (
        "HRME_Id" BIGINT,
        "FOEP_PunchDate" TIMESTAMP
    );

    FOR v_hrme_record IN
        SELECT DISTINCT emp."HRME_Id", a."FOMHWDD_FromDate"
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" a
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
        INNER JOIN "FO"."FO_Emp_Shifts_Timings" ST ON ST."FOHWDT_Id" = b."FOHWDT_Id"
        INNER JOIN "hr_master_Employee" emp ON emp."HRME_Id" = ST."HRME_Id"
        WHERE b."FOHTWD_HolidayFlag" = 0
        AND a."MI_Id" = p_MI_Id
        AND EXTRACT(MONTH FROM a."FOMHWDD_FromDate") = v_Monthid
        AND EXTRACT(YEAR FROM a."FOMHWDD_FromDate") = p_Year::INTEGER
        AND emp."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
        AND b."FOHTWD_HolidayWDTypeFlag" = 'WD'
        ORDER BY a."FOMHWDD_FromDate" DESC
    LOOP
        v_HRMEID := v_hrme_record."HRME_Id";
        v_FOMHWDD_FromDate := v_hrme_record."FOMHWDD_FromDate";

        SELECT COUNT(*) INTO v_punchcount
        FROM "FO"."FO_Emp_Punch"
        WHERE "HRME_Id" = v_HRMEID
        AND CAST("FOEP_PunchDate" AS DATE) = CAST(v_FOMHWDD_FromDate AS DATE);

        IF v_punchcount = 0 THEN
            SELECT COUNT(*) INTO v_leaveappyedcount
            FROM "HR_Emp_Leave_Application"
            WHERE "HRME_Id" = v_HRMEID
            AND v_FOMHWDD_FromDate BETWEEN "HRELAP_FromDate" AND "HRELAP_ToDate"
            AND "HRELAP_ApplicationStatus" NOT IN ('Applied', 'Approved', 'Partial Approved');

            IF v_leaveappyedcount = 0 THEN
                INSERT INTO temp_leavetemp VALUES(v_HRMEID, v_FOMHWDD_FromDate);
            END IF;
        END IF;
    END LOOP;

    INSERT INTO temp_LeaveDetails ("Hrme_id", "AbsentDays")
    SELECT "HRME_Id", COUNT(1)
    FROM temp_leavetemp
    GROUP BY "HRME_Id";

    INSERT INTO temp_LeaveDetails ("Hrme_id", "TPDays")
    SELECT P."HRME_Id", COUNT("FOEP_PunchDate")
    FROM "FO"."FO_Emp_Punch" P
    INNER JOIN "hr_master_Employee" EMP ON EMP."HRME_Id" = P."HRME_Id"
    WHERE P."MI_Id" = p_MI_Id
    AND P."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
    AND EXTRACT(MONTH FROM "FOEP_PunchDate") = v_Monthid
    AND EXTRACT(YEAR FROM "FOEP_PunchDate") = p_Year::INTEGER
    GROUP BY P."HRME_Id";

    INSERT INTO temp_LeaveDetails ("Hrme_id", "LateDays")
    SELECT P."HRME_Id", COUNT(DISTINCT "FOEP_PunchDate")
    FROM "FO"."FO_Emp_Punch" P
    INNER JOIN "FO"."FO_Emp_Punch_Details" PD ON PD."FOEP_Id" = P."FOEP_Id"
    INNER JOIN "hr_master_Employee" EMP ON EMP."HRME_Id" = P."HRME_Id"
    INNER JOIN "FO"."FO_Emp_Shifts_Timings" ST ON ST."HRME_Id" = P."HRME_Id"
    WHERE P."MI_Id" = p_MI_Id
    AND "dbo"."getonlymin"(PD."FOEPD_PunchTime") > "dbo"."getonlymin"(ST."FOEST_IHalfLoginTime")
    AND PD."FOEPD_InOutFlg" = 'I'
    AND P."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
    AND EXTRACT(MONTH FROM "FOEP_PunchDate") = v_Monthid
    AND EXTRACT(YEAR FROM "FOEP_PunchDate") = p_Year::INTEGER
    GROUP BY P."HRME_Id";

    INSERT INTO temp_LeaveDetails ("Hrme_id", "PHDay")
    SELECT emp."HRME_Id", COUNT(DISTINCT a."FOMHWDD_FromDate")
    FROM "FO"."FO_Master_HolidayWorkingDay_Dates" a
    INNER JOIN "FO"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    INNER JOIN "FO"."FO_Emp_Shifts_Timings" ST ON ST."FOHWDT_Id" = b."FOHWDT_Id"
    INNER JOIN "hr_master_Employee" emp ON emp."HRME_Id" = ST."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id
    AND b."FOHTWD_HolidayFlag" = 1
    AND emp."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
    AND EXTRACT(MONTH FROM a."FOMHWDD_FromDate") = v_Monthid
    AND EXTRACT(YEAR FROM a."FOMHWDD_ToDate") = p_Year::INTEGER
    GROUP BY emp."HRME_Id";

    INSERT INTO temp_LeaveDetails ("Hrme_id", "WeekOffDay")
    SELECT emp."HRME_Id", COUNT(DISTINCT a."FOMHWDD_FromDate")
    FROM "FO"."FO_Master_HolidayWorkingDay_Dates" a
    INNER JOIN "FO"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    INNER JOIN "FO"."FO_Emp_Shifts_Timings" ST ON ST."FOHWDT_Id" = b."FOHWDT_Id"
    INNER JOIN "hr_master_Employee" emp ON emp."HRME_Id" = ST."HRME_Id"
    WHERE a."MI_Id" = p_MI_Id
    AND EXTRACT(MONTH FROM a."FOMHWDD_FromDate") = v_Monthid
    AND EXTRACT(YEAR FROM a."FOMHWDD_ToDate") = p_Year::INTEGER
    AND emp."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
    AND b."FOHTWD_HolidayWDTypeFlag" = 'WE'
    GROUP BY emp."HRME_Id";

    DROP TABLE IF EXISTS temp_WorkingHours;
    CREATE TEMP TABLE temp_WorkingHours AS
    WITH "PunchDetails" AS (
        SELECT 
            emp."HRME_Id",
            emp."HRME_EmployeeCode" AS ecode,
            (COALESCE(emp."HRME_EmployeeFirstName", '') || ' ' || 
             COALESCE(emp."HRME_EmployeeMiddleName", '') || ' ' || 
             COALESCE(emp."HRME_EmployeeLastName", '')) AS ename,
            p."FOEP_PunchDate" AS punchdate,
            LEFT(TO_CHAR(MIN(pd."FOEPD_PunchTime"::TIME), 'HH24:MI:SS'), 5) AS intime,
            CASE 
                WHEN COUNT(pd."FOEPD_PunchTime") = 1 THEN '00:00'
                ELSE LEFT(TO_CHAR(MAX(pd."FOEPD_PunchTime"::TIME), 'HH24:MI:SS'), 5)
            END AS outtime,
            ST."FOEST_IIHalfLogoutTime"
        FROM "hr_master_Employee" emp
        INNER JOIN "FO"."FO_Emp_Punch" p ON p."HRME_Id" = emp."HRME_Id"
        INNER JOIN "FO"."FO_Emp_Punch_Details" pd ON p."FOEP_Id" = pd."FOEP_Id"
        INNER JOIN "FO"."FO_Emp_Shifts_Timings" ST ON ST."HRME_Id" = emp."HRME_Id"
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" DT ON DT."FOHWDT_Id" = ST."FOHWDT_Id"
        WHERE emp."MI_Id" = 31
        AND emp."HRME_Id" IN (SELECT CAST(unnest(string_to_array(p_HRME_Id, ',')) AS BIGINT))
        GROUP BY emp."HRME_Id", emp."HRME_EmployeeCode", p."FOEP_PunchDate",
                 emp."HRME_EmployeeFirstName", emp."HRME_EmployeeMiddleName",
                 emp."HRME_EmployeeLastName", ST."FOEST_IIHalfLogoutTime"
    )
    SELECT 
        "HRME_Id",
        CASE 
            WHEN outtime = '00:00' THEN '00:00'
            ELSE "dbo"."getdatediff"(intime, outtime)
        END AS workingtime,
        CASE 
            WHEN outtime > "FOEST_IIHalfLogoutTime" 
            THEN "dbo"."getdatediff"("FOEST_IIHalfLogoutTime", outtime)
            ELSE '00:00'
        END AS "Overtime"
    FROM "PunchDetails"
    WHERE EXTRACT(MONTH FROM punchdate) = v_Monthid
    AND EXTRACT(YEAR FROM punchdate) = p_Year::INTEGER;

    INSERT INTO temp_LeaveDetails ("HRME_Id", "TotalWrkingHours", "TotalOvertimeHours")
    SELECT 
        "HRME_Id",
        "dbo"."mintotime"(SUM("dbo"."getonlymin"(workingtime))) AS "TotalWrkingHours",
        "dbo"."mintotime"(SUM("dbo"."getonlymin"("Overtime"))) AS "TotalOvertimeHours"
    FROM temp_WorkingHours
    GROUP BY "HRME_Id";

    RETURN QUERY
    SELECT 
        a."Hrme_id",
        b."HRME_EmployeeCode",
        (COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || 
         COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || 
         COALESCE(b."HRME_EmployeeLastName", ''))::TEXT AS "EmployeeName",
        MAX(a."TPDays") AS "TPDays",
        MAX(a."LateDays") AS "LateDays",
        MAX(a."PHDay") AS "PHDay",
        MAX(a."WeekOffDay") AS "WeekOffDay",
        MAX(a."AbsentDays") AS "AbsentDays",
        MAX(a."TotalWrkingHours") AS "TotalWrkingHours",
        MAX(a."TotalOvertimeHours") AS "TotalOvertimeHours"
    FROM temp_LeaveDetails a
    INNER JOIN "hr_master_employee" b ON b."HRME_Id" = a."Hrme_id"
    WHERE b."HRME_ActiveFlag" = 1 
    AND b."HRME_LeftFlag" = 0
    AND a."Hrme_id" IN (SELECT "HRME_Id" FROM "FO"."FO_Emp_Shifts_Timings")
    GROUP BY a."Hrme_id", b."HRME_EmployeeCode", b."HRME_EmployeeFirstName",
             b."HRME_EmployeeMiddleName", b."HRME_EmployeeLastName";

    DROP TABLE IF EXISTS temp_leavetemp;
    DROP TABLE IF EXISTS temp_LeaveDetails;
    DROP TABLE IF EXISTS temp_WorkingHours;

END;
$$;