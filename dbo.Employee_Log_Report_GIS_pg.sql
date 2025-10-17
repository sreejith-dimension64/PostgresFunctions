CREATE OR REPLACE FUNCTION "Employee_Log_Report_GIS" (
    "@MI_ID" BIGINT,
    "@HRME_Id" TEXT,
    "@Month" VARCHAR(50),
    "@Year" VARCHAR(10)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "ecode" VARCHAR(50),
    "ename" VARCHAR(250),
    "punchdate" DATE,
    "punchday" VARCHAR(50),
    "intime" VARCHAR(50),
    "outtime" VARCHAR(50),
    "workingtime" VARCHAR(50),
    "Status" VARCHAR(10),
    "Overtime" VARCHAR(50),
    "FOEST_IIHalfLogoutTime" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Monthid" BIGINT;
    "@dt" DATE;
    "@COUNT" INT;
    "@HRMD_ID" BIGINT;
    "@ecode" VARCHAR(50);
    "@ename" VARCHAR(250);
    "@punchINtime" VARCHAR(50);
    "@punchOUTtime" VARCHAR(50);
    "@lateby" VARCHAR(50);
    "@earlyby" VARCHAR(50);
    "@depname" VARCHAR(250);
    "@desgname" VARCHAR(250);
    "@gtype" VARCHAR(250);
    "@Temperature" VARCHAR(250);
    "@TatalWorkingHours" VARCHAR(50);
    "@query1" TEXT;
    "@Status" VARCHAR(10);
    "@StartDate" DATE;
    "@EndDate" DATE;
    "v_HRME_Id" BIGINT;
    "v_HRMD_Id" BIGINT;
BEGIN
    DROP TABLE IF EXISTS "employeeswithoutLogs_temp";
    DROP TABLE IF EXISTS "employeelist";

    SELECT "IVRM_Month_Id" INTO "@Monthid" 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Name" = "@Month";

    CREATE TEMP TABLE "employeeswithoutLogs_temp" (
        "HRME_Id" BIGINT,
        "ecode" VARCHAR(50),
        "ename" VARCHAR(250),
        "punchdate" DATE,
        "punchday" VARCHAR(50),
        "intime" VARCHAR(50),
        "outtime" VARCHAR(50),
        "workingtime" VARCHAR(50),
        "Status" VARCHAR(10)
    );

    "@StartDate" := MAKE_DATE("@Year"::INTEGER, "@Monthid"::INTEGER, 1);
    "@EndDate" := (DATE_TRUNC('MONTH', "@StartDate"::TIMESTAMP) + INTERVAL '1 MONTH - 1 day')::DATE;

    CREATE TEMP TABLE "employeelist" AS
    SELECT a."HRME_Id", a."HRMD_Id", "HRME_EmployeeCode",
        COALESCE("HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '') AS "HRME_EmployeeFirstName",
        "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType"
    FROM "HR_Master_Employee" a
    INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
    INNER JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id"
    INNER JOIN "HR_Master_GroupType" d ON a."HRMGT_Id" = d."HRMGT_Id"
    WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
        AND a."MI_Id" = "@MI_ID"
        AND a."HRME_Id"::TEXT IN (SELECT UNNEST(STRING_TO_ARRAY("@HRME_Id", ',')));

    FOR "v_HRME_Id", "v_HRMD_Id", "@ecode", "@ename" IN
        SELECT "HRME_Id", "HRMD_Id", "HRME_EmployeeCode", "HRME_EmployeeFirstName" 
        FROM "employeelist"
    LOOP
        FOR "@dt" IN
            SELECT dt FROM "alldates"("@StartDate", "@EndDate")
        LOOP
            "@punchINtime" := '00:00';
            "@punchOUTtime" := '00:00';

            SELECT 
                COALESCE((SELECT MIN(ed."FOEPD_PunchTime") 
                         FROM "fo"."FO_Emp_Punch_details" ed 
                         WHERE ed."FOEPD_InOutFlg" = 'I' 
                             AND ed."foep_id" = b."FOEP_Id" 
                             AND ed."FOEPD_Flag" = 1
                         LIMIT 1), '00:00'),
                COALESCE((SELECT MAX(ed."FOEPD_PunchTime") 
                         FROM "fo"."FO_Emp_Punch_details" ed 
                         WHERE ed."FOEPD_InOutFlg" = 'O' 
                             AND ed."foep_id" = b."FOEP_Id"
                         LIMIT 1), '00:00')
            INTO "@punchINtime", "@punchOUTtime"
            FROM "fo"."FO_Emp_Punch" b
            INNER JOIN "fo"."FO_Emp_Punch_Details" c ON c."FOEP_Id" = b."FOEP_Id"
            WHERE b."HRME_Id" = "v_HRME_Id" 
                AND b."FOEP_PunchDate"::DATE = "@dt"
                AND c."FOEPD_Flag" = 1
            GROUP BY b."FOEP_PunchDate", b."HRME_Id", b."FOEP_Id"
            LIMIT 1;

            IF "@punchINtime" IS NULL THEN
                "@punchINtime" := '00:00';
            END IF;

            IF "@punchOUTtime" IS NULL THEN
                "@punchOUTtime" := '00:00';
            END IF;

            SELECT CASE 
                WHEN "@punchOUTtime" = '00:00' THEN '00:00' 
                ELSE "getdatediff"("@punchINtime", "@punchOUTtime") 
            END INTO "@TatalWorkingHours";

            "@punchOUTtime" := CASE WHEN "@punchINtime" = '00:00' THEN '' ELSE "@punchOUTtime" END;
            "@TatalWorkingHours" := CASE WHEN "@punchINtime" = '00:00' THEN '' ELSE "@TatalWorkingHours" END;
            "@Status" := CASE WHEN "@punchINtime" = '00:00' THEN 'A' ELSE 'P' END;
            "@punchINtime" := CASE WHEN "@punchINtime" = '00:00' THEN '' ELSE "@punchINtime" END;

            INSERT INTO "employeeswithoutLogs_temp" 
            VALUES("v_HRME_Id", "@ecode", "@ename", "@dt", EXTRACT(DAY FROM "@dt")::VARCHAR(50), "@punchINtime", "@punchOUTtime", "@TatalWorkingHours", "@Status");

        END LOOP;
    END LOOP;

    RETURN QUERY
    SELECT DISTINCT 
        Temp."HRME_Id",
        Temp."ecode",
        Temp."ename",
        Temp."punchdate",
        Temp."punchday",
        Temp."intime",
        Temp."outtime",
        Temp."workingtime",
        Temp."Status",
        CASE WHEN Temp."outtime" > "ST"."FOEST_IIHalfLogoutTime" 
             THEN "getdatediff"("ST"."FOEST_IIHalfLogoutTime", Temp."outtime") 
             ELSE '00:00' 
        END AS "Overtime",
        "ST"."FOEST_IIHalfLogoutTime"
    FROM "employeeswithoutLogs_temp" Temp
    INNER JOIN "fo"."FO_Emp_Shifts_Timings" "ST" ON "ST"."HRME_Id" = Temp."HRME_Id";

    DROP TABLE IF EXISTS "employeeswithoutLogs_temp";
    DROP TABLE IF EXISTS "employeelist";

END;
$$;