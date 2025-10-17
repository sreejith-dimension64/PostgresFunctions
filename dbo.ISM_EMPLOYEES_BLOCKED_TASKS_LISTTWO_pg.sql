CREATE OR REPLACE FUNCTION "dbo"."ISM_EMPLOYEES_BLOCKED_TASKS_LISTTWO"(
    "p_type" BIGINT,
    "p_department" TEXT,
    "p_HRME_Id" TEXT,
    "p_startdate" VARCHAR(10),
    "p_enddate" VARCHAR(10)
)
RETURNS TABLE (
    "HRME_ID" BIGINT,
    "Employeename" TEXT,
    "EmpCode" TEXT,
    "TaskNo" TEXT,
    "TaskTitle" TEXT,
    "Description" TEXT,
    "CreationDate" TEXT,
    "BlockedDate" TEXT,
    "UnBlockDate" TEXT,
    "Status" TEXT,
    "Createdby" TEXT,
    "ClientName" TEXT,
    "StartDate" TEXT,
    "EndDate" TEXT,
    "Assignedby" TEXT,
    "Reason" TEXT,
    "UpdatedDate" TEXT,
    "Memo" TEXT,
    "Notice" TEXT,
    "Task_Deviation_Days" INTEGER,
    "Task_Blocked_Days" INTEGER,
    "ISMMTCAT_TaskCategoryName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_Slqdymaic1" TEXT;
    "v_dates" TEXT;
BEGIN

    DROP TABLE IF EXISTS "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp1";
    DROP TABLE IF EXISTS "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp2";

    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := ' "ISMBE_BlockDate"::date BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := ' 1=1 ';
    END IF;

    IF "p_type" = 0 THEN
        "v_Slqdymaic" := '
        CREATE TEMP TABLE "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp1" AS
        SELECT DISTINCT "HR"."HRME_ID",
        (CASE WHEN "HR"."HRME_EmployeeFirstName" IS NULL OR "HR"."HRME_EmployeeFirstName"='''' THEN '''' ELSE "HR"."HRME_EmployeeFirstName" END ||
        CASE WHEN "HR"."HRME_EmployeeMiddleName" IS NULL OR "HR"."HRME_EmployeeMiddleName" = '''' OR "HR"."HRME_EmployeeMiddleName" =''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeMiddleName" END ||
        CASE WHEN "HR"."HRME_EmployeeLastName" IS NULL OR "HR"."HRME_EmployeeLastName" = '''' OR "HR"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeLastName" END) AS "Employeename",
        "HR"."HRME_EmployeeCode" AS "EmpCode",
        "ISMTCR_TaskNo" AS "TaskNo",
        "ISMTCR_Title" AS "TaskTitle",
        "ISMTCR_Desc" AS "Description",
        TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS "CreationDate",
        TO_CHAR("ISMBE_BlockDate", ''DD/MM/YYYY'') AS "BlockedDate",
        TO_CHAR("ISEBE_UnblockDate", ''DD/MM/YYYY'') AS "UnBlockDate",
        "TR"."ISMTCR_Status" AS "Status",
        COALESCE((SELECT (CASE WHEN "HRCR"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HRCR" WHERE "HRCR"."HRME_Id"="TR"."HRME_Id" LIMIT 1),
        (SELECT "UserName" FROM "ApplicationUser" "AU" WHERE "AU"."id"="TR"."ISMTCR_CreatedBy" LIMIT 1)) AS "Createdby",
        (CASE WHEN ("ISMMCLT_ClientName"='''' OR "ISMMCLT_ClientName" IS NULL) THEN ''NA'' ELSE "ISMMCLT_ClientName" END) AS "ClientName",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", ''DD/MM/YYYY'') AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", ''DD/MM/YYYY'') AS "EndDate",
        (SELECT (CASE WHEN "HMEP"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") AS "Assignedby",
        "BL"."ISMBE_Reason" AS "Reason",
        TO_CHAR("TR"."UpdatedDate", ''DD/MM/YYYY'') AS "UpdatedDate",
        '''' AS "Memo",
        '''' AS "Notice",
        ("ISEBE_UnblockDate"::date - "ISMTCRASTO_EndDate"::date) AS "Task_Deviation_Days",
        NULL::INTEGER AS "Task_Blocked_Days",
        NULL::TEXT AS "ISMMTCAT_TaskCategoryName"
        FROM "HR_Master_Employee" "HR"
        INNER JOIN "ISM_Block_Employee" "BL" ON "HR"."HRME_Id"="BL"."HRME_Id"
        INNER JOIN "ISM_Block_Employee_Priority" "PR" ON "PR"."ISMBE_Id"="BL"."ISMBE_Id"
        INNER JOIN "ISM_TaskCreation" "TR" ON "TR"."ISMTCR_Id"="PR"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "TR"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=1
        LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TR"."ISMTCR_Id"
        WHERE ' || "v_dates" || ' AND "BL"."HRME_Id" IN (SELECT "b"."HRME_Id" FROM "HR_Master_Department" "a"
        INNER JOIN "HR_Master_Employee" "b" ON "b"."HRMD_Id"="a"."HRMD_Id"
        WHERE "HRMDC_ID" IN(' || "p_department" || ') AND "b"."HRME_ActiveFlag"=1 AND "b"."HRME_LeftFlag"=0)
        ORDER BY "HR"."HRME_EmployeeCode", "ISMBE_BlockDate"';

        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp2" AS
        SELECT DISTINCT "HR"."HRME_ID",
        (CASE WHEN "HR"."HRME_EmployeeFirstName" IS NULL OR "HR"."HRME_EmployeeFirstName"='''' THEN '''' ELSE "HR"."HRME_EmployeeFirstName" END ||
        CASE WHEN "HR"."HRME_EmployeeMiddleName" IS NULL OR "HR"."HRME_EmployeeMiddleName" = '''' OR "HR"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeMiddleName" END ||
        CASE WHEN "HR"."HRME_EmployeeLastName" IS NULL OR "HR"."HRME_EmployeeLastName" = '''' OR "HR"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeLastName" END) AS "Employeename",
        "HR"."HRME_EmployeeCode" AS "EmpCode",
        "ISMTCR_TaskNo" AS "TaskNo",
        "ISMTCR_Title" AS "TaskTitle",
        "ISMTCR_Desc" AS "Description",
        TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS "CreationDate",
        TO_CHAR("ISMBE_BlockDate", ''DD/MM/YYYY'') AS "BlockedDate",
        TO_CHAR("ISEBE_UnblockDate", ''DD/MM/YYYY'') AS "UnBlockDate",
        "TR"."ISMTCR_Status" AS "Status",
        COALESCE((SELECT (CASE WHEN "HRCR"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HRCR" WHERE "HRCR"."HRME_Id"="TR"."HRME_Id" LIMIT 1),
        (SELECT "UserName" FROM "ApplicationUser" "AU" WHERE "AU"."id"="TR"."ISMTCR_CreatedBy" LIMIT 1)) AS "Createdby",
        (CASE WHEN ("ISMMCLT_ClientName"='''' OR "ISMMCLT_ClientName" IS NULL) THEN ''NA'' ELSE "ISMMCLT_ClientName" END) AS "ClientName",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", ''DD/MM/YYYY'') AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", ''DD/MM/YYYY'') AS "EndDate",
        (SELECT (CASE WHEN "HMEP"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") AS "Assignedby",
        "BL"."ISMBE_Reason" AS "Reason",
        TO_CHAR("TR"."UpdatedDate", ''DD/MM/YYYY'') AS "UpdatedDate",
        (SELECT STRING_AGG("TMM"."ISMEMN_No", '','') FROM "ISM_EMPLOYEE_MEMO_NOTICE" "TMM"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "TMMT" ON "TMMT"."ISMEMN_ID"="TMM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "TPL" ON "TPL"."ISMTPLTA_Id"="TMMT"."ISMTPLTA_Id"
        INNER JOIN "ISM_TaskCreation" "TTR" ON "TTR"."ISMTCR_Id"="TPL"."ISMTCR_Id"
        WHERE "TPL"."ISMTCR_Id"="PL"."ISMTCR_Id" AND "ISMEMN_Type"=''Memo'') AS "Memo",
        (SELECT STRING_AGG("TMM"."ISMEMN_No", '','') FROM "ISM_Block_Employee" "BL2"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE" "TMM" ON "TMM"."ISMEMN_ID"="BL2"."ISMEMN_ID"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "TMMT" ON "TMMT"."ISMEMN_ID"="TMM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "TPL" ON "TPL"."ISMTPLTA_Id"="TMMT"."ISMTPLTA_Id"
        INNER JOIN "ISM_TaskCreation" "TTR" ON "TTR"."ISMTCR_Id"="TPL"."ISMTCR_Id"
        WHERE "TPL"."ISMTCR_Id"="PL"."ISMTCR_Id") AS "Notice",
        ("ISEBE_UnblockDate"::date - "ISMTCRASTO_EndDate"::date) AS "Task_Deviation_Days",
        NULL::INTEGER AS "Task_Blocked_Days",
        NULL::TEXT AS "ISMMTCAT_TaskCategoryName"
        FROM "HR_Master_Employee" "HR"
        INNER JOIN "ISM_Block_Employee" "BL" ON "HR"."HRME_Id"="BL"."HRME_Id"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE" "MM" ON "MM"."ISMEMN_ID"="BL"."ISMEMN_ID"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "MMT" ON "MMT"."ISMEMN_ID"="MM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "PL" ON "PL"."ISMTPLTA_Id"="MMT"."ISMTPLTA_Id"
        INNER JOIN "ISM_TaskCreation" "TR" ON "TR"."ISMTCR_Id"="PL"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "TR"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=1
        LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TR"."ISMTCR_Id"
        WHERE ' || "v_dates" || ' AND "BL"."HRME_Id" IN (SELECT "b"."HRME_Id" FROM "HR_Master_Department" "a"
        INNER JOIN "HR_Master_Employee" "b" ON "b"."HRMD_Id"="a"."HRMD_Id"
        WHERE "HRMDC_ID" IN(' || "p_department" || ') AND "b"."HRME_ActiveFlag"=1 AND "b"."HRME_LeftFlag"=0)
        ORDER BY "HR"."HRME_EmployeeCode", "ISMBE_BlockDate"';

    ELSIF "p_type" = 1 THEN
        "v_Slqdymaic" := '
        CREATE TEMP TABLE "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp1" AS
        SELECT DISTINCT "HR"."HRME_ID",
        (CASE WHEN "HR"."HRME_EmployeeFirstName" IS NULL OR "HR"."HRME_EmployeeFirstName"='''' THEN '''' ELSE "HR"."HRME_EmployeeFirstName" END ||
        CASE WHEN "HR"."HRME_EmployeeMiddleName" IS NULL OR "HR"."HRME_EmployeeMiddleName" = '''' OR "HR"."HRME_EmployeeMiddleName" =''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeMiddleName" END ||
        CASE WHEN "HR"."HRME_EmployeeLastName" IS NULL OR "HR"."HRME_EmployeeLastName" = '''' OR "HR"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeLastName" END) AS "Employeename",
        "HR"."HRME_EmployeeCode" AS "EmpCode",
        "ISMTCR_TaskNo" AS "TaskNo",
        "ISMTCR_Title" AS "TaskTitle",
        "ISMTCR_Desc" AS "Description",
        TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS "CreationDate",
        TO_CHAR("ISMBE_BlockDate", ''DD/MM/YYYY'') AS "BlockedDate",
        TO_CHAR("ISEBE_UnblockDate", ''DD/MM/YYYY'') AS "UnBlockDate",
        "TR"."ISMTCR_Status" AS "Status",
        COALESCE((SELECT (CASE WHEN "HRCR"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HRCR" WHERE "HRCR"."HRME_Id"="TR"."HRME_Id" LIMIT 1),
        (SELECT "UserName" FROM "ApplicationUser" "AU" WHERE "AU"."id"="TR"."ISMTCR_CreatedBy" LIMIT 1)) AS "Createdby",
        (CASE WHEN ("ISMMCLT_ClientName"='''' OR "ISMMCLT_ClientName" IS NULL) THEN ''NA'' ELSE "ISMMCLT_ClientName" END) AS "ClientName",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", ''DD/MM/YYYY'') AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", ''DD/MM/YYYY'') AS "EndDate",
        (SELECT (CASE WHEN "HMEP"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") AS "Assignedby",
        "BL"."ISMBE_Reason" AS "Reason",
        TO_CHAR("TR"."UpdatedDate", ''DD/MM/YYYY'') AS "UpdatedDate",
        '''' AS "Memo",
        '''' AS "Notice",
        ("ISEBE_UnblockDate"::date - "ISMTCRASTO_EndDate"::date) AS "Task_Deviation_Days",
        ("ISEBE_UnblockDate"::date - "ISMBE_BlockDate"::date) AS "Task_Blocked_Days",
        "ISMMTCAT_TaskCategoryName"
        FROM "HR_Master_Employee" "HR"
        INNER JOIN "ISM_Block_Employee" "BL" ON "HR"."HRME_Id"="BL"."HRME_Id"
        INNER JOIN "ISM_Block_Employee_Priority" "PR" ON "PR"."ISMBE_Id"="BL"."ISMBE_Id"
        INNER JOIN "ISM_TaskCreation" "TR" ON "TR"."ISMTCR_Id"="PR"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "TR"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=1
        LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TR"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_TaskCategory" "ISMMTCAT" ON "ISMMTCAT"."ISMMTCAT_Id"="TR"."ISMMTCAT_Id"
        WHERE ' || "v_dates" || ' AND "BL"."HRME_Id" IN (' || "p_HRME_Id" || ')
        ORDER BY "HR"."HRME_EmployeeCode", "ISMBE_BlockDate"';

        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "ISM_EMPLOYEES_BLOCKED_TASKS_LIST_Temp2" AS
        SELECT DISTINCT "HR"."HRME_ID",
        (CASE WHEN "HR"."HRME_EmployeeFirstName" IS NULL OR "HR"."HRME_EmployeeFirstName"='''' THEN '''' ELSE "HR"."HRME_EmployeeFirstName" END ||
        CASE WHEN "HR"."HRME_EmployeeMiddleName" IS NULL OR "HR"."HRME_EmployeeMiddleName" = '''' OR "HR"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeMiddleName" END ||
        CASE WHEN "HR"."HRME_EmployeeLastName" IS NULL OR "HR"."HRME_EmployeeLastName" = '''' OR "HR"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HR"."HRME_EmployeeLastName" END) AS "Employeename",
        "HR"."HRME_EmployeeCode" AS "EmpCode",
        "ISMTCR_TaskNo" AS "TaskNo",
        "ISMTCR_Title" AS "TaskTitle",
        "ISMTCR_Desc" AS "Description",
        TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS "CreationDate",
        TO_CHAR("ISMBE_BlockDate", ''DD/MM/YYYY'') AS "BlockedDate",
        TO_CHAR("ISEBE_UnblockDate", ''DD/MM/YYYY'') AS "UnBlockDate",
        "TR"."ISMTCR_Status" AS "Status",
        COALESCE((SELECT (CASE WHEN "HRCR"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HRCR" WHERE "HRCR"."HRME_Id"="TR"."HRME_Id" LIMIT 1),
        (SELECT "UserName" FROM "ApplicationUser" "AU" WHERE "AU"."id"="TR"."ISMTCR_CreatedBy" LIMIT 1)) AS "Createdby",
        (CASE WHEN ("ISMMCLT_ClientName"='''' OR "ISMMCLT_ClientName" IS NULL) THEN ''NA'' ELSE "ISMMCLT_ClientName" END) AS "ClientName",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", ''DD/MM/YYYY'') AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", ''DD/MM/YYYY'') AS "EndDate",
        (SELECT (CASE WHEN "HMEP"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END ||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
        FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") AS "Assignedby",
        "BL"."ISMBE_Reason" AS "Reason",
        TO_CHAR("TR"."UpdatedDate", ''DD/MM/YYYY'') AS "UpdatedDate",
        (SELECT STRING_AGG("TMM"."ISMEMN_No", '','') FROM "ISM_EMPLOYEE_MEMO_NOTICE" "TMM"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "TMMT" ON "TMMT"."ISMEMN_ID"="TMM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "TPL" ON "TPL"."ISMTPLTA_Id"="TMMT"."ISMTPLTA_Id"
        INNER JOIN "ISM_TaskCreation" "TTR" ON "TTR"."ISMTCR_Id"="TPL"."ISMTCR_Id"
        WHERE "TPL"."ISMTCR_Id"="PL"."ISMTCR_Id" AND "ISMEMN_Type"=''Memo'') AS "Memo",
        (SELECT STRING_AGG("TMM"."ISMEMN_No", '','') FROM "ISM_Block_Employee" "BL2"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE" "TMM" ON "TMM"."ISMEMN_ID"="BL2"."ISMEMN_ID"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "TMMT" ON "TMMT"."ISMEMN_ID"="TMM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "TPL" ON "TPL"."ISMTPLTA_Id"="TMMT"."ISMTPLTA_Id"
        INNER JOIN "ISM_TaskCreation" "TTR" ON "TTR"."ISMTCR_Id"="TPL"."ISMTCR_Id"
        WHERE "TPL"."ISMTCR_Id"="PL"."ISMTCR_Id") AS "Notice",
        ("ISEBE_UnblockDate"::date - "ISMTCRASTO_EndDate"::date) AS "Task_Deviation_Days",
        ("ISEBE_UnblockDate"::date - "ISMBE_BlockDate"::date) AS "Task_Blocked_Days",
        "ISMMTCAT_TaskCategoryName"
        FROM "HR_Master_Employee" "HR"
        INNER JOIN "ISM_Block_Employee" "BL" ON "HR"."HRME_Id"="BL"."HRME_Id"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE" "MM" ON "MM"."ISMEMN_ID"="BL"."ISMEMN_ID"
        INNER JOIN "ISM_EMPLOYEE_MEMO_NOTICE_TASKS" "MMT" ON "MMT"."ISMEMN_ID"="MM"."ISMEMN_ID"
        INNER JOIN "ISM_Task_Planner_Tasks" "PL" ON "PL"."ISMTPL