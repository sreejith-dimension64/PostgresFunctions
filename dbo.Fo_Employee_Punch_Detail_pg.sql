CREATE OR REPLACE FUNCTION "dbo"."Fo_Employee_Punch_Detail"(
    p_MI_Id BIGINT,
    p_HRME_Id BIGINT,
    p_fromdate DATE,
    p_todate DATE
)
RETURNS TABLE(
    ecode VARCHAR,
    ename VARCHAR,
    "HRME_Id" BIGINT,
    punchdate DATE,
    punchINtime VARCHAR,
    punchOUTtime VARCHAR,
    lateby VARCHAR,
    earlyby VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dt DATE;
    v_COUNT INT;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_result(
        ecode VARCHAR,
        ename VARCHAR,
        "HRME_Id" BIGINT,
        punchdate DATE,
        punchINtime VARCHAR,
        punchOUTtime VARCHAR,
        lateby VARCHAR,
        earlyby VARCHAR
    ) ON COMMIT DROP;

    INSERT INTO temp_result
    SELECT 
        COALESCE(X.ecode, Y.ecode) AS ecode,
        COALESCE(X.ename, Y.ename) AS ename,
        COALESCE(X."HRME_Id", Y."HRME_Id") AS "HRME_Id",
        COALESCE(X.punchdate, Y.punchdate) AS punchdate,
        COALESCE(X.punchINtime, '00:00') AS punchINtime,
        CASE WHEN X.punchINtime = X.punchOUTtime THEN '00:00' ELSE COALESCE(X.punchOUTtime, '00:00') END AS punchOUTtime,
        COALESCE(X.lateby, '00:00') AS lateby,
        COALESCE(Y.earlyby, '00:00') AS earlyby
    FROM (
        SELECT DISTINCT 
            f."HRME_Id",
            f."HRME_EmployeeCode" AS ecode,
            (COALESCE(f."HRME_EmployeeFirstName", '') || ' ' || COALESCE(f."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(f."HRME_EmployeeLastName", '')) AS ename,
            CAST(b."FOEP_PunchDate" AS DATE) AS punchdate,
            (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS punchINtime,
            (SELECT MAX(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS punchOUTtime,
            "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
            '00:00' AS earlyby
        FROM "FO"."FO_Emp_Punch_Details" a
        INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
        INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
        WHERE j."FOEPD_InOutFlg" = 'I' 
            AND j."FOEPD_Flag" = 1 
            AND j."FOEPD_Id" IN (SELECT "FOEPD_Id" FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" ORDER BY "dbo"."getonlymin"("FOEPD_PunchTime") ASC LIMIT 1)
            AND c."FOHWDT_Id" = d."FOHWDT_Id"
            AND f."MI_Id" = p_MI_Id 
            AND TO_CHAR(b."FOEP_PunchDate", 'YYYY-MM-DD') BETWEEN p_fromdate::TEXT AND p_todate::TEXT 
            AND f."HRME_Id" = p_HRME_Id
        GROUP BY b."FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode", g."HRMD_DepartmentName", h."HRMDES_DesignationName", 
            i."HRMGT_EmployeeGroupType", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
            b."FOEP_Id", c."FOEST_DelayPerShiftHrMin", f."HRME_EmployeeFirstName", f."HRME_EmployeeMiddleName", f."HRME_EmployeeLastName", c."FOEST_IIHalfLogoutTime"
    ) X
    FULL JOIN (
        SELECT DISTINCT 
            "HRME_Id",
            ecode,
            ename,
            "FOEP_PunchDate" AS punchdate,
            outtime,
            intime,
            (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = "FOEP_Id" LIMIT 1) AS punchINtime,
            (SELECT MAX(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = "FOEP_Id" LIMIT 1) AS punchOUTtime,
            '00:00' AS lateby,
            (CASE WHEN EXTRACT(EPOCH FROM (actualtime - outtime)) / 60 > CAST(RIGHT(relaxtime, 2) AS INT) THEN earlyby ELSE '' END) AS earlyby
        FROM (
            SELECT DISTINCT 
                Oa.*,
                TO_CHAR(ob.punchdate, 'YYYY-MM-DD') AS "FOEP_PunchDate",
                ob.outtime,
                ob.intime,
                ob.actualtime,
                ob.relaxtime,
                ob.earlyby 
            FROM (
                SELECT 
                    a."HRME_Id",
                    a."HRME_EmployeeCode" AS ecode,
                    (COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '')) AS ename
                FROM "HR_Master_Employee" a,
                    "HR_Master_Department" b,
                    "HR_Master_Designation" c,
                    "HR_Master_GroupType" d
                WHERE a."HRMD_Id" = b."HRMD_Id" 
                    AND a."HRMGT_Id" = d."HRMGT_Id" 
                    AND a."HRMDES_Id" = c."HRMDES_Id" 
                    AND a."MI_Id" = p_MI_Id 
                    AND a."HRME_Id" = p_HRME_Id
            ) Oa,
            (
                SELECT 
                    b."HRME_Id",
                    b."FOEP_PunchDate" AS punchdate,
                    a.outtime,
                    a.intime,
                    c."FOEST_IIHalfLogoutTime" AS actualtime,
                    c."FOEST_EarlyPerShiftHrMin" AS relaxtime,
                    "dbo"."getdatediff"(a.outtime, c."FOEST_IIHalfLogoutTime") AS earlyby
                FROM (
                    SELECT 
                        MAX("FOEPD_PunchTime") AS outtime,
                        MIN("FOEPD_PunchTime") AS intime,
                        "FOEP_Id",
                        "FOEPD_InOutFlg"
                    FROM "fo"."FO_Emp_Punch_Details"
                    WHERE "FOEPD_InOutFlg" = 'O' AND "FOEPD_Flag" = 1
                    GROUP BY "FOEP_Id", "FOEPD_InOutFlg"
                ) a,
                "fo"."FO_Emp_Punch" b,
                "fo"."FO_Emp_Shifts_Timings" c,
                "fo"."FO_Master_HolidayWorkingDay_Dates" d,
                "FO"."FO_HolidayWorkingDay_Type" e
                WHERE a."FOEP_Id" = b."FOEP_Id" 
                    AND b."HRME_Id" = c."HRME_Id" 
                    AND b."FOEP_Flag" = 1
                    AND CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE) 
                    AND e."FOHWDT_Id" = d."FOHWDT_Id" 
                    AND e."MI_Id" = p_MI_Id
                    AND c."FOHWDT_Id" = d."FOHWDT_Id" 
                    AND d."FOMHWD_ActiveFlg" = 1 
                    AND b."MI_Id" = p_MI_Id
                    AND "dbo"."getonlymin"(a.outtime) < "dbo"."getonlymin"(c."FOEST_IIHalfLogoutTime") - "dbo"."getonlymin"(c."FOEST_EarlyPerShiftHrMin")
            ) Ob
            WHERE Oa."HRME_Id" = Ob."HRME_Id"
        ) a 
        WHERE TO_CHAR(a."FOEP_PunchDate"::DATE, 'YYYY-MM-DD') BETWEEN p_fromdate::TEXT AND p_todate::TEXT
    ) Y ON X."HRME_Id" = Y."HRME_Id" AND X.punchdate = Y.punchdate
    ORDER BY punchdate;

    FOR v_dt IN 
        SELECT dt FROM "dbo"."alldates"(p_fromdate, p_todate)
    LOOP
        SELECT COUNT(*) INTO v_COUNT 
        FROM temp_result 
        WHERE "HRME_Id" = p_HRME_Id AND punchdate = v_dt;

        IF (v_COUNT = 0) THEN
            INSERT INTO temp_result
            SELECT 
                a."HRME_EmployeeCode",
                (COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '')),
                a."HRME_Id",
                CAST(b."FOEP_PunchDate" AS DATE),
                COALESCE((SELECT MIN(c."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE "FOEPD_InOutFlg" = 'I' AND ed."foep_id" = b."FOEP_Id" LIMIT 1), '00:00'),
                COALESCE((SELECT MAX(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE "FOEPD_InOutFlg" = 'O' AND ed."foep_id" = b."FOEP_Id" LIMIT 1), '00:00'),
                '00:00',
                '00:00'
            FROM "HR_Master_Employee" a
            INNER JOIN "FO"."FO_Emp_Punch" b ON a."HRME_Id" = b."HRME_Id"
            INNER JOIN "FO"."FO_Emp_Punch_Details" c ON c."FOEP_Id" = b."FOEP_Id"
            WHERE a."HRME_Id" = p_HRME_Id AND TO_CHAR(b."FOEP_PunchDate", 'YYYY-MM-DD') = v_dt::TEXT
            GROUP BY a."HRME_EmployeeCode", a."HRME_EmployeeFirstName", a."HRME_EmployeeMiddleName", a."HRME_EmployeeLastName", b."FOEP_PunchDate", a."HRME_Id", b."FOEP_Id";
        END IF;
    END LOOP;

    RETURN QUERY 
    SELECT t.ecode, t.ename, t."HRME_Id", t.punchdate, t.punchINtime, t.punchOUTtime, t.lateby, t.earlyby 
    FROM temp_result t 
    ORDER BY t.punchdate;

END;
$$;