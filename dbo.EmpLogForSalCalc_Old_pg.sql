CREATE OR REPLACE FUNCTION "dbo"."EmpLogForSalCalc_Old" (
    "p_date" VARCHAR(10),
    "p_month" VARCHAR(2),
    "p_year" VARCHAR(4),
    "p_fromdate" VARCHAR(10),
    "p_todate" VARCHAR(10),
    "p_miid" BIGINT,
    "p_multiplehrmeid" VARCHAR(2000),
    "p_punchtype" VARCHAR(10)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRML_Id" BIGINT,
    "LType" VARCHAR(20),
    "punchdate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_content" VARCHAR(500);
    "v_content1" VARCHAR(500);
    "v_cchrme" VARCHAR(500);
    "v_query" TEXT;
    "v_dynamic" TEXT;
    "v_content_LE" TEXT;
    "v_HRME_Id" BIGINT;
    "v_punchdate" TIMESTAMP;
    "v_lateby" VARCHAR(20);
    "v_varcount" INT;
    "v_RFOEP_RunningLateInsNos" BIGINT;
    "v_RHRME_Id" BIGINT;
    "v_RFOEP_PunchDate" TIMESTAMP;
    "v_FOEP_Id" BIGINT;
    "v_Rpunchdate" TIMESTAMP;
    "v_FOEP_PunchDate" TIMESTAMP;
    "v_HRLPC_NoOfLates" INT;
    "v_HRLPC_LateLOP" DECIMAL(10,2);
    "v_leave" BIGINT;
    "v_HRML_LeaveCode" VARCHAR(500);
    "v_LateinMin" BIGINT;
    "v_FOEP_New" BIGINT;
    "v_FOEP_Id_U" BIGINT;
    "v_Exceedno" INT;
    "v_HRMLY_Id" BIGINT;
    "v_HRELT_Id" BIGINT;
    "v_rcount" INT;
    "v_lateby_New" VARCHAR(10);
    "rec_fopunchupdate" RECORD;
    "rec_readtemptable" RECORD;
BEGIN

    SELECT DISTINCT a."HRML_Id", a."HRML_LeaveCode" 
    INTO "v_leave", "v_HRML_LeaveCode"
    FROM "HR_Master_Leave" a 
    INNER JOIN "HR_Emp_Leave_Status" b ON a."HRML_Id" = b."HRML_Id" 
    WHERE "HRML_LateDeductFlag" = 1;

    SELECT "HRLPC_NoOfLates", "HRLPC_LateLOP" 
    INTO "v_HRLPC_NoOfLates", "v_HRLPC_LateLOP"
    FROM "HR_Leave_Policy_Configuration" 
    WHERE "MI_Id" = "p_miid";

    DROP TABLE IF EXISTS "EmplogDetails";
    
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

    DROP TABLE IF EXISTS "EmpTest01";
    
    CREATE TEMP TABLE "EmpTest01" (
        "HRME_Id" BIGINT,
        "HRML_Id" BIGINT,
        "LType" VARCHAR(20),
        "punchdate" TIMESTAMP
    );

    DROP TABLE IF EXISTS "EmpTest02";
    
    CREATE TEMP TABLE "EmpTest02" (
        "HRME_Id" BIGINT,
        "HRML_Id" BIGINT,
        "LType" VARCHAR(20),
        "punchdate" TIMESTAMP
    );

    IF "p_fromdate" != '' AND "p_todate" != '' THEN
        "v_content1" := ' CAST("FOEP_PunchDate" AS DATE) BETWEEN ''' || "p_fromdate" || ''' AND ''' || "p_todate" || '''';
    ELSIF "p_month" != '' AND "p_year" != '' THEN
        "v_content1" := 'EXTRACT(MONTH FROM "FOEP_PunchDate")=' || "p_month" || ' AND EXTRACT(YEAR FROM "FOEP_PunchDate")=' || "p_year";
    ELSIF "p_date" != '' THEN
        "v_content1" := ' CAST("FOEP_PunchDate" AS DATE)=''' || "p_date" || '''';
    ELSE
        "v_content1" := '';
    END IF;

    IF "p_punchtype" = 'late' THEN

        "v_dynamic" := 'SELECT DISTINCT f."MI_Id", f."HRME_Id", f."HRME_EmployeeCode" AS ecode,
        (COALESCE(f."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(f."HRME_EmployeeLastName",'''')) AS ename,
        g."HRMD_DepartmentName" AS depname, h."HRMDES_DesignationName" AS desgname, i."HRMGT_EmployeeGroupType" AS gtype,
        (SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS intime,
        b."FOEP_Id", c."FOEST_IHalfLoginTime" AS actualtime, c."FOEST_DelayPerShiftHrMin" AS relaxtime,
        "dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS lateby,
        CAST("FOEP_PunchDate" AS DATE) AS punchdate
        FROM "fo"."FO_Emp_Punch_Details" a
        INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id"
        INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE)
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay" E ON e."FOHWDT_Id" = c."FOHWDT_Id"
        WHERE (SELECT "dbo"."getonlymin"(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) > 
        "dbo"."getonlymin"("FOEST_IHalfLoginTime") + "dbo"."getonlymin"("FOEST_DelayPerShiftHrMin") 
        AND j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = 1
        AND f."MI_Id" = ' || "p_miid"::TEXT || ' AND ' || "v_content1" || ' AND F."HRME_Id" IN (' || "p_multiplehrmeid" || ')
        GROUP BY "FOEP_PunchDate", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType", 
        "FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin", 
        j."FOEPD_PunchTime", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';

        EXECUTE 'INSERT INTO "EmplogDetails"("MI_Id","HRME_Id","ecode","ename","depname","desgname","gtype","intime","FOEP_Id","actualtime","relaxtime","lateby","punchdate") ' || "v_dynamic";

    END IF;

    FOR "rec_fopunchupdate" IN 
        SELECT DISTINCT "HRME_Id", "punchdate", MIN("dbo"."getonlymin"("lateby")) AS "lateby" 
        FROM "EmplogDetails" 
        WHERE "MI_Id" = "p_miid" 
        GROUP BY "HRME_Id", "punchdate"
    LOOP
        "v_HRME_Id" := "rec_fopunchupdate"."HRME_Id";
        "v_punchdate" := "rec_fopunchupdate"."punchdate";
        "v_lateby" := "rec_fopunchupdate"."lateby";

        "v_lateby_New" := COALESCE((FLOOR(CAST("v_lateby" AS INT) / 60)::TEXT || ':' || 
                         LPAD((CAST("v_lateby" AS INT) % 60)::TEXT, 2, '0')), '0');

        UPDATE "FO"."FO_Emp_Punch" 
        SET "FOEP_LateByMins" = "v_lateby_New", "FOEP_PuncedOnLeaveDayFlg" = 0 
        WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_HRME_Id" AND CAST("FOEP_PunchDate" AS DATE) = CAST("v_punchdate" AS DATE);

    END LOOP;

    FOR "rec_readtemptable" IN 
        SELECT DISTINCT "HRME_Id", "punchdate" FROM "EmplogDetails" WHERE "MI_Id" = "p_miid"
    LOOP
        "v_RHRME_Id" := "rec_readtemptable"."HRME_Id";
        "v_Rpunchdate" := "rec_readtemptable"."punchdate";

        SELECT MAX("FOEP_PunchDate"), "FOEP_RunningLateInsNos" 
        INTO "v_punchdate", "v_RFOEP_RunningLateInsNos"
        FROM "FO"."FO_Emp_Punch" EP 
        WHERE EP."MI_Id" = "p_miid" AND EP."FOEP_HolidayPunchFlg" = 0 AND ("FOEP_RunningLateInsNos" >= 1) AND "HRME_Id" = "v_RHRME_Id"
        GROUP BY EP."MI_Id", "HRME_Id", "FOEP_RunningLateInsNos";

        IF ("v_RFOEP_RunningLateInsNos" >= 1) THEN

            SELECT MAX("FOEP_Id") INTO "v_FOEP_Id_U"
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND CAST("FOEP_PunchDate" AS DATE) = CAST("v_Rpunchdate" AS DATE);

            UPDATE "FO"."FO_Emp_Punch" 
            SET "FOEP_RunningLateInsNos" = "v_RFOEP_RunningLateInsNos" + 1 
            WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "FOEP_Id" = "v_FOEP_Id_U";

            SELECT "FOEP_RunningLateInsNos" INTO "v_RFOEP_RunningLateInsNos"
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "FOEP_RunningLateInsNos" <> 0;

            SELECT "HRLPC_NoOfLates" INTO "v_HRLPC_NoOfLates"
            FROM "HR_Leave_Policy_Configuration" 
            WHERE "MI_Id" = "p_miid";

            "v_Exceedno" := ("v_RFOEP_RunningLateInsNos" % "v_HRLPC_NoOfLates");

            IF ("v_Exceedno" = 0) THEN

                UPDATE "FO"."FO_Emp_Punch" 
                SET "FOEP_LeaveDeductedFlg" = 1 
                WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "FOEP_Id" = "v_FOEP_Id_U";

                SELECT COUNT(*) INTO "v_rcount"
                FROM "HR_Emp_Leave_Status" 
                WHERE "HRML_Id" = "v_leave" AND "HRELS_CBLeaves" > 0 AND "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id";

                IF ("v_rcount" > 0) THEN

                    SELECT "HRMLY_Id" INTO "v_HRMLY_Id"
                    FROM "HR_Master_LeaveYear" 
                    WHERE "MI_Id" = "p_miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

                    UPDATE "HR_Emp_Leave_Status" 
                    SET "HRELS_TransLeaves" = "v_HRLPC_LateLOP", "HRELS_CBLeaves" = "HRELS_CBLeaves" - "HRELS_TransLeaves" 
                    WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "HRML_Id" = "v_leave" AND "HRMLY_Id" = "v_HRMLY_Id";

                    INSERT INTO "HR_Emp_Leave_Trans"(
                        "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays", 
                        "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", "CreatedDate", "UpdatedDate", 
                        "HRELT_ActiveFlag", "HRELT_EntryDate"
                    ) VALUES (
                        "p_miid", "v_RHRME_Id", "v_HRMLY_Id", "v_leave", "v_Rpunchdate", "v_Rpunchdate", "v_HRLPC_LateLOP",
                        CURRENT_TIMESTAMP, "v_HRML_LeaveCode", 'Approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
                    );

                    SELECT MAX("HRELT_Id") INTO "v_HRELT_Id"
                    FROM "HR_Emp_Leave_Trans" 
                    WHERE "MI_Id" = "p_miid" AND CAST("HRELT_FromDate" AS DATE) = CAST("v_Rpunchdate" AS DATE) AND "HRME_Id" = "v_RHRME_Id";

                    INSERT INTO "HR_Emp_Leave_Trans_Details"(
                        "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", 
                        "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                    ) VALUES (
                        "v_HRELT_Id", "v_leave", "v_RHRME_Id", "p_miid", "v_Rpunchdate", "v_Rpunchdate", 
                        "v_HRLPC_LateLOP", 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );

                    INSERT INTO "EmpTest01" VALUES("v_RHRME_Id", "v_leave", "v_HRML_LeaveCode", "v_Rpunchdate");

                ELSE

                    UPDATE "FO"."FO_Emp_Punch" 
                    SET "FOEP_LeaveDeductedFlg" = 0 
                    WHERE "MI_id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "FOEP_Id" = "v_FOEP_Id_U";

                    SELECT "HRMLY_Id" INTO "v_HRMLY_Id"
                    FROM "HR_Master_LeaveYear" 
                    WHERE "MI_Id" = "p_miid" AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

                    INSERT INTO "HR_Emp_Leave_Trans"(
                        "MI_Id", "HRME_Id", "HRMLY_Id", "HRELT_LeaveId", "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays",
                        "HRELT_Reportingdate", "HRELT_LeaveReason", "HRELT_Status", "CreatedDate", "UpdatedDate", 
                        "HRELT_ActiveFlag", "HRELT_EntryDate"
                    ) VALUES (
                        "p_miid", "v_RHRME_Id", "v_HRMLY_Id", "v_leave", "v_Rpunchdate", "v_Rpunchdate", "v_HRLPC_LateLOP",
                        CURRENT_TIMESTAMP, 'LWP', 'Approved', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
                    );

                    SELECT MAX("HRELT_Id") INTO "v_HRELT_Id"
                    FROM "HR_Emp_Leave_Trans" 
                    WHERE "MI_Id" = "p_miid" AND CAST("HRELT_FromDate" AS DATE) = CAST("v_Rpunchdate" AS DATE) AND "HRME_Id" = "v_RHRME_Id";

                    INSERT INTO "HR_Emp_Leave_Trans_Details"(
                        "HRELT_Id", "HRML_Id", "HRME_Id", "MI_Id", "HRELTD_FromDate", "HRELTD_ToDate", 
                        "HRELTD_TotDays", "HRELTD_LWPFlag", "CreatedDate", "UpdatedDate"
                    ) VALUES (
                        "v_HRELT_Id", "v_leave", "v_RHRME_Id", "p_miid", "v_Rpunchdate", "v_Rpunchdate", 
                        "v_HRLPC_LateLOP", 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );

                    INSERT INTO "EmpTest01" VALUES("v_RHRME_Id", "v_leave", 'LWP', "v_Rpunchdate");

                END IF;

            END IF;

        END IF;

        SELECT MAX("FOEP_PunchDate"), "FOEP_RunningLateInsNos" 
        INTO "v_punchdate", "v_RFOEP_RunningLateInsNos"
        FROM "FO"."FO_Emp_Punch" EP 
        WHERE EP."MI_Id" = "p_miid" AND EP."FOEP_HolidayPunchFlg" = 0 AND ("FOEP_RunningLateInsNos" IS NULL) AND "HRME_Id" = "v_RHRME_Id"
        GROUP BY EP."MI_Id", "HRME_Id", "FOEP_RunningLateInsNos";

        IF ("v_RFOEP_RunningLateInsNos" IS NULL) THEN

            SELECT MAX("FOEP_Id") INTO "v_FOEP_Id"
            FROM "FO"."FO_Emp_Punch" 
            WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND CAST("FOEP_PunchDate" AS DATE) = CAST("v_Rpunchdate" AS DATE) 
            AND "FOEP_RunningLateInsNos" IS NULL;

            UPDATE "FO"."FO_Emp_Punch" 
            SET "FOEP_RunningLateInsNos" = 1 
            WHERE "MI_Id" = "p_miid" AND "HRME_Id" = "v_RHRME_Id" AND "FOEP_Id" = "v_FOEP_Id";

        END IF;

    END LOOP;

    RETURN QUERY 
    SELECT * FROM (
        SELECT * FROM "EmpTest01" 
        UNION 
        SELECT * FROM "EmpTest02"
    ) AS new;

END;
$$;