CREATE OR REPLACE FUNCTION "dbo"."ISM_Approved_Planner_List"(
    p_HRME_Id VARCHAR(500),
    p_roletype VARCHAR(100)
)
RETURNS TABLE(
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannedBy" BIGINT,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" BIGINT,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "planDate" TIMESTAMP,
    "ISMTPLAP_Id" BIGINT,
    "plannedby" VARCHAR,
    "ISMTPLAP_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_Month_Id BIGINT;
BEGIN
    SELECT EXTRACT(MONTH FROM CURRENT_TIMESTAMP) INTO v_Month_Id;
    
    v_Slqdymaic := '
    SELECT DISTINCT  
        TP."ISMTPL_Id", 
        TP."HRME_Id",
        TP."ISMTPL_PlannedBy",
        TP."ISMTPL_PlannerName",
        TP."ISMTPL_Remarks",
        TP."ISMTPL_StartDate",
        TP."ISMTPL_EndDate",
        TP."ISMTPL_TotalHrs",
        TP."ISMTPL_ApprovalFlg",
        TP."ISMTPL_ApprovedBy",
        TP."ISMTPL_ActiveFlg",
        TP."CreatedDate" AS planDate,
        TPTA."ISMTPLAP_Id",
        ((CASE WHEN HRE."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as plannedby,
        "ISMTPLAP_Remarks"
    FROM "ISM_Task_Planner" TP
    INNER JOIN "ISM_Task_Planner_Tasks" TPT on TP."ISMTPL_Id"=TPT."ISMTPL_Id" AND TPT."ISMTPLTA_ActiveFlg"=true
    INNER JOIN "ISM_Task_Planner_Approved" TPTA on TP."ISMTPL_Id"=TPTA."ISMTPL_Id" AND TPTA."ISMTPLAP_ActiveFlg"=true
    INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id"=TPT."ISMTCR_Id" AND TC."ISMTCR_ActiveFlg"=true
    INNER JOIN "HR_Master_Employee" HRE ON HRE."HRME_Id"=TP."HRME_Id" AND HRE."HRME_Id"=TP."HRME_Id" AND HRE."HRME_ActiveFlag"=true AND HRE."HRME_LeftFlag"=false
    INNER JOIN "HR_Master_Department" HRD ON HRD."HRMD_Id"=HRE."HRMD_Id" AND HRD."HRMD_ActiveFlag"=true
    where TP."ISMTPL_ActiveFlg"=true 
    AND TP."HRME_Id" IN (' || p_HRME_Id || ') 
    AND ((EXTRACT(MONTH FROM TP."ISMTPL_StartDate")=' || v_Month_Id::VARCHAR || ') OR (EXTRACT(MONTH FROM TP."ISMTPL_EndDate")=' || v_Month_Id::VARCHAR || '))
    Order By TP."ISMTPL_Id"';
    
    RETURN QUERY EXECUTE v_Slqdymaic;
END;
$$;