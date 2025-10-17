CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_Monthly_yearly_Report"(
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
BEGIN

    SELECT COUNT("FOMHWDD_ToDate")::VARCHAR(10) INTO "totalpresent"
    FROM "FO"."FO_HolidayWorkingDay_Type" a
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE)
      AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE)
      AND b."FOMHWD_ActiveFlg" = 1
      AND a."MI_Id" = "miid"
      AND a."FOHTWD_HolidayFlag" = 0;

    IF "type" = 'monthly' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT "dt" FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'Y';
    ELSIF "type" = 'absent' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt)
        INTO "cols"
        FROM (SELECT "dt" FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'A';
    ELSE
        "var" := 'TO_CHAR("FOEP_PunchDate", ''Month'')||''_''||TO_CHAR("FOEP_PunchDate", ''YYYY'')';
        "var1" := ' AND a."FOEP_HolidayPunchFlg" = 0';
        SELECT STRING_AGG('"' || dt || '"', ',' ORDER BY dt1)
        INTO "cols"
        FROM (
            SELECT DISTINCT TRIM(TO_CHAR(dt, 'Month')) || '_' || TO_CHAR(dt, 'YYYY') AS dt,
                   EXTRACT(MONTH FROM dt) AS dt1
            FROM "dbo"."alldates"("fromdate", "todate")
            ORDER BY EXTRACT(MONTH FROM dt)
            LIMIT 100
        ) d;
        "M" := 'N';
    END IF;

    IF ("M" = 'Y') OR ("M" = 'N') THEN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
        "query" := 'SELECT oa.*, ob.hwkdays 
        FROM (
            SELECT "HRME_EmployeeCode" AS ecode,
                   ("HRME_EmployeeFirstName" || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS ename,
                   e."HRME_DOJ",
                   s.*,
                   t.tpdays,
                   De."HRMDES_DesignationName"
            FROM "HR_Master_Employee" e
            INNER JOIN (
                SELECT * FROM CROSSTAB(
                    ''SELECT a."HRME_Id", ' || "var" || '::TEXT AS punchday, COUNT(a."FOEP_Id")
                      FROM "fo"."FO_Emp_Punch" a
                      WHERE CAST("FOEP_PunchDate" AS DATE) BETWEEN ''''' || "fromdate" || ''''' AND ''''' || "todate" || '''''
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                        AND a."MI_Id" = ' || "miid"::TEXT || ' ' || "var1" || '
                      GROUP BY a."HRME_Id", punchday
                      ORDER BY 1, 2'',
                    ''SELECT UNNEST(ARRAY[' || "cols" || '])::TEXT''
                ) AS ct("HRME_Id" BIGINT, ' || "cols" || ' BIGINT)
            ) s ON e."HRME_Id" = s."HRME_Id"
            INNER JOIN (
                SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") AS tpdays
                FROM "fo"."FO_Emp_Punch" a
                WHERE a."FOEP_HolidayPunchFlg" = 0
                  AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                  AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                  AND a."MI_Id" = ' || "miid"::TEXT || '
                GROUP BY a."HRME_Id"
            ) t ON e."HRME_Id" = t."HRME_Id"
            INNER JOIN "HR_Master_Designation" De ON e."HRMDES_Id" = De."HRMDES_Id"
        ) oa
        LEFT JOIN (
            SELECT a."HRME_Id", COUNT(a."FOEP_PunchDate") AS hwkdays
            FROM "fo"."FO_Emp_Punch" a
            WHERE a."FOEP_HolidayPunchFlg" = 1
              AND CAST(a."FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
              AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
              AND a."MI_Id" = ' || "miid"::TEXT || '
            GROUP BY a."HRME_Id"
        ) ob ON oa."HRME_Id" = ob."HRME_Id"';

        EXECUTE "query";
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    ELSIF ("M" = 'A') THEN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
        "query" := 'SELECT DISTINCT "HRME_Id", ecode, ename, "HRME_DOJ", "HRMDES_DesignationName", workday, tpdays, (workday - tpdays) AS absentdays
        FROM (
            SELECT DISTINCT ES."HRME_Id",
                   ES."HRME_EmployeeCode" AS ecode,
                   (COALESCE(ES."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(ES."HRME_EmployeeLastName", '' '')) AS ename,
                   "HRME_DOJ",
                   D."HRMDES_DesignationName",
                   (SELECT COUNT(*) AS workday
                    FROM "fo"."FO_Master_HolidayWorkingDay_Dates" a
                    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
                    WHERE a."mi_id" = ES."MI_Id"
                      AND b."FOHTWD_HolidayFlag" = 0
                      AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || '''
                      AND a."FOMHWDD_ToDate" <= ''' || "todate" || ''') AS workday,
                   (SELECT COUNT(a."FOEP_PunchDate")
                    FROM "FO"."FO_Emp_Punch" a
                    WHERE a."MI_Id" = ' || "miid"::TEXT || '
                      AND a."HRME_Id" = ES."HRME_Id"
                      AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                      AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                      AND a."FOEP_HolidayPunchFlg" = 0) AS tpdays
            FROM "HR_Master_employee" ES
            LEFT JOIN "HR_Master_Designation" D ON ES."HRMDES_Id" = D."HRMDES_Id"
                AND D."MI_Id" = ' || "miid"::TEXT || '
                AND ES."MI_Id" = ' || "miid"::TEXT || '
            WHERE ES."MI_Id" = ' || "miid"::TEXT || '
              AND "HRME_ActiveFlag" = 1
              AND "HRME_LeftFlag" = 0
              AND "HRME_Id" NOT IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM "HR_Master_Employee" E
                  LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                      AND E."MI_Id" = ' || "miid"::TEXT || '
                  WHERE a."MI_Id" = ' || "miid"::TEXT || '
                    AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                    AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                    AND a."FOEP_HolidayPunchFlg" = 0
              )
              OR "HRME_Id" IN (
                  SELECT DISTINCT "HRME_Id"
                  FROM "HR_Master_Employee" E
                  LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id"
                      AND E."MI_Id" = ' || "miid"::TEXT || '
                  WHERE a."MI_Id" = ' || "miid"::TEXT || '
                    AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
                    AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
                    AND a."FOEP_HolidayPunchFlg" = 0
              )
        ) AS New
        WHERE "HRME_Id" IN (' || "multiplehrmeid" || ')';

        EXECUTE "query";
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    END IF;

    RETURN;
END;
$$;