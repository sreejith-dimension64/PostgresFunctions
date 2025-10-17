CREATE OR REPLACE FUNCTION "dbo"."ADMIN_ISM_Approval_Report" (
    "HRME_Id" TEXT, 
    "ISMTPL_Id" TEXT,
    "APPROVAL" TEXT
)
RETURNS TABLE (
    "ISMTPL_Id" INTEGER,
    "ISMTPLTA_Id" INTEGER,
    "ISMTCR_Id" INTEGER,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "plannedby" TEXT,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPLTA_ApprovalFlg" INTEGER,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMTPLTA_FinishedDate" TIMESTAMP,
    "ISMTPLTA_Status" VARCHAR,
    "ISMTPLTA_Remarks" TEXT,
    "ISMTPLAP_Remarks" TEXT,
    "approvedby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN

    IF "APPROVAL" = '1' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "ITPT"."ISMTPL_Id", "ITPT"."ISMTPLTA_Id", "ITPT"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
        ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",

        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS plannedby,

        "ISMTCR_TaskNo", "ISMTCR_Title", "ISMTPL_PlannerName", "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPLTA_ApprovalFlg",
        "ISMTPLTA_StartDate", "ISMTPLTA_EndDate", "ISMTPLTA_EffortInHrs", "ISMTPLTA_FinishedDate", "ISMTPLTA_Status", "ISMTPLTA_Remarks", "AP"."ISMTPLAP_Remarks",
        (SELECT ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) FROM "HR_Master_Employee" WHERE "HRME_Id" = "AP"."HRME_Id") AS approvedby

        FROM "ISM_Task_Planner" "ITP"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = 1
        INNER JOIN "ISM_Task_Planner_Approved" "AP" ON "AP"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        WHERE "ITP"."ISMTPL_ActiveFlg" = 1 AND "ITP"."ISMTPL_PlannedBy" IN (' || "HRME_Id" || ') AND "ITPT"."ISMTPL_Id" IN (' || "ISMTPL_Id" || ')
        ORDER BY plannedby, "ITPT"."ISMTPLTA_Id"';
    ELSE
        "Slqdymaic" := '
        SELECT DISTINCT "ITPT"."ISMTPL_Id", "ITPT"."ISMTPLTA_Id", "ITPT"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",

        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS plannedby,

        "ISMTCR_TaskNo", "ISMTCR_Title", "ISMTPL_PlannerName", "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPLTA_ApprovalFlg",
        "ISMTPLTA_StartDate", "ISMTPLTA_EndDate", "ISMTPLTA_EffortInHrs", "ISMTPLTA_FinishedDate", "ISMTPLTA_Status", "ISMTPLTA_Remarks" AS "ISMTPLAP_Remarks", '''' AS approvedby

        FROM "ISM_Task_Planner" "ITP"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = 1
        INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = 1
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = 1
        WHERE "ITP"."ISMTPL_ActiveFlg" = 1 AND "ITP"."ISMTPL_PlannedBy" IN (' || "HRME_Id" || ') AND "ITPT"."ISMTPL_Id" IN (' || "ISMTPL_Id" || ') AND "ITPT"."ISMTPL_Id" NOT IN (SELECT "ISMTPL_Id" FROM "ISM_Task_Planner_Approved")
        ORDER BY plannedby, "ITPT"."ISMTPLTA_Id"';
    END IF;

    RETURN QUERY EXECUTE "Slqdymaic";

END;
$$;