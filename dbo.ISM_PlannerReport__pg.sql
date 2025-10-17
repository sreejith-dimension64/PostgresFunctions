CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerReport_"(
    "@MI_Id" VARCHAR,
    "@HRME_Id" VARCHAR,
    "@StartDate" TIMESTAMP,
    "@EndDate" TIMESTAMP,
    "@Flag" VARCHAR
)
RETURNS TABLE (
    "ISMTPL_Id" INTEGER,
    "HRME_Id" INTEGER,
    "ISMTPL_PlannerName" VARCHAR,
    "employeename" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "Total_Effort" TEXT,
    "Completed_Effort" TEXT,
    "NotCompleted_Effort" TEXT,
    "Completed_Percentage" DECIMAL(18,2),
    "Deviation_Percentage" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_StartDate_N" VARCHAR(10);
    "v_EndDate_N" VARCHAR(10);
    "v_betweendates" TEXT;
BEGIN

    "v_StartDate_N" := TO_CHAR("@StartDate"::DATE, 'YYYY-MM-DD');
    "v_EndDate_N" := TO_CHAR("@EndDate"::DATE, 'YYYY-MM-DD');

    IF COALESCE("v_StartDate_N", '') != '' AND COALESCE("v_EndDate_N", '') != '' THEN
        "v_betweendates" := '((CAST("ITP"."ISMTPL_StartDate" AS DATE))>=''' || "v_StartDate_N" || ''' AND (CAST("ITP"."ISMTPL_EndDate" AS DATE))<=''' || "v_EndDate_N" || ''')';
    ELSE
        "v_betweendates" := '';
    END IF;

    IF "@Flag" = '1' THEN
        "v_Slqdymaic" := '
SELECT "ITP"."ISMTPL_Id", "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
"HME"."HRME_EmployeeFirstName" END || CASE WHEN "HME"."HRME_EmployeeMiddleName" IS NULL OR "HME"."HRME_EmployeeMiddleName" = '''' 
OR "HME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
CASE WHEN "HME"."HRME_EmployeeLastName" IS NULL OR "HME"."HRME_EmployeeLastName" = '''' 
OR "HME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END)) AS employeename,
"ITP"."ISMTPL_StartDate", "ITP"."ISMTPL_EndDate",
(CAST("ITP"."ISMTPL_TotalHrs" AS VARCHAR) || '' '' || ''Hours'') AS "Total_Effort",
((CAST(SUM("ITPT"."ISMTPLTA_EffortInHrs") AS VARCHAR) || '' '' || ''Hours'')) AS "Completed_Effort",
((CAST("ITP"."ISMTPL_TotalHrs" - SUM("ITPT"."ISMTPLTA_EffortInHrs") AS VARCHAR) || '' '' || ''Hours'')) AS "NotCompleted_Effort",
CAST((SUM("ITPT"."ISMTPLTA_EffortInHrs")) * 100 / ("ITP"."ISMTPL_TotalHrs") AS DECIMAL(18,2)) AS "Completed_Percentage",
(CASE WHEN CAST((100 - (SUM("ITPT"."ISMTPLTA_EffortInHrs")) * 100 / ("ITP"."ISMTPL_TotalHrs")) AS DECIMAL(18,2)) > 0 THEN
CAST((100 - (SUM("ITPT"."ISMTPLTA_EffortInHrs")) * 100 / ("ITP"."ISMTPL_TotalHrs")) AS DECIMAL(18,2)) ELSE 0 END) AS "Deviation_Percentage"
FROM "dbo"."ISM_Task_Planner" "ITP"
INNER JOIN "dbo"."ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
INNER JOIN "dbo"."ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
INNER JOIN "dbo"."HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
WHERE ' || "v_betweendates" || ' AND "ITP"."HRME_Id" IN (' || "@HRME_Id" || ') AND "ITPT"."ISMTPLTA_Status" = ''Completed''
GROUP BY "ITP"."ISMTPL_Id", "ITP"."ISMTPL_TotalHrs", "ITP"."ISMTPL_PlannerName", "HME"."HRME_EmployeeFirstName", 
"ITP"."ISMTPL_StartDate", "ITP"."ISMTPL_EndDate", "ITP"."HRME_Id",
((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
"HME"."HRME_EmployeeFirstName" END || CASE WHEN "HME"."HRME_EmployeeMiddleName" IS NULL OR "HME"."HRME_EmployeeMiddleName" = '''' 
OR "HME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HME"."HRME_EmployeeMiddleName" END ||
CASE WHEN "HME"."HRME_EmployeeLastName" IS NULL OR "HME"."HRME_EmployeeLastName" = '''' 
OR "HME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HME"."HRME_EmployeeLastName" END))
ORDER BY "HME"."HRME_EmployeeFirstName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";
    END IF;

    RETURN;
END;
$$;