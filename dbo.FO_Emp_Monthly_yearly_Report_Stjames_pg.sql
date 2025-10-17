CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_Monthly_yearly_Report_Stjames"(
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "multiplehrmeid" TEXT,
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
    "WorkDays" VARCHAR(100);
    "HRMLY_Id" BIGINT;
    "dynamic" TEXT;
BEGIN

    SELECT COUNT("FOMHWDD_ToDate")::VARCHAR INTO "totalpresent"
    FROM "FO"."FO_HolidayWorkingDay_Type" a
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE)
      AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE)
      AND b."FOMHWD_ActiveFlg" = 1
      AND a."MI_Id" = "miid"
      AND a."FOHTWD_HolidayFlag" = 0;

    DROP TABLE IF EXISTS "Empfomonthly_Staff_Temp1";
    DROP TABLE IF EXISTS "Empfomonthly_Staff_Temp2";

    CREATE TEMP TABLE "Empfomonthly_Staff_Temp2"(
        "ecode" VARCHAR(100),
        "ename" TEXT,
        "HRME_DOJ" VARCHAR(10),
        "HRME_Id" BIGINT,
        "tpdays" INT,
        "HRMDES_DesignationName" VARCHAR(100),
        "hwkdays" INT,
        "value" INT,
        "col" VARCHAR(10)
    );

    DROP TABLE IF EXISTS "HolidaysDates";
    DROP TABLE IF EXISTS "EmpWiseHolidaysDates_Temp";

    IF "type" = 'monthly' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT dt::TEXT FROM "dbo"."alldates"("fromdate"::DATE, "todate"::DATE)) d;
        "M" := 'Y';
    ELSIF "type" = 'absent' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT dt::TEXT FROM "dbo"."alldates"("fromdate"::DATE, "todate"::DATE)) d;
        "M" := 'A';
    ELSE
        "var" := 'TO_CHAR("FOEP_PunchDate", ''Month'')||''_''||TO_CHAR("FOEP_PunchDate", ''YYYY'')';
        "var1" := ' AND a."FOEP_HolidayPunchFlg" = 0';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt1)
        INTO "cols"
        FROM (
            SELECT DISTINCT TO_CHAR(dt, 'Month') || '_' || TO_CHAR(dt, 'YYYY') AS dt,
                   EXTRACT(MONTH FROM dt) AS dt1
            FROM "dbo"."alldates"("fromdate"::DATE, "todate"::DATE)
            ORDER BY EXTRACT(MONTH FROM dt)
            LIMIT 100
        ) d;
        "M" := 'N';
    END IF;

    IF ("M" = 'Y') OR ("M" = 'N') THEN

        "query" := 'CREATE TEMP TABLE "Empfomonthly_Staff_Temp1" AS
        SELECT oa.*, COALESCE(ob."hwkdays", 0) AS "hwkdays"
        FROM (
            SELECT e."HRME_EmployeeCode" AS "ecode",
                   (e."HRME_EmployeeFirstName" || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                   e."HRME_DOJ",
                   s.*,
                   t."tpdays",
                   "De"."HRMDES_DesignationName"
            FROM "HR_Master_Employee" e
            INNER JOIN (
                SELECT * FROM CROSSTAB(
                    ''SELECT a."HRME_Id", ' || "var" || '::TEXT AS punchday, COUNT(a."FOEP_Id")::INT
                      FROM "fo"."FO_Emp_Punch" a
                      WHERE CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."MI_Id" = ' || "miid"::TEXT || ' ' || "var1" || '
                      GROUP BY a."HRME_Id", ' || "var" || '
                      ORDER BY 1, 2'',
                    ''SELECT UNNEST(ARRAY[' || "cols" || '])::TEXT''
                ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)
            ) s ON e."HRME_Id" = s."HRME_Id"
            INNER JOIN (
                SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate")::INT AS "tpdays"
                FROM "fo"."FO_Emp_Punch" a
                WHERE a."FOEP_HolidayPunchFlg" = 0
                  AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                  AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                  AND a."MI_Id" = ' || "miid"::TEXT || '
                GROUP BY a."HRME_Id"
            ) t ON e."HRME_Id" = t."HRME_Id"
            INNER JOIN "HR_Master_Designation" "De" ON e."HRMDES_Id" = "De"."HRMDES_Id"
        ) oa
        LEFT JOIN (
            SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate")::INT AS "hwkdays"
            FROM "fo"."FO_Emp_Punch" a
            WHERE a."FOEP_HolidayPunchFlg" = 1
              AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
              AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
              AND a."MI_Id" = ' || "miid"::TEXT || '
            GROUP BY a."HRME_Id"
        ) ob ON oa."HRME_Id" = ob."HRME_Id"';

        EXECUTE "query";

        "query" := 'INSERT INTO "Empfomonthly_Staff_Temp2" ("ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", "value", "col")
        SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", 
               (unpiv).value::INT, (unpiv).col::VARCHAR(10)
        FROM (
            SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays",
                   EACH(HSTORE(ARRAY[' || "cols" || '], ARRAY[' || "cols" || ']::TEXT[])) AS unpiv
            FROM "Empfomonthly_Staff_Temp1"
        ) sub';

        EXECUTE "query";

        CREATE TEMP TABLE "HolidaysDates" AS
        SELECT CAST("FOMHWDD_FromDate" AS DATE) AS "FOMHWDD_FromDate"
        FROM "fo"."FO_Master_HolidayWorkingDay_Dates"
        WHERE "FOHWDT_Id" IN (
            SELECT "FOHWDT_Id"
            FROM "fo"."FO_HolidayWorkingDay_Type"
            WHERE "mi_id" = "miid" AND "FOHTWD_HolidayFlag" = 1
        );

        CREATE TEMP TABLE "EmpWiseHolidaysDates_Temp" AS
        SELECT DISTINCT "HRME_Id", CAST("FOMEH_Date" AS DATE) AS "FOMEH_Date"
        FROM "FO"."FO_Master_Employee_Holidays"
        WHERE "FOMEH_Date" IN (
            SELECT DISTINCT CAST("FOMHWDD_FromDate" AS DATE)
            FROM "FO"."FO_Master_HolidayWorkingDay_Dates" "HWD"
            INNER JOIN "FO"."FO_HolidayWorkingDay_Type" "HTY" ON "HTY"."FOHWDT_Id" = "HWD"."FOHWDT_Id"
            INNER JOIN "HR_Master_LeaveYear" "HML" ON "HML"."HRMLY_Id" = "HWD"."HRMLY_Id"
            WHERE "HTY"."MI_Id" = "miid"
              AND "HWD"."FOHWDT_Id" = 2
              AND "HML"."HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
        );

        UPDATE "Empfomonthly_Staff_Temp2" A
        SET "value" = 3
        FROM "EmpWiseHolidaysDates_Temp" B
        WHERE A."col" = B."FOMEH_Date"::TEXT
          AND A."HRME_Id" = B."HRME_Id";

        UPDATE "Empfomonthly_Staff_Temp2" A
        SET "value" = 2
        FROM "HolidaysDates" B
        WHERE A."col" = B."FOMHWDD_FromDate"::TEXT;

        ALTER TABLE "Empfomonthly_Staff_Temp2" ADD COLUMN "WorkDays" BIGINT;

        "WorkDays" := '0';

        SELECT "HRMLY_Id" INTO "HRMLY_Id"
        FROM "HR_Master_Leaveyear"
        WHERE "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

        SELECT COUNT(DISTINCT CAST("FOMHWDD_FromDate" AS DATE))::VARCHAR INTO "WorkDays"
        FROM "fo"."FO_Master_HolidayWorkingDay_Dates"
        WHERE "HRMLY_Id" = "HRMLY_Id"
          AND "FOHWDT_Id" IN (
              SELECT "FOHWDT_Id"
              FROM "fo"."FO_HolidayWorkingDay_Type"
              WHERE "mi_id" = "miid" AND "FOHTWD_HolidayFlag" = 0
          );

        "dynamic" := 'SELECT "ecode", "ename", "HRME_DOJ", "MonthEmpList"."HRME_Id", ' || "WorkDays" || ' AS "totalworkingdays",
                      "tpdays", "HRMDES_DesignationName", "hwkdays", ' || "cols" || ',
                      SUM("dbo"."getonlymin"("EP"."FOEP_LateByMins")) AS "LateByMins"
                      FROM (
                          SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays",
                                 ' || "cols" || '
                          FROM CROSSTAB(
                              ''SELECT "HRME_Id", "col", SUM("value")::INT
                                FROM "Empfomonthly_Staff_Temp2"
                                GROUP BY "HRME_Id", "col"
                                ORDER BY 1, 2'',
                              ''SELECT UNNEST(ARRAY[' || "cols" || '])::TEXT''
                          ) AS "PVT"("HRME_Id" BIGINT, "ecode" VARCHAR(100), "ename" TEXT, "HRME_DOJ" VARCHAR(10),
                                     "tpdays" INT, "HRMDES_DesignationName" VARCHAR(100), "hwkdays" INT, ' || "cols" || ' INT)
                      ) "MonthEmpList"
                      INNER JOIN "FO"."FO_Emp_Punch" "EP" ON "MonthEmpList"."HRME_Id" = "EP"."HRME_Id"
                      WHERE "EP"."MI_Id" = ' || "miid"::TEXT || '
                      GROUP BY "MonthEmpList"."ecode", "MonthEmpList"."ename", "MonthEmpList"."HRME_DOJ",
                               "MonthEmpList"."HRME_Id", "MonthEmpList"."tpdays", "MonthEmpList"."HRMDES_DesignationName",
                               "MonthEmpList"."hwkdays", ' || "cols";

        EXECUTE "dynamic";

    ELSIF ("M" = 'A') THEN

        "query" := 'SELECT DISTINCT "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMDES_DesignationName", "workday", "tpdays", ("workday" - "tpdays") AS "absentdays"
        FROM (
            SELECT DISTINCT "ES"."HRME_Id", "ES"."HRME_EmployeeCode" AS "ecode",
                   (COALESCE("ES"."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE("ES"."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE("ES"."HRME_EmployeeLastName", '' '')) AS "ename",
                   "ES"."HRME_DOJ", "D"."HRMDES_DesignationName",
                   (SELECT COUNT(*) AS workday
                    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = "ES"."MI_Id"
                      AND b."FOHTWD_HolidayFlag" = 0
                      AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || '''::DATE
                      AND a."FOMHWDD_ToDate" <= ''' || "todate" || '''::DATE) AS "workday",
                   (SELECT COUNT(a."FOEP_PunchDate")
                    FROM "FO"."FO_Emp_Punch" a
                    WHERE a."MI_Id" = ' || "miid"::TEXT || '
                      AND a."HRME_Id" = "ES"."HRME_Id"
                      AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || '''::DATE AND ''' || "todate" || '''::DATE
                      AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                      AND a."FOEP_HolidayPunchFlg" = 0) AS "tpdays"
            FROM "HR_Master_employee" "ES"
            LEFT JOIN "HR_Master_Designation" "D" ON "ES"."HRMDES_Id" = "D"."HRMDES_Id"
                AND "D"."MI_Id" = ' || "miid"::TEXT || '
                AND "ES"."MI_Id" = ' || "miid"::TEXT || '
            WHERE "ES"."MI_Id" = ' || "miid"::TEXT || '
              AND "ES"."HRME_ActiveFlag" = 1
              AND "ES"."HRME_LeftFlag" = 0
              AND "ES"."HRME_Id" NOT IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM (
                      SELECT DISTINCT e."HRME_EmployeeCode" AS "ecode",
                             (COALESCE(e."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                             e."HRME_DOJ", "D"."HRMDES_DesignationName", a."FOEP_Id",
                             CAST(a."FOEP_PunchDate" AS DATE) AS punchday, a."HRME_Id",
                             COUNT(a."FOEP_PunchDate") AS "tpdays", COUNT(a."FOEP_PunchDate") AS "hwkdays"
                      FROM "HR_Master_Employee" e
                      LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" AND e."MI_Id" = ' || "miid"::TEXT || '
                      LEFT JOIN "HR_Master_Designation" "D" ON e."HRMDES_Id" = "D"."HRMDES_Id"
                      WHERE a."MI_Id" = ' || "miid"::TEXT || '
                        AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || '''::DATE AND ''' || "todate" || '''::DATE
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."FOEP_HolidayPunchFlg" = 0
                      GROUP BY e."HRME_EmployeeCode", e."HRME_EmployeeFirstName", e."HRME_EmployeeMiddleName",
                               e."HRME_EmployeeLastName", e."HRME_DOJ", a."FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", "D"."HRMDES_DesignationName"
                  ) "List"
              )
              OR "ES"."HRME_Id" IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM (
                      SELECT DISTINCT e."HRME_EmployeeCode" AS "ecode",
                             (COALESCE(e."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                             e."HRME_DOJ", "D"."HRMDES_DesignationName", a."FOEP_Id",
                             CAST(a."FOEP_PunchDate" AS DATE) AS punchday, a."HRME_Id",
                             COUNT(a."FOEP_PunchDate") AS "tpdays", COUNT(a."FOEP_PunchDate") AS "hwkdays"
                      FROM "HR_Master_Employee" e
                      LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" AND e."MI_Id" = ' || "miid"::TEXT || '
                      LEFT JOIN "HR_Master_Designation" "D" ON e."HRMDES_Id" = "D"."HRMDES_Id"
                      WHERE a."MI_Id" = ' || "miid"::TEXT || '
                        AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || '''::DATE AND ''' || "todate" || '''::DATE
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."FOEP_HolidayPunchFlg" = 0
                      GROUP BY e."HRME_EmployeeCode", e."HRME_EmployeeFirstName", e."HRME_EmployeeMiddleName",
                               e."HRME_EmployeeLastName", e."HRME_DOJ", a."FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", "D"."HRMDES_DesignationName"
                  ) "List"
              )
        ) AS "New"
        WHERE "HRME_Id" IN (' || "multiplehrmeid" || ')';

        EXECUTE "query";

    END IF;

END;
$$;