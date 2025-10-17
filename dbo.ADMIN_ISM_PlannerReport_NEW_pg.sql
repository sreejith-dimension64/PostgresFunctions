CREATE OR REPLACE FUNCTION "dbo"."ADMIN_ISM_PlannerReport_NEW"(
    "MI_Id" VARCHAR(100),
    "HRME_Id" TEXT,
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP,
    "UserId" VARCHAR(200),
    "PlannerFlag" VARCHAR(100),
    "Role" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
    "betweendates" TEXT;
BEGIN
    "StartDate_N" := TO_CHAR("StartDate"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("EndDate"::DATE, 'YYYY-MM-DD');

    IF "StartDate_N" != '' AND "EndDate_N" != '' THEN
        "betweendates" := '((("ITP"."ISMTPL_StartDate")::DATE)>=''' || "StartDate_N" || ''' AND (("ITP"."ISMTPL_EndDate")::DATE)<=''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
    END IF;

    IF "PlannerFlag" = 'Generated' THEN
        "Slqdymaic" := '
            SELECT DISTINCT "ITP"."ISMTPL_Id", "ITP"."HRME_Id", "ITP"."ISMTPL_PlannerName",
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS plannedby,
            "ISMTPL_StartDate", "ISMTPL_EndDate", "ISMTPL_TotalHrs", "ITP"."CreatedDate", "ISMTPL_ApprovalFlg", "ISMTPL_ApprovedBy", "ISMTPLAP_Remarks",
            (SELECT ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE   
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) FROM "HR_Master_Employee" WHERE "HRME_Id" = "ISMTPL_ApprovedBy") AS approvedby
            FROM "ISM_Task_Planner" "ITP"
            INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
            INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "HME"."HRME_Id" = "UEM"."HRME_Id"
            LEFT JOIN "ISM_Task_Planner_Approved" "APP" ON "ITP"."ISMTPL_Id" = "APP"."ISMTPL_Id"
            WHERE "ITP"."HRME_Id" IN (' || "HRME_Id" || ') AND ' || "betweendates" || ' AND "ITP"."ISMTPL_ActiveFlg" = 1
            ORDER BY plannedby';
        EXECUTE "Slqdymaic";
        
    ELSIF "PlannerFlag" = 'NotGenerated' THEN
        "Slqdymaic" := '
            SELECT DISTINCT "UEM"."HRME_Id", ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
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
            WHERE "ITP"."ISMTPL_ActiveFlg" = 1 AND "ITP"."HRME_Id" IN (' || "HRME_Id" || ') AND ' || "betweendates" || ') AND "ME"."HRME_Id" IN (' || "HRME_Id" || ')
            ORDER BY employeename';
        EXECUTE "Slqdymaic";
    END IF;

    RETURN;
END;
$$;