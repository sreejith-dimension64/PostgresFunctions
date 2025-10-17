CREATE OR REPLACE FUNCTION "ISM_Deviation_Remarkswise_Report"(
    "p_MI_Id" VARCHAR(200),
    "p_HRME_Id" TEXT,
    "p_status" TEXT,
    "p_StartDate" TEXT,
    "p_EndDate" TEXT,
    "p_NoOfDays" VARCHAR(500)
)
RETURNS TABLE(
    "ISMTCR_Id" INTEGER,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "HRMP_Name" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMDRPT_Status" VARCHAR,
    "ISMDRPT_Remarks" TEXT,
    "deviationRemarks" TEXT,
    "HRME_Id" INTEGER,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCRASTO_AssignedDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMDRPT_Date" TIMESTAMP,
    "Timetakendays" INTEGER,
    "deviationdays" INTEGER,
    "employeename" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic1" TEXT;
    "v_Slqdymaic2" TEXT;
    "v_betweendates" TEXT;
    "v_GetDate" TEXT;
    "v_StartDate_D" VARCHAR(10);
    "v_EndDate_D" VARCHAR(10);
BEGIN
    DROP TABLE IF EXISTS "Deviation_Temp1";
    DROP TABLE IF EXISTS "Deviation_Temp2";

    "v_StartDate_D" := CAST("p_StartDate" AS DATE)::VARCHAR(10);
    "v_EndDate_D" := CAST("p_EndDate" AS DATE)::VARCHAR(10);

    IF "v_StartDate_D" != '' AND "v_EndDate_D" != '' THEN
        "v_betweendates" := '((CAST("ITPT"."ISMTPLTA_StartDate" AS DATE))>=''' || "v_StartDate_D" || ''' AND (CAST("ITPT"."ISMTPLTA_EndDate" AS DATE))<=''' || "v_EndDate_D" || ''')';
        "v_GetDate" := '("ITPT"."ISMTPLTA_EndDate" < CURRENT_TIMESTAMP)';
    ELSE
        "v_betweendates" := 'TRUE';
        "v_GetDate" := '("ITPT"."ISMTPLTA_EndDate" < CURRENT_TIMESTAMP)';
    END IF;

    IF "p_NoOfDays" = 'A' THEN
        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "Deviation_Temp1" AS
        SELECT DISTINCT "DR"."ISMTCR_Id", "ITC"."ISMTCR_TaskNo", "ITC"."ISMTCR_Title", "HMP"."HRMP_Name", "ITC"."ISMTCR_Desc", "DR"."ISMDRPT_Status", "DR"."ISMDRPT_Remarks",
        "IDR"."ISMDR_Remarks" AS "deviationRemarks",
        "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        (CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
        WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
        ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ICAT"."ISMTCRASTO_AssignedDate", "ITPT"."ISMTPLTA_EndDate", "DR"."ISMDRPT_Date",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ICAT"."ISMTCRASTO_AssignedDate"::TIMESTAMP)) AS INTEGER) AS "Timetakendays",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) AS "deviationdays",
        (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
        CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '''') = '''' OR "HRE"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END ||
        CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '''') = '''' OR "HRE"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END) AS "employeename"
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ITC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation_AssignedTo" "ICAT" ON "ICAT"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ICAT"."HRME_Id" IN (' || "p_HRME_Id" || ')
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        INNER JOIN "ISM_Departmentwise_Remarks" "IDR" ON "HRE"."HRMD_Id" = "IDR"."HRMD_Id" AND "IDR"."ISMDR_ActiveFlag" = 1
        INNER JOIN "ISM_Task_Planner_Deviation" "ITPD" ON "ITPD"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPD"."ISMDR_Id" = "IDR"."ISMDR_Id" AND "ITPD"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        WHERE "DR"."ISMDRPT_DeviationFlg" = 1 AND "DR"."HRME_Id" IN (' || "p_HRME_Id" || ')
        AND ' || "v_betweendates" || '
        AND POSITION('','' || "DR"."ISMDRPT_Status" || '','' IN '','' || ''' || "p_status" || ''' || '','') > 0';

        "v_Slqdymaic2" := '
        CREATE TEMP TABLE "Deviation_Temp2" AS
        SELECT DISTINCT "DR"."ISMTCR_Id", "ITC"."ISMTCR_TaskNo", "ITC"."ISMTCR_Title", "HMP"."HRMP_Name", "ITC"."ISMTCR_Desc", "DR"."ISMDRPT_Status", "DR"."ISMDRPT_Remarks",
        ''NA''::TEXT AS "deviationRemarks",
        "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        (CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
        WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
        ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ICAT"."ISMTCRASTO_AssignedDate", "ITPT"."ISMTPLTA_EndDate", "DR"."ISMDRPT_Date",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ICAT"."ISMTCRASTO_AssignedDate"::TIMESTAMP)) AS INTEGER) AS "Timetakendays",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) AS "deviationdays",
        (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
        CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '''') = '''' OR "HRE"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END ||
        CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '''') = '''' OR "HRE"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END) AS "employeename"
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ITC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation_AssignedTo" "ICAT" ON "ICAT"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ICAT"."HRME_Id" IN (' || "p_HRME_Id" || ')
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        WHERE ' || "v_GetDate" || ' AND "DR"."ISMDRPT_Status" = ''Open'' AND "ITP"."HRME_Id" IN (' || "p_HRME_Id" || ')
        AND ' || "v_betweendates" || '
        AND "DR"."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Deviation" WHERE "ISMDRPT_ActiveFlg" = 1)';

        EXECUTE "v_Slqdymaic1";
        EXECUTE "v_Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Deviation_Temp1"
        UNION ALL
        SELECT * FROM "Deviation_Temp2"
        ORDER BY "ISMDRPT_Date";
    ELSE
        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "Deviation_Temp1" AS
        SELECT DISTINCT "DR"."ISMTCR_Id", "ITC"."ISMTCR_TaskNo", "ITC"."ISMTCR_Title", "HMP"."HRMP_Name", "ITC"."ISMTCR_Desc", "DR"."ISMDRPT_Status", "DR"."ISMDRPT_Remarks",
        "IDR"."ISMDR_Remarks" AS "deviationRemarks",
        "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        (CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
        WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
        ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ICAT"."ISMTCRASTO_AssignedDate", "ITPT"."ISMTPLTA_EndDate", "DR"."ISMDRPT_Date",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ICAT"."ISMTCRASTO_AssignedDate"::TIMESTAMP)) AS INTEGER) AS "Timetakendays",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) AS "deviationdays",
        (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
        CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '''') = '''' OR "HRE"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END ||
        CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '''') = '''' OR "HRE"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END) AS "employeename"
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ITC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation_AssignedTo" "ICAT" ON "ICAT"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ICAT"."HRME_Id" IN (' || "p_HRME_Id" || ')
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        INNER JOIN "ISM_Departmentwise_Remarks" "IDR" ON "HRE"."HRMD_Id" = "IDR"."HRMD_Id" AND "IDR"."ISMDR_ActiveFlag" = 1
        INNER JOIN "ISM_Task_Planner_Deviation" "ITPD" ON "ITPD"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPD"."ISMDR_Id" = "IDR"."ISMDR_Id" AND "ITPD"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        WHERE "DR"."ISMDRPT_DeviationFlg" = 1 AND "DR"."HRME_Id" IN (' || "p_HRME_Id" || ')
        AND CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) > ' || "p_NoOfDays" || '
        AND ' || "v_betweendates" || '
        AND POSITION('','' || "DR"."ISMDRPT_Status" || '','' IN '','' || ''' || "p_status" || ''' || '','') > 0';

        "v_Slqdymaic2" := '
        CREATE TEMP TABLE "Deviation_Temp2" AS
        SELECT DISTINCT "DR"."ISMTCR_Id", "ITC"."ISMTCR_TaskNo", "ITC"."ISMTCR_Title", "HMP"."HRMP_Name", "ITC"."ISMTCR_Desc", "DR"."ISMDRPT_Status", "DR"."ISMDRPT_Remarks",
        ''NA''::TEXT AS "deviationRemarks",
        "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        (CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
        WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
        ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        "ICAT"."ISMTCRASTO_AssignedDate", "ITPT"."ISMTPLTA_EndDate", "DR"."ISMDRPT_Date",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ICAT"."ISMTCRASTO_AssignedDate"::TIMESTAMP)) AS INTEGER) AS "Timetakendays",
        CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) AS "deviationdays",
        (COALESCE("HRE"."HRME_EmployeeFirstName", '''') || 
        CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '''') = '''' OR "HRE"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeMiddleName" END ||
        CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '''') = '''' OR "HRE"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRE"."HRME_EmployeeLastName" END) AS "employeename"
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ITC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation_AssignedTo" "ICAT" ON "ICAT"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ICAT"."HRME_Id" IN (' || "p_HRME_Id" || ')
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        WHERE ' || "v_GetDate" || ' AND "DR"."ISMDRPT_Status" = ''Open'' AND "ITP"."HRME_Id" IN (' || "p_HRME_Id" || ')
        AND CAST(EXTRACT(DAY FROM ("DR"."ISMDRPT_Date"::TIMESTAMP - "ITPT"."ISMTPLTA_EndDate"::TIMESTAMP)) AS INTEGER) > ' || "p_NoOfDays" || '
        AND ' || "v_betweendates" || '
        AND "DR"."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Deviation" WHERE "ISMDRPT_ActiveFlg" = 1)';

        EXECUTE "v_Slqdymaic1";
        EXECUTE "v_Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Deviation_Temp1"
        UNION ALL
        SELECT * FROM "Deviation_Temp2"
        ORDER BY "ISMDRPT_Date";
    END IF;

    DROP TABLE IF EXISTS "Deviation_Temp1";
    DROP TABLE IF EXISTS "Deviation_Temp2";

    RETURN;
END;
$$;