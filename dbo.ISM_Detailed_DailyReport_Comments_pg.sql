CREATE OR REPLACE FUNCTION "dbo"."ISM_Detailed_DailyReport_Comments"(
    "p_StartDate" TEXT,
    "p_EndDate" TEXT,
    "p_HRME_Id" TEXT,
    "p_HRMDES_Id" TEXT,
    "p_HRMDC_ID" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "ISMDRPTDW_OverallComments" TEXT,
    "APPROVEDEFFORTS" NUMERIC,
    "EMPLOYEENAME" TEXT,
    "EMPLOYEECODE" TEXT,
    "DEPTNAME" TEXT,
    "DESGNAME" TEXT,
    "DR_DATE" TEXT,
    "Status" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SQL" TEXT;
BEGIN
    "v_SQL" := 'SELECT "DRDW"."HRME_Id", 
                       "DRDW"."ISMDRPTDW_OverallComments", 
                       COALESCE("DRDW"."ISMDRPTDW_ApprovedEffort", 0) AS "APPROVEDEFFORTS",
                       (COALESCE("C"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("C"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("C"."HRME_EmployeeLastName", '''')) AS "EMPLOYEENAME",
                       COALESCE("C"."HRME_EmployeeCode", '''') AS "EMPLOYEECODE",
                       "D"."HRMD_DepartmentName" AS "DEPTNAME",
                       "E"."HRMDES_DesignationName" AS "DESGNAME",
                       TO_CHAR("DRDW"."ISMDRPTDW_Date", ''DD/MM/YYYY'') AS "DR_DATE",
                       CASE WHEN "DRDW"."ISMDRPTDW_ApprovedEffort" IS NULL THEN ''Pending'' ELSE ''Approved'' END AS "Status"
                FROM "dbo"."ISM_DailyReport_Daywise" "DRDW"
                INNER JOIN "dbo"."HR_Master_Employee" "C" ON "C"."HRME_Id" = "DRDW"."HRME_Id"
                INNER JOIN "dbo"."HR_Master_Department" "D" ON "D"."HRMD_Id" = "C"."HRMD_Id"
                INNER JOIN "dbo"."HR_Master_Designation" "E" ON "E"."HRMDES_Id" = "C"."HRMDES_Id"
                WHERE "DRDW"."HRME_Id" IN (' || "p_HRME_Id" || ') 
                  AND ("DRDW"."ISMDRPTDW_Date" >= ''' || "p_StartDate" || ''' AND "DRDW"."ISMDRPTDW_Date" <= ''' || "p_EndDate" || ''')
                ORDER BY "EMPLOYEENAME", "DR_DATE"';
    
    RETURN QUERY EXECUTE "v_SQL";
END;
$$;