CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_dailyabsent_Report"(
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
    "HRLPC_AbsentLeaveFlag" INTEGER;
    "HCount" INTEGER;
    "rcount" INTEGER;
    "HRME_Id" BIGINT;
    "HRMLY_Id" BIGINT;
    "HRELT_Id" BIGINT;
    "LeavePrefixSuffixFlag" INTEGER;
    "Rouwcount" INTEGER;
    v_rec RECORD;
BEGIN

    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'empabsentlist') THEN
        DROP TABLE "EmpAbsentList";
    END IF;

    CREATE TEMP TABLE "EmpAbsentList"(
        "MI_Id" BIGINT,
        "HRME_Id" BIGINT,
        "ecode" BIGINT,
        "ename" VARCHAR(60),
        "HRME_DOJ" DATE,
        "HRMDES_DesignationName" VARCHAR(60),
        "workday" INTEGER,
        "tpdatys" INTEGER,
        "absentdays" INTEGER
    );

    SELECT COUNT("FOMHWDD_ToDate")::VARCHAR(10) INTO "totalpresent"
    FROM "FO"."FO_HolidayWorkingDay_Type" a
    INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
    WHERE CAST(b."FOMHWDD_FromDate" AS DATE) >= CAST("fromdate" AS DATE)
        AND CAST(b."FOMHWDD_ToDate" AS DATE) <= CAST("todate" AS DATE)
        AND b."FOMHWD_ActiveFlg" = 1
        AND a."MI_Id" = "miid"
        AND a."FOHTWD_HolidayFlag" = 0;

    IF "type" = 'absent' THEN
        "var" := 'CAST(a."FOEP_PunchDate" AS DATE)';
        "var1" := '';
        SELECT STRING_AGG('"' || dt || '"', ',') INTO "cols"
        FROM (SELECT dt FROM "dbo"."alldates"("fromdate", "todate")) d;
        "M" := 'A';
    END IF;

    IF ("M" = 'A') THEN

        "query" := '
SELECT DISTINCT "ES"."MI_Id", "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMDES_DesignationName", "workday", "tpdays", ("workday" - "tpdays") AS "absentdays"
FROM (
    SELECT DISTINCT "ES"."HRME_Id",
        "ES"."HRME_EmployeeCode" AS "ecode",
        (COALESCE("ES"."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE("ES"."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE("ES"."HRME_EmployeeLastName", '' '')) AS "ename",
        "HRME_DOJ",
        "D"."HRMDES_DesignationName",
        (SELECT COUNT(*) AS "workday" 
         FROM "FO"."FO_Master_HolidayWorkingDay_Dates" a 
         INNER JOIN "FO"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id" 
         WHERE a."MI_Id" = "ES"."MI_Id" 
             AND b."FOHTWD_HolidayFlag" = 0 
             AND a."FOMHWDD_FromDate" >= ''' || "fromdate" || ''' 
             AND a."FOMHWDD_ToDate" <= ''' || "todate" || ''') AS "workday",
        (SELECT COUNT(a."FOEP_PunchDate") 
         FROM "FO"."FO_Emp_Punch" a 
         WHERE a."MI_Id" = ' || "miid"::TEXT || ' 
             AND a."HRME_Id" = "ES"."HRME_Id" 
             AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || ''' 
             AND a."HRME_Id" IN (' || "multiplehrmeid" || ') 
             AND a."FOEP_HolidayPunchFlg" = 0) AS "tpdays"
    FROM "HR_Master_employee" "ES"
    LEFT JOIN "HR_Master_Designation" "D" ON "ES"."HRMDES_Id" = "D"."HRMDES_Id" 
        AND "D"."MI_Id" = ' || "miid"::TEXT || ' 
        AND "ES"."MI_Id" = ' || "miid"::TEXT || '
    WHERE "ES"."MI_Id" = ' || "miid"::TEXT || ' 
        AND "HRME_ActiveFlag" = 1 
        AND "HRME_LeftFlag" = 0 
        AND "HRME_Id" NOT IN (
            SELECT DISTINCT "HRME_Id" 
            FROM (
                SELECT * FROM (
                    SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                        (COALESCE("HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                        e."HRME_DOJ",
                        "D"."HRMDES_DesignationName",
                        a."FOEP_Id",
                        CAST(a."FOEP_PunchDate" AS DATE) AS "punchday",
                        a."HRME_Id",
                        COUNT(a."FOEP_PunchDate") AS "tpdays",
                        COUNT(a."FOEP_PunchDate") AS "hwkdays"
                    FROM "HR_Master_Employee" "E"
                    LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" 
                        AND "E"."MI_Id" = ' || "miid"::TEXT || '
                    WHERE a."MI_Id" = ' || "miid"::TEXT || ' 
                        AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || ''' 
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ') 
                        AND a."FOEP_HolidayPunchFlg" = 0
                    GROUP BY "HRME_EmployeeCode", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", 
                        "HRME_DOJ", "FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id"
                ) "List"
                CROSS JOIN LATERAL (
                    SELECT ' || "cols" || '
                ) "PVT"
            ) AS "HRME"
        )
        OR "HRME_Id" IN (
            SELECT DISTINCT "HRME_Id" 
            FROM (
                SELECT * FROM (
                    SELECT DISTINCT "HRME_EmployeeCode" AS "ecode",
                        (COALESCE("HRME_EmployeeFirstName", '' '') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE(e."HRME_EmployeeLastName", '' '')) AS "ename",
                        e."HRME_DOJ",
                        "D"."HRMDES_DesignationName",
                        a."FOEP_Id",
                        CAST(a."FOEP_PunchDate" AS DATE) AS "punchday",
                        a."HRME_Id",
                        COUNT(a."FOEP_PunchDate") AS "tpdays",
                        COUNT(a."FOEP_PunchDate") AS "hwkdays"
                    FROM "HR_Master_Employee" "E"
                    LEFT JOIN "FO"."FO_Emp_Punch" a ON a."HRME_Id" = e."HRME_Id" 
                        AND "E"."MI_Id" = ' || "miid"::TEXT || '
                    WHERE a."MI_Id" = ' || "miid"::TEXT || ' 
                        AND CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || ''' 
                        AND a."HRME_Id" IN (' || "multiplehrmeid" || ') 
                        AND a."FOEP_HolidayPunchFlg" = 0
                    GROUP BY "HRME_EmployeeCode", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", 
                        "HRME_DOJ", "FOEP_Id", CAST(a."FOEP_PunchDate" AS DATE), a."HRME_Id"
                ) "List"
                CROSS JOIN LATERAL (
                    SELECT ' || "cols" || '
                ) "PVT"
            ) AS "HRME"
        )
) AS "New"';

        EXECUTE 'INSERT INTO "EmpAbsentList"("MI_Id", "HRME_Id", "ecode", "ename", "HRME_DOJ", "HRMDES_DesignationName", "workday", "tpdatys", "absentdays") ' || "query";

    END IF;

    FOR v_rec IN SELECT "HRME_Id" FROM "EmpAbsentList" WHERE "MI_Id" = "miid"
    LOOP
        "HRME_Id" := v_rec."HRME_Id";

        SELECT "HRLPC_AbsentLeaveFlag", "HRLPC_LeavePrefixSuffixFlag" 
        INTO "HRLPC_AbsentLeaveFlag", "LeavePrefixSuffixFlag"
        FROM "HR_Leave_Policy_Configuration" 
        WHERE "MI_Id" = "miid";

        SELECT COUNT(*) INTO "HCount"
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" A
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" B ON A."FOHWDT_Id" = B."FOHWDT_Id"
        WHERE A."MI_Id" = "miid" 
            AND B."FOHTWD_HolidayFlag" = 1 
            AND CAST("FOMHWDD_FromDate" AS DATE) BETWEEN CAST(CURRENT_DATE - INTERVAL '1 day' AS DATE) 
                AND CAST(CURRENT_DATE + INTERVAL '1 day' AS DATE);

        IF ("HRLPC_AbsentLeaveFlag" = 1) AND ("LeavePrefixSuffixFlag" = 1) THEN
            "Rouwcount" := 0;

            SELECT COUNT(*) INTO "Rouwcount"
            FROM "HR_Emp_Leave_Trans"
            WHERE "MI_Id" = "miid" 
                AND "HRMLY_Id" = "HRMLY_Id" 
                AND "HRME_Id" = "HRME_Id" 
                AND "HRELT_Status" = 'Approved'
                AND CAST(CURRENT_DATE AS DATE) BETWEEN "HRELT_FromDate" AND "HRELT_ToDate";

            IF ("Rouwcount" > 0) THEN
                RAISE NOTICE 'leave already approved';
            ELSE
                SELECT COUNT(*) INTO "rcount"
                FROM "HR_Emp_Leave_Status"
                WHERE "HRML_Id" = 1 
                    AND "HRELS_CBLeaves" > 0 
                    AND "MI_Id" = "miid" 
                    AND "HRME_Id" = "HRME_Id";

                IF ("rcount" > 0) THEN
                    SELECT "HRMLY_Id" INTO "HRMLY_Id"
                    FROM "HR_Master_LeaveYear"
                    WHERE "MI_Id" = "miid" 
                        AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

                    UPDATE "HR_Emp_Leave_Status"
                    SET "HRELS_TransLeaves" = "HCount",
                        "HRELS_CBLeaves" = "HRELS_CBLeaves" - "HRELS_TransLeaves"
                    WHERE "MI_Id" = "miid" 
                        AND "HRME_Id" = "HRME_Id" 
                        AND "HRML_Id" = 1 
                        AND "HRMLY_Id" = "HRMLY_Id";

                    INSERT INTO "HR_Emp_Leave_Trans"(
                        "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", 
                        "HRELT_TotDays", "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", 
                        "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
                    ) VALUES(
                        "miid", "HRME_Id", "HRMLY_Id", 1, CURRENT_DATE, CURRENT_DATE, 
                        "HCount", CURRENT_DATE, 'Absent', 'Approved', 
                        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_DATE
                    );

                    SELECT "HRELT_Id" INTO "HRELT_Id"
                    FROM "HR_Emp_Leave_Trans"
                    WHERE "MI_Id" = "miid" 
                        AND CAST("HRELT_FromDate" AS DATE) = CAST(CURRENT_DATE AS DATE) 
                        AND "HRME_Id" = "HRME_Id";

                    INSERT INTO "HR_Emp_Leave_Trans_Details"(
                        "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", 
                        "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                    ) VALUES(
                        "HRELT_Id", 1, "HRME_Id", "miid", CURRENT_DATE, CURRENT_DATE, 
                        "HCount", 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );

                ELSE
                    SELECT "HRMLY_Id" INTO "HRMLY_Id"
                    FROM "HR_Master_LeaveYear"
                    WHERE "MI_Id" = "miid" 
                        AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

                    INSERT INTO "HR_Emp_Leave_Trans"(
                        "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", 
                        "HRELT_TotDays", "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", 
                        "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
                    ) VALUES(
                        "miid", "HRME_Id", "HRMLY_Id", 1, CURRENT_DATE, CURRENT_DATE, 
                        "HCount", CURRENT_DATE, 'LWP', 'Approved', 
                        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_DATE
                    );

                    SELECT "HRELT_Id" INTO "HRELT_Id"
                    FROM "HR_Emp_Leave_Trans"
                    WHERE "MI_Id" = "miid" 
                        AND CAST("HRELT_FromDate" AS DATE) = CAST(CURRENT_DATE AS DATE) 
                        AND "HRME_Id" = "HRME_Id";

                    INSERT INTO "HR_Emp_Leave_Trans_Details"(
                        "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", 
                        "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                    ) VALUES(
                        "HRELT_Id", 1, "HRME_Id", "miid", CURRENT_DATE, CURRENT_DATE, 
                        "HCount", 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );

                END IF;
            END IF;
        END IF;
    END LOOP;

END;
$$;