CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_TaskDeatils" (
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "ISMTPLTA_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "BugOREnhancementFlg" VARCHAR,
    "ISMTCR_BugOREnhancement" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
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
SELECT DISTINCT "ITPT"."ISMTPL_Id","ITPT"."ISMTPLTA_Id", "ITPT"."ISMTCR_Id","TC"."HRMPR_Id","HRP"."HRMP_Name",
"ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg",

(CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints'' ELSE ''Enhancement/Others'' end) AS "ISMTCR_BugOREnhancement",

"ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
"ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","CL"."ISMMCLT_ClientName","ISMTPL_CreatedBy","ITP"."CreatedDate" AS "plannerDate","ISMTPLTA_Status",
"ITP"."ISMTPL_PlannedBy","ISMTPL_PlannerName","ISMTPL_Remarks","ISMTPL_StartDate","ISMTPL_EndDate","ISMTPL_TotalHrs","ISMTPL_ApprovalFlg","ISMTPL_ApprovedBy","ISMTPL_ActiveFlg","ISMTPLTA_ApprovalFlg",
"ITPT"."ISMTPLTA_StartDate","ISMTPLTA_EndDate","ISMTPLTA_EffortInHrs","ISMTPLTA_Remarks",

((CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
"HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as "plannedby"

FROM "ISM_Task_Planner" "ITP"
INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg"=true
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id"="ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg"=true
LEFT JOIN "ISM_TaskCreation_Client" "AC" on "TC"."ISMTCR_Id"="AC"."ISMTCR_Id" 
LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id"="CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag"=true
INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id"="HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag"=true
INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id"="HRD"."HRMD_Id" AND "HRE"."HRME_Id"="ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag"=true AND "HRE"."HRME_LeftFlag"=false
INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id"="TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag"=true
where "ITP"."ISMTPL_ActiveFlg"=true AND "TC"."MI_Id"=' || "MI_Id"::VARCHAR || ' AND "ITP"."ISMTPL_PlannedBy" = ' || "HRME_Id"::VARCHAR || ' AND "ITPT"."ISMTPL_Id" IN (' || "ISMTPL_Id" || ')
Order BY "ISMTPL_Id"';

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;