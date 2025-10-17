CREATE OR REPLACE FUNCTION "dbo"."HR_EMP_LateIn_Salary_Deduction" (
    p_HRME_ID BIGINT,
    p_MI_ID BIGINT,
    p_Year BIGINT,
    p_IVRM_Month_Name VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Fromdate VARCHAR(255);
    v_Todate VARCHAR(255);
    v_MONTH BIGINT;
BEGIN

    SELECT "IVRM_Month_Id" INTO v_MONTH
    FROM "IVRM_Month"
    WHERE "IVRM_Month_Name" = p_IVRM_Month_Name;

    v_Fromdate := TO_CHAR(MAKE_DATE(p_Year::INTEGER, v_MONTH::INTEGER, 1), 'YYYY-MM-DD');
    v_Todate := TO_CHAR((MAKE_DATE(p_Year::INTEGER, v_MONTH::INTEGER, 1) + INTERVAL '1 month' - INTERVAL '1 day')::DATE, 'YYYY-MM-DD');

    DROP TABLE IF EXISTS "lateins";
    
    CREATE TEMP TABLE "lateins" AS
    SELECT DISTINCT 
        c."FOHWDT_Id",
        f."HRME_Id",
        f."HRME_EmployeeCode" AS ecode,
        (COALESCE(f."HRME_EmployeeFirstName",'') || ' ' || COALESCE(f."HRME_EmployeeMiddleName",'') || ' ' || COALESCE(f."HRME_EmployeeLastName",'')) AS ename,
        g."HRMD_DepartmentName" AS depname,
        h."HRMDES_DesignationName" AS desgname,
        i."HRMGT_EmployeeGroupType" AS gtype,
        (SELECT MIN(ed."FOEPD_PunchTime") 
         FROM "fo"."FO_Emp_Punch_details" ed 
         WHERE ed."foep_id" = b."FOEP_Id" 
         LIMIT 1) AS intime,
        b."FOEP_Id",
        c."FOEST_IHalfLoginTime" AS actualtime,
        c."FOEST_DelayPerShiftHrMin" AS relaxtime,
        "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
        CAST(b."FOEP_PunchDate" AS DATE) AS punchdate,
        ROW_NUMBER() OVER (PARTITION BY f."HRME_Id", f."HRME_EmployeeCode" ORDER BY f."HRME_Id") AS rownumber
    FROM "fo"."FO_Emp_Punch_Details" a
    INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id" AND b."MI_Id" = p_MI_ID AND a."MI_Id" = p_MI_ID
    INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id" AND j."MI_Id" = p_MI_ID
    INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id" AND c."MI_Id" = p_MI_ID
    INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id" AND f."MI_Id" = p_MI_ID
    INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id" AND g."MI_Id" = p_MI_ID
    INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id" AND h."MI_Id" = p_MI_ID
    INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id" AND i."MI_Id" = p_MI_ID
    INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE) AND d."MI_Id" = p_MI_ID
    WHERE (SELECT "dbo"."getonlymin"(ed."FOEPD_PunchTime") 
           FROM "fo"."FO_Emp_Punch_details" ed
           WHERE ed."foep_id" = b."FOEP_Id"
           LIMIT 1) > "dbo"."getonlymin"(c."FOEST_IHalfLoginTime") + "dbo"."getonlymin"(c."FOEST_DelayPerShiftHrMin")
    AND j."FOEPD_InOutFlg" = 'I' 
    AND j."FOEPD_Flag" = 1
    AND f."MI_Id" = p_MI_ID 
    AND TO_CHAR(b."FOEP_PunchDate", 'YYYY-MM-DD') BETWEEN v_Fromdate AND v_Todate
    AND c."FOHWDT_Id" = d."FOHWDT_Id" 
    AND b."HRME_Id" = p_Hrme_Id
    GROUP BY b."FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode", g."HRMD_DepartmentName", 
             h."HRMDES_DesignationName", i."HRMGT_EmployeeGroupType", c."FOEST_IHalfLoginTime",
             j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id", c."FOEST_DelayPerShiftHrMin", 
             f."HRME_EmployeeFirstName", f."HRME_EmployeeMiddleName", f."HRME_EmployeeLastName";

    DROP TABLE IF EXISTS "LateDeduction";
    
    CREATE TEMP TABLE "LateDeduction" AS
    SELECT 
        "ED"."HRMED_Id",
        "ED"."HRMED_Name",
        lateins."HRME_Id",
        lateins.ecode,
        SUM(CASE 
            WHEN "dbo"."getonlymin"(lateins.lateby) <= 20 THEN 50
            WHEN "dbo"."getonlymin"(lateins.lateby) > 20 AND "dbo"."getonlymin"(lateins.lateby) <= 50 THEN 100
            WHEN "dbo"."getonlymin"(lateins.lateby) > 50 AND "dbo"."getonlymin"(lateins.lateby) <= 80 THEN 150 
            ELSE 200 
        END) AS "AmuntDeduction"
    FROM "dbo"."HR_Master_EarningsDeductions" "ED"
    INNER JOIN "dbo"."HR_Employee_EarningsDeductions" "EED" ON "EED"."HRMED_Id" = "ED"."HRMED_Id"
    INNER JOIN "lateins" ON lateins."HRME_Id" = "EED"."HRME_Id"
    WHERE lateins."HRME_Id" = p_Hrme_Id 
    AND "ED"."HRMED_EDTypeFlag" = 'LOP'
    AND lateins.rownumber > 1
    GROUP BY "ED"."HRMED_Id", "ED"."HRMED_Name", lateins."HRME_Id", lateins.ecode;

    UPDATE "dbo"."HR_Employee_Salary_Details" AS "SD"
    SET "HRESD_Amount" = lates."AmuntDeduction"
    FROM "dbo"."HR_Employee_Salary" "ES"
    INNER JOIN "LateDeduction" lates ON "ES"."HRME_Id" = lates."HRME_Id" 
        AND "ES"."HRES_Year" = p_Year 
        AND "ES"."HRES_Month" = p_IVRM_Month_Name 
        AND "SD"."HRMED_Id" = lates."HRMED_Id"
    WHERE "SD"."HRES_Id" = "ES"."HRES_Id"
    AND lates."HRME_Id" = p_HRME_ID;

    DROP TABLE IF EXISTS "lateins";
    DROP TABLE IF EXISTS "LateDeduction";

    RETURN;
END;
$$;