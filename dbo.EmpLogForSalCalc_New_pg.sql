CREATE OR REPLACE FUNCTION "dbo"."EmpLogForSalCalc_New"(
    "date" VARCHAR(10),
    "month" VARCHAR(2),
    "year" VARCHAR(4),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "miid" BIGINT,
    "multiplehrmeid" VARCHAR(2000),
    "punchtype" VARCHAR(10)
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "HRML_Id" BIGINT,
    "LType" VARCHAR(20),
    "punchdate" TIMESTAMP
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "content" VARCHAR(500);
    "content1" VARCHAR(500);
    "cchrme" VARCHAR(500);
    "query" TEXT;
    "dynamic" TEXT;
    "content_LE" TEXT;
    "HRME_Id" BIGINT;
    "punchdate" TIMESTAMP;
    "lateby" VARCHAR(20);
    "varcount" INT;
    "RFOEP_RunningLateInsNos" BIGINT;
    "RHRME_Id" BIGINT;
    "RFOEP_PunchDate" TIMESTAMP;
    "FOEP_Id" BIGINT;
    "Rpunchdate" TIMESTAMP;
    "FOEP_PunchDate" TIMESTAMP;
    "HRLPC_NoOfLates" INT;
    "HRLPC_LateLOP" DECIMAL(10,2);
    "leave" BIGINT;
    "HRML_LeaveCode" VARCHAR(500);
    "LateinMin" BIGINT;
    "FOEP_New" BIGINT;
    "FOEP_Id_U" BIGINT;
    "Exceedno" INT;
    "HRMLY_Id" BIGINT;
    "HRELT_Id" BIGINT;
    "rcount" INT;
    "LateInTime" VARCHAR(20);
    "EarlyOutTime" VARCHAR(20);
    "earlyby" VARCHAR(20);
    "lateby_New" VARCHAR(10);
    "Rouwcount" INT;
    rec RECORD;
BEGIN

    SELECT DISTINCT a."HRML_Id", a."HRML_LeaveCode" 
    INTO "leave", "HRML_LeaveCode"
    FROM "HR_Master_Leave" a 
    INNER JOIN "HR_Emp_Leave_Status" b ON a."HRML_Id" = b."HRML_Id" 
    WHERE a."HRML_LateDeductFlag" = 1
    LIMIT 1;

    SELECT "HRLPC_NoOfLates", "HRLPC_LateLOP", "HRLPC_LateInTime", "HRLPC_EarlyOutTime"
    INTO "HRLPC_NoOfLates", "HRLPC_LateLOP", "LateInTime", "EarlyOutTime"
    FROM "HR_Leave_Policy_Configuration" 
    WHERE "MI_Id" = "miid";

    DROP TABLE IF EXISTS "EmplogDetails";
    DROP TABLE IF EXISTS "EmplogDetails_EO";
    DROP TABLE IF EXISTS "EmpTest01";
    DROP TABLE IF EXISTS "EmpTest02";

    CREATE TEMP TABLE "EmplogDetails" (
        "MI_Id" BIGINT,
        "HRME_Id" BIGINT,
        "ecode" VARCHAR(20),
        "ename" VARCHAR(100),
        "depname" VARCHAR(100),
        "desgname" VARCHAR(100),
        "gtype" VARCHAR(100),
        "intime" VARCHAR(20),
        "FOEP_Id" BIGINT,
        "actualtime" VARCHAR(10),
        "relaxtime" VARCHAR(10),
        "lateby" VARCHAR(10),
        "punchdate" TIMESTAMP
    );

    CREATE TEMP TABLE "EmplogDetails_EO" (
        "HRME_Id" BIGINT,
        "MI_Id" BIGINT,
        "ecode" VARCHAR(20),
        "ename" VARCHAR(100),
        "depname" VARCHAR(100),
        "desgname" VARCHAR(100),
        "gtype" VARCHAR(100),
        "punchdate" TIMESTAMP,
        "punchtime" VARCHAR(10),
        "actualtime" VARCHAR(10),
        "relaxtime" VARCHAR(10),
        "lateby" VARCHAR(10),
        "earlyby" VARCHAR(10),
        "FOEPD_InOutFlg" VARCHAR(5)
    );

    CREATE TEMP TABLE "EmpTest01" (
        "HRME_Id" BIGINT,
        "HRML_Id" BIGINT,
        "LType" VARCHAR(20),
        "punchdate" TIMESTAMP
    );

    CREATE TEMP TABLE "EmpTest02" (
        "HRME_Id" BIGINT,
        "HRML_Id" BIGINT,
        "LType" VARCHAR(20),
        "punchdate" TIMESTAMP
    );

    IF "fromdate" != '' AND "todate" != '' THEN
        "content1" := ' CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    ELSIF "month" != '' AND "year" != '' THEN
        "content1" := 'EXTRACT(MONTH FROM "FOEP_PunchDate")::TEXT = ''' || "month" || ''' AND EXTRACT(YEAR FROM "FOEP_PunchDate")::TEXT = ''' || "year" || '''';
    ELSIF "date" != '' THEN
        "content1" := ' CAST("FOEP_PunchDate" AS DATE)::TEXT = ''' || "date" || '''';
    ELSE
        "content1" := '';
    END IF;

    IF LOWER("punchtype") = 'late' THEN

        "dynamic" := 'SELECT DISTINCT f."MI_Id", f."HRME_Id", f."HRME_EmployeeCode" AS ecode,
        (COALESCE(f."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(f."HRME_EmployeeLastName",'''')) AS ename,
        g."HRMD_DepartmentName" AS depname, h."HRMDES_DesignationName" AS desgname, i."HRMGT_EmployeeGroupType" AS gtype,
        (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS intime,
        b."FOEP_Id", c."FOEST_IHalfLoginTime" AS actualtime, c."FOEST_DelayPerShiftHrMin" AS relaxtime,
        dbo.getdatediff(dbo.mintotime((dbo.getonlymin(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
        CAST(b."FOEP_PunchDate" AS DATE) AS punchdate
        FROM "fo"."FO_Emp_Punch_Details" a
        INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
        INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay" e ON e."FOHWDT_Id" = c."FOHWDT_Id"
        WHERE (SELECT dbo.getonlymin(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) > 
        dbo.getonlymin(c."FOEST_IHalfLoginTime") + dbo.getonlymin(c."FOEST_DelayPerShiftHrMin")
        AND j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1
        AND f."MI_Id" = ' || "miid"::TEXT || ' AND ' || "content1" || ' AND f."HRME_Id" IN (' || "multiplehrmeid" || ')
        GROUP BY b."FOEP_PunchDate", f."HRME_Id", f."HRME_EmployeeCode", g."HRMD_DepartmentName", h."HRMDES_DesignationName",
        i."HRMGT_EmployeeGroupType", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id",
        c."FOEST_DelayPerShiftHrMin", f."HRME_EmployeeFirstName", f."HRME_EmployeeMiddleName", f."HRME_EmployeeLastName"';

        EXECUTE 'INSERT INTO "EmplogDetails"("MI_Id","HRME_Id","ecode","ename","depname","desgname","gtype","intime","FOEP_Id","actualtime","relaxtime","lateby","punchdate") ' || "dynamic";

        "dynamic" := 'SELECT DISTINCT f."MI_Id", "HRME_Id", "ecode", "ename", "depname", "desgname", "gtype", "FOEP_PunchDate" AS punchdate,
        "outtime" AS punchtime, "actualtime", "relaxtime", ''00:00'' AS lateby,
        (CASE WHEN EXTRACT(EPOCH FROM ("actualtime"::TIME - "outtime"::TIME))/60 > CAST(RIGHT("relaxtime", 2) AS INT) THEN "earlyby" ELSE '''' END) AS earlyby, "FOEPD_InOutFlg"
        FROM (
            SELECT DISTINCT Oa.*, CAST(ob."punchdate" AS DATE)::TEXT AS "FOEP_PunchDate", ob."outtime", ob."actualtime", ob."relaxtime", ob."earlyby", ob."FOEPD_InOutFlg"
            FROM (
                SELECT a."HRME_Id", a."HRME_EmployeeCode" AS ecode,
                (COALESCE(a."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(a."HRME_EmployeeLastName",'''')) AS ename,
                b."HRMD_DepartmentName" AS depname, c."HRMDES_DesignationName" AS desgname, d."HRMGT_EmployeeGroupType" AS gtype
                FROM "HR_Master_Employee" a
                INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id"
                INNER JOIN "HR_Master_Designation" c ON a."HRMDES_Id" = c."HRMDES_Id"
                INNER JOIN "HR_Master_GroupType" d ON a."HRMGT_Id" = d."HRMGT_Id"
                WHERE a."MI_Id" = ' || "miid"::TEXT || ' AND a."HRME_Id" IN (' || "multiplehrmeid" || ')
            ) Oa,
            (
                SELECT b."HRME_Id", b."FOEP_PunchDate" AS punchdate, a."outtime", c."FOEST_IIHalfLogoutTime" AS actualtime,
                c."FOEST_EarlyPerShiftHrMin" AS relaxtime, dbo.getdatediff(a."outtime", c."FOEST_IIHalfLogoutTime") AS earlyby, a."FOEPD_InOutFlg"
                FROM (
                    SELECT MAX("FOEPD_PunchTime") AS outtime, "FOEP_Id", "FOEPD_InOutFlg"
                    FROM "fo"."FO_Emp_Punch_Details"
                    WHERE "FOEPD_InOutFlg" = ''O'' AND "FOEPD_Flag" = 1
                    GROUP BY "FOEP_Id", "FOEPD_InOutFlg"
                ) a
                INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
                INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON b."HRME_Id" = c."HRME_Id"
                WHERE b."FOEP_Flag" = 1 AND b."MI_Id" = ' || "miid"::TEXT || '
                AND dbo.getonlymin(a."outtime") < dbo.getonlymin(c."FOEST_IIHalfLogoutTime") - dbo.getonlymin(c."FOEST_EarlyPerShiftHrMin")
            ) Ob
            WHERE Oa."HRME_Id" = Ob."HRME_Id"
        ) a WHERE ' || "content1" || ' ORDER BY "HRME_Id", punchdate, punchtime';

        EXECUTE 'INSERT INTO "EmplogDetails_EO"("MI_Id","HRME_Id","ecode","ename","depname","desgname","gtype","punchdate","punchtime","actualtime","relaxtime","lateby","earlyby","FOEPD_InOutFlg") ' || "dynamic";

    END IF;

    FOR rec IN SELECT DISTINCT "HRME_Id", "punchdate", MIN(dbo.getonlymin("lateby")) AS lateby 
               FROM "EmplogDetails" 
               WHERE "MI_Id" = "miid" 
               GROUP BY "HRME_Id", "punchdate"
    LOOP
        "HRME_Id" := rec."HRME_Id";
        "punchdate" := rec."punchdate";
        "lateby" := rec.lateby;

        IF ("lateby"::BIGINT >= "LateInTime"::BIGINT) THEN

            SELECT "HRMLY_Id" INTO "HRMLY_Id" 
            FROM "HR_Master_LeaveYear" 
            WHERE "MI_Id" = "miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

            INSERT INTO "HR_Emp_Leave_Trans"(
                "MI_Id","HRME_Id","HRMLY_Id","HRELT_LeaveId","HRELT_FromDate","HRELT_ToDate","HRELT_TotDays",
                "HRELT_Reportingdate","HRELT_LeaveReason","HRELT_Status","CreatedDate","UpdatedDate",
                "HRELT_ActiveFlag","HRELT_EntryDate"
            ) VALUES(
                "miid","HRME_Id","HRMLY_Id","leave","punchdate","punchdate","HRLPC_LateLOP",
                CURRENT_TIMESTAMP,'LWP','Approved',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1,CURRENT_TIMESTAMP
            );

            SELECT MAX("HRELT_Id") INTO "HRELT_Id" 
            FROM "HR_Emp_Leave_Trans" 
            WHERE "MI_Id" = "miid" 
            AND CAST("HRELT_FromDate" AS DATE) = CAST("punchdate" AS DATE) 
            AND "HRME_Id" = "HRME_Id";

            INSERT INTO "HR_Emp_Leave_Trans_Details"(
                "HRELT_Id","HRML_Id","HRME_Id","MI_Id","HRELTD_FromDate","HRELTD_ToDate",
                "HRELTD_TotDays","HRELTD_LWPFlag","CreatedDate","UpdatedDate"
            ) VALUES(
                "HRELT_Id","leave","HRME_Id","miid","punchdate","punchdate",
                "HRLPC_LateLOP",0.5,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
            );

        END IF;

        "lateby_New" := COALESCE(LPAD((("lateby"::INT / 60)::TEXT), 2, '0') || ':' || LPAD((("lateby"::INT % 60)::TEXT), 2, '0'), '0');

        UPDATE "FO"."FO_Emp_Punch" 
        SET "FOEP_LateByMins" = "lateby_New", "FOEP_PuncedOnLeaveDayFlg" = 0
        WHERE "MI_Id" = "miid" 
        AND "HRME_Id" = "HRME_Id" 
        AND CAST("FOEP_PunchDate" AS DATE) = CAST("punchdate" AS DATE);

    END LOOP;

    FOR rec IN SELECT DISTINCT "HRME_Id", "punchdate", MIN(dbo.getonlymin("earlyby")) AS earlyby 
               FROM "EmplogDetails_EO" 
               WHERE "MI_Id" = "miid" 
               GROUP BY "HRME_Id", "punchdate"
    LOOP
        "HRME_Id" := rec."HRME_Id";
        "punchdate" := rec."punchdate";
        "earlyby" := rec.earlyby;

        IF ("earlyby"::BIGINT >= "EarlyOutTime"::BIGINT) THEN

            SELECT "HRMLY_Id" INTO "HRMLY_Id" 
            FROM "HR_Master_LeaveYear" 
            WHERE "MI_Id" = "miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

            INSERT INTO "HR_Emp_Leave_Trans"(
                "MI_Id","HRME_Id","HRMLY_Id","HRELT_LeaveId","HRELT_FromDate","HRELT_ToDate","HRELT_TotDays",
                "HRELT_Reportingdate","HRELT_LeaveReason","HRELT_Status","CreatedDate","UpdatedDate",
                "HRELT_ActiveFlag","HRELT_EntryDate"
            ) VALUES(
                "miid","HRME_Id","HRMLY_Id","leave","punchdate","punchdate","HRLPC_LateLOP",
                CURRENT_TIMESTAMP,'LWP','Approved',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1,CURRENT_TIMESTAMP
            );

            SELECT MAX("HRELT_Id") INTO "HRELT_Id" 
            FROM "HR_Emp_Leave_Trans" 
            WHERE "MI_Id" = "miid" 
            AND CAST("HRELT_FromDate" AS DATE) = CAST("punchdate" AS DATE) 
            AND "HRME_Id" = "HRME_Id";

            INSERT INTO "HR_Emp_Leave_Trans_Details"(
                "HRELT_Id","HRML_Id","HRME_Id","MI_Id","HRELTD_FromDate","HRELTD_ToDate",
                "HRELTD_TotDays","HRELTD_LWPFlag","CreatedDate","UpdatedDate"
            ) VALUES(
                "HRELT_Id","leave","HRME_Id","miid","punchdate","punchdate",
                "HRLPC_LateLOP",0.5,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
            );

        END IF;

    END LOOP;

    FOR rec IN SELECT DISTINCT "HRME_Id", "punchdate" FROM "EmplogDetails" WHERE "MI_Id" = "miid"
    LOOP
        "RHRME_Id" := rec."HRME_Id";
        "Rpunchdate" := rec."punchdate";

        SELECT MAX("FOEP_PunchDate"), "FOEP_RunningLateInsNos"
        INTO "punchdate", "RFOEP_RunningLateInsNos"
        FROM "FO"."FO_Emp_Punch" EP
        WHERE EP."MI_Id" = "miid" 
        AND EP."FOEP_HolidayPunchFlg" = 0 
        AND ("FOEP_RunningLateInsNos" >= 1) 
        AND "HRME_Id" = "RHRME_Id"
        GROUP BY EP."MI_Id", "HRME_Id", "FOEP_RunningLateInsNos";

        IF ("RFOEP_RunningLateInsNos" >= 1) THEN

            SELECT MAX("FOEP_Id") INTO "FOEP_Id_U" 
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = "miid" 
            AND "HRME_Id" = "RHRME_Id" 
            AND CAST("FOEP_PunchDate" AS DATE) = CAST("Rpunchdate" AS DATE);

            UPDATE "FO"."FO_Emp_Punch" 
            SET "FOEP_RunningLateInsNos" = "RFOEP_RunningLateInsNos" + 1
            WHERE "MI_Id" = "miid" 
            AND "HRME_Id" = "RHRME_Id" 
            AND "FOEP_Id" = "FOEP_Id_U";

            SELECT "FOEP_RunningLateInsNos" INTO "RFOEP_RunningLateInsNos"
            FROM "FO"."FO_Emp_Punch"
            WHERE "MI_Id" = "miid" 
            AND "HRME_Id" = "RHRME_Id" 
            AND "FOEP_RunningLateInsNos" <> 0 
            AND "FOEP_Id" = "FOEP_Id_U";

            "Exceedno" := ("RFOEP_RunningLateInsNos" % "HRLPC_NoOfLates");

            IF ("Exceedno" = 0) THEN

                "Rouwcount" := 0;

                SELECT COUNT(*) INTO "Rouwcount"
                FROM "HR_Emp_Leave_Trans"
                WHERE "MI_Id" = "miid" 
                AND "HRMLY_Id" = "HRMLY_Id" 
                AND "HRME_Id" = "RHRME_Id" 
                AND "HRELT_Status" = 'Approved'
                AND CAST("Rpunchdate" AS DATE) BETWEEN CAST("HRELT_FromDate" AS DATE) AND CAST("HRELT_ToDate" AS DATE);

                IF ("Rouwcount" > 0) THEN

                    UPDATE "FO"."FO_Emp_Punch" 
                    SET "FOEP_PuncedOnLeaveDayFlg" = 1
                    WHERE "MI_Id" = "miid" 
                    AND "HRME_Id" = "RHRME_Id" 
                    AND "FOEP_Id" = "FOEP_Id_U";

                ELSE

                    UPDATE "FO"."FO_Emp_Punch" 
                    SET "FOEP_LeaveDeductedFlg" = 1, "FOEP_LOPDeductedFlg" = 0
                    WHERE "MI_Id" = "miid" 
                    AND "HRME_Id" = "RHRME_Id" 
                    AND "FOEP_Id" = "FOEP_Id_U";

                    SELECT COUNT(*) INTO "rcount"
                    FROM "HR_Emp_Leave_Status"
                    WHERE "HRML_Id" = "leave" 
                    AND "HRELS_CBLeaves" > 0 
                    AND "MI_Id" = "miid" 
                    AND "HRME_Id" = "RHRME_Id";

                    IF ("rcount" > 0) THEN

                        SELECT "HRMLY_Id" INTO "HRMLY_Id" 
                        FROM "HR_Master_LeaveYear" 
                        WHERE "MI_Id" = "miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

                        UPDATE "HR_Emp_Leave_Status" 
                        SET "HRELS_TransLeaves" = "HRLPC_LateLOP", "HRELS_CBLeaves" = "HRELS_CBLeaves" - "HRELS_TransLeaves"
                        WHERE "MI_Id" = "miid" 
                        AND "HRME_Id" = "RHRME_Id" 
                        AND "HRML_Id" = "leave" 
                        AND "HRMLY_Id" = "HRMLY_Id";

                        INSERT INTO "HR_Emp_Leave_Trans"(
                            "MI_Id","HRME_Id","HRMLY_Id","HRELT_LeaveId","HRELT_FromDate","HRELT_ToDate","HRELT_TotDays",
                            "HRELT_Reportingdate","HRELT_LeaveReason","HRELT_Status","CreatedDate","UpdatedDate",
                            "HRELT_ActiveFlag","HRELT_EntryDate"
                        ) VALUES(
                            "miid","RHRME_Id","HRMLY_Id","leave","Rpunchdate","Rpunchdate","HRLPC_LateLOP",
                            CURRENT_TIMESTAMP,"HRML_LeaveCode",'Approved',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1,CURRENT_TIMESTAMP
                        );

                        SELECT MAX("HRELT_Id") INTO "HRELT_Id" 
                        FROM "HR_Emp_Leave_Trans" 
                        WHERE "MI_Id" = "miid" 
                        AND CAST("HRELT_FromDate" AS DATE) = CAST("Rpunchdate" AS DATE) 
                        AND "HRME_Id" = "RHRME_Id";

                        INSERT INTO "HR_Emp_Leave_Trans_Details"(
                            "HRELT_Id","HRML_Id","HRME_Id","MI_Id","HRELTD_FromDate","HRELTD_ToDate",
                            "HRELTD_TotDays","HRELTD_LWPFlag","CreatedDate","UpdatedDate"
                        ) VALUES(
                            "HRELT_Id","leave","RHRME_Id","miid","Rpunchdate","Rpunchdate",
                            "HRLPC_LateLOP",0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
                        );

                        INSERT INTO "EmpTest01" VALUES("RHRME_Id", "leave", "HRML_LeaveCode", "Rpunchdate");

                    ELSE

                        UPDATE "FO"."FO_Emp_Punch" 
                        SET "FOEP_LeaveDeductedFlg" = 0, "FOEP_LOPDeductedFlg" = 1
                        WHERE "MI_id" = "miid" 
                        AND "HRME_Id" = "RHRME_Id" 
                        AND "FOEP_Id" = "FOEP_Id_U";

                        SELECT "HRMLY_Id" INTO "HRMLY_Id" 
                        FROM "HR_Master_LeaveYear" 
                        WHERE "MI_Id" = "miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

                        INSERT INTO "HR_Emp_Leave_Trans"(
                            "MI_Id","HRME_Id","HRMLY_Id","HRELT_LeaveId","HRELT_FromDate","HRELT_ToDate","HRELT_TotDays",
                            "HRELT_Reportingdate","HRELT_LeaveReason","HRELT_Status","CreatedDate","UpdatedDate",
                            "HRELT_ActiveFlag","HRELT_EntryDate"
                        ) VALUES(
                            "miid","RHRME_Id","HRMLY_Id","leave","Rpunchdate","Rpunchdate","HRLPC_LateLOP",
                            CURRENT_TIMESTAMP,'LWP','Approved',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1,CURRENT_TIMESTAMP
                        );

                        SELECT MAX("HRELT_Id") INTO "HRELT_Id" 
                        FROM "HR_Emp_Leave_Trans" 
                        WHERE "MI_Id" = "miid" 
                        AND CAST("HRELT_FromDate" AS DATE) = CAST("Rpunchdate" AS DATE) 
                        AND "HRME_Id" = "RHRME_Id";

                        INSERT INTO "HR_Emp_Leave_Trans_Details"(
                            "HRELT_Id","HRML_Id","HRME_Id","MI_Id","HRELTD_FromDate","HRELTD_ToDate",
                            "HRELTD_TotDays","HRELTD_LWPFlag","CreatedDate","UpdatedDate"
                        ) VALUES(
                            "HRELT_Id","leave","RHRME_Id","miid","Rpunchdate","Rpunchdate",
                            "HRLPC_LateLOP",1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
                        );

                        INSERT INTO "EmpTest01" VALUES("RHRME_Id", "leave", 'LWP', "Rpunchdate");

                    END IF;

                END IF;

            END IF;

        END IF;

        SELECT MAX("FOEP_PunchDate"), "FOEP_RunningLateInsNos"
        INTO "punchdate", "RFOEP_RunningLateInsNos"
        FROM "FO"."FO_Emp_Punch" EP
        WHERE EP."MI_Id" = "miid" 
        AND EP."FOEP_HolidayPunchFlg" = 0 
        AND ("FOEP_RunningLateInsNos" IS NULL) 
        AND "HRME_Id" = "RHRME_Id"
        GROUP BY EP."MI_Id", "HRME_Id", "FOEP_RunningLateInsNos";

        IF ("RFOEP_RunningLateInsNos" IS NULL) THEN

            SELECT MAX("FOEP_Id") INTO "FOEP_Id" 
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = "miid" 
            AND "HRME_Id" = "RHRME_Id" 
            AND