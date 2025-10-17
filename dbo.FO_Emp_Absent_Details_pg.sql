CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_Absent_Details"(
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "miid" BIGINT,
    "type" VARCHAR(10),
    OUT "cols" TEXT,
    OUT "totalpresent" VARCHAR(10)
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "var" VARCHAR(200);
    "var1" VARCHAR(50);
    "M" VARCHAR(50);
BEGIN

SELECT COUNT("FOMHWDD_ToDate")::VARCHAR(10) INTO "totalpresent" 
FROM "FO"."FO_HolidayWorkingDay_Type" a, "FO"."FO_Master_HolidayWorkingDay_Dates" b
WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE) 
AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE) 
AND a."FOHWDT_Id" = b."FOHWDT_Id" 
AND b."FOMHWD_ActiveFlg" = 1 
AND a."MI_Id" = "miid" 
AND a."FOHTWD_HolidayFlag" = 0;

DROP TABLE IF EXISTS "Empfomonthly_New";

CREATE TEMP TABLE "Empfomonthly_New"(
    "ecode" VARCHAR(100),
    "ename" TEXT,
    "HRME_DOJ" VARCHAR(10),
    "HRME_Id" BIGINT,
    "tpdays" INT,
    "HRMDES_DesignationName" VARCHAR(100),
    "HRMD_DepartmentName" VARCHAR(100),
    "hwkdays" INT,
    "value" INT,
    "col" VARCHAR(10)
);

DROP TABLE IF EXISTS "HolidaysDates";

IF "type" = 'absent' THEN
    "var" := 'convert(date,a.FOEP_PunchDate)';
    "var1" := '';
    SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt) INTO "cols"
    FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
    "M" := 'A';
END IF;

IF ("M" = 'A') THEN

    "query" := '
    SELECT DISTINCT "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMDES_DesignationName", "HRMD_DepartmentName", "workday", "tpdays", ("workday" - "tpdays") AS "absentdays" 
    FROM (
        SELECT DISTINCT ES."HRME_Id", ES."HRME_EmployeeCode" AS "ecode",
        (COALESCE(ES."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeLastName", '' '')) AS "ename",
        ES."HRME_DOJ", D."HRMDES_DesignationName", F."HRMD_DepartmentName",
        (SELECT COUNT(*) AS "workday" FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a 
         INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id" 
         WHERE a."mi_id" = ES."MI_Id" AND b."FOHTWD_HolidayFlag" = 0 
         AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || ''' AND a."FOMHWDD_ToDate" <= ''' || "todate" || ''') AS "workday",
        (SELECT COUNT(a."FOEP_PunchDate") FROM "FO"."FO_Emp_Punch" a  
         WHERE a."MI_Id" = ' || "miid"::VARCHAR || ' AND a."HRME_Id" = ES."HRME_Id" 
         AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''  
         AND a."FOEP_HolidayPunchFlg" = 0) AS "tpdays"
        FROM "HR_Master_employee" ES 
        LEFT JOIN "HR_Master_Designation" D ON ES."HRMDES_Id" = D."HRMDES_Id" AND D."MI_Id" = ' || "miid"::VARCHAR || ' AND ES."MI_Id" = ' || "miid"::VARCHAR || ' 
        INNER JOIN "HR_Master_Department" F ON ES."HRMD_Id" = F."HRMD_Id"
        WHERE ES."MI_Id" = ' || "miid"::VARCHAR || ' AND ES."HRME_ActiveFlag" = 1 AND ES."HRME_LeftFlag" = 0 
        AND ES."HRME_Id" NOT IN (
            SELECT DISTINCT "HRME_Id" FROM (
                SELECT * FROM (
                    SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                    (COALESCE(e."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                    e."HRME_DOJ", D."HRMDES_DesignationName", F."HRMD_DepartmentName", a."FOEP_Id",
                    CAST(a."FOEP_PunchDate" AS DATE) AS "punchday", a."HRME_Id", COUNT(a."FOEP_PunchDate") AS "tpdays", COUNT(a."FOEP_PunchDate") AS "hwkdays" 
                    FROM "HR_Master_Employee" E
                    LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" AND E."MI_Id" = ' || "miid"::VARCHAR || ' 
                    WHERE a."MI_Id" = ' || "miid"::VARCHAR || ' AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''  
                    AND a."FOEP_HolidayPunchFlg" = 0
                    GROUP BY e."HRME_EmployeeCode", e."HRME_EmployeeFirstName", e."HRME_EmployeeMiddleName", e."HRME_EmployeeLastName", 
                    e."HRME_DOJ", a."FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", D."HRMDES_DesignationName", F."HRMD_DepartmentName"
                ) List
            ) AS HRME
        )
        OR ES."HRME_Id" IN (
            SELECT DISTINCT "HRME_Id" FROM (
                SELECT * FROM (
                    SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                    (COALESCE(e."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                    e."HRME_DOJ", D."HRMDES_DesignationName", F."HRMD_DepartmentName", a."FOEP_Id",
                    CAST(a."FOEP_PunchDate" AS DATE) AS "punchday", a."HRME_Id", COUNT(a."FOEP_PunchDate") AS "tpdays", COUNT(a."FOEP_PunchDate") AS "hwkdays" 
                    FROM "HR_Master_Employee" E
                    LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" AND E."MI_Id" = ' || "miid"::VARCHAR || '  
                    WHERE a."MI_Id" = ' || "miid"::VARCHAR || ' AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''  
                    AND a."FOEP_HolidayPunchFlg" = 0
                    GROUP BY e."HRME_EmployeeCode", e."HRME_EmployeeFirstName", e."HRME_EmployeeMiddleName", e."HRME_EmployeeLastName", 
                    e."HRME_DOJ", a."FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", D."HRMDES_DesignationName", F."HRMD_DepartmentName"
                ) List
            ) AS HRME
        )
    ) AS "New"';

    EXECUTE "query";

END IF;

RETURN;

END;
$$;