CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_NotSent_Remarks_Details"(
    "DEPARTMENTS_Ids" TEXT, 
    "DESGINATION_Ids" TEXT, 
    "HRME_Id" TEXT, 
    "FROMDATE" VARCHAR(10), 
    "TODATE" VARCHAR(10)
)
RETURNS TABLE(
    "EMPLOYEENAME" TEXT,
    "EMPLOYEECODE" TEXT,
    "HRME_Id" INTEGER,
    "DRNotSentDate" VARCHAR(10),
    "ISMDRNSDR_RemarksDate" VARCHAR(10),
    "ISMDRNSDR_Remarks" TEXT,
    "CreatedDate" TIMESTAMP,
    "DESGNAME" TEXT,
    "DEPTNAME" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQLQUERY" TEXT;
BEGIN

    "SQLQUERY" := '
    SELECT  (COALESCE(B."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(B."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(B."HRME_EmployeeLastName",'''')) AS "EMPLOYEENAME",
    COALESCE(B."HRME_EmployeeCode",'''') AS "EMPLOYEECODE", A."HRME_Id", TO_CHAR(A."ISMDRNSDR_DRNotSentDate", ''DD/MM/YYYY'') AS "DRNotSentDate",
    TO_CHAR(A."ISMDRNSDR_RemarksDate", ''DD/MM/YYYY'') AS "ISMDRNSDR_RemarksDate", A."ISMDRNSDR_Remarks", A."CreatedDate", D."HRMDES_DesignationName" AS "DESGNAME", C."HRMD_DepartmentName" AS "DEPTNAME"
    
    FROM "ISM_DailyReportNotSent_DateWiseRemarks" A 
    INNER JOIN "HR_MASTER_EMPLOYEE" B ON A."HRME_ID" = B."HRME_ID"
    INNER JOIN "HR_MASTER_DEPARTMENT" C ON C."HRMD_Id" = B."HRMD_Id"
    INNER JOIN "HR_MASTER_DESIGNATION" D ON D."HRMDES_Id" = B."HRMDES_Id"
    
    WHERE A."HRME_Id" IN (' || "HRME_Id" || ') AND (A."ISMDRNSDR_RemarksDate" >= ''' || "FROMDATE" || ''' AND A."ISMDRNSDR_RemarksDate" <= ''' || "TODATE" || ''')  
    ORDER BY "EMPLOYEENAME", "CreatedDate"';

    RETURN QUERY EXECUTE "SQLQUERY";

END;
$$;