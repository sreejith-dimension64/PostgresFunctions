CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerApproval_ExtraTask"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT
)
RETURNS TABLE(
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "ISMTCRASTO_Remarks" TEXT,
    "assignedby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name", "TC"."ISMTCR_BugOREnhancementFlg", "TC"."ISMTCR_CreationDate", "TC"."ISMTCR_Title", "TC"."ISMTCR_Desc",
"TC"."ISMTCR_Status", "TC"."ISMTCR_ReOpenFlg", "TC"."ISMTCR_ReOpenDate", "TC"."ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "CL"."ISMMCLT_ClientName", "ATO"."ISMTCRASTO_StartDate", "ATO"."ISMTCRASTO_EndDate", "ATO"."ISMTCRASTO_EffortInHrs", "ATO"."ISMTCRASTO_Remarks",
((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' ELSE 
"HRE"."HRME_EmployeeFirstName" END || CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' 
OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END || CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' 
OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END))::TEXT AS "assignedby"
FROM "dbo"."ISM_TaskCreation" "TC"
LEFT JOIN "dbo"."ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
LEFT JOIN "dbo"."ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = 1
INNER JOIN "dbo"."ISM_TaskCreation_AssignedTo" "ATO" ON "TC"."ISMTCR_Id" = "ATO"."ISMTCR_Id"
INNER JOIN "dbo"."HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
INNER JOIN "dbo"."HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRE"."HRME_Id" = "TC"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
INNER JOIN "dbo"."HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = 1 AND "TC"."ISMTCR_Status" != 'Closed' AND "TC"."ISMTCR_Status" != 'Completed'
WHERE "TC"."MI_Id" = "@MI_Id" AND "TC"."HRME_Id" = "@HRME_Id" AND "TC"."ISMTCR_Id" NOT IN (
    SELECT "ITPT"."ISMTCR_Id" 
    FROM "dbo"."ISM_Task_Planner" "ITP" 
    INNER JOIN "dbo"."ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id"
    AND "ITPT"."ISMTPLTA_ActiveFlg" = 1 AND "ITPT"."ISMTPLTA_Status" != 'Completed'
);

END;
$$;