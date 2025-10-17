CREATE OR REPLACE FUNCTION "dbo"."FO_sp_mg_paycare_latein_details_New" (p_miid bigint)
RETURNS TABLE (
    "SL NO." bigint,
    "HRME_Id" bigint,
    "EMPLOYEE NAME" varchar(500),
    "DEPARTMENT" varchar(50),
    "DESIGNATION" varchar(50),
    "GRADE" varchar(50),
    "IN TIME" varchar(9),
    "ENTRY TIME" varchar(9),
    "LATE BY" varchar(11),
    "EmailId" varchar(100),
    "MobileNo" bigint,
    "LogoutTime" varchar(20),
    "earlyby" varchar(20)
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
    v_EmailId varchar(500);
    v_MobileNo bigint;
    v_LogoutTime varchar(20);
    v_earlyby varchar(20);
    cur_record RECORD;
BEGIN
    v_emp_code1 := 0;
    v_flag := '';

    DROP TABLE IF EXISTS "MG_DB_late_in_temp_New";
    
    CREATE TEMP TABLE "MG_DB_late_in_temp_New"(
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
        "EmailId" varchar(100),
        "MobileNo" bigint,
        "LogoutTime" varchar(20),
        "earlyby" varchar(20)
    );

    IF v_flag = '' THEN
        v_flag := 'WD';
    END IF;

    RAISE NOTICE '%', v_flag;

    FOR cur_record IN
        SELECT * FROM (
            SELECT DISTINCT "f"."HRME_Id",
                (COALESCE("f"."HRME_EmployeeFirstName",'') || '' || COALESCE("f"."HRME_EmployeeMiddleName",'') || ' ' || COALESCE("f"."HRME_EmployeeLastName",'')) as "HRME_EmployeeFirstName",
                "f"."HRME_EmailId","f"."HRME_MobileNo","g"."HRMD_DepartmentName" as depname,"h"."HRMDES_DesignationName" as desgname,"i"."HRMGT_EmployeeGroupType" as gtype,
                (SELECT MIN("ed"."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" "ed" WHERE "ed"."foep_id"="b"."FOEP_Id" LIMIT 1) as "FOEPD_PunchTime",
                "c"."FOEST_IHalfLoginTime" as "LoginTime","dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"("c"."FOEST_IHalfLoginTime"))),"j"."FOEPD_PunchTime") as "LATE BY",'00:00' as earlyby,"FOEST_IIHalfLogoutTime" AS "LogoutTime"
            FROM "fo"."FO_Emp_Punch_Details" "a" 
            INNER JOIN "fo"."FO_Emp_Punch" "b" ON "a"."FOEP_Id"="b"."FOEP_Id"
            INNER JOIN "fo"."FO_Emp_Punch_Details" "j" ON "a"."FOEP_Id"="j"."FOEP_Id"
            INNER JOIN "fo"."FO_Emp_Shifts_Timings" "c" ON "c"."HRME_Id"="b"."HRME_Id" 
            INNER JOIN "dbo"."HR_Master_Employee" "f" ON "f"."HRME_Id"="c"."HRME_Id"
            INNER JOIN "dbo"."HR_Master_Department" "g" ON "g"."HRMD_Id"="f"."HRMD_Id"
            INNER JOIN "dbo"."HR_Master_Designation" "h" ON "h"."HRMDES_Id"="f"."HRMDES_Id"
            INNER JOIN "dbo"."HR_Master_GroupType" "i" ON "i"."HRMGT_Id"="f"."HRMGT_Id"
            INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" "d" ON CAST("b"."FOEP_PunchDate" AS date)=CAST("d"."FOMHWDD_FromDate" AS date)
            WHERE (SELECT "dbo"."getonlymin"("ed"."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" "ed" WHERE "ed"."foep_id"="b"."FOEP_Id" LIMIT 1) > "dbo"."getonlymin"("FOEST_IHalfLoginTime")+"dbo"."getonlymin"("FOEST_DelayPerShiftHrMin")
            AND "j"."FOEPD_InOutFlg"='I' AND "j"."FOEPD_Flag"=1 AND "c"."FOHWDT_Id"="d"."FOHWDT_Id" 
            AND "f"."MI_Id"=p_miid AND (TO_CHAR("FOEP_PunchDate",'DD/MM/YYYY') = TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY'))
            GROUP BY "FOEP_PunchDate","c"."FOHWDT_Id","f"."HRME_Id","HRMD_DepartmentName","HRMDES_DesignationName","HRMGT_EmployeeGroupType","FOEP_PunchDate","c"."FOEST_IHalfLoginTime","j"."FOEPD_PunchTime","f"."MI_Id","j"."FOEPD_InOutFlg",
            "b"."FOEP_Id","FOEST_IHalfLoginTime","j"."FOEPD_PunchTime","HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName","HRME_EmailId","HRME_MobileNo","FOEST_IIHalfLogoutTime"
            
            UNION
            
            SELECT DISTINCT "HRME_Id",ename AS "HRME_EmployeeFirstName","HRME_EmailId","HRME_MobileNo",depname,desgname,gtype,outtime as "FOEPD_PunchTime",'' AS "LoginTime",
            '00:00' as lateby,(CASE WHEN EXTRACT(EPOCH FROM (actualtime - outtime))/60 > CAST(RIGHT(relaxtime,2) AS int) THEN earlyby ELSE '' END) as earlyby,actualtime AS "LogoutTime"
            FROM (
                SELECT DISTINCT "Oa".*,TO_CHAR("ob".punchdate,'YYYY-MM-DD') as "FOEP_PunchDate","ob".outtime,"ob".actualtime,"ob".relaxtime,"ob".earlyby 
                FROM (
                    SELECT "a"."HRME_Id","a"."HRME_EmployeeCode" as ecode,(COALESCE("a"."HRME_EmployeeFirstName",'') || '' || COALESCE("a"."HRME_EmployeeMiddleName",'') ||
                    '' || COALESCE("a"."HRME_EmployeeLastName",'')) as ename,"HRME_EmailId","HRME_MobileNo","b"."HRMD_DepartmentName" as depname,"c"."HRMDES_DesignationName" as desgname,"d"."HRMGT_EmployeeGroupType" as gtype 
                    FROM "HR_Master_Employee" "a","HR_Master_Department" "b","HR_Master_Designation" "c","HR_Master_GroupType" "d" 
                    WHERE "a"."HRMD_Id"="b"."HRMD_Id" AND "a"."HRMGT_Id"="d"."HRMGT_Id" AND "a"."HRMDES_Id"="c"."HRMDES_Id"
                ) "Oa", 
                (
                    SELECT "b"."HRME_Id","b"."FOEP_PunchDate" as punchdate,"a".outtime,"c"."FOEST_IIHalfLogoutTime" as actualtime, 
                    "c"."FOEST_EarlyPerShiftHrMin" as relaxtime,"dbo"."getdatediff"("a".outtime,"c"."FOEST_IIHalfLogoutTime") AS earlyby,"FOEPD_InOutFlg" 
                    FROM (
                        SELECT MAX("FOEPD_PunchTime") as outtime,"FOEP_Id","FOEPD_InOutFlg" 
                        FROM "fo"."FO_Emp_Punch_Details" 
                        WHERE "FOEPD_InOutFlg"='O' AND "FOEPD_Flag"=1 
                        GROUP BY "FOEP_Id","FOEPD_InOutFlg"
                    ) "a","fo"."FO_Emp_Punch" "b","fo"."FO_Emp_Shifts_Timings" "c" 
                    WHERE "a"."FOEP_Id"="b"."FOEP_Id" AND "b"."HRME_Id"="c"."HRME_Id" AND "b"."FOEP_Flag"=1 AND "b"."MI_Id"=p_miid 
                    AND "dbo"."getonlymin"("a".outtime) < "dbo"."getonlymin"("c"."FOEST_IIHalfLogoutTime")- "dbo"."getonlymin"("c"."FOEST_EarlyPerShiftHrMin")
                ) "Ob" 
                WHERE "Oa"."HRME_Id"="Ob"."HRME_Id"
            ) "a" 
            WHERE (TO_CHAR("FOEP_PunchDate",'DD/MM/YYYY') = TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY')) 
            ORDER BY "HRME_Id"
        ) AS "New"
    LOOP
        v_emp_code := cur_record."HRME_Id";
        v_name := cur_record."HRME_EmployeeFirstName";
        v_EmailId := cur_record."HRME_EmailId";
        v_MobileNo := cur_record."HRME_MobileNo";
        v_Department := cur_record.depname;
        v_Designation := cur_record.desgname;
        v_grade := cur_record.gtype;
        v_time := cur_record."FOEPD_PunchTime";
        v_st_time := cur_record."LoginTime";
        v_lateby := cur_record."LATE BY";
        v_earlyby := cur_record.earlyby;
        v_LogoutTime := cur_record."LogoutTime";

        IF v_emp_code1 <> v_emp_code THEN
            INSERT INTO "MG_DB_late_in_temp_New"("EMP_CODE","EMP_NAME","EMP_DEPARTMENT","EMP_DESIGNATION","EMP_GRADE","punchtime","shifttime","LATE_BY","REMARKS",
            "EmailId","MobileNo","LogoutTime") 
            VALUES(v_emp_code,v_name,v_Department,v_Designation,v_grade,v_time,v_st_time,v_lateby,'',v_EmailId,v_MobileNo,v_LogoutTime);
            
            v_emp_code1 := v_emp_code;
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT 
        "SL_NO",
        "EMP_CODE",
        "EMP_NAME",
        "EMP_DEPARTMENT",
        "EMP_DESIGNATION",
        "EMP_GRADE",
        SUBSTRING(CAST("punchtime" as varchar),13,9),
        SUBSTRING(CAST("shifttime" as varchar),13,9),
        TO_CHAR("LATE_BY",'HH24:MI:SS'),
        "EmailId",
        "MobileNo",
        "LogoutTime",
        "earlyby"
    FROM "MG_DB_late_in_temp_New";

    RETURN;
END;
$$;