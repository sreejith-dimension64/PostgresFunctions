CREATE OR REPLACE FUNCTION "dbo"."ISM_DeviationReport_Calculation_Chart"(
    "MI_Id" TEXT,
    "HRME_Id" TEXT,
    "Flag" TEXT
)
RETURNS TABLE(
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannerName" TEXT,
    "employeename" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "Total_Effort" TEXT,
    "Completed_Effort" TEXT,
    "NotCompleted_Effort" TEXT,
    "Completed_Percentage" NUMERIC,
    "Deviation_Percentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
    "betweendates" TEXT;
    "StartDate" TIMESTAMP;
    "EndDate" TIMESTAMP;
BEGIN

    SELECT DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '7 days' INTO "StartDate";
    SELECT DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '2 days' INTO "EndDate";

    "StartDate_N" := "StartDate"::DATE::TEXT;
    "EndDate_N" := "EndDate"::DATE::TEXT;

    "betweendates" := '(("ITP"."ISMTPL_StartDate"::DATE)>=''' || "StartDate_N" || ''' AND ("ITP"."ISMTPL_EndDate"::DATE)<=''' || "EndDate_N" || ''')';

    IF "Flag" = '1' THEN
        
        "Slqdymaic" := '
        SELECT "ITP"."ISMTPL_Id", "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename,
        "ISMTPL_StartDate", "ISMTPL_EndDate",
        (CAST("ITP"."ISMTPL_TotalHrs" AS TEXT) || '' '' || ''Hours'') AS "Total_Effort",
        ((CAST(SUM("ITPT"."ISMTPLTA_EffortInHrs") AS TEXT) || '' '' || ''Hours'')) AS "Completed_Effort", 
        ((CAST("ITP"."ISMTPL_TotalHrs" - SUM("ITPT"."ISMTPLTA_EffortInHrs") AS TEXT) || '' '' || ''Hours'')) AS "NotCompleted_Effort",
        ROUND((SUM("ITPT"."ISMTPLTA_EffortInHrs") * 100.0 / NULLIF("ITP"."ISMTPL_TotalHrs", 0))::NUMERIC, 2) AS "Completed_Percentage",
        (CASE WHEN ROUND((100.0 - (SUM("ITPT"."ISMTPLTA_EffortInHrs") * 100.0 / NULLIF("ITP"."ISMTPL_TotalHrs", 0)))::NUMERIC, 2) > 0 THEN
        ROUND((100.0 - (SUM("ITPT"."ISMTPLTA_EffortInHrs") * 100.0 / NULLIF("ITP"."ISMTPL_TotalHrs", 0)))::NUMERIC, 2) ELSE 0 END) AS "Deviation_Percentage"
        FROM "ISM_Task_Planner" "ITP" 
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = TRUE
        WHERE ' || "betweendates" || ' AND "ITP"."HRME_Id" IN (' || "HRME_Id" || ') 
        AND ("ITPT"."ISMTPLTA_Status" = ''Completed'' OR "ITPT"."ISMTPLTA_Status" = ''Development Completed'' 
        OR "ITPT"."ISMTPLTA_Status" = ''Deployement Completed in test link'' 
        OR "ITPT"."ISMTPLTA_Status" = ''Deployement Completed in Live link'' 
        OR "ITPT"."ISMTPLTA_Status" = ''Close'')
        GROUP BY "ITP"."ISMTPL_Id", "ITP"."ISMTPL_TotalHrs", "ISMTPL_PlannerName", "HME"."HRME_EmployeeFirstName", 
        "ISMTPL_StartDate", "ISMTPL_EndDate", "ITP"."HRME_Id", 
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
        ORDER BY "HRME_EmployeeFirstName"';

        RETURN QUERY EXECUTE "Slqdymaic";
        
    END IF;

END;
$$;