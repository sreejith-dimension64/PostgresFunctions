CREATE OR REPLACE FUNCTION "dbo"."ISM_Peding_Planner_List" (
    p_HRME_Id VARCHAR(500), 
    p_roletype VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannedBy" VARCHAR,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" VARCHAR,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "planDate" TIMESTAMP,
    "plannedby" VARCHAR,
    "MI_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_Month_Id BIGINT;
BEGIN
    SELECT EXTRACT(MONTH FROM CURRENT_TIMESTAMP) INTO v_Month_Id;
    
    v_Slqdymaic := '
    SELECT DISTINCT TP."ISMTPL_Id", TP."HRME_Id", TP."ISMTPL_PlannedBy", TP."ISMTPL_PlannerName", 
    TP."ISMTPL_Remarks", TP."ISMTPL_StartDate", TP."ISMTPL_EndDate", TP."ISMTPL_TotalHrs",
    TP."ISMTPL_ApprovalFlg", TP."ISMTPL_ApprovedBy", TP."ISMTPL_ActiveFlg", TP."CreatedDate" AS planDate,
    ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' 
    ELSE HRE."HRME_EmployeeFirstName" END || 
    CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
    OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || 
    CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
    OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END)) AS plannedby, 
    HRE."MI_Id"
    FROM "ISM_Task_Planner" TP
    INNER JOIN "ISM_Task_Planner_Tasks" TPT ON TP."ISMTPL_Id" = TPT."ISMTPL_Id" AND TPT."ISMTPLTA_ActiveFlg" = true
    INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id" = TPT."ISMTCR_Id" AND TC."ISMTCR_ActiveFlg" = true
    INNER JOIN "HR_Master_Employee" HRE ON HRE."HRME_Id" = TP."HRME_Id" AND HRE."HRME_Id" = TP."HRME_Id" 
    AND HRE."HRME_ActiveFlag" = true AND HRE."HRME_LeftFlag" = false
    WHERE TP."ISMTPL_ActiveFlg" = true 
    AND TP."HRME_Id" IN (' || p_HRME_Id || ') 
    AND ((EXTRACT(MONTH FROM TP."ISMTPL_StartDate") = ' || v_Month_Id::VARCHAR || ') 
    OR (EXTRACT(MONTH FROM TP."ISMTPL_EndDate") = ' || v_Month_Id::VARCHAR || '))
    AND TP."ISMTPL_Id" NOT IN (SELECT DISTINCT "ISMTPL_Id" FROM "ISM_Task_Planner_Approved" 
    WHERE "ISMTPLAP_ActiveFlg" = true)
    ORDER BY TP."ISMTPL_Id"';
    
    RETURN QUERY EXECUTE v_Slqdymaic;
END;
$$;