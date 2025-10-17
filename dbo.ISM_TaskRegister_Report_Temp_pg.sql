CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskRegister_Report_Temp" (
    p_TypeFlg VARCHAR(100),
    p_SelectionFlag VARCHAR(100),
    p_startDate TIMESTAMP,
    p_endDate TIMESTAMP,
    p_status TEXT,
    p_MI_Id VARCHAR(100),
    p_HRMD_Id VARCHAR(100),
    p_HRME_Id VARCHAR(100),
    p_userid VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "assginedDate" VARCHAR,
    "CompletedDate" VARCHAR,
    "HRME_Id" INTEGER,
    "employeename" VARCHAR,
    "createdby" VARCHAR,
    "AssignedBy" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_Slqdymaic2 TEXT;
    v_betweendates TEXT;
    v_betweendates1 TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_StartDate TIMESTAMP;
    v_EndDate TIMESTAMP;
BEGIN
    v_StartDate := p_startDate;
    v_EndDate := p_endDate;

    DROP TABLE IF EXISTS "StaffAdmin_Temp01";
    DROP TABLE IF EXISTS "StaffAdmin_Temp02";
    DROP TABLE IF EXISTS "StaffAdmin_Temp001";
    DROP TABLE IF EXISTS "StaffAdmin_Temp002";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";
    DROP TABLE IF EXISTS "StaffAdmin_Temp5";
    DROP TABLE IF EXISTS "StaffAdmin_Temp6";

    v_StartDate_N := TO_CHAR(v_StartDate, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(v_EndDate, 'YYYY-MM-DD');

    IF v_StartDate_N != '' AND v_EndDate_N != '' THEN
        v_betweendates := '((CAST("TCAT"."ISMTCRASTO_StartDate" AS DATE) BETWEEN ''' || v_StartDate_N || ''' and ''' || v_EndDate_N || ''') OR (CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE)) between ''' || v_StartDate_N || ''' and ''' || v_EndDate_N || ''')';
        v_betweendates1 := '((CAST("TCAT"."ISMTCRTRTO_StartDate" AS DATE) BETWEEN ''' || v_StartDate_N || ''' and ''' || v_EndDate_N || ''') OR (CAST("TCAT"."ISMTCRTRTO_EndDate" AS DATE)) between ''' || v_StartDate_N || ''' and ''' || v_EndDate_N || ''')';
    ELSE
        v_betweendates := '';
    END IF;

    IF p_TypeFlg = 'Consolidated' THEN
        IF p_SelectionFlag = '1' THEN
            v_Slqdymaic := '
            CREATE TEMP TABLE "StaffAdmin_Temp01" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND ' || v_betweendates || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo")
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)';

            v_Slqdymaic2 := '
            CREATE TEMP TABLE "StaffAdmin_Temp02" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND ' || v_betweendates1 || '
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)';

            EXECUTE v_Slqdymaic;
            EXECUTE v_Slqdymaic2;

            RETURN QUERY
            SELECT "HRME_Id", "ISMTCR_Status", SUM("totalCount")::INTEGER AS "totalCount", "employeename"
            FROM (
                SELECT * FROM "StaffAdmin_Temp01"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp02"
            ) AS "New"
            GROUP BY "HRME_Id", "ISMTCR_Status", "employeename";

        ELSIF p_SelectionFlag = '2' THEN
            v_Slqdymaic := '
            CREATE TEMP TABLE "StaffAdmin_Temp5" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND "TCAT"."HRME_Id" IN (' || p_HRME_Id || ') AND "TCAT"."ISMTCRASTO_AssignedBy" NOT IN (' || p_HRME_Id || ') AND ' || v_betweendates || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN(' || p_HRME_Id || '))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)';

            v_Slqdymaic2 := '
            CREATE TEMP TABLE "StaffAdmin_Temp6" AS
            SELECT DISTINCT "TCAT"."HRME_Id", "TC"."ISMTCR_Status", COUNT("TC"."ISMTCR_Id") AS "totalCount",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND "TCAT"."HRME_Id" IN (' || p_HRME_Id || ') AND "TCAT"."ISMTCRTRTO_TransferredBy" NOT IN (' || p_HRME_Id || ') AND ' || v_betweendates1 || '
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_AssignedBy" IN (' || p_HRME_Id || '))
            GROUP BY "TCAT"."HRME_Id", "TC"."ISMTCR_Status",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)';

            EXECUTE v_Slqdymaic;
            EXECUTE v_Slqdymaic2;

            RETURN QUERY
            SELECT "HRME_Id", "ISMTCR_Status", SUM("totalCount")::INTEGER AS "totalCount", "employeename"
            FROM (
                SELECT * FROM "StaffAdmin_Temp5"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp6"
            ) AS "New"
            GROUP BY "HRME_Id", "ISMTCR_Status", "employeename";

        END IF;

    ELSIF p_TypeFlg = 'Detailed' THEN
        IF p_SelectionFlag = '1' THEN
            v_Slqdymaic := '
            CREATE TEMP TABLE "StaffAdmin_Temp001" AS
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                 WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                 ELSE ''Others'' END AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
            CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'')
                 ELSE ''NA'' END AS "CompletedDate",
            "TCAT"."HRME_Id",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename",
            (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                     CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                     CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
            (SELECT DISTINCT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND ' || v_betweendates || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo")
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0';

            v_Slqdymaic2 := '
            CREATE TEMP TABLE "StaffAdmin_Temp002" AS
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                 WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                 ELSE ''Others'' END AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRTRTO_TransferredDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
            CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'')
                 ELSE ''NA'' END AS "CompletedDate",
            "TCAT"."HRME_Id",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename",
            (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                     CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                     CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
            (SELECT DISTINCT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."HRME_Id") AS "AssignedBy"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND ' || v_betweendates1 || '
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "HRME_Id" IN(' || p_HRME_Id || '))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || p_status || ''' || '','') > 0';

            EXECUTE v_Slqdymaic;
            EXECUTE v_Slqdymaic2;

            RETURN QUERY
            SELECT * FROM "StaffAdmin_Temp001"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp002";

        ELSIF p_SelectionFlag = '2' THEN
            v_Slqdymaic := '
            CREATE TEMP TABLE "StaffAdmin_Temp3" AS
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                 WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                 ELSE ''Others'' END AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", ''DD/MM/YYYY HH24:MI'') AS "assginedDate",
            CASE WHEN "TC"."ISMTCR_Status" = ''Completed'' THEN TO_CHAR("TC"."UpdatedDate", ''DD/MM/YYYY HH24:MI'')
                 ELSE ''NA'' END AS "CompletedDate",
            "TCAT"."HRME_Id",
            (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END) as "employeename",
            (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                     CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                     CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
            (SELECT DISTINCT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                             CASE WHEN COALESCE("HME"."HRME_EmployeeMiddleName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
                             CASE WHEN COALESCE("HME"."HRME_EmployeeLastName", '''') IN ('''', ''0'') THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."