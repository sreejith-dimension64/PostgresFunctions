CREATE OR REPLACE FUNCTION "dbo"."FO_SingleLog" (
    "@MI_Id" bigint, 
    "@Multihrme_Id" TEXT, 
    "@Fromdate" varchar(10), 
    "@Todate" varchar(10)
)
RETURNS TABLE (
    "hrme_id" bigint,
    "HRME_EmployeeCode" varchar,
    "HRME_EmployeeFirstName" varchar,
    "HRME_EmployeeMiddleName" varchar,
    "HRME_EmployeeLastName" varchar,
    "PunchDate" date,
    "count" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@dynamic" TEXT;
BEGIN

    "@dynamic" := '
    SELECT a."hrme_id", c."HRME_EmployeeCode", c."HRME_EmployeeFirstName", c."HRME_EmployeeMiddleName", c."HRME_EmployeeLastName", 
    CAST(a."FOEP_PunchDate" AS date) AS PunchDate,
    COUNT(b."FOEPD_Id") AS count 
    FROM "fo"."FO_Emp_Punch" a
    INNER JOIN "fo"."FO_Emp_Punch_Details" b ON a."FOEP_Id" = b."FOEP_Id"
    INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id" AND c."HRME_ActiveFlag" = true
    WHERE a."MI_Id" = ' || "@MI_Id"::varchar || ' AND a."HRME_Id" IN (' || "@Multihrme_Id" || ') 
    AND CAST(a."FOEP_PunchDate" AS date) BETWEEN ''' || "@Fromdate" || ''' AND ''' || "@Todate" || '''
    GROUP BY a."hrme_id", c."HRME_EmployeeCode", c."HRME_EmployeeFirstName", c."HRME_EmployeeMiddleName", c."HRME_EmployeeLastName", CAST(a."FOEP_PunchDate" AS date) 
    HAVING COUNT(b."FOEPD_Id") = 1
    ORDER BY a."hrme_id"';

    RETURN QUERY EXECUTE "@dynamic";

END;
$$;