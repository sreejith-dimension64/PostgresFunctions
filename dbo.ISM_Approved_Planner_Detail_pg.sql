CREATE OR REPLACE FUNCTION "dbo"."ISM_Approved_Planner_Detail"(
    "HRME_Id" BIGINT,
    "ISMTPLAP_Id" BIGINT,
    "UserId" BIGINT
)
RETURNS TABLE(
    "ISMTPLAP_Id" BIGINT,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTPLAPTA_StartDate" TIMESTAMP,
    "ISMTPLAPTA_EndDate" TIMESTAMP,
    "ISMTPLAPTA_EffortInHrs" NUMERIC,
    "ISMTPLAPTA_RejectedFlg" BOOLEAN,
    "ISMTPLAPTA_ApprovalFlg" BOOLEAN,
    "ISMTPL_Id" BIGINT,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPLAPTA_Remarks" TEXT,
    "plannedby" TEXT,
    "approvedby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT "TPA"."ISMTPLAP_Id", "TC"."ISMTCR_TaskNo", "TC"."ISMTCR_Title", 
    "TPAT"."ISMTPLAPTA_StartDate", "TPAT"."ISMTPLAPTA_EndDate", "TPAT"."ISMTPLAPTA_EffortInHrs",
    "TPAT"."ISMTPLAPTA_RejectedFlg", "TPAT"."ISMTPLAPTA_ApprovalFlg", 
    "TPA"."ISMTPL_Id", "TP"."ISMTPL_PlannerName", "TPAT"."ISMTPLAPTA_Remarks",

(SELECT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
"HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END )) 
FROM "HR_Master_Employee" "HME" WHERE "HME"."HRME_Id" = "TP"."ISMTPL_PlannedBy") AS "plannedby",

(SELECT ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
"HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END ))  FROM "HR_Master_Employee" WHERE "HRME_Id" = "TPA"."HRME_Id") AS "approvedby"

FROM "ISM_Task_Planner_Approved" "TPA"
INNER JOIN "ISM_Task_Planner_Approved_Tasks" "TPAT" ON "TPAT"."ISMTPLAP_Id" = "TPA"."ISMTPLAP_Id" AND "TPAT"."ISMTPLAPTA_ActiveFlg" = 1
INNER JOIN "ISM_Task_Planner" "TP" ON "TP"."ISMTPL_Id" = "TPA"."ISMTPL_Id" AND "TP"."ISMTPL_ActiveFlg" = 1
INNER JOIN "ISM_Task_Planner_Tasks" "TPT" ON "TP"."ISMTPL_Id" = "TPT"."ISMTPL_Id" AND "TPT"."ISMTCR_Id" = "TPAT"."ISMTCR_Id" AND "TPT"."ISMTPLTA_ActiveFlg" = 1
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "TPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = 1
LEFT OUTER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "TC"."HRMD_Id" AND "HRE"."HRME_Id" = "TPA"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
WHERE "TP"."ISMTPL_ActiveFlg" = 1 AND "TPA"."ISMTPLAP_Id" = "ISM_Approved_Planner_Detail"."ISMTPLAP_Id"
ORDER BY "TPA"."ISMTPLAP_Id" DESC;

END;
$$;