CREATE OR REPLACE FUNCTION "dbo"."ISM_Deviation_Remarkswise_Report_Department" (
    "p_HRME_Id" VARCHAR,
    "p_startDate_N" DATE,
    "p_EndDate_N" DATE
) 
RETURNS TABLE (
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "AssignedBy" TEXT,
    "StartDate" VARCHAR,
    "EndDate" VARCHAR,
    "ISMTPLTA_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "TC"."ISMTCR_TaskNo",
        "TC"."ISMTCR_Title",
        "ITPT"."ISMTPLTA_Status" AS "ISMTCR_Status",
        (CASE 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
            ELSE 'Others' 
        END) AS "ISMTCR_BugOREnhancementFlg",
        (SELECT DISTINCT (
            (CASE 
                WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
                ELSE "HRME_EmployeeFirstName" 
            END ||
            CASE 
                WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeMiddleName" 
            END || 
            CASE 
                WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeLastName" 
            END)
        ) 
        FROM "HR_Master_Employee" "MME" 
        WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", 'DD/MM/YYYY') AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", 'DD/MM/YYYY') AS "EndDate",
        "ITPT"."ISMTPLTA_Id"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTCR_Id" = "TC"."ISMTCR_Id" 
        AND "ITPT"."ISMTPLTA_ApprovalFlg" = 1
    INNER JOIN "ISM_Task_Planner" "ITP" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" 
        AND "ITP"."ISMTPL_ApprovalFlg" = 1
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" 
        AND "cl"."ISMMCLT_ActiveFlag" = 1
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" 
        AND "MP"."HRMP_ActiveFlag" = 1
    INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" 
        AND "HME"."HRME_ActiveFlag" = 1 
        AND "HME"."HRME_LeftFlag" = 0
    WHERE "HME"."HRME_Id"::VARCHAR = "p_HRME_Id"
        AND (CAST("ITP"."ISMTPL_StartDate" AS DATE) >= "p_startDate_N" 
            AND CAST("ITP"."ISMTPL_EndDate" AS DATE) <= "p_EndDate_N")
        AND "ITPT"."ISMTPLTA_Status" != 'Completed' 
        AND "ITPT"."ISMTPLTA_Status" != 'Close' 
        AND "ITPT"."ISMTPLTA_Status" != 'Development Completed';
        
    RETURN;
END;
$$;