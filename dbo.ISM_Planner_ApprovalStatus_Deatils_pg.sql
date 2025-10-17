CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_ApprovalStatus_Deatils"(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_Id" VARCHAR(100)
)
RETURNS TABLE(
    "ISMTPL_Id" BIGINT,
    "ISMTPLTA_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "BugOREnhancementFlg" VARCHAR,
    "ISMTCR_BugOREnhancement" TEXT,
    "ISMTPLAPTA_ApprovalFlg" BOOLEAN,
    "ISMTPLAPTA_RejectedFlg" BOOLEAN,
    "taskStatus" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTPLAPTA_EffortInHrs" NUMERIC,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTPL_CreatedBy" BIGINT,
    "plannerDate" TIMESTAMP,
    "ISMTPLTA_Status" VARCHAR,
    "ISMTPL_PlannedBy" BIGINT,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" BIGINT,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "ISMTPLTA_ApprovalFlg" BOOLEAN,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMTPLTA_Remarks" TEXT,
    "plannedby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
SELECT DISTINCT "ITPT"."ISMTPL_Id", "ITPT"."ISMTPLTA_Id", "ITPT"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name",
"ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg",

(CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' ELSE ''Enhancement/Others'' END) AS "ISMTCR_BugOREnhancement",
"ISMTPLAPTA_ApprovalFlg", "ISMTPLAPTA_RejectedFlg",

(CASE WHEN ("TPAT"."ISMTPLAPTA_ApprovalFlg" = TRUE) AND ("ISMTPLAPTA_RejectedFlg" = FALSE OR "ISMTPLAPTA_RejectedFlg" IS NULL) THEN ''APPROVED'' 
WHEN ("TPAT"."ISMTPLAPTA_ApprovalFlg" = FALSE OR "TPAT"."ISMTPLAPTA_ApprovalFlg" IS NULL) AND "ISMTPLAPTA_RejectedFlg" = TRUE THEN ''REJECTED'' 
WHEN ("TPAT"."ISMTPLAPTA_ApprovalFlg" = FALSE OR "TPAT"."ISMTPLAPTA_ApprovalFlg" IS NULL) 
AND ("ISMTPLAPTA_RejectedFlg" = FALSE OR "ISMTPLAPTA_RejectedFlg" IS NULL) THEN ''PENDING'' END) AS "taskStatus",

"ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "ISMTPLAPTA_EffortInHrs",
"ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "CL"."ISMMCLT_ClientName", "ISMTPL_CreatedBy", "ITP"."CreatedDate" AS "plannerDate", "ISMTPLTA_Status",
"ITP"."ISMTPL_PlannedBy", "ISMTPL_PlannerName", "ISMTPL_Remarks", "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPL_TotalHrs", "ISMTPL_ApprovalFlg", "ISMTPL_ApprovedBy", "ISMTPL_ActiveFlg", "ISMTPLTA_ApprovalFlg",
"ITPT"."ISMTPLTA_StartDate", "ISMTPLTA_EndDate", "ISMTPLTA_EffortInHrs", "ISMTPLTA_Remarks",

((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
"HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "plannedby"

FROM "ISM_Task_Planner" "ITP"
INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = TRUE
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
INNER JOIN "ISM_Task_Planner_Approved" "TPA" ON "TPA"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "TPA"."ISMTPLAP_ActiveFlg" = TRUE
INNER JOIN "ISM_Task_Planner_Approved_Tasks" "TPAT" ON "TPA"."ISMTPLAP_Id" = "TPAT"."ISMTPLAP_Id" AND "TPAT"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id" 
LEFT JOIN "ISM_Master_Client" "CL" ON "ac"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
WHERE "ITP"."ISMTPL_ActiveFlg" = TRUE AND "TC"."MI_Id" = ' || $1 || ' AND "ITP"."ISMTPL_PlannedBy" = ' || $2 || ' AND "ITPT"."ISMTPL_Id" IN (' || $3 || ')
ORDER BY "ISMTPL_Id"';

    RETURN QUERY EXECUTE "Slqdymaic" USING "MI_Id", "HRME_Id", "ISMTPL_Id";
END;
$$;