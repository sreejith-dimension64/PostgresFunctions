CREATE OR REPLACE FUNCTION "dbo"."ISM_PLANNER_CREATION_TASKDEATILS" (
    "p_MI_Id" VARCHAR(100),
    "p_HRME_Id" VARCHAR(100),
    "p_ISMTPL_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "ISMTPLTA_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "BugOREnhancementFlg" TEXT,
    "ISMTPLAP_Id" BIGINT,
    "ISMTCR_BugOREnhancement" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "CreatedDate" TIMESTAMP,
    "ISMTCR_Status" TEXT,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "ISMTPL_CreatedBy" BIGINT,
    "plannerDate" TIMESTAMP,
    "ISMTPLTA_Status" TEXT,
    "ISMTPL_PlannedBy" BIGINT,
    "ISMTPL_PlannerName" TEXT,
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
    "MI_Id" BIGINT,
    "plannedby" TEXT,
    "ISMTPLTA_PreviousTask" BIGINT,
    "ISMMTCAT_TaskCategoryName" TEXT,
    "ISMMTCAT_TaskPercentage" NUMERIC,
    "ISMMTCAT_DurationFlg" BOOLEAN,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMMTCAT_EachTaskMaxDuration" NUMERIC,
    "ISMMTCAT_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ENAME" TEXT,
    "ISMTPLAP_TotalHrs" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_RCOUNT" INTEGER;
BEGIN
    "v_RCOUNT" := 0;

    SELECT COUNT(*) INTO "v_RCOUNT"
    FROM "ISM_Task_Planner_Category"
    WHERE "ISMTPL_Id" = "p_ISMTPL_Id"::BIGINT;

    IF "v_RCOUNT" > 0 THEN
        RETURN QUERY EXECUTE
        'SELECT DISTINCT ITPT."ISMTPL_Id", ITPT."ISMTPLTA_Id", ITPT."ISMTCR_Id", TC."HRMPR_Id", HRP."HRMP_Name",
        TC."ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg", ITPA."ISMTPLAP_Id",
        (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' 
              WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' 
              ELSE ''Others'' END) AS "ISMTCR_BugOREnhancement",
        TC."ISMTCR_CreationDate", TC."ISMTCR_Title", TC."ISMTCR_Desc", TC."CreatedDate",
        TC."ISMTCR_Status", TC."ISMTCR_ReOpenFlg", TC."ISMTCR_ReOpenDate", TC."ISMTCR_TaskNo", 
        ac."ISMMCLT_Id", CL."ISMMCLT_ClientName", ITP."ISMTPL_CreatedBy", ITP."CreatedDate" AS "plannerDate", 
        ITPT."ISMTPLTA_Status",
        ITP."ISMTPL_PlannedBy", ITP."ISMTPL_PlannerName", ITP."ISMTPL_Remarks", ITP."ISMTPL_StartDate", 
        ITP."ISMTPL_EndDate", ITP."ISMTPL_TotalHrs", ITP."ISMTPL_ApprovalFlg", ITP."ISMTPL_ApprovedBy", 
        ITP."ISMTPL_ActiveFlg", ITPT."ISMTPLTA_ApprovalFlg",
        ITPT."ISMTPLTA_StartDate", ITPT."ISMTPLTA_EndDate", ITPT."ISMTPLTA_EffortInHrs", ITPT."ISMTPLTA_Remarks", 
        HRE."MI_Id",
        ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' 
               ELSE HRE."HRME_EmployeeFirstName" END ||
          CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
               OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' 
               ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || 
          CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
               OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' 
               ELSE '' '' || HRE."HRME_EmployeeLastName" END)) AS "plannedby",
        ITPT."ISMTPLTA_PreviousTask", IMT."ISMMTCAT_TaskCategoryName", 
        GGG."ISMTPLC_TaskPercentage" AS "ISMMTCAT_TaskPercentage",
        GGG."ISMTPLC_DurationFlg" AS "ISMMTCAT_DurationFlg",
        GGG."ISMTPLC_CompulsoryFlg" AS "ISMMTCAT_CompulsoryFlg",
        GGG."ISMTPLC_EachTaskMaxDuration" AS "ISMMTCAT_EachTaskMaxDuration",
        TC."ISMMTCAT_Id", HRE."HRME_Id",
        COALESCE(HRE."HRME_EmployeeFirstName", '' '') || '' '' || 
        COALESCE(HRE."HRME_EmployeeMiddleName", '' '') || '' '' || 
        COALESCE(HRE."HRME_EmployeeLastName", '' '') AS "ENAME",
        ITPA."ISMTPLAP_TotalHrs"
        FROM "ISM_Task_Planner" ITP
        INNER JOIN "ISM_Task_Planner_Tasks" ITPT ON ITP."ISMTPL_Id" = ITPT."ISMTPL_Id" 
            AND ITPT."ISMTPLTA_ActiveFlg" = TRUE
        INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id" = ITPT."ISMTCR_Id" 
            AND TC."ISMTCR_ActiveFlg" = TRUE
        INNER JOIN "ISM_Master_TaskCategory" AS IMT ON IMT."ISMMTCAT_Id" = TC."ISMMTCAT_Id"
        INNER JOIN "ISM_Task_Planner_Category" AS GGG ON GGG."ISMMTCAT_Id" = TC."ISMMTCAT_Id" 
            AND GGG."ISMTPL_Id" = ITP."ISMTPL_Id"
        LEFT JOIN "ISM_TaskCreation_Client" AC ON TC."ISMTCR_Id" = AC."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" CL ON AC."ISMMCLT_Id" = CL."ISMMCLT_Id" 
            AND CL."ISMMCLT_ActiveFlag" = TRUE
        LEFT JOIN "ISM_Task_Planner_Approved" ITPA ON ITPA."ISMTPL_Id" = ITP."ISMTPL_Id" 
            AND ITPA."ISMTPLAP_ActiveFlg" = TRUE
        INNER JOIN "HR_Master_Employee" HRE ON HRE."HRME_Id" = ITP."ISMTPL_PlannedBy" 
            AND HRE."HRME_ActiveFlag" = TRUE AND HRE."HRME_LeftFlag" = FALSE
        INNER JOIN "HR_Master_Priority" HRP ON HRP."HRMPR_Id" = TC."HRMPR_Id" 
            AND HRP."HRMP_ActiveFlag" = TRUE
        WHERE ITP."ISMTPL_ActiveFlg" = TRUE AND ITPT."ISMTPL_Id" IN (' || "p_ISMTPL_Id" || ')
        ORDER BY ITP."ISMTPL_Id", ITPT."ISMTPLTA_PreviousTask" DESC';
    ELSE
        RETURN QUERY EXECUTE
        'SELECT DISTINCT ITPT."ISMTPL_Id", ITPT."ISMTPLTA_Id", ITPT."ISMTCR_Id", TC."HRMPR_Id", HRP."HRMP_Name",
        TC."ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg", ITPA."ISMTPLAP_Id",
        (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' 
              WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' 
              ELSE ''Others'' END) AS "ISMTCR_BugOREnhancement",
        TC."ISMTCR_CreationDate", TC."ISMTCR_Title", TC."ISMTCR_Desc", TC."CreatedDate",
        TC."ISMTCR_Status", TC."ISMTCR_ReOpenFlg", TC."ISMTCR_ReOpenDate", TC."ISMTCR_TaskNo", 
        ac."ISMMCLT_Id", CL."ISMMCLT_ClientName", ITP."ISMTPL_CreatedBy", ITP."CreatedDate" AS "plannerDate", 
        ITPT."ISMTPLTA_Status",
        ITP."ISMTPL_PlannedBy", ITP."ISMTPL_PlannerName", ITP."ISMTPL_Remarks", ITP."ISMTPL_StartDate", 
        ITP."ISMTPL_EndDate", ITP."ISMTPL_TotalHrs", ITP."ISMTPL_ApprovalFlg", ITP."ISMTPL_ApprovedBy", 
        ITP."ISMTPL_ActiveFlg", ITPT."ISMTPLTA_ApprovalFlg",
        ITPT."ISMTPLTA_StartDate", ITPT."ISMTPLTA_EndDate", ITPT."ISMTPLTA_EffortInHrs", ITPT."ISMTPLTA_Remarks", 
        HRE."MI_Id",
        ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' 
               ELSE HRE."HRME_EmployeeFirstName" END ||
          CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
               OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' 
               ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || 
          CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
               OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' 
               ELSE '' '' || HRE."HRME_EmployeeLastName" END)) AS "plannedby",
        ITPT."ISMTPLTA_PreviousTask", IMT."ISMMTCAT_TaskCategoryName", 
        IMT."ISMMTCAT_TaskPercentage", IMT."ISMMTCAT_DurationFlg",
        IMT."ISMMTCAT_CompulsoryFlg", IMT."ISMMTCAT_EachTaskMaxDuration",
        TC."ISMMTCAT_Id", HRE."HRME_Id",
        COALESCE(HRE."HRME_EmployeeFirstName", '' '') || '' '' || 
        COALESCE(HRE."HRME_EmployeeMiddleName", '' '') || '' '' || 
        COALESCE(HRE."HRME_EmployeeLastName", '' '') AS "ENAME",
        ITPA."ISMTPLAP_TotalHrs"
        FROM "ISM_Task_Planner" ITP
        INNER JOIN "ISM_Task_Planner_Tasks" ITPT ON ITP."ISMTPL_Id" = ITPT."ISMTPL_Id" 
            AND ITPT."ISMTPLTA_ActiveFlg" = TRUE
        INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id" = ITPT."ISMTCR_Id" 
            AND TC."ISMTCR_ActiveFlg" = TRUE
        INNER JOIN "ISM_Master_TaskCategory" AS IMT ON IMT."ISMMTCAT_Id" = TC."ISMMTCAT_Id"
        LEFT JOIN "ISM_TaskCreation_Client" AC ON TC."ISMTCR_Id" = AC."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" CL ON AC."ISMMCLT_Id" = CL."ISMMCLT_Id" 
            AND CL."ISMMCLT_ActiveFlag" = TRUE
        LEFT JOIN "ISM_Task_Planner_Approved" ITPA ON ITPA."ISMTPL_Id" = ITP."ISMTPL_Id" 
            AND ITPA."ISMTPLAP_ActiveFlg" = TRUE
        INNER JOIN "HR_Master_Employee" HRE ON HRE."HRME_Id" = ITP."ISMTPL_PlannedBy" 
            AND HRE."HRME_ActiveFlag" = TRUE AND HRE."HRME_LeftFlag" = FALSE
        INNER JOIN "HR_Master_Priority" HRP ON HRP."HRMPR_Id" = TC."HRMPR_Id" 
            AND HRP."HRMP_ActiveFlag" = TRUE
        WHERE ITP."ISMTPL_ActiveFlg" = TRUE AND ITPT."ISMTPL_Id" IN (' || "p_ISMTPL_Id" || ')
        ORDER BY ITP."ISMTPL_Id", ITPT."ISMTPLTA_PreviousTask"';
    END IF;

    RETURN;
END;
$$;