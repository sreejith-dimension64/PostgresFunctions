CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskRegister_Report_Department" (
    "startDate" TIMESTAMP,
    "endDate" TIMESTAMP,
    "status" TEXT,
    "HRME_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "HRMP_Name" VARCHAR,
    "AssignedBy" TEXT,
    "StartDate" VARCHAR,
    "EndDate" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Slqdymaic2" TEXT;
    "betweendates" TEXT;
    "betweendates1" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
BEGIN
    "startDate" := "startDate";
    "endDate" := "endDate";

    DROP TABLE IF EXISTS "StaffAdmin_Temp_Dept";
    DROP TABLE IF EXISTS "StaffAdmin_Temp_Dept_Emp";

    "StartDate_N" := TO_CHAR("startDate"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("endDate"::DATE, 'YYYY-MM-DD');

    IF "StartDate_N" != '' AND "EndDate_N" != '' THEN
        "betweendates" := '((CAST("TCAT"."ISMTCRASTO_StartDate" AS DATE) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''') OR (CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE)) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''')';
        "betweendates1" := '((CAST("TCAT"."ISMTCRTRTO_StartDate" AS DATE) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''') OR (CAST("TCAT"."ISMTCRTRTO_EndDate" AS DATE)) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
    END IF;

    "Slqdymaic" := '
        CREATE TEMP TABLE "StaffAdmin_Temp_Dept" AS
        SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
        TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
        (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'') ELSE ''NA'' END) AS "CompletedDate",
        "TCAT"."HRME_Id",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
          CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
          CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "employeename",
        (SELECT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                  CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                  CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
         FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                           CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                           CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
         FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy",
        "TCAT"."ISMTCRASTO_StartDate" AS "StartDate", "TCAT"."ISMTCRASTO_EndDate" AS "EndDate", "TCAT"."ISMTCRASTO_EffortInHrs" AS "EffortInHrs", "TC"."ISMTCR_Desc" AS "IssueDesc"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
        LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
        LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
        WHERE "TC"."ISMTCR_ActiveFlg" = 1 
        AND "TCAT"."HRME_Id"::VARCHAR IN (' || "HRME_Id" || ')
        AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy"::VARCHAR IN (' || "HRME_Id" || '))
        AND ' || "betweendates" || ' 
        AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0';

    "Slqdymaic2" := '
        CREATE TEMP TABLE "StaffAdmin_Temp_Dept_Emp" AS
        SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
        TO_CHAR("TCAT"."ISMTCRTRTO_TransferredDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
        (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'') ELSE ''NA'' END) AS "CompletedDate",
        "TCAT"."HRME_Id",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
          CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
          CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "employeename",
        (SELECT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                  CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                  CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
         FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                           CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                           CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
         FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRTRTO_TransferredBy") AS "AssignedBy",
        "TCAT"."ISMTCRTRTO_StartDate" AS "StartDate", "TCAT"."ISMTCRTRTO_EndDate" AS "EndDate", "TCAT"."ISMTCRTRTO_EffortInHrs" AS "EffortInHrs", "TC"."ISMTCR_Desc" AS "IssueDesc"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
        LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
        LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
        WHERE "TC"."ISMTCR_ActiveFlg" = 1 
        AND "TCAT"."HRME_Id"::VARCHAR IN (' || "HRME_Id" || ')
        AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_AssignedBy"::VARCHAR IN (' || "HRME_Id" || '))
        AND ' || "betweendates1" || ' 
        AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0';

    EXECUTE "Slqdymaic";
    EXECUTE "Slqdymaic2";

    RETURN QUERY
    SELECT 
        "ISMTCR_TaskNo"::VARCHAR,
        "ISMTCR_Title"::VARCHAR,
        "ISMTCR_BugOREnhancementFlg"::VARCHAR,
        "HRMP_Name"::VARCHAR,
        "AssignedBy"::TEXT,
        TO_CHAR("StartDate"::DATE, 'DD/MM/YYYY') AS "StartDate",
        TO_CHAR("EndDate"::DATE, 'DD/MM/YYYY') AS "EndDate"
    FROM "StaffAdmin_Temp_Dept";

    DROP TABLE IF EXISTS "StaffAdmin_Temp_Dept";
    DROP TABLE IF EXISTS "StaffAdmin_Temp_Dept_Emp";

END;
$$;