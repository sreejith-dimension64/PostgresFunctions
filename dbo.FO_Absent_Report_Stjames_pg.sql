CREATE OR REPLACE FUNCTION "dbo"."FO_Absent_Report_Stjames"(
    p_MI_Id bigint,
    p_StartDate date,
    p_EndDate date,
    p_multiplehrmeid TEXT
)
RETURNS TABLE(
    "WorkDate" date,
    "EmpCode" varchar(100),
    "EmployeeName" varchar(200),
    "Department" varchar(300),
    "Designation" varchar(300),
    "Status" varchar(300),
    "HRME_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRLPC_AbsentLeaveFlag int;
    v_WDate date;
    v_Rouwcount int;
    v_HRMD_Id BIGINT;
    v_HCount int;
    v_Rcount int;
    v_status varchar(100);
    v_HRME_Id bigint;
    v_HRMLY_Id bigint;
    v_HRELT_Id bigint;
    v_LeavePrefixSuffixFlag int;
    v_EmpCode varchar(100);
    v_EmployeeName varchar(200);
    v_Department varchar(300);
    v_Designation varchar(300);
    v_dynamicsql TEXT;
    rec_workdate RECORD;
    rec_emp RECORD;
BEGIN

    DROP TABLE IF EXISTS "EmpsAbsentDetails_Temp";
    
    CREATE TEMP TABLE "EmpsAbsentDetails_Temp"(
        "WorkDate" date,
        "EmpCode" varchar(100),
        "EmployeeName" varchar(200),
        "Department" varchar(300),
        "Designation" varchar(300),
        "Status" varchar(300),
        "HRME_Id" bigint
    );

    FOR rec_workdate IN
        SELECT DISTINCT CAST(a."FOMHWDD_FromDate" AS date) AS "WDate", a."HRMD_Id"
        FROM "FO"."FO_Master_HolidayWorkingDay_Dates" a
        INNER JOIN "FO"."FO_HolidayWorkingDay_Type" b ON a."FOHWDT_Id" = b."FOHWDT_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND b."FOHTWD_HolidayFlag" = 0 
            AND CAST(a."FOMHWDD_FromDate" AS date) >= p_StartDate 
            AND CAST(a."FOMHWDD_ToDate" AS date) <= p_EndDate
        ORDER BY CAST(a."FOMHWDD_FromDate" AS date)
    LOOP
        v_WDate := rec_workdate."WDate";
        v_HRMD_Id := rec_workdate."HRMD_Id";

        DROP TABLE IF EXISTS "AbsentEmpsDeptwise_Temp";
        
        v_dynamicsql := 'CREATE TEMP TABLE "AbsentEmpsDeptwise_Temp" AS 
        SELECT DISTINCT "E"."HRME_Id", "E"."HRME_EmployeeCode" AS "EmpCode",
        (COALESCE("E"."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE("E"."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE("E"."HRME_EmployeeLastName", '' '')) AS "EmployeeName",
        "F"."HRMD_DepartmentName" AS "Department", "D"."HRMDES_DesignationName" AS "Designation"
        FROM "HR_Master_Employee" "E"
        INNER JOIN "HR_Master_Designation" "D" ON "E"."HRMDES_Id" = "D"."HRMDES_Id" 
            AND "D"."MI_Id" = ' || p_MI_Id || ' AND "E"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "HR_Master_Department" "F" ON "E"."HRMD_Id" = "F"."HRMD_Id"
        WHERE "E"."MI_Id" = ' || p_MI_Id || ' 
            AND "E"."HRME_ActiveFlag" = 1 
            AND "E"."HRME_LeftFlag" = 0 
            AND "F"."HRMD_Id" = ' || v_HRMD_Id || '
            AND "E"."HRME_Id" IN (' || p_multiplehrmeid || ')';
        
        EXECUTE v_dynamicsql;

        FOR rec_emp IN
            SELECT * FROM "AbsentEmpsDeptwise_Temp"
        LOOP
            v_HRME_Id := rec_emp."HRME_Id";
            v_EmpCode := rec_emp."EmpCode";
            v_EmployeeName := rec_emp."EmployeeName";
            v_Department := rec_emp."Department";
            v_Designation := rec_emp."Designation";

            v_Rcount := 0;
            SELECT COUNT(*) INTO v_Rcount
            FROM "FO"."FO_Emp_Punch"
            WHERE CAST("FOEP_PunchDate" AS date) = v_WDate 
                AND "FOEP_HolidayPunchFlg" = 0 
                AND "HRME_Id" = v_HRME_Id;

            IF v_Rcount = 0 THEN
                
                SELECT "HRMLY_Id" INTO v_HRMLY_Id
                FROM "HR_Master_LeaveYear"
                WHERE "MI_Id" = p_MI_Id 
                    AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
                LIMIT 1;

                SELECT COUNT(*) INTO v_Rouwcount
                FROM "HR_Emp_Leave_Trans"
                WHERE "MI_Id" = p_MI_Id 
                    AND "HRMLY_Id" = v_HRMLY_Id 
                    AND "HRME_Id" = v_HRME_Id 
                    AND "HRELT_Status" = 'Approved' 
                    AND v_WDate BETWEEN CAST("HRELT_FromDate" AS date) AND CAST("HRELT_ToDate" AS date);

                IF COALESCE(v_Rouwcount, 0) > 0 THEN
                    v_status := 'On Leave';
                ELSE
                    v_status := 'Absent';
                END IF;

                INSERT INTO "EmpsAbsentDetails_Temp" 
                VALUES(v_WDate, v_EmpCode, v_EmployeeName, v_Department, v_Designation, v_status, v_HRME_Id);

            END IF;

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT * FROM "EmpsAbsentDetails_Temp"
    ORDER BY "HRME_Id", "WorkDate";

END;
$$;