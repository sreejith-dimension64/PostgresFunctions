CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_TaskDeatils_view2" (
    "MI_Id" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "ISMTPL_Id" VARCHAR(100)
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
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "ISMTPLTA_Remarks" TEXT,
    "MI_Id" BIGINT,
    "plannedby" TEXT,
    "ISMTPLTA_PreviousTask" BIGINT,
    "ISMMTCAT_TaskCategoryName" TEXT,
    "createdby" TEXT,
    "ISMMTCAT_TaskPercentage" NUMERIC,
    "ISMMTCAT_DurationFlg" BOOLEAN,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMMTCAT_EachTaskMaxDuration" NUMERIC,
    "ISMMTCAT_Id" BIGINT,
    "Periodicity" TEXT,
    "PTSCount" BIGINT,
    "eachtaskeff" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN

RETURN QUERY
SELECT DISTINCT 
    "ITPT"."ISMTPL_Id",
    "ITPT"."ISMTPLTA_Id",
    "ITPT"."ISMTCR_Id",
    "TC"."HRMPR_Id",
    "HRP"."HRMP_Name",
    "TC"."ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg",
    "ITPA"."ISMTPLAP_Id",
    (CASE 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
        ELSE 'Others' 
    END) AS "ISMTCR_BugOREnhancement",
    "TC"."ISMTCR_CreationDate",
    "TC"."ISMTCR_Title",
    "TC"."ISMTCR_Desc",
    "TC"."CreatedDate",
    "TC"."ISMTCR_Status",
    "TC"."ISMTCR_ReOpenFlg",
    "TC"."ISMTCR_ReOpenDate",
    "TC"."ISMTCR_TaskNo",
    "ac"."ISMMCLT_Id",
    "CL"."ISMMCLT_ClientName",
    "ITP"."ISMTPL_CreatedBy",
    "ITP"."CreatedDate" AS "plannerDate",
    "ITPT"."ISMTPLTA_Status",
    "ITP"."ISMTPL_PlannedBy",
    "ITP"."ISMTPL_PlannerName",
    "ITP"."ISMTPL_Remarks",
    "ITP"."ISMTPL_StartDate",
    "ITP"."ISMTPL_EndDate",
    "ITP"."ISMTPL_TotalHrs",
    "ITP"."ISMTPL_ApprovalFlg",
    "ITP"."ISMTPL_ApprovedBy",
    "ITP"."ISMTPL_ActiveFlg",
    "ITPT"."ISMTPLTA_ApprovalFlg",
    "ITPT"."ISMTPLTA_StartDate",
    "ITPT"."ISMTPLTA_EndDate",
    "ass"."ISMTCRASTO_StartDate",
    "ass"."ISMTCRASTO_EndDate",
    "ITPT"."ISMTPLTA_EffortInHrs",
    "ITPT"."ISMTPLTA_Remarks",
    "HRE"."MI_Id",
    ((CASE 
        WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
        ELSE "HRE"."HRME_EmployeeFirstName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
    END)) AS "plannedby",
    "ITPT"."ISMTPLTA_PreviousTask",
    "IMT"."ISMMTCAT_TaskCategoryName",
    (SELECT (CASE 
            WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
            ELSE "HRME_EmployeeFirstName" 
        END || CASE 
            WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || "HRME_EmployeeMiddleName" 
        END || CASE 
            WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || "HRME_EmployeeLastName" 
        END) 
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = "TC"."HRME_Id") AS "createdby",
    "GGG"."ISMTPLC_TaskPercentage" AS "ISMMTCAT_TaskPercentage",
    "GGG"."ISMTPLC_DurationFlg" AS "ISMMTCAT_DurationFlg",
    "GGG"."ISMTPLC_CompulsoryFlg" AS "ISMMTCAT_CompulsoryFlg",
    "GGG"."ISMTPLC_EachTaskMaxDuration" AS "ISMMTCAT_EachTaskMaxDuration",
    "TC"."ISMMTCAT_Id",
    "ITAP"."ISMTAPL_Periodicity" AS "Periodicity",
    1::BIGINT AS "PTSCount",
    "ITPT"."ISMTPLTA_EffortInHrs" AS "eachtaskeff"
FROM "ISM_Task_Planner" "ITP"
INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = TRUE
LEFT JOIN "ISM_TaskCreation_AssignedTo" "ass" ON "ass"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "ass"."ISMTCRASTO_ActiveFlg" = TRUE
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
LEFT JOIN "ISM_Master_TaskCategory" AS "IMT" ON "IMT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
LEFT JOIN "ISM_Task_Planner_Category" AS "GGG" ON "GGG"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "GGG"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
LEFT JOIN "ISM_Master_Client" "CL" ON "ac"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
LEFT JOIN "ISM_Task_Planner_Approved" "ITPA" ON "ITPA"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPA"."ISMTPLAP_ActiveFlg" = TRUE
INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
LEFT JOIN "ISM_Task_Advance_Planner" AS "ITAP" ON "ITAP"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ITAP"."ISMTAPL_ActiveFlg" = TRUE
INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
WHERE "ITP"."ISMTPL_ActiveFlg" = TRUE 
    AND "ITPT"."ISMTPL_Id" = "ISMTPL_Id"::BIGINT 
    AND (COALESCE("ITAP"."ISMTAPL_Periodicity", '') != 'Daily' OR "ITAP"."ISMTAPL_Periodicity" IS NULL)

UNION ALL

SELECT DISTINCT 
    "ITPT"."ISMTPL_Id",
    0::BIGINT AS "ISMTPLTA_Id",
    "ITPT"."ISMTCR_Id",
    "TC"."HRMPR_Id",
    "HRP"."HRMP_Name",
    "TC"."ISMTCR_BugOREnhancementFlg" AS "BugOREnhancementFlg",
    "ITPA"."ISMTPLAP_Id",
    (CASE 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
        ELSE 'Others' 
    END) AS "ISMTCR_BugOREnhancement",
    "TC"."ISMTCR_CreationDate",
    "TC"."ISMTCR_Title",
    "TC"."ISMTCR_Desc",
    "TC"."CreatedDate",
    "TC"."ISMTCR_Status",
    "TC"."ISMTCR_ReOpenFlg",
    "TC"."ISMTCR_ReOpenDate",
    "TC"."ISMTCR_TaskNo",
    "ac"."ISMMCLT_Id",
    "CL"."ISMMCLT_ClientName",
    "ITP"."ISMTPL_CreatedBy",
    "ITP"."CreatedDate" AS "plannerDate",
    "ITPT"."ISMTPLTA_Status",
    "ITP"."ISMTPL_PlannedBy",
    "ITP"."ISMTPL_PlannerName",
    "ITP"."ISMTPL_Remarks",
    "ITP"."ISMTPL_StartDate",
    "ITP"."ISMTPL_EndDate",
    "ITP"."ISMTPL_TotalHrs",
    "ITP"."ISMTPL_ApprovalFlg",
    "ITP"."ISMTPL_ApprovedBy",
    "ITP"."ISMTPL_ActiveFlg",
    "ITPT"."ISMTPLTA_ApprovalFlg",
    NULL::TIMESTAMP AS "ISMTPLTA_StartDate",
    NULL::TIMESTAMP AS "ISMTPLTA_EndDate",
    "ass"."ISMTCRASTO_StartDate",
    "ass"."ISMTCRASTO_EndDate",
    SUM("ITPT"."ISMTPLTA_EffortInHrs") AS "ISMTPLTA_EffortInHrs",
    "ITPT"."ISMTPLTA_Remarks",
    "HRE"."MI_Id",
    ((CASE 
        WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
        ELSE "HRE"."HRME_EmployeeFirstName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
    END)) AS "plannedby",
    "ITPT"."ISMTPLTA_PreviousTask",
    "IMT"."ISMMTCAT_TaskCategoryName",
    (SELECT (CASE 
            WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
            ELSE "HRME_EmployeeFirstName" 
        END || CASE 
            WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' 
            ELSE ' ' || "HRME_EmployeeMiddleName" 
        END || CASE 
            WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' 
            ELSE ' ' || "HRME_EmployeeLastName" 
        END) 
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = "TC"."HRME_Id") AS "createdby",
    "GGG"."ISMTPLC_TaskPercentage" AS "ISMMTCAT_TaskPercentage",
    "GGG"."ISMTPLC_DurationFlg" AS "ISMMTCAT_DurationFlg",
    "GGG"."ISMTPLC_CompulsoryFlg" AS "ISMMTCAT_CompulsoryFlg",
    "GGG"."ISMTPLC_EachTaskMaxDuration" AS "ISMMTCAT_EachTaskMaxDuration",
    "TC"."ISMMTCAT_Id",
    "ITAP"."ISMTAPL_Periodicity" AS "Periodicity",
    COUNT("ITPT"."ISMTCR_Id") AS "PTSCount",
    "ITPT"."ISMTPLTA_EffortInHrs" AS "eachtaskeff"
FROM "ISM_Task_Planner" "ITP"
INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = TRUE
LEFT JOIN "ISM_TaskCreation_AssignedTo" "ass" ON "ass"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "ass"."ISMTCRASTO_ActiveFlg" = TRUE
INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
LEFT JOIN "ISM_Master_TaskCategory" AS "IMT" ON "IMT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
LEFT JOIN "ISM_Task_Planner_Category" AS "GGG" ON "GGG"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "GGG"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
LEFT JOIN "ISM_Master_Client" "CL" ON "ac"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
LEFT JOIN "ISM_Task_Planner_Approved" "ITPA" ON "ITPA"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPA"."ISMTPLAP_ActiveFlg" = TRUE
INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
LEFT JOIN "ISM_Task_Advance_Planner" AS "ITAP" ON "ITAP"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ITAP"."ISMTAPL_ActiveFlg" = TRUE
INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
WHERE "ITP"."ISMTPL_ActiveFlg" = TRUE 
    AND "ITPT"."ISMTPL_Id" = "ISMTPL_Id"::BIGINT 
    AND "ITAP"."ISMTAPL_Periodicity" = 'Daily'
GROUP BY 
    "ITPT"."ISMTPL_Id",
    "ITPT"."ISMTCR_Id",
    "TC"."HRMPR_Id",
    "HRP"."HRMP_Name",
    "TC"."ISMTCR_BugOREnhancementFlg",
    "ITPA"."ISMTPLAP_Id",
    (CASE 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
        ELSE 'Others' 
    END),
    "TC"."ISMTCR_CreationDate",
    "TC"."ISMTCR_Title",
    "TC"."ISMTCR_Desc",
    "TC"."CreatedDate",
    "TC"."ISMTCR_Status",
    "TC"."ISMTCR_ReOpenFlg",
    "TC"."ISMTCR_ReOpenDate",
    "TC"."ISMTCR_TaskNo",
    "ac"."ISMMCLT_Id",
    "CL"."ISMMCLT_ClientName",
    "ITP"."ISMTPL_CreatedBy",
    "ITP"."CreatedDate",
    "ITPT"."ISMTPLTA_Status",
    "ITP"."ISMTPL_PlannedBy",
    "ITP"."ISMTPL_PlannerName",
    "ITP"."ISMTPL_Remarks",
    "ITP"."ISMTPL_StartDate",
    "ITP"."ISMTPL_EndDate",
    "ITP"."ISMTPL_TotalHrs",
    "ITP"."ISMTPL_ApprovalFlg",
    "ITP"."ISMTPL_ApprovedBy",
    "ITP"."ISMTPL_ActiveFlg",
    "ITPT"."ISMTPLTA_ApprovalFlg",
    "ass"."ISMTCRASTO_StartDate",
    "ass"."ISMTCRASTO_EndDate",
    "ITPT"."ISMTPLTA_EffortInHrs",
    "ITPT"."ISMTPLTA_Remarks",
    "HRE"."MI_Id",
    ((CASE 
        WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
        ELSE "HRE"."HRME_EmployeeFirstName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
    END || CASE 
        WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
        ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
    END)),
    "ITPT"."ISMTPLTA_PreviousTask",
    "IMT"."ISMMTCAT_TaskCategoryName",
    "GGG"."ISMTPLC_TaskPercentage",
    "GGG"."ISMTPLC_DurationFlg",
    "TC"."HRME_Id",
    "GGG"."ISMTPLC_CompulsoryFlg",
    "GGG"."ISMTPLC_EachTaskMaxDuration",
    "TC"."ISMMTCAT_Id",
    "ITAP"."ISMTAPL_Periodicity"
ORDER BY "ISMTPLTA_PreviousTask", "ISMMTCAT_CompulsoryFlg" DESC;

RETURN;

END;
$$;