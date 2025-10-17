CREATE OR REPLACE FUNCTION "dbo"."ISM_Detailed_YearlyPlanner_Report"(
    "StartDate" TEXT,
    "EndDate" TEXT,
    "HRME_Id" TEXT,
    "HRMDES_Id" TEXT,
    "HRMDC_ID" TEXT
)
RETURNS TABLE(
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "EMPLOYEE" TEXT,
    "AssignedBy" TEXT,
    "IVRMM_ModuleName" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "ISMTAPL_FromDate" VARCHAR,
    "ISMTAPL_ToDate" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQL" TEXT;
BEGIN
    "SQL" := 'SELECT "TC"."ISMTCR_TaskNo", "ISMTCR_Title","ISMTCR_Desc","ISMTCR_Status",
(CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement'' ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
(CASE WHEN "EMP"."HRME_EmployeeFirstName" is null or "EMP"."HRME_EmployeeFirstName"='''' then '''' else "EMP"."HRME_EmployeeFirstName" end||
CASE WHEN "EMP"."HRME_EmployeeMiddleName" is null or "EMP"."HRME_EmployeeMiddleName" = '''' or "EMP"."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "EMP"."HRME_EmployeeMiddleName" END || 
CASE WHEN "EMP"."HRME_EmployeeLastName" is null or "EMP"."HRME_EmployeeLastName" = '''' or "EMP"."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "EMP"."HRME_EmployeeLastName" END ) "EMPLOYEE",

(SELECT  ((CASE WHEN "MME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||
CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) 
from "HR_Master_Employee" "MME" where "MME"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy" ) AS "AssignedBy",
"IVRMM_ModuleName" , "HMD"."HRMD_DepartmentName","HMDES"."HRMDES_DesignationName", 
TO_CHAR("ISMTAPL_FromDate",''DD/MM/YYYY'') "ISMTAPL_FromDate" ,TO_CHAR("ISMTAPL_ToDate",''DD/MM/YYYY'') "ISMTAPL_ToDate"

from "ISM_TaskCreation" "TC" INNER JOIN "ISM_Task_Advance_Planner" "TAP" ON "TC"."ISMTCR_Id"="TAP"."ISMTCR_Id"
INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
INNER JOIN "ISM_Task_Advance_Planner_Dates" "TAPD" ON "TAPD"."ISMTAPL_Id"="TAP"."ISMTAPL_Id"
INNER JOIN "HR_MASTER_PRIORITY" "HMP" ON "HMP"."HRMPR_Id"="TC"."HRMPR_Id"
INNER JOIN "HR_Master_Employee" "EMP"  ON "EMP"."HRME_Id"="TCAT"."HRME_Id"
INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id"="EMP"."HRMD_Id"
INNER JOIN "HR_MASTER_DESIGNATION" "HMDES" ON "HMDES"."HRMDES_Id"="EMP"."HRMDES_Id"
LEFT JOIN "IVRM_MODULE" "IMM" ON "IMM"."IVRMM_Id"="TC"."IVRMM_Id"

WHERE "TCAT"."HRME_Id" IN (' || "HRME_Id" || ')  
AND (( "ISMTAPL_FromDate" BETWEEN ''' || "StartDate" || ''' AND ''' || "EndDate" || ''' ) OR ("ISMTAPL_ToDate" BETWEEN ''' || "StartDate" || ''' AND ''' || "EndDate" || ''') )';

    RETURN QUERY EXECUTE "SQL";
    
    RETURN;
END;
$$;