CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskRegister_Report" (
    "TypeFlg" VARCHAR(100), 
    "SelectionFlag" VARCHAR(100), 
    "startDate" TIMESTAMP, 
    "endDate" TIMESTAMP,
    "status" TEXT,
    "MI_Id" VARCHAR(100),
    "HRMD_Id" VARCHAR(100), 
    "HRME_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "ISMTCR_Status" TEXT,
    "totalCount" BIGINT,
    "employeename" TEXT,
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "assginedDate" TEXT,
    "CompletedDate" TEXT,
    "deviationdays" TEXT,
    "createdby" TEXT,
    "AssignedBy" TEXT,
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP,
    "EffortInHrs" NUMERIC,
    "IssueDesc" TEXT
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

    DROP TABLE IF EXISTS "StaffAdmin_Temp01";
    DROP TABLE IF EXISTS "StaffAdmin_Temp02";
    DROP TABLE IF EXISTS "StaffAdmin_Temp001";
    DROP TABLE IF EXISTS "StaffAdmin_Temp002";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";
    DROP TABLE IF EXISTS "StaffAdmin_Temp5";
    DROP TABLE IF EXISTS "StaffAdmin_Temp6";

    "StartDate_N" := TO_CHAR("startDate"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("endDate"::DATE, 'YYYY-MM-DD');

    IF "StartDate_N" != '' AND "EndDate_N" != '' THEN 
        "betweendates" := '(("TCAT"."ISMTCRASTO_StartDate"::DATE BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''') OR ("TCAT"."ISMTCRASTO_EndDate"::DATE) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''')';
        "betweendates1" := '(("TCAT"."ISMTCRTRTO_StartDate"::DATE BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''') OR ("TCAT"."ISMTCRTRTO_EndDate"::DATE) BETWEEN ''' || "StartDate_N" || ''' AND ''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
    END IF;

    IF "TypeFlg" = 'Consolidated' THEN
        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp01" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = true AND "HME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND ' || "betweendates" || ' AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo") 
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status", 
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp02" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = true AND "HME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND ' || "betweendates1" || ' 
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status", 
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)';

            EXECUTE "Slqdymaic";
            EXECUTE "Slqdymaic2";

            RETURN QUERY 
            SELECT "HRME_Id", "ISMTCR_Status", SUM("totalCount")::BIGINT AS "totalCount", "employeename",
                   NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, 
                   NULL::TEXT, NULL::TEXT, NULL::BOOLEAN, NULL::TIMESTAMP, NULL::TEXT, NULL::BIGINT, 
                   NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, 
                   NULL::TIMESTAMP, NULL::NUMERIC, NULL::TEXT
            FROM (
                SELECT * FROM "StaffAdmin_Temp01"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp02"
            ) AS "New" 
            GROUP BY "HRME_Id", "ISMTCR_Status", "employeename";

        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp5" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = true AND "HME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCAT"."HRME_Id" IN (' || "HRME_Id" || ') 
            AND ' || "betweendates" || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN(' || "HRME_Id" || '))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp6" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = true AND "HME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCAT"."HRME_Id" IN (' || "HRME_Id" || ') 
            AND "TCAT"."ISMTCRTRTO_TransferredBy" NOT IN (' || "HRME_Id" || ') 
            AND ' || "betweendates1" || '
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || '))
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)';

            EXECUTE "Slqdymaic";
            EXECUTE "Slqdymaic2";

            RETURN QUERY 
            SELECT "HRME_Id", "ISMTCR_Status", SUM("totalCount")::BIGINT AS "totalCount", "employeename",
                   NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, 
                   NULL::TEXT, NULL::TEXT, NULL::BOOLEAN, NULL::TIMESTAMP, NULL::TEXT, NULL::BIGINT, 
                   NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, 
                   NULL::TIMESTAMP, NULL::NUMERIC, NULL::TEXT
            FROM (
                SELECT * FROM "StaffAdmin_Temp5"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp6"
            ) AS "New" 
            GROUP BY "HRME_Id", "ISMTCR_Status", "employeename";
        END IF;

    ELSIF "TypeFlg" = 'Detailed' THEN
        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp001" AS
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' 
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' 
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "ISMTCR_Status", "ISMTCR_ReOpenFlg", 
            "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
            (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'') ELSE ''NA'' END) AS "CompletedDate",
            (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN ("TC"."UpdatedDate"::DATE - "ITP"."ISMTPLTA_EndDate"::DATE)::TEXT ELSE ''NA'' END) AS "deviationdays",
            "TCAT"."HRME_Id",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename",
            (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
             FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby",
            (SELECT DISTINCT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                              CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                              CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
             FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy",
            "TCAT"."ISMTCRASTO_StartDate" AS "StartDate", "TCAT"."ISMTCRASTO_EndDate" AS "EndDate", 
            "TCAT"."ISMTCRASTO_EffortInHrs" AS "EffortInHrs", "TC"."ISMTCR_Desc" AS "IssueDesc"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = true AND "HME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND ' || "betweendates" || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo")
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp002" AS
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' 
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' 
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "ISMTCR_Status", "ISMTCR_ReOpenFlg", 
            "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRTRTO_TransferredDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
            (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'') ELSE ''NA'' END) AS "CompletedDate",
            (CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN ("TC"."UpdatedDate"::DATE - "ITP"."ISMTPLTA_EndDate"::DATE)::TEXT ELSE ''NA'' END) AS "deviationdays",
            "TCAT"."HRME_Id",
            (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "employeename",
            (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
             FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby",
            (SELECT DISTINCT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || 
                              CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                              CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
             FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."HRME_Id") AS "AssignedBy",
            "TCAT"."ISMTCRTRTO_StartDate" AS "StartDate", "TCAT"."ISMTCRTRTO_EndDate" AS "EndDate", 
            "TCAT"."ISMTCRTRTO_EffortInHrs" AS "EffortInHrs", "TC"."ISMTCR_Desc" AS "IssueDesc"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."