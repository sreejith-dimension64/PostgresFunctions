
CREATE OR REPLACE FUNCTION "dbo"."EmpLogForSalCalc_Bdcampus"(
    p_date VARCHAR(10),
    p_month VARCHAR(2),
    p_year VARCHAR(4),
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_miid BIGINT,
    p_multiplehrmeid VARCHAR(2000),
    p_punchtype VARCHAR(10)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRML_Id" BIGINT,
    "LType" VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_content VARCHAR(500);
    v_content1 VARCHAR(500);
    v_cchrme VARCHAR(500);
    v_query VARCHAR;
    v_dynamic VARCHAR;
    v_content_LE VARCHAR;
    v_HRME_Id BIGINT;
    v_punchdate TIMESTAMP;
    v_lateby VARCHAR(20);
    v_varcount INT;
    v_RFOEP_RunningLateInsNos INT;
    v_RHRME_Id BIGINT;
    v_RFOEP_PunchDate TIMESTAMP;
    v_FOEP_Id BIGINT;
    v_Rpunchdate TIMESTAMP;
    v_FOEP_PunchDate TIMESTAMP;
    v_RunningLateMins INT;
    v_cummulativetime INT;
    v_RunningLateMins_New INT;
    v_Exceedno INT;
    v_HRMLY_Id BIGINT;
    v_HRELT_Id BIGINT;
    v_rcount INT;
    v_CummulativeTimeFlag INT;
    v_HRLPC_NoOfLates INT;
    v_cols VARCHAR(2000);
    v_totalpresent VARCHAR(10);
    v_leave BIGINT;
    v_HRML_LeaveCode VARCHAR(500);
    v_HRLPC_LateInFlag INT;
    v_HRLPC_EarlyOutFlag INT;
    v_earlyby VARCHAR(20);
    v_FOEP_Id_U BIGINT;
    v_HRLPC_LateLOP DECIMAL(10,2);
    v_Rouwcount INT;
    rec_fopunchupdate RECORD;
    rec_readtemptable RECORD;
BEGIN

    DROP TABLE IF EXISTS "EmplogDetails";
    DROP TABLE IF EXISTS "EmplogDetails_LIEO";
    DROP TABLE IF EXISTS "EmpTest01";
    DROP TABLE IF EXISTS "EmpTest02";
    DROP TABLE IF EXISTS "EmpTest03";

    v_Rouwcount := 0;
    
    CREATE TEMP TABLE "EmpTest01" ("HRME_Id" BIGINT, "HRML_Id" BIGINT, "LType" VARCHAR(20));
    CREATE TEMP TABLE "EmpTest02" ("HRME_Id" BIGINT, "HRML_Id" BIGINT, "LType" VARCHAR(20));
    CREATE TEMP TABLE "EmpTest03" ("HRME_Id" BIGINT, "HRML_Id" BIGINT, "LType" VARCHAR(20));

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

    CREATE TEMP TABLE "EmplogDetails_LIEO" (
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

    SELECT a."HRML_Id", a."HRML_LeaveCode" INTO v_leave, v_HRML_LeaveCode
    FROM "HR_Master_Leave" a 
    INNER JOIN "HR_Emp_Leave_Status" b ON a."HRML_Id" = b."HRML_Id" 
    WHERE "HRML_LateDeductFlag" = 1
    LIMIT 1;

    SELECT "HRLPC_NoOfLates", "HRLPC_LateLOP" INTO v_HRLPC_NoOfLates, v_HRLPC_LateLOP
    FROM "HR_Leave_Policy_Configuration" 
    WHERE "MI_Id" = p_miid;

    IF p_fromdate != '' AND p_todate != '' THEN
        v_content1 := ' CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    ELSIF p_month != '' AND p_year != '' THEN
        v_content1 := 'EXTRACT(MONTH FROM "FOEP_PunchDate")=' || p_month || ' AND EXTRACT(YEAR FROM "FOEP_PunchDate")=' || p_year;
    ELSIF p_date != '' THEN
        v_content1 := ' CAST("FOEP_PunchDate" AS DATE)=''' || p_date || '''';
    ELSE
        v_content1 := '';
    END IF;

    IF p_fromdate != '' AND p_todate != '' THEN
        v_content_LE := ' CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    ELSIF p_month != '' AND p_year != '' THEN
        v_content_LE := 'EXTRACT(MONTH FROM "FOEP_PunchDate")=' || p_month || ' AND EXTRACT(YEAR FROM "FOEP_PunchDate")=' || p_year;
    ELSIF p_date != '' THEN
        v_content_LE := ' CAST("FOEP_PunchDate" AS DATE)=''' || p_date || '''';
    ELSE
        v_content_LE := '';
    END IF;

    IF p_punchtype = 'LIEO' THEN

        v_dynamic := 'INSERT INTO "EmplogDetails_LIEO"("MI_Id","HRME_Id","ecode","ename","depname","desgname","gtype","punchdate","punchtime","actualtime","relaxtime","lateby","earlyby","FOEPD_InOutFlg")
        SELECT DISTINCT f."MI_Id", f."HRME_Id", f."HRME_EmployeeCode" ecode,
        (COALESCE(f."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(f."HRME_EmployeeLastName",'''')) AS ename,
        g."HRMD_DepartmentName" depname, h."HRMDES_DesignationName" desgname, i."HRMGT_EmployeeGroupType" gtype,
        CAST("FOEP_PunchDate" AS DATE) punchdate, 
        (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS punchtime,
        c."FOEST_IHalfLoginTime" actualtime, c."FOEST_DelayPerShiftHrMin" relaxtime,
        dbo.getdatediff(dbo.mintotime((dbo.getonlymin(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") lateby, ''00:00'' AS earlyby, j."FOEPD_InOutFlg"
        FROM "FO"."FO_Emp_Punch_Details" a 
        INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
        INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
        WHERE j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1 AND c."FOHWDT_Id" = d."FOHWDT_Id"
        AND f."MI_Id" = ' || p_miid || ' AND ' || v_content_LE || ' AND f."HRME_Id" IN(' || p_multiplehrmeid || ')
        GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType",
        c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", j."FOEPD_InOutFlg", b."FOEP_Id", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

        EXECUTE v_dynamic;

    ELSIF p_punchtype = 'late' THEN

        v_dynamic := 'INSERT INTO "EmplogDetails"("MI_Id","HRME_Id","ecode","ename","depname","desgname","gtype","intime","FOEP_Id","actualtime","relaxtime","lateby","punchdate")
        SELECT DISTINCT f."MI_Id", f."HRME_Id", f."HRME_EmployeeCode" ecode,
        (COALESCE(f."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(f."HRME_EmployeeLastName",'''')) AS ename,
        g."HRMD_DepartmentName" depname, h."HRMDES_DesignationName" desgname, i."HRMGT_EmployeeGroupType" gtype,
        (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS intime,
        b."FOEP_Id", c."FOEST_IHalfLoginTime" actualtime, c."FOEST_DelayPerShiftHrMin" relaxtime,
        dbo.getdatediff(dbo.mintotime((dbo.getonlymin(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") lateby,
        CAST("FOEP_PunchDate" AS DATE) punchdate
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
        WHERE j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1
        AND f."MI_Id" = ' || p_miid || ' AND ' || v_content1 || ' AND f."HRME_Id" IN(' || p_multiplehrmeid || ')
        GROUP BY "FOEP_PunchDate", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType",
        c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

        EXECUTE v_dynamic;

    END IF;

    SELECT "HRLPC_LateInFlag", "HRLPC_EarlyOutFlag" INTO v_HRLPC_LateInFlag, v_HRLPC_EarlyOutFlag
    FROM "HR_Leave_Policy_Configuration" 
    WHERE "MI_Id" = p_miid;

    IF (v_HRLPC_LateInFlag = 1) AND (v_HRLPC_EarlyOutFlag = 1) THEN

        FOR rec_fopunchupdate IN 
            SELECT DISTINCT "HRME_Id", "punchdate", MIN(dbo.getonlymin("lateby")) AS lateby, MIN(dbo.getonlymin("earlyby")) AS earlyby 
            FROM "EmplogDetails_LIEO" 
            WHERE "MI_Id" = p_miid 
            GROUP BY "HRME_Id", "punchdate"
        LOOP
            v_HRME_Id := rec_fopunchupdate."HRME_Id";
            v_punchdate := rec_fopunchupdate."punchdate";
            v_lateby := rec_fopunchupdate.lateby;
            v_earlyby := rec_fopunchupdate.earlyby;

            SELECT SUM(CAST("FOEP_RunningLateMins" AS INT)) INTO v_RunningLateMins
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id
            AND CAST("FOEP_PunchDate" AS DATE) <= (SELECT DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH' - INTERVAL '1 DAY');

            UPDATE "FO"."FO_Emp_Punch" 
            SET "FOEP_LateByMins" = v_lateby, 
                "FOEP_RunningLateMins" = COALESCE(v_RunningLateMins, 0) + v_lateby::INT + v_earlyby::INT,
                "FOEP_PuncedOnLeaveDayFlg" = 0
            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id
            AND CAST("FOEP_PunchDate" AS DATE) = CAST(v_punchdate AS DATE);

            SELECT SUM(CAST("FOEP_RunningLateMins" AS INT)) INTO v_RunningLateMins_New
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id
            AND CAST("FOEP_PunchDate" AS DATE) <= (SELECT DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH' - INTERVAL '1 DAY');

            SELECT "HRLPC_CummulativeTimeFlag", "HRLPC_CummulativeTime" INTO v_CummulativeTimeFlag, v_cummulativetime
            FROM "HR_Leave_Policy_Configuration" 
            WHERE "MI_Id" = p_miid;

            IF (v_CummulativeTimeFlag = 1) THEN
                IF (v_cummulativetime <= v_RunningLateMins_New) THEN
                    SELECT COUNT(*) INTO v_rcount
                    FROM "HR_Emp_Leave_Status" 
                    WHERE "HRML_Id" = 1 AND "HRELS_CBLeaves" > 0 AND "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id;

                    IF (v_rcount > 0) THEN
                        SELECT COUNT(*) INTO v_Rouwcount
                        FROM "HR_Emp_Leave_Trans"
                        WHERE "MI_Id" = p_miid AND v_HRMLY_Id = "HRMLY_Id" AND "HRME_Id" = v_HRME_Id AND "HRELT_Status" = 'Approved'
                        AND v_Rpunchdate BETWEEN "HRELT_FromDate" AND "HRELT_ToDate";

                        IF (v_Rouwcount > 0) THEN
                            SELECT MAX("FOEP_Id") INTO v_FOEP_Id_U
                            FROM "FO"."FO_Emp_Punch" 
                            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id AND CAST("FOEP_PunchDate" AS DATE) = CAST(v_Rpunchdate AS DATE);

                            UPDATE "FO"."FO_Emp_Punch" 
                            SET "FOEP_PuncedOnLeaveDayFlg" = 1 
                            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U;
                        ELSE
                            SELECT "HRMLY_Id" INTO v_HRMLY_Id
                            FROM "HR_Master_LeaveYear" 
                            WHERE "MI_Id" = p_miid AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

                            UPDATE "HR_Emp_Leave_Status" 
                            SET "HRELS_TransLeaves" = 1, "HRELS_CBLeaves" = "HRELS_CBLeaves" - "HRELS_TransLeaves"
                            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_HRME_Id AND "HRML_Id" = 1 AND "HRMLY_Id" = v_HRMLY_Id;

                            INSERT INTO "HR_Emp_Leave_Trans"(
                                "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays",
                                "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
                            ) VALUES(
                                p_miid, v_HRME_Id, v_HRMLY_Id, 1, v_punchdate, v_punchdate, 0.5,
                                CURRENT_TIMESTAMP, 'LateIn_LOPExCum', 'Approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
                            );

                            SELECT "HRELT_Id" INTO v_HRELT_Id
                            FROM "HR_Emp_Leave_Trans" 
                            WHERE "MI_Id" = p_miid AND CAST("HRELT_FromDate" AS DATE) = CAST(v_punchdate AS DATE) AND "HRME_Id" = v_RHRME_Id;

                            INSERT INTO "HR_Emp_Leave_Trans_Details"(
                                "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                            ) VALUES(
                                v_HRELT_Id, 1, v_HRME_Id, p_miid, v_punchdate, v_punchdate, 0.5, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                            );
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        FOR rec_readtemptable IN 
            SELECT DISTINCT "HRME_Id", "punchdate" 
            FROM "EmplogDetails_LIEO" 
            WHERE "MI_Id" = p_miid
        LOOP
            v_RHRME_Id := rec_readtemptable."HRME_Id";
            v_Rpunchdate := rec_readtemptable."punchdate";

            SELECT MAX("FOEP_PunchDate"), "FOEP_RunningLateInsNos" INTO v_FOEP_PunchDate, v_RFOEP_RunningLateInsNos
            FROM "FO"."FO_Emp_Punch" EP
            WHERE EP."MI_Id" = p_miid AND EP."FOEP_HolidayPunchFlg" = 0 AND ("FOEP_RunningLateInsNos" >= 1) AND "HRME_Id" = v_RHRME_Id
            GROUP BY EP."MI_Id", "HRME_Id", "FOEP_RunningLateInsNos";

            IF (v_RFOEP_RunningLateInsNos >= 1) THEN
                SELECT MAX("FOEP_Id") INTO v_FOEP_Id_U
                FROM "FO"."FO_Emp_Punch" 
                WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND CAST("FOEP_PunchDate" AS DATE) = CAST(v_Rpunchdate AS DATE);

                UPDATE "FO"."FO_Emp_Punch" 
                SET "FOEP_RunningLateInsNos" = v_RFOEP_RunningLateInsNos + 1
                WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U;

                SELECT "FOEP_RunningLateInsNos" INTO v_RFOEP_RunningLateInsNos
                FROM "FO"."FO_Emp_Punch"
                WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U AND "FOEP_RunningLateInsNos" <> 0;

                SELECT "HRLPC_NoOfLates" INTO v_HRLPC_NoOfLates
                FROM "HR_Leave_Policy_Configuration" 
                WHERE "MI_Id" = p_miid;

                v_Exceedno := (v_RFOEP_RunningLateInsNos % v_HRLPC_NoOfLates);

                IF (v_Exceedno = 0) THEN
                    SELECT COUNT(*) INTO v_Rouwcount
                    FROM "HR_Emp_Leave_Trans"
                    WHERE "MI_Id" = p_miid AND v_HRMLY_Id = "HRMLY_Id" AND "HRME_Id" = v_RHRME_Id AND "HRELT_Status" = 'Approved'
                    AND v_Rpunchdate BETWEEN "HRELT_FromDate" AND "HRELT_ToDate";

                    IF (v_Rouwcount > 0) THEN
                        UPDATE "FO"."FO_Emp_Punch" 
                        SET "FOEP_PuncedOnLeaveDayFlg" = 1 
                        WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U;
                    ELSE
                        UPDATE "FO"."FO_Emp_Punch" 
                        SET "FOEP_LeaveDeductedFlg" = 1, "FOEP_LOPDeductedFlg" = 0
                        WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U;

                        SELECT COUNT(*) INTO v_rcount
                        FROM "HR_Emp_Leave_Status" 
                        WHERE "HRML_Id" = 1 AND "HRELS_CBLeaves" > 0 AND "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id;

                        IF (v_rcount > 0) THEN
                            SELECT "HRMLY_Id" INTO v_HRMLY_Id
                            FROM "HR_Master_LeaveYear" 
                            WHERE "MI_Id" = p_miid AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

                            UPDATE "HR_Emp_Leave_Status" 
                            SET "HRELS_TransLeaves" = 1, "HRELS_CBLeaves" = "HRELS_CBLeaves" - "HRELS_TransLeaves"
                            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "HRML_Id" = 1 AND "HRMLY_Id" = v_HRMLY_Id;

                            INSERT INTO "HR_Emp_Leave_Trans"(
                                "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays",
                                "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
                            ) VALUES(
                                p_miid, v_RHRME_Id, v_HRMLY_Id, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1,
                                CURRENT_TIMESTAMP, 'LateIn_LOP', 'Approved', v_Rpunchdate, v_Rpunchdate, 1, CURRENT_TIMESTAMP
                            );

                            SELECT "HRELT_Id" INTO v_HRELT_Id
                            FROM "HR_Emp_Leave_Trans" 
                            WHERE "MI_Id" = p_miid AND CAST("HRELT_FromDate" AS DATE) = CAST(v_Rpunchdate AS DATE) AND "HRME_Id" = v_RHRME_Id;

                            INSERT INTO "HR_Emp_Leave_Trans_Details"(
                                "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                            ) VALUES(
                                v_HRELT_Id, 1, v_RHRME_Id, p_miid, v_Rpunchdate, v_Rpunchdate, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                            );
                        ELSE
                            UPDATE "FO"."FO_Emp_Punch" 
                            SET "FOEP_LeaveDeductedFlg" = 0, "FOEP_LOPDeductedFlg" = 1
                            WHERE "MI_Id" = p_miid AND "HRME_Id" = v_RHRME_Id AND "FOEP_Id" = v_FOEP_Id_U;

                            SELECT "HRMLY_Id" INTO v_HRMLY_Id
                            FROM "HR_Master_LeaveYear" 
                            WHERE "MI_Id" = p_miid AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_DATE);

                            INSERT INTO "HR_Emp_Leave_Trans"(
                                "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays",
                                "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", "CreatedDate", "UpdatedDate", "HRELT_ActiveFlag", "HRELT_EntryDate"
                            ) VALUES(
                                p_miid, v_RHRME_Id, v_HRMLY_Id, 1, v_Rpunchdate, v_Rpunchdate, 1,
                                CURRENT_TIMESTAMP, 'LWP', 'Approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
                            );

                            SELECT "HRELT_Id" INTO v_HRELT_Id
                            FROM "HR_Emp_Leave_Trans" 
                            WHERE "MI_Id" = p_miid AND CAST("HRELT_FromDate" AS DATE) = CAST(v_Rpunchdate AS DATE) AND "HRME_Id" = v_RHRME_Id;

                            INSERT INTO "HR_Emp_Leave_Trans_Details"(
                                "HRELT_Id", "HRML_Id", "HR