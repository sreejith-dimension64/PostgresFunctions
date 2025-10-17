CREATE OR REPLACE FUNCTION "dbo"."FO_SP_MG_PAYCARE_EARLY_OUT_DETAILS_LUNCH"(p_miid bigint)
RETURNS TABLE(
    "EMPLOYEE NAME" varchar(200),
    "DEPARTMENT" varchar(50),
    "DESIGNATION" varchar(50),
    "GRADE" varchar(50),
    "OUT TIME" varchar(9),
    "EXIT TIME" varchar(9),
    "EARLY BY" varchar(11)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_emp_code1 bigint;
    v_name varchar(500);
    v_emp_code bigint;
    v_Department varchar(50);
    v_Designation varchar(50);
    v_grade varchar(50);
    v_time timestamp;
    v_st_time timestamp;
    v_lateby timestamp;
    v_flag varchar(20);
    v_REEM_E_T varchar(500);
    v_FOEP_PunchDate date;
    rec RECORD;
BEGIN
    v_emp_code1 := 0;
    v_flag := '';
    
    -- Drop temp table if exists
    DROP TABLE IF EXISTS "MG_DB_LEARLY_OUT_TEMP";
    
    -- Create temp table
    CREATE TEMP TABLE "MG_DB_LEARLY_OUT_TEMP"(
        "SL_NO" bigserial NOT NULL,
        "EMP_CODE" bigint,
        "EMP_NAME" varchar(200),
        "EMP_DEPARTMENT" varchar(50),
        "EMP_DESIGNATION" varchar(50),
        "EMP_GRADE" varchar(50),
        "punchtime" timestamp,
        "shifttime" timestamp,
        "EARLY_BY" timestamp
    );

    IF v_flag = '' THEN
        v_flag := 'WD';
    END IF;

    RAISE NOTICE '%', v_flag;

    -- Cursor loop converted to FOR loop
    FOR rec IN
        SELECT DISTINCT "dbo"."HR_Master_Employee"."HRME_Id", 
            (COALESCE("HRME_EmployeeFirstName",'')||' '||COALESCE("HRME_EmployeeMiddleName",'')||' '||COALESCE("HRME_EmployeeLastName",'')) AS "HRME_EmployeeFirstName", 
            "dbo"."HR_Master_Department"."HRMD_DepartmentName",
            "dbo"."HR_Master_Designation"."HRMDES_DesignationName", 
            "dbo"."HR_Master_EmployeeType"."HRMET_EmployeeType", 
            "fo"."FO_Emp_Punch_Details"."FOEPD_PunchTime",
            "fo"."FO_Emp_Shifts_Timings"."FOEST_IHalfLogoutTime",
            TO_CHAR((CAST("fo"."FO_Emp_Shifts_Timings"."FOEST_IHalfLogoutTime" AS timestamp) - CAST("fo"."FO_Emp_Punch_Details"."FOEPD_PunchTime" AS timestamp)), 'HH24:MI:SS') AS "EARLY BY",
            "Fo"."FO_Emp_Punch"."FOEP_PunchDate"
        FROM "FO"."FO_Emp_Punch" 
        INNER JOIN "fo"."FO_Emp_Punch_Details" ON "FO"."FO_Emp_Punch"."FOEP_Id" = "fo"."FO_Emp_Punch_Details"."FOEP_Id" 
        INNER JOIN "FO"."FO_Emp_Shifts_Timings" ON "FO"."FO_Emp_Punch"."HRME_Id" = "FO"."FO_Emp_Shifts_Timings"."HRME_Id" 
        INNER JOIN "dbo"."HR_Master_Employee" ON "Fo"."FO_Emp_Punch"."HRME_Id" = "dbo"."HR_Master_Employee"."HRME_Id" 
        INNER JOIN "dbo"."HR_Master_EmployeeType" ON "dbo"."HR_Master_Employee"."HRMET_Id" = "dbo"."HR_Master_EmployeeType"."HRMET_Id" 
        INNER JOIN "dbo"."HR_Master_Designation" ON "dbo"."HR_Master_Employee"."HRMDES_Id" = "dbo"."HR_Master_Designation"."HRMDES_Id" 
        INNER JOIN "dbo"."HR_Master_Department" ON "dbo"."HR_Master_Employee"."HRMD_Id" = "dbo"."HR_Master_Department"."HRMD_Id" 
        INNER JOIN "fo"."FO_Master_Shifts" ON "fo"."FO_Master_Shifts"."FOMS_Id" = "FO"."FO_Emp_Shifts_Timings"."FOMS_Id" 
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" ON "fo"."FO_Master_HolidayWorkingDay_Dates"."FOHWDT_Id" = "FO"."FO_Emp_Shifts_Timings"."FOHWDT_Id" 
        WHERE TO_CHAR("Fo"."FO_Emp_Punch"."FOEP_PunchDate", 'DD/MM/YYYY') = TO_CHAR(CURRENT_DATE, 'DD/MM/YYYY') 
        AND TO_CHAR("fo"."FO_Master_HolidayWorkingDay_Dates"."FOMHWDD_FromDate", 'DD/MM/YYYY') = TO_CHAR("Fo"."FO_Emp_Punch"."FOEP_PunchDate", 'DD/MM/YYYY')
        AND ("FO"."FO_Emp_Punch_Details"."FOEPD_InOutFlg" = 'O')  
        AND "FO"."FO_Emp_Punch_Details"."FOEPD_PunchTime" < (CAST("fo"."FO_Emp_Shifts_Timings"."FOEST_IHalfLogoutTime" AS timestamp) - "fo"."FO_Emp_Shifts_Timings"."FOEST_EarlyPerShiftHrMin")
        AND "dbo"."HR_Master_Employee"."MI_Id" = p_miid
    LOOP
        v_emp_code := rec."HRME_Id";
        v_name := rec."HRME_EmployeeFirstName";
        v_Department := rec."HRMD_DepartmentName";
        v_Designation := rec."HRMDES_DesignationName";
        v_grade := rec."HRMET_EmployeeType";
        v_time := rec."FOEPD_PunchTime";
        v_st_time := rec."FOEST_IHalfLogoutTime";
        v_lateby := rec."EARLY BY"::timestamp;
        v_FOEP_PunchDate := rec."FOEP_PunchDate";
        
        IF v_emp_code1 <> v_emp_code THEN
            INSERT INTO "MG_DB_LEARLY_OUT_TEMP" 
            VALUES(DEFAULT, v_emp_code, v_name, v_Department, v_Designation, v_grade, v_time, v_st_time, v_lateby);
            v_emp_code1 := v_emp_code;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT 
        "EMP_NAME" AS "EMPLOYEE NAME",
        "EMP_DEPARTMENT" AS "DEPARTMENT",
        "EMP_DESIGNATION" AS "DESIGNATION",
        "EMP_GRADE" AS "GRADE",
        SUBSTRING(CAST("punchtime" AS varchar) FROM 13 FOR 9) AS "OUT TIME",
        SUBSTRING(CAST("shifttime" AS varchar) FROM 13 FOR 9) AS "EXIT TIME",
        TO_CHAR("EARLY_BY", 'HH24:MI:SS') AS "EARLY BY"
    FROM "MG_DB_LEARLY_OUT_TEMP";

END;
$$;