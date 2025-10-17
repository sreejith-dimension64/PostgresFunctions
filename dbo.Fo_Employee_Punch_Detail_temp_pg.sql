CREATE OR REPLACE FUNCTION "dbo"."Fo_Employee_Punch_Detail_temp"(
    p_MI_Id BIGINT,
    p_fromdate DATE,
    p_todate DATE
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "ecode" VARCHAR(50),
    "ename" VARCHAR(250),
    "depname" VARCHAR(250),
    "desgname" VARCHAR(250),
    "gtype" VARCHAR(250),
    "punchdate" TIMESTAMP,
    "punchINtime" VARCHAR(50),
    "punchOUTtime" VARCHAR(50),
    "lateby" VARCHAR(50),
    "earlyby" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dt DATE;
    v_COUNT INT;
    v_HRME_Id BIGINT;
    v_ecode VARCHAR(50);
    v_ename VARCHAR(250);
    v_punchINtime VARCHAR(50);
    v_punchOUTtime VARCHAR(50);
    v_lateby VARCHAR(50);
    v_earlyby VARCHAR(50);
    v_depname VARCHAR(250);
    v_desgname VARCHAR(250);
    v_gtype VARCHAR(250);
    rec_employee RECORD;
    rec_date RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "employeeswithoutLogs" (
        "HRME_Id" BIGINT,
        "ecode" VARCHAR(50),
        "ename" VARCHAR(250),
        "depname" VARCHAR(250),
        "desgname" VARCHAR(250),
        "gtype" VARCHAR(250),
        "punchdate" TIMESTAMP,
        "punchINtime" VARCHAR(50),
        "punchOUTtime" VARCHAR(50),
        "lateby" VARCHAR(50),
        "earlyby" VARCHAR(50)
    ) ON COMMIT DROP;

    FOR rec_employee IN
        SELECT a."HRME_Id", a."HRME_EmployeeCode",
               COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '') AS fullname,
               b."HRMD_DepartmentName", c."HRMDES_DesignationName", d."HRMGT_EmployeeGroupType"
        FROM "HR_Master_Employee" a
        INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id"
        INNER JOIN "HR_Master_GroupType" d ON a."HRMGT_Id" = d."HRMGT_Id"
        WHERE a."HRME_ActiveFlag" = 1 AND a."HRME_LeftFlag" = 0
    LOOP
        v_HRME_Id := rec_employee."HRME_Id";
        v_ecode := rec_employee."HRME_EmployeeCode";
        v_ename := rec_employee.fullname;
        v_depname := rec_employee."HRMD_DepartmentName";
        v_desgname := rec_employee."HRMDES_DesignationName";
        v_gtype := rec_employee."HRMGT_EmployeeGroupType";

        FOR rec_date IN
            SELECT dt FROM "dbo"."alldates"(p_fromdate, p_todate)
        LOOP
            v_dt := rec_date.dt;
            v_punchINtime := NULL;
            v_punchOUTtime := NULL;
            v_lateby := NULL;
            v_earlyby := NULL;

            SELECT COALESCE((SELECT MIN(c."FOEPD_PunchTime")
                            FROM "fo"."FO_Emp_Punch_details" ed
                            WHERE ed."FOEPD_InOutFlg" = 'I' AND ed."foep_id" = b."FOEP_Id"
                            LIMIT 1), '00:00'),
                   COALESCE((SELECT MAX(ed."FOEPD_PunchTime")
                            FROM "fo"."FO_Emp_Punch_details" ed
                            WHERE ed."FOEPD_InOutFlg" = 'O' AND ed."foep_id" = b."FOEP_Id"
                            LIMIT 1), '00:00')
            INTO v_punchINtime, v_punchOUTtime
            FROM "FO"."FO_Emp_Punch" b
            INNER JOIN "FO"."FO_Emp_Punch_Details" c ON c."FOEP_Id" = b."FOEP_Id"
            WHERE b."HRME_Id" = v_HRME_Id AND CAST(b."FOEP_PunchDate" AS DATE) = v_dt
            GROUP BY b."FOEP_PunchDate", b."HRME_Id", b."FOEP_Id"
            LIMIT 1;

            SELECT DISTINCT "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime")
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
              AND j."FOEPD_Id" IN (SELECT ed."FOEPD_Id" 
                                   FROM "fo"."FO_Emp_Punch_details" ed 
                                   WHERE ed."foep_id" = b."FOEP_Id" 
                                   ORDER BY "dbo"."getonlymin"(ed."FOEPD_PunchTime") ASC 
                                   LIMIT 1)
              AND c."FOHWDT_Id" = d."FOHWDT_Id"
              AND f."MI_Id" = 4 AND f."HRME_Id" = v_HRME_Id AND CAST(b."FOEP_PunchDate" AS DATE) = v_dt
            GROUP BY b."FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode", g."HRMD_DepartmentName", h."HRMDES_DesignationName",
                     i."HRMGT_EmployeeGroupType", b."FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
                     b."FOEP_Id", c."FOEST_IHalfLoginTime", c."FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", f."HRME_EmployeeFirstName",
                     f."HRME_EmployeeMiddleName", f."HRME_EmployeeLastName", c."FOEST_IIHalfLogoutTime"
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
              AND j."FOEPD_Id" IN (SELECT ed."FOEPD_Id" 
                                   FROM "fo"."FO_Emp_Punch_details" ed 
                                   WHERE ed."foep_id" = b."FOEP_Id" 
                                   ORDER BY "dbo"."getonlymin"(ed."FOEPD_PunchTime") ASC 
                                   LIMIT 1)
              AND c."FOHWDT_Id" = d."FOHWDT_Id"
              AND f."MI_Id" = 4 AND f."HRME_Id" = v_HRME_Id AND CAST(b."FOEP_PunchDate" AS DATE) = v_dt
            GROUP BY b."FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode", g."HRMD_DepartmentName", h."HRMDES_DesignationName",
                     i."HRMGT_EmployeeGroupType", b."FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
                     b."FOEP_Id", c."FOEST_IHalfLoginTime", c."FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", f."HRME_EmployeeFirstName",
                     f."HRME_EmployeeMiddleName", f."HRME_EmployeeLastName", c."FOEST_IIHalfLogoutTime"
            LIMIT 1;

            INSERT INTO "employeeswithoutLogs" VALUES (
                v_HRME_Id, v_ecode, v_ename, v_depname, v_desgname, v_gtype, v_dt,
                v_punchINtime, v_punchOUTtime, COALESCE(v_lateby, '00:00'), COALESCE(v_earlyby, '00:00')
            );

        END LOOP;

    END LOOP;

    RETURN QUERY SELECT * FROM "employeeswithoutLogs" ORDER BY "punchdate";

END;
$$;