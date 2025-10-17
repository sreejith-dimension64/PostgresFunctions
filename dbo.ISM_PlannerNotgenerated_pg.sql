CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerNotgenerated"(
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP,
    "HRMDC_ID" TEXT
)
RETURNS TABLE(
    "HRME_Id" INTEGER,
    "employeename" TEXT,
    "HRME_EmployeeCode" TEXT
)
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
        "betweendates" := '((ITP."ISMTPL_StartDate"::DATE)>=''' || "StartDate_N" || ''' AND (ITP."ISMTPL_EndDate"::DATE)<=''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
    END IF;

    "Slqdymaic" := '
        SELECT DISTINCT ME."HRME_Id", 
            ((CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR ME."HRME_EmployeeFirstName"='''' THEN '''' ELSE 
            ME."HRME_EmployeeFirstName" END || 
            CASE WHEN ME."HRME_EmployeeMiddleName" IS NULL OR ME."HRME_EmployeeMiddleName" = '''' 
            OR ME."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
            CASE WHEN ME."HRME_EmployeeLastName" IS NULL OR ME."HRME_EmployeeLastName" = '''' 
            OR ME."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)) AS employeename,
            ME."HRME_EmployeeCode"
        FROM "HR_Master_Employee" ME 
        INNER JOIN "ISM_User_Employees_Mapping" UEM ON ME."HRME_Id"=UEM."HRME_Id" 
        INNER JOIN "HR_Master_Department" HRD ON ME."HRMD_Id"=HRD."HRMD_Id" AND HRD."HRMD_ActiveFlag"=1
        INNER JOIN "HR_Master_DepartmentCode" HRDH ON HRD."HRMDC_ID"=HRDH."HRMDC_ID"
        WHERE ME."HRME_ActiveFlag"=1 AND ME."HRME_LeftFlag"=0 AND HRDH."HRMDC_ID"=' || "HRMDC_ID" || '
        AND ME."HRME_Id" NOT IN (
            SELECT DISTINCT ITP."HRME_Id"
            FROM "ISM_Task_Planner" ITP 
            INNER JOIN "ISM_Task_Planner_Tasks" ITPT ON ITPT."ISMTPL_Id"=ITP."ISMTPL_Id"
            INNER JOIN "ISM_TaskCreation" ITC ON ITC."ISMTCR_Id"=ITPT."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = ITP."HRME_Id" AND HME."HRME_ActiveFlag"=1
            INNER JOIN "HR_Master_Department" HRD ON HME."HRMD_Id"=HRD."HRMD_Id" AND HRD."HRMD_ActiveFlag"=1
            INNER JOIN "HR_Master_DepartmentCode" HRDH ON HRD."HRMDC_ID"=HRDH."HRMDC_ID"
            WHERE ITP."ISMTPL_ActiveFlg"=1 AND HRDH."HRMDC_ID"=' || "HRMDC_ID" || ' AND ' || "betweendates" || ') 		
        ORDER BY employeename';

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;