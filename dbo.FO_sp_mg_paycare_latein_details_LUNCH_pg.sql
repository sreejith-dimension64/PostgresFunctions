CREATE OR REPLACE FUNCTION "dbo"."FO_sp_mg_paycare_latein_details_LUNCH" (p_miid bigint)
RETURNS TABLE (
    "SL NO." bigint,
    "EMPLOYEE NAME" varchar(500),
    "DEPARTMENT" varchar(50),
    "DESIGNATION" varchar(50),
    "GRADE" varchar(50),
    "IN TIME" varchar(9),
    "ENTRY TIME" varchar(9),
    "LATE BY" varchar(11),
    "HRMEM_EmailId" varchar(100),
    "HRMEMNO_MobileNo" bigint
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
    v_REEM_T varchar(500);
    v_HRMEM_EmailId varchar(100);
    v_HRMEMNO_MobileNo bigint;
    cur_rec RECORD;
BEGIN
    v_emp_code1 := 0;
    v_flag := '';
    
    DROP TABLE IF EXISTS "MG_DB_lunch_in_temp";
    
    CREATE TEMP TABLE "MG_DB_lunch_in_temp"(
        "SL_NO" bigserial NOT NULL,
        "EMP_CODE" bigint,
        "EMP_NAME" varchar(500),
        "EMP_DEPARTMENT" varchar(50),
        "EMP_DESIGNATION" varchar(50),
        "EMP_GRADE" varchar(50),
        "punchtime" timestamp,
        "shifttime" timestamp,
        "LATE_BY" timestamp,
        "REMARKS" varchar(500),
        "HRMEM_EmailId" varchar(100),
        "HRMEMNO_MobileNo" bigint
    );
    
    IF v_flag = '' THEN
        v_flag := 'WD';
    END IF;
    
    RAISE NOTICE '%', v_flag;
    
    FOR cur_rec IN
        SELECT DISTINCT "HR_Master_Employee"."HRME_Id",
            (COALESCE("HRME_EmployeeFirstName",'') || ' ' || COALESCE("HRME_EmployeeMiddleName",'') || ' ' || COALESCE("HRME_EmployeeLastName",'')) AS "HRME_EmployeeFirstName",
            "HR_Master_Department"."HRMD_DepartmentName",
            "HR_Master_Designation"."HRMDES_DesignationName",
            "HR_Master_EmployeeType"."HRMET_EmployeeType",
            (SELECT MAX("FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_Details" "EP" WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" AND "FOEPD_InOutFlg" = 'I') AS "FOEPD_PunchTime",
            "FO_Emp_Shifts_Timings"."FOEST_IIHalfLoginTime",
            TO_CHAR((SELECT MAX("FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_Details" "EP" WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" AND "FOEPD_InOutFlg" = 'I')::timestamp - "FO_Emp_Shifts_Timings"."FOEST_IIHalfLoginTime"::timestamp, 'HH24:MI:SS') AS "LATE BY",
            "HRE"."HRMEM_EmailId",
            "HRM"."HRMEMNO_MobileNo"
        FROM "fo"."FO_Emp_Punch"
        INNER JOIN "fo"."FO_Emp_Punch_Details" ON "FO_Emp_Punch"."FOEP_Id" = "FO_Emp_Punch_Details"."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" ON "FO_Emp_Punch"."HRME_Id" = "FO_Emp_Shifts_Timings"."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" ON "FO_Emp_Punch"."HRME_Id" = "HR_Master_Employee"."HRME_Id"
        INNER JOIN "dbo"."HR_Master_EmployeeType" ON "HR_Master_Employee"."HRMET_Id" = "HR_Master_EmployeeType"."HRMET_Id"
        INNER JOIN "dbo"."HR_Master_Designation" ON "HR_Master_Employee"."HRMDES_Id" = "HR_Master_Designation"."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_Department" ON "HR_Master_Employee"."HRMD_Id" = "HR_Master_Department"."HRMD_Id"
        INNER JOIN "fo"."FO_Master_Shifts" ON "FO_Master_Shifts"."FOMS_Id" = "FO_Emp_Shifts_Timings"."FOMS_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" "d" ON "d"."FOHWDT_Id" = "FO_Emp_Shifts_Timings"."FOHWDT_Id" 
            AND "FO_Emp_Punch"."FOEP_PunchDate"::date BETWEEN "d"."FOMHWDD_FromDate"::date AND "d"."FOMHWDD_ToDate"::date
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay" "E" ON "E"."FOHWDT_Id" = "FO_Emp_Shifts_Timings"."FOHWDT_Id"
        INNER JOIN "dbo"."HR_Master_Employee_EmailId" "HRE" ON "HRE"."HRME_Id" = "HR_Master_Employee"."HRME_Id" AND "HRMEM_DeFaultFlag" = 'default'
        INNER JOIN "dbo"."HR_Master_Employee_MobileNo" "HRM" ON "HRM"."HRME_Id" = "HR_Master_Employee"."HRME_Id" AND "HRMEMNO_DeFaultFlag" = 'default'
        WHERE TO_CHAR("FO_Emp_Punch"."FOEP_PunchDate", 'DD/MM/YYYY') = TO_CHAR(CURRENT_DATE, 'DD/MM/YYYY')
        AND ("FO_Emp_Punch_Details"."FOEPD_InOutFlg" = 'I')
        AND (SELECT MAX("FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_Details" "EP" WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" AND "FOEPD_InOutFlg" = 'I') > "FO_Emp_Shifts_Timings"."FOEST_IIHalfLoginTime"::timestamp
        AND "HR_Master_Employee"."MI_Id" = p_miid
    LOOP
        v_emp_code := cur_rec."HRME_Id";
        v_name := cur_rec."HRME_EmployeeFirstName";
        v_Department := cur_rec."HRMD_DepartmentName";
        v_Designation := cur_rec."HRMDES_DesignationName";
        v_grade := cur_rec."HRMET_EmployeeType";
        v_time := cur_rec."FOEPD_PunchTime";
        v_st_time := cur_rec."FOEST_IIHalfLoginTime";
        v_lateby := cur_rec."LATE BY"::timestamp;
        v_HRMEM_EmailId := cur_rec."HRMEM_EmailId";
        v_HRMEMNO_MobileNo := cur_rec."HRMEMNO_MobileNo";
        
        IF v_emp_code1 <> v_emp_code THEN
            INSERT INTO "MG_DB_lunch_in_temp"("EMP_CODE", "EMP_NAME", "EMP_DEPARTMENT", "EMP_DESIGNATION", "EMP_GRADE", "punchtime", "shifttime", "LATE_BY", "REMARKS", "HRMEM_EmailId", "HRMEMNO_MobileNo")
            VALUES(v_emp_code, v_name, v_Department, v_Designation, v_grade, v_time, v_st_time, v_lateby, '', v_HRMEM_EmailId, v_HRMEMNO_MobileNo);
            
            v_emp_code1 := v_emp_code;
        END IF;
    END LOOP;
    
    RETURN QUERY
    SELECT 
        "SL_NO",
        "EMP_NAME",
        "EMP_DEPARTMENT",
        "EMP_DESIGNATION",
        "EMP_GRADE",
        SUBSTRING(CAST("punchtime" AS varchar), 13, 9),
        SUBSTRING(CAST("shifttime" AS varchar), 13, 9),
        TO_CHAR("LATE_BY", 'HH24:MI:SS'),
        "HRMEM_EmailId",
        "HRMEMNO_MobileNo"
    FROM "MG_DB_lunch_in_temp";
    
    RETURN;
END;
$$;