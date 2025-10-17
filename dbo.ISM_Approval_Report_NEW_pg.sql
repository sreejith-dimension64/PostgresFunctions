CREATE OR REPLACE FUNCTION "dbo"."ISM_Approval_Report_NEW" (
    "p_HRME_Id" BIGINT,
    "p_ISMTPL_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "ISMTPLTA_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "plannedby" VARCHAR,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPLTA_ApprovalFlg" VARCHAR,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMTPLTA_FinishedDate" TIMESTAMP,
    "ISMTPLTA_Status" VARCHAR,
    "ISMTPLTA_Remarks" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
BEGIN
    "v_Slqdymaic" := '
    SELECT DISTINCT ITPT."ISMTPL_Id", ITPT."ISMTPLTA_Id", ITPT."ISMTCR_Id", TC."HRMPR_Id", HRP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' 
          WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
          ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    
    ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' 
           ELSE HRE."HRME_EmployeeFirstName" END || 
      CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
                OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' 
           ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || 
      CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
                OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' 
           ELSE '' '' || HRE."HRME_EmployeeLastName" END)) AS plannedby,
    
    TC."ISMTCR_TaskNo", TC."ISMTCR_Title", ITP."ISMTPL_PlannerName", ITP."ISMTPL_StartDate", ITP."ISMTPL_EndDate", 
    ITPT."ISMTPLTA_ApprovalFlg", ITPT."ISMTPLTA_StartDate", ITPT."ISMTPLTA_EndDate", ITPT."ISMTPLTA_EffortInHrs", 
    ITPT."ISMTPLTA_FinishedDate", ITPT."ISMTPLTA_Status", ITPT."ISMTPLTA_Remarks"
    
    FROM "dbo"."ISM_Task_Planner" ITP
    INNER JOIN "dbo"."ISM_Task_Planner_Tasks" ITPT ON ITP."ISMTPL_Id" = ITPT."ISMTPL_Id" AND ITPT."ISMTPLTA_ActiveFlg" = 1
    INNER JOIN "dbo"."ISM_TaskCreation" TC ON TC."ISMTCR_Id" = ITPT."ISMTCR_Id" AND TC."ISMTCR_ActiveFlg" = 1
    INNER JOIN "dbo"."HR_Master_Employee" HRE ON HRE."HRME_Id" = ITP."ISMTPL_PlannedBy" AND HRE."HRME_ActiveFlag" = 1 AND HRE."HRME_LeftFlag" = 0
    INNER JOIN "dbo"."HR_Master_Priority" HRP ON HRP."HRMPR_Id" = TC."HRMPR_Id" AND HRP."HRMP_ActiveFlag" = 1
    WHERE ITP."ISMTPL_ActiveFlg" = 1 
      AND ITP."ISMTPL_PlannedBy" = ' || "p_HRME_Id"::VARCHAR || '
      AND ITPT."ISMTPL_Id" IN (' || "p_ISMTPL_Id" || ')
    ORDER BY ITPT."ISMTPLTA_Id"';
    
    RAISE NOTICE '%', "v_Slqdymaic";
    
    RETURN QUERY EXECUTE "v_Slqdymaic";
    
END;
$$;