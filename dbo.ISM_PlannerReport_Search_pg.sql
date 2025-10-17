CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerReport_Search"(
    p_MI_Id TEXT,
    p_HRME_Id TEXT,
    p_ISMTPL_Id TEXT
)
RETURNS TABLE(
    "ISMTCR_TaskNo" VARCHAR,
    "HRMP_Name" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTPLTA_Status" VARCHAR,
    "ISMTPLTA_StartDate" TIMESTAMP,
    "ISMTPLTA_EndDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTPLTA_EffortInHrs" TEXT,
    "ISMMCLT_ClientName" VARCHAR,
    "assignedby" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ITC"."ISMTCR_TaskNo",
        "HMP"."HRMP_Name",
        "ITC"."ISMTCR_Desc",
        "TPT"."ISMTPLTA_Status",
        "TPT"."ISMTPLTA_StartDate",
        "TPT"."ISMTPLTA_EndDate",
        "ITC"."ISMTCR_Title",
        CASE 
            WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
            ELSE 'Enhancement/Others' 
        END AS "ISMTCR_BugOREnhancementFlg",
        CAST("TPT"."ISMTPLTA_EffortInHrs" AS TEXT) || ' Hour' AS "ISMTPLTA_EffortInHrs",
        "CL"."ISMMCLT_ClientName",
        (CASE 
            WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
            ELSE "HRE"."HRME_EmployeeFirstName" 
        END || 
        CASE 
            WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
        END || 
        CASE 
            WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
        END) AS "assignedby"
    FROM "ISM_Task_Planner" "TP"
    INNER JOIN "ISM_Task_Planner_Tasks" "TPT" ON "TP"."ISMTPL_Id" = "TPT"."ISMTPL_Id"
    INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "TPT"."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "TP"."ISMTPL_PlannedBy" 
        AND "HRE"."HRME_ActiveFlag" = 1 
        AND "HRE"."HRME_LeftFlag" = 0
    LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "ITC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" 
        AND "CL"."ISMMCLT_ActiveFlag" = 1
    WHERE "TP"."MI_Id" = p_MI_Id 
        AND "TP"."HRME_Id" = p_HRME_Id 
        AND "TP"."ISMTPL_Id" = p_ISMTPL_Id;
END;
$$;