CREATE OR REPLACE FUNCTION "dbo"."departmentWise_Dev_Report_Employee"(
    "p_Startdate" TIMESTAMP,
    "p_EndDate" TIMESTAMP,
    "p_HRME_Id" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "employeename" TEXT,
    "DevPer" NUMERIC(18,2)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Dynamic" TEXT;
    "v_StartDate_N" VARCHAR(10);
    "v_EndDate_N" VARCHAR(10);
    "v_betweendates" TEXT;
BEGIN

    "v_StartDate_N" := TO_CHAR("p_Startdate"::DATE, 'YYYY-MM-DD');
    "v_EndDate_N" := TO_CHAR("p_EndDate"::DATE, 'YYYY-MM-DD');

    IF "v_StartDate_N" != '' AND "v_EndDate_N" != '' THEN
        "v_betweendates" := '((ITP."ISMTPL_StartDate"::DATE)>=''' || "v_StartDate_N" || ''' AND (ITP."ISMTPL_EndDate"::DATE)<=''' || "v_EndDate_N" || ''')';
    ELSE
        "v_betweendates" := '';
    END IF;

    "v_Dynamic" := 'SELECT DISTINCT "New"."HRME_Id", "New"."employeename", CAST(SUM("New"."Deviation_Percentage")/COUNT("New"."ISMTPL_Id") AS NUMERIC(18,2)) AS "DevPer" FROM
    (SELECT ITP."ISMTPL_Id", "HRC"."HRMDC_Name", "HRC"."HRMDC_ID", ITP."HRME_Id", ITP."ISMTPL_PlannerName",
    ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )) AS "employeename", 
    "ISMTPL_StartDate", "ISMTPL_EndDate",
    (CAST(ITP."ISMTPL_TotalHrs" AS TEXT) || '' '' || ''Hours'') AS "Total_Effort",
    ((CAST(SUM("ITPT"."ISMTPLTA_EffortInHrs") AS TEXT) || '' '' || ''Hours'')) AS "Completed_Effort", 
    ((CAST(ITP."ISMTPL_TotalHrs" - SUM("ITPT"."ISMTPLTA_EffortInHrs") AS TEXT) || '' '' || ''Hours'')) AS "NotCompleted_Effort",
    CAST((SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/NULLIF(ITP."ISMTPL_TotalHrs", 0) AS NUMERIC(18,2)) AS "Completed_Percentage",
    (CASE WHEN CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/NULLIF(ITP."ISMTPL_TotalHrs", 0)) AS NUMERIC(18,2)) > 0 THEN
    CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/NULLIF(ITP."ISMTPL_TotalHrs", 0)) AS NUMERIC(18,2)) ELSE 0 END) AS "Deviation_Percentage"
    FROM "ISM_Task_Planner" ITP 
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = ITP."ISMTPL_Id"
    INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = ITP."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
    INNER JOIN "HR_Master_Department" "HD" ON "HD"."HRMD_Id" = "HME"."HRMD_Id"
    LEFT OUTER JOIN "HR_Master_DepartmentCode" "HRC" ON "HRC"."HRMDC_ID" = "HD"."HRMDC_ID"
    WHERE ' || "v_betweendates" || ' AND ITP."HRME_Id" IN (' || "p_HRME_Id" || ') AND "ITPT"."ISMTPLTA_Status" = ''Completed''
    GROUP BY ITP."ISMTPL_Id", ITP."ISMTPL_TotalHrs", "ISMTPL_PlannerName", "HME"."HRME_EmployeeFirstName", "ISMTPL_StartDate", "ISMTPL_EndDate", ITP."HRME_Id", "HRC"."HRMDC_ID", ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END )), "HRMDC_Name", "HRC"."HRMDC_ID" 
    ORDER BY "HRME_EmployeeFirstName" 
    LIMIT 100) AS "New" 
    GROUP BY "New"."employeename", "New"."HRME_Id"';

    RETURN QUERY EXECUTE "v_Dynamic";

END;
$$;