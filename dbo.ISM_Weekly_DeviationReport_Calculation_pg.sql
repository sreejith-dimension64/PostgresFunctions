CREATE OR REPLACE FUNCTION "dbo"."ISM_Weekly_DeviationReport_Calculation"(
    p_MI_Id bigint,
    p_HRME_Id text,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP,
    p_Flag text
)
RETURNS TABLE (
    "ISMWD_Id" bigint,
    "ISMTPL_Id" bigint,
    "HRME_Id" bigint,
    "ISMWD_StartDate" TIMESTAMP,
    "ISMWD_EndDate" TIMESTAMP,
    "ISMWD_TotalEffort" text,
    "ISMWD_CompletedEffort" text,
    "ISMWD_Completed" numeric,
    "ISMWD_Deviation" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_betweendates text;
    v_ISMTPL_Id bigint;
    v_HRME_Id bigint;
    v_Rcount bigint;
BEGIN

    v_StartDate_N := TO_CHAR(p_StartDate::DATE, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(p_EndDate::DATE, 'YYYY-MM-DD');

    IF COALESCE(v_StartDate_N, '') != '' AND COALESCE(v_EndDate_N, '') != '' THEN
        v_betweendates := '((CAST("ITP"."ISMTPL_StartDate" AS DATE))>=''' || v_StartDate_N || ''' AND (CAST("ITP"."ISMTPL_EndDate" AS DATE))<=''' || v_EndDate_N || ''')';
    ELSE
        v_betweendates := '';
    END IF;

    IF p_Flag = '1' THEN
        v_Rcount := 0;

        DROP TABLE IF EXISTS "EmpDeviation_Temp";

        v_Slqdymaic := '
        CREATE TEMP TABLE "EmpDeviation_Temp" AS
        SELECT "ITP"."ISMTPL_Id", "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename,
        "ISMTPL_StartDate", "ISMTPL_EndDate",

        (CAST("ITP"."ISMTPL_TotalHrs" as text) || '' '' || ''Hours'') AS "Total_Effort",
        ((CAST(SUM("ITPT"."ISMTPLTA_EffortInHrs") as text) || '' '' || ''Hours'')) AS "Completed_Effort", 
        ((CAST("ITP"."ISMTPL_TotalHrs" - SUM("ITPT"."ISMTPLTA_EffortInHrs") as text) || '' '' || ''Hours'')) AS "NotCompleted_Effort",

        CAST((SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/("ITP"."ISMTPL_TotalHrs") AS DECIMAL(18,2)) AS "Completed_Percentage",
        (case when CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/("ITP"."ISMTPL_TotalHrs")) AS DECIMAL(18,2))>0 then
        CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/("ITP"."ISMTPL_TotalHrs")) AS DECIMAL(18,2)) else 0 end) AS "Deviation_Percentage"

        FROM "ISM_Task_Planner" "ITP"
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id"="ITP"."ISMTPL_Id"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id"="ITPT"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag"=true

        WHERE ' || v_betweendates || ' AND "ITP"."HRME_Id" IN (' || p_HRME_Id || ') and "ITPT"."ISMTPLTA_Status"=''Completed''

        GROUP BY "ITP"."ISMTPL_Id", "ITP"."ISMTPL_TotalHrs", "ISMTPL_PlannerName", "HME"."HRME_EmployeeFirstName", "ISMTPL_StartDate", "ISMTPL_EndDate",
        "ITP"."HRME_Id",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))
        Order By "HRME_EmployeeFirstName"';

        EXECUTE v_Slqdymaic;
    END IF;

    SELECT "ISMTPL_Id", "HRME_Id" INTO v_ISMTPL_Id, v_HRME_Id FROM "EmpDeviation_Temp" LIMIT 1;
    
    SELECT count(*) INTO v_Rcount FROM "ISM_Weekly_Deviation" WHERE "ISMTPL_Id" = v_ISMTPL_Id AND "HRME_Id" = v_HRME_Id;

    IF COALESCE(v_Rcount, 0) = 0 THEN
        INSERT INTO "ISM_Weekly_Deviation"("ISMTPL_Id", "HRME_Id", "ISMWD_StartDate", "ISMWD_EndDate", "ISMWD_TotalEffort", "ISMWD_CompletedEffort", "ISMWD_Completed", "ISMWD_Deviation")
        SELECT "ISMTPL_Id", "HRME_Id", "ISMTPL_StartDate", "ISMTPL_EndDate", "Total_Effort", "Completed_Effort", "Completed_Percentage", "Deviation_Percentage" 
        FROM "EmpDeviation_Temp";
    END IF;

    RETURN QUERY SELECT * FROM "ISM_Weekly_Deviation";

END;
$$;