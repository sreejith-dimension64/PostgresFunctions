CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerReport"(
    "MI_Id" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP,
    "UserId" VARCHAR(200),
    "PlannerFlag" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTPL_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMTPL_PlannerName" VARCHAR,
    "plannedby" TEXT,
    "ISMTPL_StartDate" TIMESTAMP,
    "ISMTPL_EndDate" TIMESTAMP,
    "ISMTPL_TotalHrs" NUMERIC,
    "employeename" TEXT,
    "HRME_EmployeeCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_betweendates TEXT;
BEGIN

    v_StartDate_N := TO_CHAR("StartDate"::DATE, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR("EndDate"::DATE, 'YYYY-MM-DD');

    IF v_StartDate_N != '' AND v_EndDate_N != '' THEN
        v_betweendates := '((CAST("ITP"."ISMTPL_StartDate" AS DATE))>=''' || v_StartDate_N || ''' AND (CAST("ITP"."ISMTPL_EndDate" AS DATE))<=''' || v_EndDate_N || ''')';
    ELSE
        v_betweendates := '';
    END IF;

    IF "PlannerFlag" = 'Generated' THEN
        v_Slqdymaic := '
            SELECT DISTINCT "ITP"."ISMTPL_Id", "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS plannedby,
            "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPL_TotalHrs",
            NULL::TEXT AS employeename, NULL::VARCHAR AS "HRME_EmployeeCode"

            FROM "ISM_Task_Planner" "ITP"
            INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
            INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "HME"."HRME_Id" = "UEM"."HRME_Id"

            WHERE "ITP"."HRME_Id" IN (' || "HRME_Id" || ') AND ' || v_betweendates || ' AND "ITP"."ISMTPL_ActiveFlg" = 1 AND "UEM"."User_Id" = ' || "UserId" || '
            ORDER BY plannedby';
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF "PlannerFlag" = 'NotGenerated' THEN
        v_Slqdymaic := '
            SELECT DISTINCT NULL::BIGINT AS "ISMTPL_Id", "UEM"."HRME_Id", NULL::VARCHAR AS "ISMTPL_PlannerName", NULL::TEXT AS plannedby,
            NULL::TIMESTAMP AS "ISMTPL_StartDate", NULL::TIMESTAMP AS "ISMTPL_EndDate", NULL::NUMERIC AS "ISMTPL_TotalHrs",
            ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename,
            "HRME_EmployeeCode"
            FROM "HR_Master_Employee" "ME"
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "ME"."HRME_Id" = "UEM"."HRME_Id"
            WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
            AND "UEM"."HRME_Id" NOT IN (
            SELECT DISTINCT "ITP"."HRME_Id"
            FROM "ISM_Task_Planner" "ITP"
            INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
            INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
            WHERE "ITP"."ISMTPL_ActiveFlg" = 1 AND "ITP"."HRME_Id" IN (' || "HRME_Id" || ') AND ' || v_betweendates || ') 
            AND "ME"."HRME_Id" IN (' || "HRME_Id" || ') AND "UEM"."User_Id" = ' || "UserId" || '
            ORDER BY employeename';
        
        RETURN QUERY EXECUTE v_Slqdymaic;

    END IF;

    RETURN;

END;
$$;