CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerApproval_Search"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT,
    "@ISMTPL_Id" TEXT
)
RETURNS TABLE(
    "ISMTCR_TaskNo" VARCHAR,
    "HRMP_Name" VARCHAR,
    "ISMTCR_Desc" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTPLAPTA_StartDate" TIMESTAMP,
    "ISMTPLAPTA_EndDate" TIMESTAMP,
    "ISMTPLAPTA_Status" VARCHAR,
    "ISMTPLAPTA_ExtraTaskFlg" BOOLEAN,
    "ISMTPLAPTA_ApprovalFlg" BOOLEAN,
    "ISMTPLAPTA_RejectedFlg" BOOLEAN,
    "ISMTPLAPTA_Remarks" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTPLAPTA_EffortInHrs" TEXT,
    "ISMMCLT_ClientName" VARCHAR,
    "approvedby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ITC"."ISMTCR_TaskNo",
        "HMP"."HRMP_Name",
        "ITC"."ISMTCR_Desc",
        "ITC"."ISMTCR_Title",
        "TPT"."ISMTPLAPTA_StartDate",
        "TPT"."ISMTPLAPTA_EndDate",
        "TPT"."ISMTPLAPTA_Status",
        "TPT"."ISMTPLAPTA_ExtraTaskFlg",
        "TPT"."ISMTPLAPTA_ApprovalFlg",
        "TPT"."ISMTPLAPTA_RejectedFlg",
        "TPT"."ISMTPLAPTA_Remarks",
        CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' ELSE 'Enhancement/Others' END AS "ISMTCR_BugOREnhancementFlg",
        CAST("TPT"."ISMTPLAPTA_EffortInHrs" AS TEXT) || ' Hour' AS "ISMTPLAPTA_EffortInHrs",
        "CL"."ISMMCLT_ClientName",
        (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' ELSE "HRE"."HRME_EmployeeFirstName" END ||
         CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
         CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END) AS "approvedby"
    FROM "ISM_Task_Planner_Approved" "TP"
    INNER JOIN "ISM_Task_Planner_Approved_Tasks" "TPT" ON "TP"."ISMTPLAP_Id" = "TPT"."ISMTPLAP_Id"
    INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "TPT"."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "TP"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
    LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "ITC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = 1
    WHERE "TP"."MI_Id" = "@MI_Id" AND "TP"."HRME_Id" = "@HRME_Id" AND "TP"."ISMTPL_Id" = "@ISMTPL_Id";
END;
$$;