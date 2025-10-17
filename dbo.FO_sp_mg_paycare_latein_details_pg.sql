CREATE OR REPLACE FUNCTION "dbo"."FO_sp_mg_paycare_latein_details" (
    "@miid" bigint
)
RETURNS TABLE (
    "SL NO." bigint,
    "EMPLOYEE NAME" varchar(500),
    "DEPARTMENT" varchar(50),
    "DESIGNATION" varchar(50),
    "GRADE" varchar(50),
    "IN TIME" varchar(9),
    "ENTRY TIME" varchar(9),
    "LATE BY" varchar(11)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@emp_code1" bigint;
    "@name" varchar(500);
    "@emp_code" bigint;
    "@Department" varchar(50);
    "@Designation" varchar(50);
    "@grade" varchar(50);
    "@time" timestamp;
    "@st_time" timestamp;
    "@lateby" timestamp;
    "@flag" varchar(20);
    "@REEM_T" varchar(500);
    cur_rec RECORD;
BEGIN
    "@emp_code1" := 0;
    "@flag" := '';
    
    DROP TABLE IF EXISTS "MG_DB_late_in_temp";
    
    CREATE TEMP TABLE "MG_DB_late_in_temp"(
        "SL_NO" bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
        "EMP_CODE" bigint,
        "EMP_NAME" varchar(500),
        "EMP_DEPARTMENT" varchar(50),
        "EMP_DESIGNATION" varchar(50),
        "EMP_GRADE" varchar(50),
        "punchtime" timestamp,
        "shifttime" timestamp,
        "LATE_BY" timestamp,
        "REMARKS" varchar(500)
    );
    
    IF "@flag" = '' THEN
        "@flag" := 'WD';
    END IF;
    
    RAISE NOTICE '%', "@flag";
    
    FOR cur_rec IN
        SELECT DISTINCT 
            "HR_Master_Employee"."HRME_Id",
            (COALESCE("HRME_EmployeeFirstName",'') || ' ' || COALESCE("HRME_EmployeeMiddleName",'') || ' ' || COALESCE("HRME_EmployeeLastName",'')) AS "HRME_EmployeeFirstName",
            "HR_Master_Department"."HRMD_DepartmentName",
            "HR_Master_Designation"."HRMDES_DesignationName",
            "HR_Master_EmployeeType"."HRMET_EmployeeType",
            (SELECT "FOEPD_PunchTime" 
             FROM "fo"."FO_Emp_Punch_Details" "EP" 
             WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" 
             LIMIT 1) AS "FOEPD_PunchTime",
            "FO_Emp_Shifts_Timings"."FOEST_IHalfLoginTime",
            TO_CHAR(
                CAST((SELECT "FOEPD_PunchTime" 
                      FROM "fo"."FO_Emp_Punch_Details" "EP" 
                      WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" 
                      LIMIT 1) AS timestamp) - 
                CAST("FO_Emp_Shifts_Timings"."FOEST_IHalfLoginTime" AS timestamp),
                'HH24:MI:SS'
            )::timestamp AS "LATE BY"
        FROM "fo"."FO_Emp_Punch"
        INNER JOIN "fo"."FO_Emp_Punch_Details" ON "FO_Emp_Punch"."FOEP_Id" = "FO_Emp_Punch_Details"."FOEP_Id"
        INNER JOIN "fo"."FO_Emp_Shifts_Timings" ON "FO_Emp_Punch"."HRME_Id" = "FO_Emp_Shifts_Timings"."HRME_Id"
        INNER JOIN "dbo"."HR_Master_Employee" ON "FO_Emp_Punch"."HRME_Id" = "HR_Master_Employee"."HRME_Id"
        INNER JOIN "dbo"."HR_Master_EmployeeType" ON "HR_Master_Employee"."HRMET_Id" = "HR_Master_EmployeeType"."HRMET_Id"
        INNER JOIN "dbo"."HR_Master_Designation" ON "HR_Master_Employee"."HRMDES_Id" = "HR_Master_Designation"."HRMDES_Id"
        INNER JOIN "dbo"."HR_Master_Department" ON "HR_Master_Employee"."HRMD_Id" = "HR_Master_Department"."HRMD_Id"
        INNER JOIN "fo"."FO_Master_Shifts" ON "FO_Master_Shifts"."FOMS_Id" = "FO_Emp_Shifts_Timings"."FOMS_Id"
        INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" "d" ON "d"."FOHWDT_Id" = "FO_Emp_Shifts_Timings"."FOHWDT_Id"
            AND CAST("FO_Emp_Punch"."FOEP_PunchDate" AS date) = CAST("d"."FOMHWDD_FromDate" AS date)
        WHERE TO_CHAR("FO_Emp_Punch"."FOEP_PunchDate", 'DD/MM/YYYY') = TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY')
        AND "FO_Emp_Punch_Details"."FOEPD_InOutFlg" = 'I'
        AND (SELECT "FOEPD_PunchTime" 
             FROM "fo"."FO_Emp_Punch_Details" "EP" 
             WHERE "EP"."FOEP_Id" = "FO_Emp_Punch"."FOEP_Id" 
             LIMIT 1) > 
            CAST("FO_Emp_Shifts_Timings"."FOEST_IHalfLoginTime" AS timestamp) + 
            "FO_Emp_Shifts_Timings"."FOEST_DelayPerShiftHrMin"
        AND "HR_Master_Employee"."MI_Id" = "@miid"
    LOOP
        "@emp_code" := cur_rec."HRME_Id";
        "@name" := cur_rec."HRME_EmployeeFirstName";
        "@Department" := cur_rec."HRMD_DepartmentName";
        "@Designation" := cur_rec."HRMDES_DesignationName";
        "@grade" := cur_rec."HRMET_EmployeeType";
        "@time" := cur_rec."FOEPD_PunchTime";
        "@st_time" := cur_rec."FOEST_IHalfLoginTime";
        "@lateby" := cur_rec."LATE BY";
        
        IF "@emp_code1" <> "@emp_code" THEN
            INSERT INTO "MG_DB_late_in_temp" 
                ("EMP_CODE", "EMP_NAME", "EMP_DEPARTMENT", "EMP_DESIGNATION", "EMP_GRADE", 
                 "punchtime", "shifttime", "LATE_BY", "REMARKS")
            VALUES 
                ("@emp_code", "@name", "@Department", "@Designation", "@grade", 
                 "@time", "@st_time", "@lateby", '');
            "@emp_code1" := "@emp_code";
        END IF;
    END LOOP;
    
    RETURN QUERY
    SELECT 
        "SL_NO" AS "SL NO.",
        "EMP_NAME" AS "EMPLOYEE NAME",
        "EMP_DEPARTMENT" AS "DEPARTMENT",
        "EMP_DESIGNATION" AS "DESIGNATION",
        "EMP_GRADE" AS "GRADE",
        SUBSTRING(CAST("punchtime" AS varchar), 13, 9) AS "IN TIME",
        SUBSTRING(CAST("shifttime" AS varchar), 13, 9) AS "ENTRY TIME",
        TO_CHAR("LATE_BY", 'HH24:MI:SS') AS "LATE BY"
    FROM "MG_DB_late_in_temp";
    
    DROP TABLE IF EXISTS "MG_DB_late_in_temp";
    
END;
$$;