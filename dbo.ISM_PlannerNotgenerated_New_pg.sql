CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerNotgenerated_New"(
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP,
    "userid" TEXT
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
        "betweendates" := '((CAST("ITP"."ISMTPL_StartDate" AS DATE))>=''' || "StartDate_N" || ''' AND (CAST("ITP"."ISMTPL_EndDate" AS DATE))<=''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
    END IF;

    "Slqdymaic" := 'SELECT DISTINCT "ME"."HRME_Id", ((CASE WHEN "HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename,
         "HRME_EmployeeCode"
        FROM "HR_Master_Employee" "ME" 
        INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "ME"."HRME_Id"="UEM"."HRME_Id" and "ISMUSEMM_ActiveFlag"=1
        Where "HRME_ActiveFlag"=1 AND "HRME_LeftFlag"=0 and "HRME_ExcPunch"=0 and "ISMUSEMM_Order"=1 and "User_Id"=' || "userid" || '
        AND "ME"."HRME_Id" NOT IN (
        SELECT DISTINCT "ITP"."HRME_Id"
        FROM "ISM_Task_Planner" "ITP" 
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id"="ITP"."ISMTPL_Id"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id"="ITPT"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1    
        inner join "ISM_User_Employees_Mapping" "UE" on "UE"."HRME_Id"="ITP"."HRME_Id" and "UE"."ISMUSEMM_ActiveFlag"=1        
        WHERE "ITP"."ISMTPL_ActiveFlg"=1 and "UE"."ISMUSEMM_Order"=1 and "User_Id"=' || "userid" || '   AND ' || "betweendates" || ')         
        Order By employeename';

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;