CREATE OR REPLACE FUNCTION "dbo"."FO_Emp_OT_Report" (
    "date" VARCHAR(10),
    "miid" BIGINT,
    "multiplehrmeid" VARCHAR(2000)
)
RETURNS TABLE (
    "HRME_EmployeeCode" VARCHAR,
    "HRME_EmployeeFirstName" VARCHAR,
    "HRME_EmployeeMiddleName" VARCHAR,
    "HRME_EmployeeLastName" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "MinuteDifference" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "YEARID" BIGINT;
    "dynamic" TEXT;
BEGIN
    SELECT "HRMLY_Id" INTO "YEARID" 
    FROM "HR_Master_LeaveYear" 
    WHERE "date"::DATE >= "HRMLY_FromDate"::DATE 
      AND "date"::DATE <= "HRMLY_ToDate"::DATE 
      AND "HRMLY_ActiveFlag" = 1 
      AND "MI_Id" = "miid";

    "dynamic" := 'SELECT E."HRME_EmployeeCode", E."HRME_EmployeeFirstName", E."HRME_EmployeeMiddleName", E."HRME_EmployeeLastName", F."HRMD_DepartmentName", G."HRMDES_DesignationName", EXTRACT(EPOCH FROM (D."FOEST_IIHalfLogoutTime" - B."FOEPD_PunchTime"))/60 AS MinuteDifference 
    FROM "fo"."FO_Emp_Punch" A 
    INNER JOIN "fo"."FO_Emp_Punch_Details" B ON A."FOEP_Id" = B."FOEP_Id" 
    INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" C ON A."MI_Id" = C."MI_Id" 
        AND C."FOMHWDD_FromDate"::DATE = ''' || "date" || '''::DATE 
        AND C."FOMHWD_ActiveFlg" = 1 
        AND C."HRMLY_Id" = ' || COALESCE("YEARID"::TEXT, 'NULL') || '
    INNER JOIN "fo"."FO_Emp_Shifts_Timings" D ON A."MI_Id" = D."MI_Id" 
        AND A."HRME_Id" = D."HRME_Id" 
        AND C."FOHWDT_Id" = D."FOHWDT_Id"
    INNER JOIN "HR_Master_Employee" E ON E."HRME_Id" = A."HRME_Id" 
        AND E."MI_Id" = ' || "miid"::TEXT || ' 
        AND E."HRME_ActiveFlag" = 1
    INNER JOIN "HR_Master_Department" F ON F."MI_Id" = ' || "miid"::TEXT || ' 
        AND F."HRMD_Id" = E."HRMD_Id"
    INNER JOIN "HR_Master_Designation" G ON G."MI_Id" = ' || "miid"::TEXT || ' 
        AND G."HRMDES_Id" = E."HRMDES_Id"
    WHERE A."FOEP_PunchDate"::DATE = ''' || "date" || '''::DATE 
        AND A."HRME_Id" IN (' || "multiplehrmeid" || ') 
        AND EXTRACT(EPOCH FROM (B."FOEPD_PunchTime" - D."FOEST_IIHalfLogoutTime"))/60 > 0';

    RETURN QUERY EXECUTE "dynamic";

END;
$$;