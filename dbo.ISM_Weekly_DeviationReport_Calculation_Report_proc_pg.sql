CREATE OR REPLACE FUNCTION "dbo"."ISM_Weekly_DeviationReport_Calculation_Report_proc"(
    p_HRME_Id TEXT,
    p_StartDate TIMESTAMP,
    p_EndDate TIMESTAMP,
    p_Flag TEXT
)
RETURNS TABLE(
    employeename TEXT,
    "ISMTPL_PlannerName" TEXT,
    "ISMWD_StartDate" TIMESTAMP,
    "ISMWD_EndDate" TIMESTAMP,
    "ISMWD_TotalEffort" NUMERIC,
    "ISMWD_CompletedEffort" NUMERIC,
    "ISMWD_Completed" NUMERIC,
    "ISMWD_Deviation" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_betweendates TEXT;
BEGIN
    v_StartDate_N := p_StartDate::DATE::TEXT;
    v_EndDate_N := p_EndDate::DATE::TEXT;

    v_betweendates := '((a."ISMWD_StartDate"::DATE)>=''' || v_StartDate_N || ''' AND (a."ISMWD_EndDate"::DATE)<=''' || v_EndDate_N || ''')';

    IF p_Flag = '1' THEN
        IF p_StartDate::DATE = CURRENT_DATE THEN
            v_Slqdymaic := '
            SELECT 
                ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName"='''' THEN '''' ELSE 
                b."HRME_EmployeeFirstName" END || CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '''' 
                OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END ||
                CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '''' 
                OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END)) AS employeename,
                c."ISMTPL_PlannerName" AS "ISMTPL_PlannerName", 
                a."ISMWD_StartDate" AS "ISMWD_StartDate", 
                a."ISMWD_EndDate" AS "ISMWD_EndDate", 
                a."ISMWD_TotalEffort" AS "ISMWD_TotalEffort", 
                a."ISMWD_CompletedEffort" AS "ISMWD_CompletedEffort",
                a."ISMWD_Completed" AS "ISMWD_Completed",
                a."ISMWD_Deviation" AS "ISMWD_Deviation"
            FROM "ISM_Weekly_Deviation" a, "HR_Master_Employee" b, "ISM_Task_Planner" c 
            WHERE a."ISMTPL_Id" = c."ISMTPL_Id" 
                AND a."HRME_Id" = b."HRME_Id" 
                AND a."HRME_Id" IN (' || p_HRME_Id || ')';
        ELSE
            v_Slqdymaic := '
            SELECT 
                ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName"='''' THEN '''' ELSE 
                b."HRME_EmployeeFirstName" END || CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = '''' 
                OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END ||
                CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = '''' 
                OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END)) AS employeename,
                c."ISMTPL_PlannerName" AS "ISMTPL_PlannerName", 
                a."ISMWD_StartDate" AS "ISMWD_StartDate", 
                a."ISMWD_EndDate" AS "ISMWD_EndDate", 
                a."ISMWD_TotalEffort" AS "ISMWD_TotalEffort", 
                a."ISMWD_CompletedEffort" AS "ISMWD_CompletedEffort",
                a."ISMWD_Completed" AS "ISMWD_Completed",
                a."ISMWD_Deviation" AS "ISMWD_Deviation"
            FROM "ISM_Weekly_Deviation" a, "HR_Master_Employee" b, "ISM_Task_Planner" c 
            WHERE ' || v_betweendates || ' 
                AND a."ISMTPL_Id" = c."ISMTPL_Id" 
                AND a."HRME_Id" = b."HRME_Id" 
                AND a."HRME_Id" IN (' || p_HRME_Id || ')';
        END IF;
        
        RETURN QUERY EXECUTE v_Slqdymaic;
    END IF;

    RETURN;
END;
$$;