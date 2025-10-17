CREATE OR REPLACE FUNCTION "dbo"."ISM_ASSIGNED_TASKLIST_WITH_ADVPLANNER"(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "user_Id" VARCHAR(100)
)
RETURNS TABLE(
    "ISMTCRASTO_Id" BIGINT,
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" TEXT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" TEXT,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "ISMTCRASTO_AssignedDate" TIMESTAMP,
    "ISMTCRASTO_Remarks" TEXT,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "assignedby" TEXT,
    "Periodicity" TEXT,
    "ISMTAPL_Day" TEXT,
    "OFFDate" TEXT,
    "ISMTPLTA_Id" BIGINT,
    "ISMMTCAT_Id" BIGINT,
    "ISMMTCAT_TaskCategoryName" TEXT,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMTPLTA_Status" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Slqdymaic1" TEXT;
    "dates" VARCHAR(200);
BEGIN

    DROP TABLE IF EXISTS "ISM_AssignedByDetailsNEW_Temp";
    DROP TABLE IF EXISTS "ISM_AssignedByDetails1NEW_Temp";

    "Slqdymaic" := '
    CREATE TEMP TABLE "ISM_AssignedByDetailsNEW_Temp" AS
    SELECT DISTINCT "TCAT"."ISMTCRASTO_Id", "TCAT"."ISMTCR_Id","TC"."HRMD_Id","HRD"."HRMD_DepartmentName","TC"."HRMPR_Id","HRP"."HRMP_Name","ISMTCR_BugOREnhancementFlg","ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TCAT"."ISMTCRASTO_AssignedDate","ISMTCRASTO_Remarks",
    "ISMTCRASTO_StartDate","ISMTCRASTO_EndDate","ISMTCRASTO_EffortInHrs",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
    "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
    or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
    or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as assignedby 
    ,"ITAP"."ISMTAPL_Periodicity" AS "Periodicity" ,"ITAP"."ISMTAPL_Day" AS "ISMTAPL_Day","ITAP"."ISMTAPL_OFFDate" AS "OFFDate",0::BIGINT as "ISMTPLTA_Id","TC"."ISMMTCAT_Id","ISMMTCAT_TaskCategoryName","ISMMTCAT_CompulsoryFlg",'''' as "ISMTPLTA_Status"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg"=true
    INNER JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id"="TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag"=true
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=true
    INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id"="HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" "HRE" ON "TCAT"."ISMTCRASTO_AssignedBy"="HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag"=true AND "HRE"."HRME_LeftFlag"=false
    INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id"="HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag"=true
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code"="TCAT"."HRME_Id"
    LEFT JOIN "ISM_Task_Advance_Planner" AS "ITAP" ON "ITAP"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ITAP"."ISMTAPL_ActiveFlg"=true
    WHERE "TCAT"."ISMTCRASTO_ActiveFlg"=true AND "TCAT"."HRME_Id" = ' || "HRME_Id"::TEXT || '
    AND "TCAT"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_Task_Planner_Tasks" Where "ISMTPLTA_ActiveFlg"=true and 
    "ISMTCR_Id" not in(select distinct "ISMTCR_Id" from "ISM_Task_Advance_Planner" where "MI_Id"=' || "MI_Id"::TEXT || ')) and ((CAST("ISMTCRASTO_EndDate" AS DATE)<=''' || "enddate" || ''') OR ''' || "enddate" || ''' BETWEEN "TCAT"."ISMTCRASTO_StartDate" AND CAST("ISMTCRASTO_EndDate" AS DATE) and "TCAT"."HRME_Id"=' || "HRME_Id"::TEXT || ')
    and "TC"."ISMTCR_Status" not in (''Completed'',''Development Completed'',''Deployement Completed in test link'',''Deployement Completed in Live link'',''Close'') and "TCAT"."ISMTCR_Id" not in (select distinct "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo"  where "ISMTCRTRTO_TransferredBy"= ' || "HRME_Id"::TEXT || ')';

    EXECUTE "Slqdymaic";

    "Slqdymaic1" := '
    CREATE TEMP TABLE "ISM_AssignedByDetails1NEW_Temp" AS
    SELECT DISTINCT "TCAT"."ISMTCRASTO_Id", "TCAT"."ISMTCR_Id","TC"."HRMD_Id","HRD"."HRMD_DepartmentName","TC"."HRMPR_Id","HRP"."HRMP_Name","ISMTCR_BugOREnhancementFlg","ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TCAT"."ISMTCRASTO_AssignedDate","ISMTCRASTO_Remarks","ISMTPL_StartDate" as
    "ISMTCRASTO_StartDate","ISMTPLTA_EndDate" as "ISMTCRASTO_EndDate","ISMTCRASTO_EffortInHrs",
    ((CASE WHEN "HRE"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
    "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
    or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
    or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as assignedby 
    ,"ITAP"."ISMTAPL_Periodicity" AS "Periodicity" ,"ITAP"."ISMTAPL_Day" AS "ISMTAPL_Day","ITAP"."ISMTAPL_OFFDate" AS "OFFDate","ITPT"."ISMTPLTA_Id" ,"TC"."ISMMTCAT_Id","ISMMTCAT_TaskCategoryName","ISMMTCAT_CompulsoryFlg","ITPT"."ISMTPLTA_Status" as "ISMTPLTA_Status"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg"=true
    INNER JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id"="TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag"=true
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=true
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
    INNER JOIN "ISM_Task_Planner" "ITP" ON "ITP"."ISMTPL_Id"="ITPT"."ISMTPL_Id"
    INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id"="HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" "HRE" ON "TCAT"."ISMTCRASTO_AssignedBy"="HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag"=true AND "HRE"."HRME_LeftFlag"=false
    INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id"="HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag"=true
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code"="TCAT"."HRME_Id"
    LEFT JOIN "ISM_Task_Advance_Planner" AS "ITAP" ON "ITAP"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ITAP"."ISMTAPL_ActiveFlg"=true
    WHERE "TCAT"."ISMTCRASTO_ActiveFlg"=true AND "TCAT"."HRME_Id" =' || "HRME_Id"::TEXT || '
    AND "ITPT"."ISMTPLTA_Status" IN (''Open'',''open'',''Inprogress'',''In progress'',''In-progress'')
    AND CAST("ITP"."ISMTPL_StartDate" AS DATE)<=''' || "enddate" || ''' and ((CAST("ISMTCRASTO_EndDate" AS DATE)<=''' || "enddate" || ''') or ''' || "enddate" || ''' BETWEEN "TCAT"."ISMTCRASTO_StartDate" AND CAST("ISMTCRASTO_EndDate" AS DATE))
    and "TC"."ISMTCR_Status"!=''Completed''  and "TC"."ISMTCR_Id" not in (select distinct "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo"  where "ISMTCRTRTO_TransferredBy"= ' || "HRME_Id"::TEXT || ')  Order BY "ISMTCRASTO_AssignedDate"';

    EXECUTE "Slqdymaic1";

    RETURN QUERY
    SELECT * FROM "ISM_AssignedByDetailsNEW_Temp"
    UNION ALL 
    SELECT * FROM "ISM_AssignedByDetails1NEW_Temp" 
    ORDER BY "ISMTPLTA_Id";

END;
$$;