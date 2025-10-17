CREATE OR REPLACE FUNCTION "dbo"."ISM_FEEDBACK_DR_REPORT"(
    "@START_DATE" TEXT,
    "@END_DATE" TEXT,
    "@HRME_Id" TEXT,
    "@HRMDES_Id" TEXT,
    "@HRMDC_Id" TEXT,
    "@FLAG" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "EMPLOYEENAME" TEXT,
    "EMPLOYEECODE" TEXT,
    "DEPTNAME" TEXT,
    "DESGNAME" TEXT,
    "TASKNO" TEXT,
    "TASKDES" TEXT,
    "DR_DATE" TEXT,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Id" INTEGER,
    "COMMENTSBY" TEXT,
    "DEPT_HEAD" TEXT,
    "DEPT_HEAD_Id" INTEGER,
    "COMMENTS" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@SQL" TEXT;
BEGIN
    IF "@FLAG" = 'CONSOLIDATE' THEN
        "@SQL" := '
        SELECT DISTINCT "C"."HRME_Id",
        (COALESCE("C"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("C"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("C"."HRME_EmployeeLastName",'''')) AS "EMPLOYEENAME",
        COALESCE("C"."HRME_EmployeeCode",'''') AS "EMPLOYEECODE",
        "D"."HRMD_DepartmentName" AS "DEPTNAME",
        "E"."HRMDES_DesignationName" AS "DESGNAME",
        "B"."ISMTCR_TaskNo" AS "TASKNO",
        "B"."ISMTCR_Desc" AS "TASKDES",
        TO_CHAR("ISMDRPT_Date", ''DD/MM/YYYY'') AS "DR_DATE",
        "B"."ISMTCR_Title",
        "B"."ISMTCR_Id",
        
        (SELECT DISTINCT (COALESCE("EM"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("EM"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("EM"."HRME_EmployeeLastName",''''))
         FROM "HR_Master_Employee" "EM"
         INNER JOIN "ISM_DailyReport_FeedBack" "DF" ON "EM"."HRME_Id" = "DF"."ISMDRF_Send_HRME_Id"
         AND "A"."ISMTCR_Id" = "DF"."ISMTCR_Id"
         AND "DF"."ISMDRF_RCV_HRME_Id" IN (' || "@HRME_Id" || ')
         AND ("ISMDRF_Feedback_DR_Date" >= ''' || "@START_DATE" || ''' AND "ISMDRF_Feedback_DR_Date" <= ''' || "@END_DATE" || ''')
         LIMIT 1) AS "COMMENTSBY",
        
        (SELECT (COALESCE("C1"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("C1"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("C1"."HRME_EmployeeLastName",''''))
         FROM "HR_Master_DepartmentCode" "A1"
         INNER JOIN "HR_Master_DepartmentCode_Head" "B1" ON "A1"."HRMDC_ID" = "B1"."HRMDC_ID"
         INNER JOIN "HR_Master_Employee" "C1" ON "C1"."HRME_Id" = "B1"."HRME_ID"
         INNER JOIN "HR_Master_Department" "D1" ON "D1"."HRMDC_ID" = "A1"."HRMDC_ID" AND "D1"."HRMD_Id" = "C1"."HRMD_Id"
         WHERE "A1"."HRMDC_ID" IN (' || "@HRMDC_Id" || ') AND "C1"."HRMDES_Id" IN (' || "@HRMDES_Id" || ')) AS "DEPT_HEAD",
        
        (SELECT "C2"."HRME_Id"
         FROM "HR_Master_DepartmentCode" "A2"
         INNER JOIN "HR_Master_DepartmentCode_Head" "B2" ON "A2"."HRMDC_ID" = "B2"."HRMDC_ID"
         INNER JOIN "HR_Master_Employee" "C2" ON "C2"."HRME_Id" = "B2"."HRME_ID"
         INNER JOIN "HR_Master_Department" "D2" ON "D2"."HRMDC_ID" = "A2"."HRMDC_ID" AND "D2"."HRMD_Id" = "C2"."HRMD_Id"
         WHERE "A2"."HRMDC_ID" IN (' || "@HRMDC_Id" || ') AND "C2"."HRMDES_Id" IN (' || "@HRMDES_Id" || ')) AS "DEPT_HEAD_Id",
        
        (SELECT DISTINCT "ISMDRF_FeedBack"
         FROM "ISM_DailyReport_FeedBack" "F"
         INNER JOIN "ISM_TaskCreation" "FT" ON "F"."ISMDRF_RCV_HRME_Id" = "C"."HRME_Id"
         AND "FT"."ISMTCR_Id" = "F"."ISMTCR_Id"
         AND "F"."ISMTCR_Id" = "A"."ISMTCR_Id"
         AND ("ISMDRF_Feedback_DR_Date" >= ''' || "@START_DATE" || ''' AND "ISMDRF_Feedback_DR_Date" <= ''' || "@END_DATE" || ''')
         LIMIT 1) AS "COMMENTS"
        
        FROM "ISM_DailyReport" "A"
        INNER JOIN "ISM_TaskCreation" "B" ON "A"."ISMTCR_Id" = "B"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "C" ON "C"."HRME_Id" = "A"."HRME_Id"
        INNER JOIN "HR_Master_Department" "D" ON "D"."HRMD_Id" = "C"."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "E" ON "E"."HRMDES_Id" = "C"."HRMDES_Id"
        
        WHERE "A"."HRME_Id" IN (' || "@HRME_Id" || ')
        AND ("ISMDRPT_Date" >= ''' || "@START_DATE" || ''' AND "ISMDRPT_Date" <= ''' || "@END_DATE" || ''')
        ORDER BY "EMPLOYEENAME", "DR_DATE"';
        
        RETURN QUERY EXECUTE "@SQL";
    END IF;
    
    RETURN;
END;
$$;