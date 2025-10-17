CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_Generation_Search"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT,
    "@Date" TEXT,
    "@Flag" BIGINT
)
RETURNS TABLE (
    "ISMTCR_TaskNo" VARCHAR,
    "HRMP_Name" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMDRPT_Status" VARCHAR,
    "ISMDRPT_Date" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMDRPT_TimeTakenInHrs" TEXT,
    "ISMMCLT_ClientName" VARCHAR,
    "assignedby" TEXT,
    "ISMTCR_Id" BIGINT,
    "HRMPR_Id" BIGINT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMMCLT_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@Flag" = 1 THEN
        RETURN QUERY
        SELECT 
            "ITC"."ISMTCR_TaskNo",
            "HMP"."HRMP_Name",
            "ITC"."ISMTCR_Desc",
            "DR"."ISMDRPT_Status",
            "DR"."ISMDRPT_Date",
            CASE 
                WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'::TEXT 
                ELSE 'Enhancement/Others'::TEXT 
            END AS "ISMTCR_BugOREnhancementFlg",
            CAST("DR"."ISMDRPT_TimeTakenInHrs" AS TEXT) || ' Hour' AS "ISMDRPT_TimeTakenInHrs",
            "CL"."ISMMCLT_ClientName",
            ((CASE 
                WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
                ELSE "HRE"."HRME_EmployeeFirstName" 
            END || CASE 
                WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
            END || CASE 
                WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
            END))::TEXT AS "assignedby",
            NULL::BIGINT AS "ISMTCR_Id",
            NULL::BIGINT AS "HRMPR_Id",
            NULL::TIMESTAMP AS "ISMTCR_CreationDate",
            NULL::VARCHAR AS "ISMTCR_Title",
            NULL::BOOLEAN AS "ISMTCR_ReOpenFlg",
            NULL::TIMESTAMP AS "ISMTCR_ReOpenDate",
            NULL::BIGINT AS "ISMMCLT_Id"
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "ITC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = 1
        WHERE "DR"."MI_Id" = "@MI_Id" AND "DR"."HRME_Id" = "@HRME_Id" AND "DR"."ISMDRPT_Date" = "@Date";

    ELSIF "@Flag" = 2 THEN
        RETURN QUERY
        SELECT DISTINCT
            "TC"."ISMTCR_TaskNo",
            "HRP"."HRMP_Name",
            "TC"."ISMTCR_Desc",
            "TC"."ISMTCR_Status" AS "ISMDRPT_Status",
            NULL::VARCHAR AS "ISMDRPT_Date",
            "TC"."ISMTCR_BugOREnhancementFlg"::TEXT,
            NULL::TEXT AS "ISMDRPT_TimeTakenInHrs",
            "CL"."ISMMCLT_ClientName",
            ((CASE 
                WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
                ELSE "HRE"."HRME_EmployeeFirstName" 
            END || CASE 
                WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" 
            END || CASE 
                WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || "HRE"."HRME_EmployeeLastName" 
            END))::TEXT AS "assignedby",
            "TC"."ISMTCR_Id",
            "TC"."HRMPR_Id",
            "TC"."ISMTCR_CreationDate",
            "TC"."ISMTCR_Title",
            "TC"."ISMTCR_ReOpenFlg",
            "TC"."ISMTCR_ReOpenDate",
            "ac"."ISMMCLT_Id"
        FROM "ISM_TaskCreation" "TC"
        LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = 1
        INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = 1
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRE"."HRME_Id" = "TC"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = 1 AND "HRE"."HRME_LeftFlag" = 0
        INNER JOIN "HR_Master_Priority" "HRP" ON "HRP"."HRMPR_Id" = "TC"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = 1 AND "TC"."ISMTCR_Status" != 'Closed' AND "TC"."ISMTCR_Status" != 'Completed'
        WHERE "TC"."MI_Id" = "@MI_Id" AND "TC"."HRME_Id" = "@HRME_Id" 
        AND "TC"."ISMTCR_Id" NOT IN (
            SELECT "ISMTCR_Id" 
            FROM "ISM_TaskCreation_AssignedTo" 
            WHERE "ISMTCRASTO_ActiveFlg" = 1
        )
        AND "TC"."ISMTCR_Id" NOT IN (
            SELECT "ISMTCR_Id" 
            FROM "ISM_Task_Planner" "ITP"
            INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id" AND "ITPT"."ISMTPLTA_ActiveFlg" = 1 AND "ITPT"."ISMTPLTA_Status" != 'Completed'
        );

    END IF;
END;
$$;