CREATE OR REPLACE FUNCTION "dbo"."Emp_DailyReport_Details_Modify"(
    "@MI_Id" bigint,
    "@HRME_Id" TEXT,
    "@Fromdate" TEXT,
    "@Todate" TEXT,
    "@UserId" bigint
)
RETURNS TABLE(
    "Employee_name" TEXT,
    "HRME_Id" bigint,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Id" bigint,
    "ISMDRPT_Status" VARCHAR,
    "ISMDRPT_Remarks" TEXT,
    "ISMTPL_Id" bigint,
    "MI_Id" bigint,
    "ISMDRPT_Id" bigint,
    "ISMDRPT_Date" TIMESTAMP,
    "ISMDRPT_TimeTakenInHrs" NUMERIC,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "feedbact" TEXT,
    "FLAG" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    "@Slqdymaic" := 'SELECT DISTINCT 
        ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '''' THEN '''' ELSE b."HRME_EmployeeFirstName" END ||
        CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '''' OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || 
        CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '''' OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END )) as "Employee_name", 
        
        a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", 
        a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date", a."ISMDRPT_TimeTakenInHrs", d."ISMTCRASTO_EffortInHrs",
        E."ISMDRF_FeedBack" AS feedbact, CASE WHEN E."ISMDRF_FeedBack" IS NULL THEN 0 ELSE 1 END AS FLAG
        
        FROM
        
        "ISM_DailyReport" a INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "ISM_TaskCreation" c ON a."ISMTCR_Id" = c."ISMTCR_Id"
        INNER JOIN "ISM_TaskCreation_AssignedTo" d ON d."ISMTCR_Id" = c."ISMTCR_Id" AND d."HRME_Id" = b."HRME_Id"
        LEFT JOIN "ISM_DailyReport_FeedBack" E ON E."ISMTCR_Id" = a."ISMTCR_Id" AND E."ISMDRF_Send_HRME_Id" = ' || "@UserId" || ' AND (CAST(E."ISMDRF_Feedback_DR_Date" AS DATE) >= ''' || "@Fromdate" || '''
        AND CAST(E."ISMDRF_Feedback_DR_Date" AS DATE) <= ''' || "@Todate" || ''')
        
        WHERE b."HRME_Id" IN (' || "@HRME_Id" || ') AND (CAST(a."ISMDRPT_Date" AS DATE) >= ''' || "@Fromdate" || ''' AND CAST(a."ISMDRPT_Date" AS DATE) <= ''' || "@Todate" || ''') ORDER BY a."ISMDRPT_Date"';
    
    RETURN QUERY EXECUTE "@Slqdymaic";
    
    RETURN;
END;
$$;