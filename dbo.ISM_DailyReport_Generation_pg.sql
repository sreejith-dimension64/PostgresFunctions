CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_Generation"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT,
    "@Date" TEXT
)
RETURNS TABLE(
    "ISMTPL_Id" INTEGER,
    "ISMTCR_Id" INTEGER,
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
    "ISMTPL_PlannedBy" INTEGER,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" INTEGER,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "assignedby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT "ITPT"."ISMTPL_Id", "ITPT"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name", "TC"."ISMTCR_BugOREnhancementFlg", 
"TC"."ISMTCR_CreationDate", "TC"."ISMTCR_Title", "TC"."ISMTCR_Desc",
"TC"."ISMTCR_Status", "TC"."ISMTCR_ReOpenFlg", "TC"."ISMTCR_ReOpenDate", "TC"."ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "CL"."ISMMCLT_ClientName",
"ITP"."ISMTPL_PlannedBy", "ITP"."ISMTPL_PlannerName", "ITP"."ISMTPL_Remarks", "ITP"."ISMTPL_StartDate", "ITP"."ISMTPL_EndDate", "ITP"."ISMTPL_TotalHrs", 
"ITP"."ISMTPL_ApprovalFlg", "ITP"."ISMTPL_ApprovedBy", "ITP"."ISMTPL_ActiveFlg",
((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' ELSE 
"HRE"."HRME_EmployeeFirstName" END || CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' 
OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END || CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' 
OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END))::TEXT AS "assignedby"

FROM "ISM_Task_Planner" "ITP"
INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = TRUE
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
WHERE "ITP"."ISMTPL_ActiveFlg" = TRUE AND "TC"."MI_Id" = "@MI_Id" AND "ITP"."HRME_Id" = "@HRME_Id" AND "ITPT"."ISMTPLTA_Status" != 'Completed' 
AND (CAST("@Date" AS TIMESTAMP) BETWEEN "ITP"."ISMTPL_StartDate" AND "ITP"."ISMTPL_EndDate")
ORDER BY "ISMTPL_Id";

END;
$$;