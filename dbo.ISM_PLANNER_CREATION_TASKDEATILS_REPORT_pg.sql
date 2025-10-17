CREATE OR REPLACE FUNCTION "dbo"."ISM_PLANNER_CREATION_TASKDEATILS_REPORT" (
    p_HRME_Id VARCHAR(100),
    p_ISMTPL_Id TEXT
)
RETURNS TABLE (
    "ISMTPL_Id" INTEGER,
    "ISMTPLTA_Id" INTEGER,
    "ISMTCR_Id" INTEGER,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "BugOREnhancementFlg" VARCHAR,
    "ISMTPLAP_Id" INTEGER,
    "ISMTCR_BugOREnhancement" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "CreatedDate" TIMESTAMP,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTPL_CreatedBy" INTEGER,
    "plannerDate" TIMESTAMP,
    "ISMTPLTA_Status" VARCHAR,
    "ISMTPL_PlannedBy" INTEGER,
    "ISMTPL_PlannerName" VARCHAR,
    "ISMTPL_Remarks" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "ISMTPL_ApprovalFlg" BOOLEAN,
    "ISMTPL_ApprovedBy" INTEGER,
    "ISMTPL_ActiveFlg" BOOLEAN,
    "ISMTPLTA_ApprovalFlg" BOOLEAN,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMTPLTA_Remarks" TEXT,
    "MI_Id" INTEGER,
    "plannedby" TEXT,
    "ISMTPLTA_PreviousTask" VARCHAR,
    "ISMMTCAT_TaskCategoryName" VARCHAR,
    "ISMTPLC_TaskPercentage" NUMERIC,
    "ISMMTCAT_TaskPercentage" NUMERIC,
    "ISMTPLC_DurationFlg" BOOLEAN,
    "ISMMTCAT_DurationFlg" BOOLEAN,
    "ISMTPLC_CompulsoryFlg" BOOLEAN,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMTPLC_EachTaskMaxDuration" NUMERIC,
    "ISMMTCAT_EachTaskMaxDuration" NUMERIC,
    "ISMMTCAT_Id" INTEGER,
    "HRME_Id" INTEGER,
    "ENAME" TEXT,
    "ISMTPLC_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_RCOUNT INTEGER;
BEGIN

    v_Slqdymaic := 'SELECT DISTINCT "ITPT"."ISMTPL_Id", "ITPT"."ISMTPLTA_Id", "ITPT"."ISMTCR_Id", "TC"."HRMPR_Id", "HRP"."HRMP_Name",
    "ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg", "ITPA"."ISMTPLAP_Id",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancement",
    "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc", "TC"."CreatedDate",
    "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "CL"."ISMMCLT_ClientName", "ISMTPL_CreatedBy", "ITP"."CreatedDate" AS "plannerDate", "ISMTPLTA_Status",
    "ITP"."ISMTPL_PlannedBy", "ISMTPL_PlannerName", "ISMTPL_Remarks", "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPL_TotalHrs", "ISMTPL_ApprovalFlg", "ISMTPL_ApprovedBy", "ISMTPL_ActiveFlg", "ISMTPLTA_ApprovalFlg",
    "ITPT"."ISMTPLTA_StartDate", "ISMTPLTA_EndDate", "ISMTPLTA_EffortInHrs", "ISMTPLTA_Remarks", "HRE"."MI_Id",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS "plannedby", "ISMTPLTA_PreviousTask", "IMT"."ISMMTCAT_TaskCategoryName", "ISMTPLC_TaskPercentage",
    "ISMMTCAT_TaskPercentage", "ISMTPLC_DurationFlg", "ISMMTCAT_DurationFlg",
    "ISMTPLC_CompulsoryFlg", "ISMMTCAT_CompulsoryFlg", "ISMTPLC_EachTaskMaxDuration", "ISMMTCAT_EachTaskMaxDuration",
    "TC"."ISMMTCAT_Id", "HRE"."HRME_Id", COALESCE("HRE"."HRME_EmployeeFirstName", '' '') || '' '' || COALESCE("HRE"."HRME_EmployeeMiddleName", '' '') || '' '' || COALESCE("HRE"."HRME_EmployeeLastName", '' '') AS "ENAME",
    "ISMTPLC_Id"
    FROM "ISM_Task_Planner" "ITP"
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = TRUE
    INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
    INNER JOIN "ISM_Master_TaskCategory" AS "IMT" ON "IMT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
    LEFT JOIN "ISM_Task_Planner_Category" AS "GGG" ON "GGG"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "GGG"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id" 
    LEFT JOIN "ISM_Master_Client" "CL" ON "ac"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_Task_Planner_Approved" "ITPA" ON "ITPA"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPA"."ISMTPLAP_ActiveFlg" = TRUE
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
    INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
    WHERE "ITP"."ISMTPL_ActiveFlg" = TRUE AND "ITPT"."ISMTPL_Id" IN (' || p_ISMTPL_Id || ')
    ORDER BY "ISMTPL_Id", "ISMTPLTA_PreviousTask" DESC';

    RETURN QUERY EXECUTE v_Slqdymaic;

END;
$$;