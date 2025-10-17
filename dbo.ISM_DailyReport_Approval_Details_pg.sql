CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_Approval_Details"(
    "departments" TEXT,
    "designation" TEXT,
    "emplist" TEXT,
    "FromDate" TEXT,
    "ToDate" TEXT
)
RETURNS TABLE(
    "ISMDRPT_Id" INTEGER,
    "ISMTCR_Id" INTEGER,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMDRPT_Status" VARCHAR,
    "ISMDRPT_TimeTakenInHrs" NUMERIC,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMDRPT_Date" VARCHAR,
    "COUNTCHECKLIST" BIGINT,
    "EMPLOYEENAME" TEXT,
    "EMPLOYEECODE" VARCHAR,
    "DEPTNAME" VARCHAR,
    "DESGNAME" VARCHAR,
    "HRME_Id" INTEGER,
    "ISMDRPT_Remarks" TEXT,
    "ISMTPLTA_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQLQUERY" TEXT;
BEGIN

    "SQLQUERY" := 'SELECT DISTINCT A."ISMDRPT_Id" , A."ISMTCR_Id", B."ISMTCR_TaskNo", B."ISMTCR_Title" , A."ISMDRPT_Status", A."ISMDRPT_TimeTakenInHrs" , D."ISMTPLTA_EffortInHrs" ,   
    TO_CHAR(A."ISMDRPT_Date",''DD/MM/YYYY'') "ISMDRPT_Date" ,  (SELECT COUNT(*) FROM "ISM_DailyReport_Files" DF WHERE DF."ISMDRPT_Id"=A."ISMDRPT_Id" ) "COUNTCHECKLIST",  
    (CASE WHEN E."HRME_EmployeeFirstName" IS NULL THEN ''''  ELSE E."HRME_EmployeeFirstName" END ||  
    CASE WHEN E."HRME_EmployeeMiddleName" IS NULL OR E."HRME_EmployeeMiddleName"='''' THEN '''' ELSE '' ''|| E."HRME_EmployeeMiddleName" END ||  
    CASE WHEN E."HRME_EmployeeLastName" IS NULL OR E."HRME_EmployeeLastName"='''' THEN '''' ELSE '' ''|| E."HRME_EmployeeLastName" END ) AS  "EMPLOYEENAME",   
    E."HRME_EmployeeCode" "EMPLOYEECODE",F."HRMD_DepartmentName" "DEPTNAME" , G."HRMDES_DesignationName" "DESGNAME",A."HRME_Id" , A."ISMDRPT_Remarks" , D."ISMTPLTA_Id"
      
    FROM "ISM_DailyReport" A INNER JOIN "ISM_TaskCreation" B ON A."ISMTCR_Id"=B."ISMTCR_Id"  
    INNER JOIN "ISM_Task_Planner" C ON C."ISMTPL_Id"=A."ISMTPL_Id"  
    INNER JOIN "ISM_Task_Planner_Tasks" D ON D."ISMTPL_Id"=C."ISMTPL_Id" AND D."ISMTCR_Id"=A."ISMTCR_Id" AND D."ISMTCR_Id"=B."ISMTCR_Id" AND D."ISMTPLTA_ApprovalFlg"=1  
    INNER JOIN "HR_Master_Employee" E ON E."HRME_Id"=A."HRME_Id" AND E."HRME_Id"=C."HRME_Id"  
    INNER JOIN "HR_Master_Department" F ON F."HRMD_Id"=E."HRMD_Id"  
    INNER JOIN "HR_Master_Designation" G ON G."HRMDES_Id"=E."HRMDES_Id"  
      
    WHERE A."HRME_Id" IN (' || "emplist" || ') AND A."ISMDRPT_Id" NOT IN (SELECT "ISMDRPT_Id" FROM "ISM_DailyReport_Approval")  
    AND CAST(A."ISMDRPT_Date" AS DATE) >=''' || "FromDate" || ''' AND CAST(A."ISMDRPT_Date" AS DATE)<=''' || "ToDate" || '''';

    RETURN QUERY EXECUTE "SQLQUERY";

END;
$$;