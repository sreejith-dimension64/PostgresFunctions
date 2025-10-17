CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_List" (
    "@MI_Id" BIGINT,
    "@HRME_Id" BIGINT
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannedBy" TEXT,
    "ISMTPL_PlannerName" TEXT,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovedBy" TEXT,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "planDate" TIMESTAMP,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "plannedby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    "@Slqdymaic" := 
    'SELECT DISTINCT  TP."ISMTPL_Id", TP."HRME_Id",TP."ISMTPL_PlannedBy",TP."ISMTPL_PlannerName",TP."ISMTPL_Remarks",TP."ISMTPL_StartDate",TP."ISMTPL_EndDate",TP."ISMTPL_TotalHrs",
    TP."ISMTPL_ApprovedBy",TP."ISMTPL_ActiveFlg",TP."CreatedDate" AS planDate,TP."ISMTPL_ApprovalFlg",
    ((CASE WHEN HRE."HRME_EmployeeFirstName" is null or HRE."HRME_EmployeeFirstName"='''' then '''' else 
    HRE."HRME_EmployeeFirstName" end||CASE WHEN HRE."HRME_EmployeeMiddleName" is null or HRE."HRME_EmployeeMiddleName" = '''' 
    or HRE."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || CASE WHEN HRE."HRME_EmployeeLastName" is null or HRE."HRME_EmployeeLastName" = '''' 
    or HRE."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END )) as plannedby
    FROM "ISM_Task_Planner" TP
    INNER JOIN "ISM_Task_Planner_Tasks" TPT on TP."ISMTPL_Id"=TPT."ISMTPL_Id" AND TPT."ISMTPLTA_ActiveFlg"=true
    INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id"=TC."ISMTCR_Id" AND TC."ISMTCR_ActiveFlg"=true
    INNER JOIN "HR_Master_Employee" HRE ON HRE."HRMD_Id"=TC."HRMD_Id" AND HRE."HRME_Id"=TP."HRME_Id" AND HRE."HRME_ActiveFlag"=true AND HRE."HRME_LeftFlag"=false
    INNER JOIN "IVRM_Staff_User_Login" f ON TC."ISMTCR_CreatedBy"=f."Id" AND f."Emp_Code"=TP."HRME_Id"
    where TP."ISMTPL_ActiveFlg"=true AND TP."MI_Id"=' || "@MI_Id"::VARCHAR || ' AND TP."HRME_Id" =' || "@HRME_Id"::VARCHAR || '
    Order By TP."ISMTPL_Id" Desc';

    RETURN QUERY EXECUTE "@Slqdymaic";
END;
$$;