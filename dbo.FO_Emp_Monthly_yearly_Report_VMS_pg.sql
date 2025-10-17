CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_Monthly_yearly_Report_VMS"(
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
    FROM "FO"."FO_HolidayWorkingDay_Type" a, "FO"."FO_Master_HolidayWorkingDay_Dates" b
    WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE)
    AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE)
    AND a."FOHWDT_Id" = b."FOHWDT_Id"
    AND b."FOMHWD_ActiveFlg" = 1
    AND a."MI_Id" = "miid"
    AND a."FOHTWD_HolidayFlag" = 0;

    DROP TABLE IF EXISTS "Empfomonthly";
    DROP TABLE IF EXISTS "Empfomonthly_New";

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

    DROP TABLE IF EXISTS "HolidaysDates";

    IF "type" = 'monthly' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'Y';
    ELSIF "type" = 'absent' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'A';
    ELSE
        "var" := 'TO_CHAR("FOEP_PunchDate", ''Month'')||''_''||TO_CHAR("FOEP_PunchDate", ''YYYY'')';
        "var1" := ' AND a."FOEP_HolidayPunchFlg" = 0';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt1)
        INTO "cols"
        FROM (
            SELECT DISTINCT TO_CHAR(dt, 'Month') || '_' || TO_CHAR(dt, 'YYYY') dt,
                   EXTRACT(MONTH FROM dt) dt1
            FROM "dbo"."alldates"("fromdate", "todate")
            ORDER BY EXTRACT(MONTH FROM dt)
            LIMIT 100
        ) d;
        "M" := 'N';
    END IF;

    IF ("M" = 'Y') OR ("M" = 'N') THEN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

        "query" := 'CREATE TEMP TABLE "Empfomonthly" AS SELECT oa.*, ob.hwkdays FROM (
            SELECT "HRME_EmployeeCode" ecode,
                   ("HRME_EmployeeFirstName" || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) ename,
                   e."HRME_DOJ", s.*, t.tpdays, De."HRMDES_DesignationName"
            FROM "HR_Master_Employee" e,
            (SELECT * FROM crosstab(
                ''SELECT a."HRME_Id", ' || "var" || '::text, COUNT(a."FOEP_Id")::int
                  FROM "fo"."FO_Emp_Punch" a
                  WHERE CAST("FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                  AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                  AND a."MI_Id" = ' || "miid"::TEXT || ' ' || "var1" || '
                  GROUP BY a."HRME_Id", ' || "var" || '
                  ORDER BY 1, 2'',
                ''VALUES ' || REPLACE("cols", '"', '''''''') || '''
            ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)) s,
            (SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") tpdays
             FROM "fo"."FO_Emp_Punch" a
             WHERE a."FOEP_HolidayPunchFlg" = 0
             AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
             AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
             AND a."MI_Id" = ' || "miid"::TEXT || '
             GROUP BY a."HRME_Id") t,
            "HR_Master_Designation" De
            WHERE e."HRME_Id" = s."HRME_Id"
            AND e."HRME_Id" = t."HRME_Id"
            AND e."HRMDES_Id" = De."HRMDES_Id"
        ) Oa
        LEFT JOIN (
            SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") hwkdays
            FROM "fo"."FO_Emp_Punch" a
            WHERE a."FOEP_HolidayPunchFlg" = 1
            AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
            AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
            AND a."MI_Id" = ' || "miid"::TEXT || '
            GROUP BY a."HRME_Id"
        ) Ob ON oa."HRME_Id" = Ob."HRME_Id"';

        EXECUTE "query";

        "query" := 'INSERT INTO "Empfomonthly_New"("ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", "value", "col")
            SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", "value", "col"
            FROM "Empfomonthly"
            CROSS JOIN LATERAL (
                VALUES ' || (
                    SELECT STRING_AGG('(' || col || ', ''' || REPLACE(col, '"', '') || ''')', ',')
                    FROM UNNEST(STRING_TO_ARRAY("cols", ',')) AS col
                ) || '
            ) AS unpiv("value", "col")';

        EXECUTE "query";

        CREATE TEMP TABLE "HolidaysDates" AS
        SELECT CAST("FOMHWDD_FromDate" AS DATE) "FOMHWDD_FromDate"
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
        WHERE A."col" = B."FOMHWDD_FromDate"::TEXT;

        "dynamic" := 'SELECT "ecode", "ename", "HRME_DOJ", MonthEmpList."HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", ' || "cols" || ',
            SUM("dbo"."getonlymin"(EP."FOEP_LateByMins")) "LateByMins"
            FROM (
                SELECT "ecode", "ename", "HRME_DOJ", "HRME_Id", "tpdays", "HRMDES_DesignationName", "hwkdays", ' || "cols" || '
                FROM crosstab(
                    ''SELECT "HRME_Id", "col", SUM("value")::int
                      FROM "Empfomonthly_New"
                      GROUP BY "HRME_Id", "col"
                      ORDER BY 1, 2'',
                    ''VALUES ' || REPLACE("cols", '"', '''''''') || '''
                ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)
            ) MonthEmpList
            INNER JOIN "FO"."FO_Emp_Punch" EP ON MonthEmpList."HRME_Id" = EP."HRME_Id"
            WHERE EP."MI_Id" = ' || "miid"::TEXT || '
            GROUP BY MonthEmpList."ecode", MonthEmpList."ename", MonthEmpList."HRME_DOJ", MonthEmpList."HRME_Id",
                     MonthEmpList."tpdays", MonthEmpList."HRMDES_DesignationName", MonthEmpList."hwkdays", ' || "cols";

        EXECUTE "dynamic";

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    ELSIF ("M" = 'A') THEN

        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
        "query" := 'SELECT DISTINCT "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMD_DepartmentName", "HRMDES_DesignationName", "workday", "tpdays", ("workday" - "tpdays") absentdays
        FROM (
            SELECT DISTINCT ES."HRME_Id", ES."HRME_EmployeeCode" ecode,
                   (COALESCE(ES."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeLastName", '' '')) ename,
                   "HRME_DOJ", X."HRMD_DepartmentName", D."HRMDES_DesignationName",
                   (SELECT COUNT(*) as workday
                    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = es."MI_Id"
                    AND b."FOHTWD_HolidayFlag" = 0
                    AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || '''
                    AND a."FOMHWDD_ToDate" <= ''' || "todate" || ''') as workday,
                   (SELECT COUNT(a."FOEP_PunchDate")
                    FROM "FO"."FO_Emp_Punch" a
                    WHERE a."HRME_Id" = ES."HRME_Id"
                    AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                    AND a."HRME_Id" IN (SELECT "HRME_Id" FROM "HR_Master_Employee" WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0 AND "MI_Id" IN (SELECT "MI_Id" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1))
                    AND a."FOEP_HolidayPunchFlg" = 0) AS tpdays
            FROM "HR_Master_employee" ES
            LEFT JOIN "HR_Master_Designation" D ON ES."HRMDES_Id" = D."HRMDES_Id"
            LEFT JOIN "HR_Master_Department" X ON ES."HRMD_Id" = X."HRMD_Id"
            WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
            AND "HRME_Id" NOT IN (
                SELECT DISTINCT "HRME_Id"
                FROM (
                    SELECT * FROM crosstab(
                        ''SELECT a."HRME_Id", CAST(a."FOEP_PunchDate" AS DATE)::text, COUNT(a."FOEP_Id")::int
                          FROM "HR_Master_Employee" E
                          LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                          WHERE CAST("FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                          AND a."HRME_Id" IN (SELECT "HRME_Id" FROM "HR_Master_Employee" WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0 AND "MI_Id" IN (SELECT "MI_Id" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1))
                          AND a."FOEP_HolidayPunchFlg" = 0
                          GROUP BY a."HRME_Id", CAST(a."FOEP_PunchDate" AS DATE)
                          ORDER BY 1, 2'',
                        ''VALUES ' || REPLACE("cols", '"', '''''''') || '''
                    ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)
                ) AS HRME
            )
            OR "HRME_Id" IN (
                SELECT DISTINCT "HRME_Id"
                FROM (
                    SELECT * FROM crosstab(
                        ''SELECT a."HRME_Id", CAST(a."FOEP_PunchDate" AS DATE)::text, COUNT(a."FOEP_Id")::int
                          FROM "HR_Master_Employee" E
                          LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                          WHERE CAST("FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                          AND a."HRME_Id" IN (SELECT "HRME_Id" FROM "HR_Master_Employee" WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0 AND "MI_Id" IN (SELECT "MI_Id" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1))
                          AND a."FOEP_HolidayPunchFlg" = 0
                          GROUP BY a."HRME_Id", CAST(a."FOEP_PunchDate" AS DATE)
                          ORDER BY 1, 2'',
                        ''VALUES ' || REPLACE("cols", '"', '''''''') || '''
                    ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' INT)
                ) AS HRME
            )
        ) AS New
        WHERE "HRME_Id" IN (SELECT "HRME_Id" FROM "HR_Master_Employee" WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0 AND "MI_Id" IN (SELECT "MI_Id" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1))';

        EXECUTE "query";
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    END IF;

END;
$$;