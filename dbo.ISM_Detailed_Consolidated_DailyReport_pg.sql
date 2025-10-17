CREATE OR REPLACE FUNCTION "dbo"."ISM_Detailed_Consolidated_DailyReport"(
    "StartDate" TEXT,
    "EndDate" TEXT,
    "HRME_Id" TEXT,
    "HRMDES_Id" TEXT,
    "HRMDC_ID" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "EMPLOYEENAME" TEXT,
    "EMPLOYEECODE" TEXT,
    "DEPTNAME" TEXT,
    "DESGNAME" TEXT,
    "TASKNO" TEXT,
    "TASKDES" TEXT,
    "TASKSTATUS" TEXT,
    "DR_REMARKS" TEXT,
    "DR_STATUS" TEXT,
    "DR_DATE" TEXT,
    "DR_OTHERDATE" TEXT,
    "DR_OTHERDATEREASON" TEXT,
    "TASK_START_DATE" TEXT,
    "TASK_END_DATE" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQL" TEXT;
BEGIN
    "SQL" := '
    SELECT C."HRME_Id",
    (COALESCE(C."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(C."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(C."HRME_EmployeeLastName",'''')) AS EMPLOYEENAME,
    COALESCE(C."HRME_EmployeeCode",'''') AS EMPLOYEECODE,
    D."HRMD_DepartmentName" AS DEPTNAME,
    E."HRMDES_DesignationName" AS DESGNAME,
    B."ISMTCR_TaskNo" AS TASKNO,
    B."ISMTCR_Desc" AS TASKDES,
    B."ISMTCR_Status" AS TASKSTATUS,
    A."ISMDRPT_Remarks" AS DR_REMARKS,
    A."ISMDRPT_Status" AS DR_STATUS,
    TO_CHAR(A."ISMDRPT_Date", ''DD/MM/YYYY'') AS DR_DATE,
    CASE WHEN A."ISMDRPT_OrdersDateFlg" = 1 THEN ''OTHERS DATE'' ELSE '''' END AS DR_OTHERDATE,
    CASE WHEN A."ISMDRPT_OrdersDateFlg" = 1 THEN A."ISMDRPT_OthersDateReason" ELSE '''' END AS DR_OTHERDATEREASON,
    TO_CHAR(F."ISMTCRASTO_StartDate", ''DD/MM/YYYY'') AS TASK_START_DATE,
    TO_CHAR(F."ISMTCRASTO_EndDate", ''DD/MM/YYYY'') AS TASK_END_DATE
    FROM "ISM_DailyReport" A
    INNER JOIN "ISM_TaskCreation" B ON A."ISMTCR_Id" = B."ISMTCR_Id"
    INNER JOIN "HR_Master_Employee" C ON C."HRME_Id" = A."HRME_Id"
    INNER JOIN "HR_Master_Department" D ON D."HRMD_Id" = C."HRMD_Id"
    INNER JOIN "HR_Master_Designation" E ON E."HRMDES_Id" = C."HRMDES_Id"
    INNER JOIN "ISM_TaskCreation_AssignedTo" F ON F."ISMTCR_Id" = B."ISMTCR_Id"
    WHERE A."HRME_Id" IN (' || "HRME_Id" || ')
    AND (A."ISMDRPT_Date" >= ''' || "StartDate" || ''' AND A."ISMDRPT_Date" <= ''' || "EndDate" || ''')
    ORDER BY EMPLOYEENAME, DR_DATE';

    RETURN QUERY EXECUTE "SQL";
END;
$$;