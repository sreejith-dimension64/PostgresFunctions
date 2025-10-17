CREATE OR REPLACE FUNCTION "dbo"."EmpLunchDetails"(
    p_MI_Id bigint,
    p_HRME_Id text,
    p_StartDate varchar(10),
    p_EndDate varchar(10)
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "HRME_EmployeeCode" varchar,
    "name" text,
    "HRMDES_DesignationName" varchar,
    "FOEP_PunchDate" date,
    "AFLogout" timestamp,
    "AFLogin" timestamp,
    "Diff" integer
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic text;
BEGIN
    
    v_dynamic := '
    SELECT DISTINCT "HRME_Id","HRME_EmployeeCode",CONCAT("HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName") as name,"HRMDES_DesignationName",CAST("FOEP_PunchDate" as date) as "FOEP_PunchDate","AFLogout","AFLogin",
    EXTRACT(EPOCH FROM ("AFLogin" - "AFLogout"))/60 as "Diff" from (
    SELECT DISTINCT "EMP"."HRME_Id","EMP"."HRME_EmployeeCode","EMP"."HRME_EmployeeFirstName","EMP"."HRME_EmployeeMiddleName","EMP"."HRME_EmployeeLastName","DESG"."HRMDES_DesignationName","FOEP_PunchDate",
    (SELECT "FE"."FOEPD_PunchTime" from "FO"."FO_Emp_Punch_Details" "FE" where "FE"."FOEP_Id"="EPD"."FOEP_Id" and "FOEPD_InOutFlg"=''O'' order by "FOEPD_Id" LIMIT 1) as "AFLogout",
    (SELECT "E"."FOEPD_PunchTime" from "FO"."FO_Emp_Punch_Details" "E" where "E"."FOEP_Id"="EPD"."FOEP_Id" and "FOEPD_InOutFlg"=''I'' order by "FOEPD_Id" desc LIMIT 1) as "AFLogin"
    FROM "FO"."FO_Emp_Punch" "EP"
    INNER JOIN "FO"."FO_Emp_Punch_Details" "EPD" ON "EPD"."FOEP_Id"="EP"."FOEP_Id"
    INNER JOIN "HR_Master_Employee" "EMP" ON "EMP"."HRME_Id" = "EP"."HRME_Id" AND "EMP"."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Master_Designation" "DESG" ON "EMP"."HRMDES_Id" = "DESG"."HRMDES_Id"
    where "EMP"."HRME_Id" IN  (' || p_HRME_Id || ') and CAST("FOEP_PunchDate" as Date) between ''' || p_StartDate || ''' and ''' || p_EndDate || ''' ) As "New"';

    RETURN QUERY EXECUTE v_dynamic;
    
END;
$$;