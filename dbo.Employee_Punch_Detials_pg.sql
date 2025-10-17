CREATE OR REPLACE FUNCTION "Employee_Punch_Detials"(
    "MI_Id" TEXT,
    "HRME_ID" TEXT,
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10)
)
RETURNS TABLE(
    "ecode" VARCHAR,
    "hrmE_Id" BIGINT,
    "ename" VARCHAR,
    "foeP_PunchDate" TIMESTAMP,
    "foepD_PunchTime" TIME,
    "foepD_InOutFlg" VARCHAR,
    "hrmdeS_DesignationName" VARCHAR,
    "HRME_EmployeeOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT c."HRME_EmployeeCode" AS ecode,
                       c."HRME_Id" AS hrmE_Id,
                       c."HRME_EmployeeFirstName" AS ename,
                       b."FOEP_PunchDate" AS foeP_PunchDate,
                       a."FOEPD_PunchTime" AS foepD_PunchTime,
                       a."FOEPD_InOutFlg" AS foepD_InOutFlg,
                       d."HRMDES_DesignationName" AS hrmdeS_DesignationName,
                       c."HRME_EmployeeOrder"
                FROM "fo"."FO_Emp_Punch_Details" a
                INNER JOIN "fo"."FO_Emp_Punch" b ON b."FOEP_Id" = a."FOEP_Id"
                INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = b."HRME_Id"
                INNER JOIN "HR_Master_Designation" d ON d."HRMDES_Id" = c."HRMDES_Id"
                WHERE c."MI_Id" IN (' || "MI_Id" || ') 
                  AND c."HRME_Id" IN (' || "HRME_ID" || ') 
                  AND c."MI_Id" IN (' || "MI_Id" || ')
                  AND CAST(b."FOEP_PunchDate" AS DATE) >= ''' || "fromdate" || '''
                  AND CAST(b."FOEP_PunchDate" AS DATE) <= ''' || "todate" || '''
                ORDER BY c."HRME_EmployeeOrder"';
    
    RETURN QUERY EXECUTE "query";
END;
$$;