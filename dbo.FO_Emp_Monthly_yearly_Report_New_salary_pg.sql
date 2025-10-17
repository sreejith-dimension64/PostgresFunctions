CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_Monthly_yearly_Report_New_salary"(
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
    "dynamic" TEXT;
BEGIN

    SELECT COUNT("FOMHWDD_ToDate")::VARCHAR(10) INTO "totalpresent"
    FROM "FO"."FO_HolidayWorkingDay_Type" a
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE)
        AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE)
        AND b."FOMHWD_ActiveFlg" = 1
        AND a."MI_Id" = "miid"
        AND a."FOHTWD_HolidayFlag" = 0;

    DROP TABLE IF EXISTS "Empfomonthly";
    DROP TABLE IF EXISTS "Empfomonthly_New";
    DROP TABLE IF EXISTS "HolidaysDates";
    DROP TABLE IF EXISTS "Empfomonthly_HRMS";

    CREATE TEMP TABLE "Empfomonthly_New"(
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

    IF "type" = 'monthly' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',')
        INTO "cols"
        FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'Y';
    ELSIF "type" = 'absent' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',')
        INTO "cols"
        FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'A';
    ELSE
        "var" := 'TO_CHAR("FOEP_PunchDate", ''Month'')||''_''||TO_CHAR("FOEP_PunchDate", ''YYYY'')';
        "var1" := ' AND a."FOEP_HolidayPunchFlg" = 0';
        SELECT STRING_AGG('"' || dt || '"', ',')
        INTO "cols"
        FROM (
            SELECT DISTINCT TRIM(TO_CHAR(CAST(dt AS DATE), 'Month')) || '_' || TO_CHAR(CAST(dt AS DATE), 'YYYY') AS dt,
                   EXTRACT(MONTH FROM CAST(dt AS DATE)) AS dt1
            FROM "dbo"."alldates"("fromdate", "todate")
            ORDER BY EXTRACT(MONTH FROM CAST(dt AS DATE))
            LIMIT 100
        ) d;
        "M" := 'N';
    END IF;

    IF ("M" = 'Y') OR ("M" = 'N') THEN

        "query" := 'CREATE TEMP TABLE "Empfomonthly" AS
        SELECT oa.*, COALESCE(ob."hwkdays", 0) AS "hwkdays"
        FROM (
            SELECT "HRME_EmployeeCode" AS "ecode",
                   (e."HRME_EmployeeFirstName" || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                   e."HRME_DOJ",
                   s.*,
                   t."tpdays",
                   "De"."HRMDES_DesignationName"
            FROM "HR_Master_Employee" e
            INNER JOIN (
                SELECT * FROM CROSSTAB(
                    ''SELECT a."HRME_Id", ' || "var" || ' AS punchday, COUNT(a."FOEP_Id") AS cnt
                      FROM "fo"."FO_Emp_Punch" a
                      WHERE CAST("FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."MI_Id" = ' || "miid"::TEXT || ' ' || "var1" || '
                      GROUP BY a."HRME_Id", ' || "var" || '
                      ORDER BY 1, 2'',
                    ''SELECT UNNEST(ARRAY[' || "cols" || '])''
                ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)
            ) s ON e."HRME_Id" = s."HRME_Id"
            INNER JOIN (
                SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") AS "tpdays"
                FROM "fo"."FO_Emp_Punch" a
                WHERE a."FOEP_HolidayPunchFlg" = 0
                  AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                  AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                  AND a."MI_Id" = ' || "miid"::TEXT || '
                GROUP BY a."HRME_Id"
            ) t ON e."HRME_Id" = t."HRME_Id"
            INNER JOIN "HR_Master_Designation" "De" ON e."HRMDES_Id" = "De"."HRMDES_Id"
        ) Oa
        LEFT JOIN (
            SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") AS "hwkdays"
            FROM "fo"."FO_Emp_Punch" a
            WHERE a."FOEP_HolidayPunchFlg" = 1
              AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
              AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
              AND a."MI_Id" = ' || "miid"::TEXT || '
            GROUP BY a."HRME_Id"
        ) Ob ON oa."HRME_Id" = Ob."HRME_Id"';

        EXECUTE "query";

        "query" := 'INSERT INTO "Empfomonthly_New" ("ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", "value", "col")
        SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays",
               CAST("value" AS INT), "col"
        FROM (
            SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", ' || "cols" || '
            FROM "Empfomonthly"
        ) src
        UNPIVOT ("value" FOR "col" IN (' || "cols" || ')) AS unpiv';

        EXECUTE "query";

        CREATE TEMP TABLE "HolidaysDates" AS
        SELECT CAST("FOMHWDD_FromDate" AS DATE) AS "FOMHWDD_FromDate"
        FROM "fo"."FO_Master_HolidayWorkingDay_Dates"
        WHERE "FOHWDT_Id" IN (
            SELECT "FOHWDT_Id"
            FROM "fo"."FO_HolidayWorkingDay_Type"
            WHERE "mi_id" = "miid"
              AND "FOHTWD_HolidayFlag" = 1
        );

        UPDATE "Empfomonthly_New" A
        SET "value" = 2
        FROM "HolidaysDates" B
        WHERE A."col" = CAST(B."FOMHWDD_FromDate" AS VARCHAR);

        "dynamic" := 'CREATE TEMP TABLE "Empfomonthly_HRMS" AS
        SELECT "ecode", "ename", "HRME_DOJ", "MonthEmpList"."HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays",
               ' || "cols" || ',
               SUM("dbo"."getonlymin"("EP"."FOEP_LateByMins")) AS "LateByMins"
        FROM (
            SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", ' || "cols" || '
            FROM CROSSTAB(
                ''SELECT "ecode" || ''''|'''' || "ename" || ''''|'''' || "HRME_DOJ" || ''''|'''' || "HRME_Id"::TEXT || ''''|'''' || "tpdays"::TEXT || ''''|'''' || "HRMDES_DesignationName" || ''''|'''' || "hwkdays"::TEXT AS key,
                        "col", SUM("value")
                 FROM "Empfomonthly_New"
                 GROUP BY "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", "col"
                 ORDER BY 1, 2'',
                ''SELECT UNNEST(ARRAY[' || "cols" || '])''
            ) AS ct(key TEXT, ' || "cols" || ' INT)
        ) AS unpacked
        CROSS JOIN LATERAL (
            SELECT SPLIT_PART(key, ''|'', 1) AS "ecode",
                   SPLIT_PART(key, ''|'', 2) AS "ename",
                   SPLIT_PART(key, ''|'', 3) AS "HRME_DOJ",
                   CAST(SPLIT_PART(key, ''|'', 4) AS BIGINT) AS "HRME_Id",
                   CAST(SPLIT_PART(key, ''|'', 5) AS INT) AS "tpdays",
                   SPLIT_PART(key, ''|'', 6) AS "HRMDES_DesignationName",
                   CAST(SPLIT_PART(key, ''|'', 7) AS INT) AS "hwkdays"
        ) "MonthEmpList"
        INNER JOIN "FO"."FO_Emp_Punch" "EP" ON "MonthEmpList"."HRME_Id" = "EP"."HRME_Id"
        WHERE "EP"."MI_Id" = ' || "miid"::TEXT || '
        GROUP BY "MonthEmpList"."ecode", "MonthEmpList"."ename", "MonthEmpList"."HRME_DOJ", "MonthEmpList"."HRME_Id",
                 "MonthEmpList"."tpdays", "MonthEmpList"."HRMDES_DesignationName", "MonthEmpList"."hwkdays", ' || "cols";

        EXECUTE "dynamic";

        PERFORM "dbo"."HRMS_EmployeeSal_Test"("miid", "fromdate", "todate");

    ELSIF "M" = 'A' THEN

        "query" := 'SELECT DISTINCT "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMDES_DesignationName", "workday", "tpdays", ("workday" - "tpdays") AS "absentdays"
        FROM (
            SELECT DISTINCT ES."HRME_Id",
                   ES."HRME_EmployeeCode" AS "ecode",
                   (COALESCE(ES."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeLastName", '' '')) AS "ename",
                   "HRME_DOJ",
                   D."HRMDES_DesignationName",
                   (SELECT COUNT(*) AS "workday"
                    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = ES."MI_Id"
                      AND b."FOHTWD_HolidayFlag" = 0
                      AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || '''
                      AND a."FOMHWDD_ToDate" <= ''' || "todate" || ''') AS "workday",
                   (SELECT COUNT(a."FOEP_PunchDate")
                    FROM "FO"."FO_Emp_Punch" a
                    WHERE a."MI_Id" = ' || "miid"::TEXT || '
                      AND a."HRME_Id" = ES."HRME_Id"
                      AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                      AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                      AND a."FOEP_HolidayPunchFlg" = 0) AS "tpdays"
            FROM "HR_Master_employee" ES
            LEFT JOIN "HR_Master_Designation" D ON ES."HRMDES_Id" = D."HRMDES_Id"
                AND D."MI_Id" = ' || "miid"::TEXT || '
                AND ES."MI_Id" = ' || "miid"::TEXT || '
            WHERE ES."MI_Id" = ' || "miid"::TEXT || '
              AND "HRME_ActiveFlag" = 1
              AND "HRME_LeftFlag" = 0
              AND "HRME_ExcDR" = 0
              AND "HRME_Id" NOT IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM (
                      SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                             (COALESCE("HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                             e."HRME_DOJ",
                             D."HRMDES_DesignationName",
                             a."FOEP_Id",
                             CAST(a."FOEP_PunchDate" AS DATE) AS "punchday",
                             a."HRME_Id",
                             COUNT(a."FOEP_PunchDate") AS "tpdays",
                             COUNT(a."FOEP_PunchDate") AS "hwkdays"
                      FROM "HR_Master_Employee" E
                      LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                         AND E."MI_Id" = ' || "miid"::TEXT || '
                      LEFT JOIN "HR_Master_Designation" D ON e."HRMDES_Id" = D."HRMDES_Id"
                      WHERE a."MI_Id" = ' || "miid"::TEXT || '
                        AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."FOEP_HolidayPunchFlg" = 0
                      GROUP BY "HRME_EmployeeCode", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName",
                               "HRME_DOJ", "FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", D."HRMDES_DesignationName"
                  ) "List"
              )
              OR "HRME_Id" IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM (
                      SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                             (COALESCE("HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                             e."HRME_DOJ",
                             D."HRMDES_DesignationName",
                             a."FOEP_Id",
                             CAST(a."FOEP_PunchDate" AS DATE) AS "punchday",
                             a."HRME_Id",
                             COUNT(a."FOEP_PunchDate") AS "tpdays",
                             COUNT(a."FOEP_PunchDate") AS "hwkdays"
                      FROM "HR_Master_Employee" E
                      LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                         AND E."MI_Id" = ' || "miid"::TEXT || '
                      LEFT JOIN "HR_Master_Designation" D ON e."HRMDES_Id" = D."HRMDES_Id"
                      WHERE a."MI_Id" = ' || "miid"::TEXT || '
                        AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."FOEP_HolidayPunchFlg" = 0
                      GROUP BY "HRME_EmployeeCode", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName",
                               "HRME_DOJ", "FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id", D."HRMDES_DesignationName"
                  ) "List"
              )
        ) AS "New"
        WHERE "HRME_Id" IN (' || "multiplehrmeid" || ')';

        EXECUTE "query";

    END IF;

END;
$$;