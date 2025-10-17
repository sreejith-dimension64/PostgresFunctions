CREATE OR REPLACE FUNCTION "dbo"."ISM_Planner_MaxDate" (
    "HRME_Id" VARCHAR(500), 
    "roletype" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannedBy" BIGINT,
    "ISMTPL_StartMaxDate" DATE,
    "ISMTPL_EndDate" DATE,
    "ISMTPL_TotalHrs" NUMERIC,
    "planDate" DATE,
    "plannedby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Month_Id" BIGINT;
BEGIN
    SELECT EXTRACT(MONTH FROM CURRENT_TIMESTAMP) INTO "Month_Id";
    
    "Slqdymaic" := '
    SELECT DISTINCT MAX(TP."ISMTPL_Id") AS "ISMTPL_Id", 
        TP."HRME_Id",
        TP."ISMTPL_PlannedBy",
        MAX(CAST(TP."ISMTPL_StartDate" AS DATE)) AS "ISMTPL_StartMaxDate",
        MAX(CAST(TP."ISMTPL_EndDate" AS DATE)) AS "ISMTPL_EndDate",
        MAX(TP."ISMTPL_TotalHrs") AS "ISMTPL_TotalHrs",
        MAX(CAST(TP."CreatedDate" AS DATE)) AS "planDate",
        ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        HRE."HRME_EmployeeFirstName" END || CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
        OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
        OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END )) AS "plannedby"
    FROM "ISM_Task_Planner" TP
    INNER JOIN "ISM_Task_Planner_Tasks" TPT ON TP."ISMTPL_Id" = TPT."ISMTPL_Id" AND TPT."ISMTPLTA_ActiveFlg" = 1
    INNER JOIN "ISM_TaskCreation" TC ON TC."ISMTCR_Id" = TPT."ISMTCR_Id" AND TC."ISMTCR_ActiveFlg" = 1
    INNER JOIN "HR_Master_Employee" HRE ON HRE."HRME_Id" = TP."HRME_Id" AND HRE."HRME_Id" = TP."HRME_Id" AND HRE."HRME_ActiveFlag" = 1 AND HRE."HRME_LeftFlag" = 0
    WHERE TP."ISMTPL_ActiveFlg" = 1 
    AND TP."HRME_Id" IN (' || "HRME_Id" || ') 
    AND ((EXTRACT(MONTH FROM TP."ISMTPL_StartDate") = ' || "Month_Id"::VARCHAR || ') OR (EXTRACT(MONTH FROM TP."ISMTPL_EndDate") = ' || "Month_Id"::VARCHAR || '))
    AND TP."ISMTPL_Id" NOT IN (SELECT DISTINCT "ISMTPL_Id" FROM "ISM_Task_Planner_Approved" WHERE "ISMTPLAP_ActiveFlg" = 1) 
    GROUP BY
    TP."HRME_Id",
    TP."ISMTPL_PlannedBy",
    ((CASE WHEN HRE."HRME_EmployeeFirstName" IS NULL OR HRE."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
    HRE."HRME_EmployeeFirstName" END || CASE WHEN HRE."HRME_EmployeeMiddleName" IS NULL OR HRE."HRME_EmployeeMiddleName" = '''' 
    OR HRE."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeMiddleName" END || CASE WHEN HRE."HRME_EmployeeLastName" IS NULL OR HRE."HRME_EmployeeLastName" = '''' 
    OR HRE."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || HRE."HRME_EmployeeLastName" END ))
    ';
    
    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;