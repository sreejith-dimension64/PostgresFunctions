CREATE OR REPLACE FUNCTION "dbo"."ISM_DEVIATED_TASKLIST_FOR_EMAIL" (
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "user_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCRASTO_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMTCRASTO_AssignedDate" TIMESTAMP,
    "ISMTCRASTO_Remarks" TEXT,
    "ISMTCRASTO_StartDate" DATE,
    "ISMTCRASTO_EndDate" DATE,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "assignedby" VARCHAR,
    "Periodicity" VARCHAR,
    "ISMTAPL_Day" VARCHAR,
    "OFFDate" VARCHAR,
    "ISMTPLTA_Id" BIGINT,
    "ISMMTCAT_Id" BIGINT,
    "ISMMTCAT_TaskCategoryName" VARCHAR,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMTPLTA_Status" VARCHAR,
    "assignedtoe" VARCHAR,
    "daydiff" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Slqdymaic1" TEXT;
    "dates" VARCHAR(200);
    "enddate" VARCHAR(200);
BEGIN
    "enddate" := CURRENT_TIMESTAMP::TEXT;

    DROP TABLE IF EXISTS "ISM_AssignedByDetailsNEW_Tempwwww";
    DROP TABLE IF EXISTS "ISM_AssignedByDetails1NEW_Tempee";

    "Slqdymaic" := '
    CREATE TEMP TABLE "ISM_AssignedByDetailsNEW_Tempwwww" AS
    SELECT DISTINCT "TCAT"."ISMTCRASTO_Id", "TCAT"."ISMTCR_Id", "TC"."HRMD_Id", "HRD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "HRP"."HRMP_Name", "ISMTCR_BugOREnhancementFlg", "ISMTCR_CreationDate", "ISMTCR_Title", COALESCE("ISMTCR_Desc", '''') AS "ISMTCR_Desc",
    "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TCAT"."ISMTCRASTO_AssignedDate", "ISMTCRASTO_Remarks",
    "ISMTCRASTO_StartDate"::DATE AS "ISMTCRASTO_StartDate", "ISMTCRASTO_EndDate"::DATE AS "ISMTCRASTO_EndDate", "ISMTCRASTO_EffortInHrs",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS "assignedby",
    "ITAP"."ISMTAPL_Periodicity" AS "Periodicity", "ITAP"."ISMTAPL_Day" AS "ISMTAPL_Day", "ITAP"."ISMTAPL_OFFDate" AS "OFFDate", 0 AS "ISMTPLTA_Id", "TC"."ISMMTCAT_Id", "ISMMTCAT_TaskCategoryName", "ISMMTCAT_CompulsoryFlg", "TC"."ISMTCR_Status" AS "ISMTPLTA_Status",
    (SELECT (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END ) FROM "HR_Master_Employee" WHERE "HRME_Id" = ' || $1 || ' ) AS "assignedtoe",
    ("ISMTCRASTO_EndDate"::DATE - ''' || $2 || '''::DATE) AS "daydiff"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
    INNER JOIN "ISM_Master_TaskCategory" "CCT" ON "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" "HRE" ON "TCAT"."ISMTCRASTO_AssignedBy" = "HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
    INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id" = "HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "TCAT"."HRME_Id"
    LEFT JOIN "ISM_Task_Advance_Planner" AS "ITAP" ON "ITAP"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ITAP"."ISMTAPL_ActiveFlg" = TRUE
    WHERE "TCAT"."ISMTCRASTO_ActiveFlg" = TRUE AND "TCAT"."HRME_Id" = ' || $1 || '
    AND "TCAT"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE "ISMTPLTA_ActiveFlg" = TRUE AND 
    "ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_Task_Advance_Planner" WHERE "MI_Id" = ' || $3 || ')) 
    AND (("ISMTCRASTO_EndDate"::DATE < ''' || $2 || '''::DATE) AND "TCAT"."HRME_Id" = ' || $1 || ')
    AND "TC"."ISMTCR_Status" NOT IN (''Completed'', ''Development Completed'', ''Deployement Completed in test link'', ''Deployement Completed in Live link'', ''Close'') 
    AND "TCAT"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" = ' || $1 || ')';

    EXECUTE "Slqdymaic" USING "HRME_Id", "enddate", "MI_Id";

    "Slqdymaic1" := '
    CREATE TEMP TABLE "ISM_AssignedByDetails1NEW_Tempee" AS
    SELECT DISTINCT "TCAT"."ISMTCRASTO_Id", "TCAT"."ISMTCR_Id", "TC"."HRMD_Id", "HRD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "HRP"."HRMP_Name", "ISMTCR_BugOREnhancementFlg", "ISMTCR_CreationDate", "ISMTCR_Title", COALESCE("ISMTCR_Desc", '''') AS "ISMTCR_Desc",
    "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TCAT"."ISMTCRASTO_AssignedDate", "ISMTCRASTO_Remarks", 
    "ISMTPL_StartDate"::DATE AS "ISMTCRASTO_StartDate", "ISMTPLTA_EndDate"::DATE AS "ISMTCRASTO_EndDate", "ISMTCRASTO_EffortInHrs",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS "assignedby",
    '' '' AS "Periodicity", '' '' AS "ISMTAPL_Day", '' '' AS "OFFDate", "ITPT"."ISMTPLTA_Id", "TC"."ISMMTCAT_Id", "ISMMTCAT_TaskCategoryName", "ISMMTCAT_CompulsoryFlg", "ISMTPLTA_Status",
    (SELECT (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
    OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
    OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END ) FROM "HR_Master_Employee" WHERE "HRME_Id" = ' || $1 || ' ) AS "assignedtoe",
    ("ISMTPLTA_EndDate"::DATE - ''' || $2 || '''::DATE) AS "daydiff"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
    INNER JOIN "ISM_Master_TaskCategory" "CCT" ON "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = TRUE
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
    INNER JOIN "ISM_Task_Planner" "ITP" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id"
    INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" "HRE" ON "TCAT"."ISMTCRASTO_AssignedBy" = "HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
    INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id" = "HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "TCAT"."HRME_Id"
    WHERE "TCAT"."ISMTCRASTO_ActiveFlg" = TRUE AND "TCAT"."HRME_Id" = ' || $1 || '
    AND "ITPT"."ISMTPLTA_Status" IN (''Open'', ''open'', ''Inprogress'', ''In progress'', ''In-progress'')
    AND "ITPT"."ISMTPLTA_EndDate"::DATE <= ''' || $2 || '''::DATE 
    AND (("ISMTCRASTO_EndDate"::DATE <= ''' || $2 || '''::DATE))
    AND "TC"."ISMTCR_Status" != ''Completed'' 
    AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" = ' || $1 || ')
    ORDER BY "ISMTCRASTO_AssignedDate"';

    EXECUTE "Slqdymaic1" USING "HRME_Id", "enddate";

    RETURN QUERY
    SELECT * FROM "ISM_AssignedByDetailsNEW_Tempwwww"
    UNION ALL 
    SELECT * FROM "ISM_AssignedByDetails1NEW_Tempee" 
    ORDER BY "daydiff" DESC;

    DROP TABLE IF EXISTS "ISM_AssignedByDetailsNEW_Tempwwww";
    DROP TABLE IF EXISTS "ISM_AssignedByDetails1NEW_Tempee";

END;
$$;