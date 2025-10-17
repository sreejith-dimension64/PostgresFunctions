CREATE OR REPLACE FUNCTION "dbo"."FO_ParametersCount"(
    p_MI_Id bigint,
    p_From_Date varchar,
    p_To_Date varchar,
    p_HRME_Id bigint
)
RETURNS TABLE(
    "NoOfBiometricRegisterCount" bigint,
    "TotalNoOfPublicHolidays" bigint,
    "TotalNoOfWorkingHolidays" bigint,
    "EmpInwardCount" bigint,
    "EmpOutwardCount" bigint,
    "EmpAbsenetCount" bigint,
    "EmpLateInCount" bigint,
    "EmpEarlyOutCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_NoOfBiometricRegisterCount bigint;
    v_TotalNoOfPublicHolidays bigint;
    v_TotalNoOfWorkingHolidays bigint;
    v_EmpInwardCount bigint;
    v_EmpOutwardCount bigint;
    v_EmpAbsenetCount bigint;
    v_EmpLateInCount bigint;
    v_EmpEarlyOutCount bigint;
BEGIN

    SELECT count(distinct "FOBVIEM_BiometricId") INTO v_NoOfBiometricRegisterCount
    FROM "FO"."FO_Biometric_VAPS_IEMapping"
    WHERE "MI_Id" = p_MI_Id AND "FOBVIEM_BiometricId" != '';

    EXECUTE 'SELECT count(*)
    FROM "FO"."FO_HolidayWorkingDay_Type" "FHWT"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHWD" ON "FHWT"."FOHWDT_Id" = "FMHWD"."FOHWDT_Id" AND "FHWT"."MI_Id" = "FMHWD"."MI_Id"
    WHERE "FHWT"."FOHTWD_HolidayFlag" = 0 AND "FHWT"."MI_Id" = $1 
    AND CAST("FMHWD"."FOMHWDD_FromDate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date)
    INTO v_TotalNoOfWorkingHolidays
    USING p_MI_Id;

    EXECUTE 'SELECT count(*)
    FROM "FO"."FO_HolidayWorkingDay_Type" "FHWT"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHWD" ON "FHWT"."FOHWDT_Id" = "FMHWD"."FOHWDT_Id" AND "FHWT"."MI_Id" = "FMHWD"."MI_Id"
    WHERE "FHWT"."FOHTWD_HolidayFlag" = 1 AND "FHWT"."MI_Id" = $1 
    AND CAST("FMHWD"."FOMHWDD_FromDate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date)
    INTO v_TotalNoOfPublicHolidays
    USING p_MI_Id;

    EXECUTE 'SELECT count(lateby), count(distinct earlyby)
    FROM (
        SELECT distinct f."HRME_Id", f."HRME_EmployeeCode" AS ecode,
        (COALESCE(f."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(f."HRME_EmployeeLastName", '''')) AS ename,
        g."HRMD_DepartmentName" AS depname, h."HRMDES_DesignationName" AS desgname, i."HRMGT_EmployeeGroupType" AS gtype,
        CAST("FOEP_PunchDate" AS date) AS punchdate,
        (SELECT min(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS punchtime,
        c."FOEST_IHalfLoginTime" AS actualtime, c."FOEST_DelayPerShiftHrMin" AS relaxtime,
        "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
        ''00:00'' AS earlyby, j."FOEPD_InOutFlg"
        FROM "FO"."FO_Emp_Punch_Details" a
        INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
        INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS date) = CAST(d."FOMHWDD_FromDate" AS date)
        WHERE (SELECT "dbo"."getonlymin"(MIN(ed."FOEPD_PunchTime")) FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) > 
              "dbo"."getonlymin"("FOEST_IHalfLoginTime") + "dbo"."getonlymin"("FOEST_DelayPerShiftHrMin")
        AND j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1 
        AND j."FOEPD_Id" IN (SELECT "FOEPD_Id" FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" ORDER BY "dbo"."getonlymin"("FOEPD_PunchTime") ASC LIMIT 1)
        AND c."FOHWDT_Id" = d."FOHWDT_Id"
        AND f."MI_Id" = $1 
        AND CAST("FOEP_PunchDate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date) || '
        GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName",
                 "HRMGT_EmployeeGroupType", "FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg",
                 b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", "HRME_EmployeeFirstName", 
                 "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"

        UNION

        SELECT distinct "HRME_Id", ecode, ename, depname, desgname, gtype, "FOEP_PunchDate" AS punchdate, outtime AS punchtime,
               actualtime, relaxtime, ''00:00'' AS lateby,
               (CASE WHEN EXTRACT(EPOCH FROM (actualtime - outtime))/60 > CAST(right(relaxtime, 2) AS int) THEN earlyby ELSE '''' END) AS earlyby,
               "FOEPD_InOutFlg"
        FROM (
            SELECT distinct Oa.*, CAST(ob.punchdate AS varchar) AS "FOEP_PunchDate", ob.outtime, ob.actualtime, ob.relaxtime, ob.earlyby, "FOEPD_InOutFlg"
            FROM (
                SELECT a."HRME_Id", a."HRME_EmployeeCode" AS ecode,
                       (COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''')) AS ename,
                       b."HRMD_DepartmentName" AS depname, c."HRMDES_DesignationName" AS desgname, d."HRMGT_EmployeeGroupType" AS gtype
                FROM "HR_Master_Employee" a, "HR_Master_Department" b, "HR_Master_Designation" c, "HR_Master_GroupType" d
                WHERE a."HRMD_Id" = b."HRMD_Id" AND a."HRMGT_Id" = d."HRMGT_Id" AND a."HRMDES_Id" = c."HRMDES_Id" AND a."MI_Id" = $1
            ) Oa,
            (
                SELECT b."HRME_Id", b."FOEP_PunchDate" AS punchdate, a.outtime, c."FOEST_IIHalfLogoutTime" AS actualtime,
                       c."FOEST_EarlyPerShiftHrMin" AS relaxtime, "dbo"."getdatediff"(a.outtime, c."FOEST_IIHalfLogoutTime") AS earlyby, "FOEPD_InOutFlg"
                FROM (
                    SELECT max("FOEPD_PunchTime") AS outtime, "FOEP_Id", "FOEPD_InOutFlg"
                    FROM "fo"."FO_Emp_Punch_Details"
                    WHERE "FOEPD_InOutFlg" = ''O'' AND "FOEPD_Flag" = 1
                    GROUP BY "FOEP_Id", "FOEPD_InOutFlg"
                ) a, "fo"."FO_Emp_Punch" b, "fo"."FO_Emp_Shifts_Timings" c,
                "fo"."FO_Master_HolidayWorkingDay_Dates" d, "FO"."FO_HolidayWorkingDay_Type" e
                WHERE a."FOEP_Id" = b."FOEP_Id" AND b."HRME_Id" = c."HRME_Id" AND b."FOEP_Flag" = 1
                AND CAST(b."FOEP_PunchDate" AS date) = CAST(d."FOMHWDD_FromDate" AS date) 
                AND e."FOHWDT_Id" = d."FOHWDT_Id" AND e."MI_Id" = $1
                AND c."FOHWDT_Id" = d."FOHWDT_Id" AND d."FOMHWD_ActiveFlg" = 1 AND b."MI_Id" = $1
                AND "dbo"."getonlymin"(a.outtime) < "dbo"."getonlymin"(c."FOEST_IIHalfLogoutTime") - "dbo"."getonlymin"(c."FOEST_EarlyPerShiftHrMin")
            ) Ob
            WHERE Oa."HRME_Id" = Ob."HRME_Id"
        ) a 
        WHERE CAST("FOEP_PunchDate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date) || '
    ) AS New'
    INTO v_EmpLateInCount, v_EmpEarlyOutCount
    USING p_MI_Id;

    EXECUTE 'SELECT count(distinct CAST("FMHWD"."FOMHWDD_FromDate" AS date))
    FROM "FO"."FO_HolidayWorkingDay_Type" "FHWT"
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHWD" ON "FMHWD"."FOHWDT_Id" = "FHWT"."FOHWDT_Id"
    WHERE "FHWT"."MI_Id" = $1 AND "FOHTWD_HolidayFlag" = 0 
    AND CAST("FMHWD"."FOMHWDD_FromDate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date) || '
    AND CAST("FMHWD"."FOMHWDD_FromDate" AS date) NOT IN (
        SELECT distinct CAST("foep_punchdate" AS date) 
        FROM "FO"."FO_Emp_Punch"
        WHERE CAST("foep_punchdate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date) || '
    )'
    INTO v_EmpAbsenetCount
    USING p_MI_Id;

    EXECUTE 'SELECT count(CASE WHEN "FOEPD_InOutFlg" = ''I'' THEN 1 END), 
                    count(CASE WHEN "FOEPD_InOutFlg" = ''O'' THEN 1 END)
    FROM "FO"."FO_Emp_Punch" "FEP"
    INNER JOIN "FO"."FO_Emp_Punch_Details" "FEPD" ON "FEP"."FOEP_Id" = "FEPD"."FOEP_Id"
    WHERE CAST("foep_punchdate" AS varchar) BETWEEN ' || quote_literal(p_From_Date) || ' AND ' || quote_literal(p_To_Date)
    INTO v_EmpInwardCount, v_EmpOutwardCount;

    RETURN QUERY
    SELECT v_NoOfBiometricRegisterCount AS "NoOfBiometricRegisterCount",
           v_TotalNoOfPublicHolidays AS "TotalNoOfPublicHolidays",
           v_TotalNoOfWorkingHolidays AS "TotalNoOfWorkingHolidays",
           v_EmpInwardCount AS "EmpInwardCount",
           v_EmpOutwardCount AS "EmpOutwardCount",
           v_EmpAbsenetCount AS "EmpAbsenetCount",
           v_EmpLateInCount AS "EmpLateInCount",
           v_EmpEarlyOutCount AS "EmpEarlyOutCount";

END;
$$;