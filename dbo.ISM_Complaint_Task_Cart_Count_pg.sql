CREATE OR REPLACE FUNCTION "ISM_Complaint_Task_Cart_Count"(
    "RoleFlg" TEXT,
    "TypeFlg" TEXT,
    "status" TEXT,
    "HRME_Id" TEXT,
    "IVRMM_Id" TEXT,
    "userid" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic1" TEXT;
    "Slqdymaic2" TEXT;
    "Slqdymaic3" TEXT;
    "Slqdymaic" TEXT;
    "Slqdymaic4" TEXT;
    "Slqdymaic5" TEXT;
BEGIN
    DROP TABLE IF EXISTS "StaffAdmin_Temp1";
    DROP TABLE IF EXISTS "StaffAdmin_Temp2";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";
    DROP TABLE IF EXISTS "StaffAdmin_Temp5";

    IF "RoleFlg" = 'Staff' OR "RoleFlg" = 'Admin' OR "RoleFlg" = 'COORDINATOR' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            TO_CHAR("ISMTCR_CreationDate", ''DD-MM-YYYY'') as "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id",(case when (COALESCE("ISMMCLT_ClientName",'''') = '''') then ''NA'' else "ISMMCLT_ClientName" end) "ISMMCLT_ClientName","TC"."HRME_Id",
            (select case when "assi"."HRME_Id" is null then "AU"."UserName" else (CASE WHEN COALESCE("HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END) end FROM "ApplicationUser" "AU" LEFT JOIN "IVRM_Staff_User_Login" "UL" ON "UL".id="AU".id LEFT JOIN "HR_Master_Employee" "assi" ON "UL"."Emp_Code"="assi"."HRME_Id" where ("assi"."HRME_Id"="TC"."HRME_Id" OR "AU".id="TC"."ISMTCR_CreatedBy") LIMIT 1) as createdby,
            CURRENT_TIMESTAMP as todaysdate,(select DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''1 year'' - INTERVAL ''1 day'') AS "endOfYear",
            ''NA'' as assignedby,''Not-Assigned'' as assignedto,
            1 as tasktag,1 as addtoplannerflag,(case when (COALESCE("IVRMM_ModuleName",'''') = '''') then ''NA'' else "IVRMM_ModuleName" end) "IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime,"ISMTAPL_Periodicity","TC"."ISMMTCAT_Id",(select case when count(*)>0 then count(*) else 0 end from "ISM_TaskCreation_Attachment" "TCATT" where "TCATT"."ISMTCR_Id"="TC"."ISMTCR_Id" and "ISMTCRAT_Attatchment" is not NULL) as attachement,TO_CHAR("ISMTAPL_FromDate", ''DD-MM-YYYY'')|| '' To '' ||TO_CHAR("ISMTAPL_ToDate", ''DD-MM-YYYY'') as taskdate,"ISMTAPL_FromDate" as strdate,"ISMTAPL_ToDate" as flttodate,(case when "TC"."ISMIMPPL_Id" is not NULL then ''Yearly Planner :''||"ISMMIMPPL_PlannerName" else NULL end) as yrplan,(select count(*) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") priorityswitch,(select (case when count(*)>0 then ''switch'' else '''' end) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") switch
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Implementation_Planner" "impl" on "TC"."ISMIMPPL_Id"="impl"."ISMMIMPPL_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=true
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            LEFT JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id"="ME"."HRME_Id"
            LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id"="TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag"=true
            LEFT join "IVRM_Module" f on "TC"."IVRMM_Id"=f."IVRMM_Id"
            Left join "ISM_Task_Advance_Planner" "ADV" ON "ADV"."ISMTCR_Id"="TC"."ISMTCR_Id" WHERE "TC"."ISMTCR_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
            AND ('','' || "TC"."ISMTCR_Status" || '','' LIKE ''%,'' || ANY(STRING_TO_ARRAY(''' || "status" || ''','','')) || '',%'')
            AND "TC"."HRME_Id" IN (' || "HRME_Id" || ') order by crdate desc';

            "Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp2" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            TO_CHAR("ISMTCR_CreationDate", ''DD-MM-YYYY'') as "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id",(case when (COALESCE("ISMMCLT_ClientName",'''') = '''') then ''NA'' else "ISMMCLT_ClientName" end) "ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" appuser WHERE appuser."Id"="TC"."ISMTCR_CreatedBy") AS createdby,CURRENT_TIMESTAMP as todaysdate,(select DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''1 year'' - INTERVAL ''1 day'') AS "endOfYear",
            ''NA'' as assignedby,
            ''Not-Assigned'' as assignedto,2 as tasktag,1 as addtoplannerflag,(case when (COALESCE("IVRMM_ModuleName",'''') = '''') then ''NA'' else "IVRMM_ModuleName" end) "IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime,"ISMTAPL_Periodicity","TC"."ISMMTCAT_Id",(select case when count(*)>0 then count(*) else 0 end from "ISM_TaskCreation_Attachment" "TCATT" where "TCATT"."ISMTCR_Id"="TC"."ISMTCR_Id" and "ISMTCRAT_Attatchment" is not NULL) as attachement,TO_CHAR("ISMTAPL_FromDate", ''DD-MM-YYYY'')|| '' To '' ||TO_CHAR("ISMTAPL_ToDate", ''DD-MM-YYYY'') as taskdate,"ISMTAPL_FromDate" as strdate,"ISMTAPL_ToDate" as flttodate,(case when "TC"."ISMIMPPL_Id" is not NULL then ''Yearly Planner :''||"ISMMIMPPL_PlannerName" else NULL end) as yrplan,(select count(*) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") priorityswitch,(select (case when count(*)>0 then ''switch'' else '''' end) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") switch
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id"="TCC"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Implementation_Planner" "impl" on "TC"."ISMIMPPL_Id"="impl"."ISMMIMPPL_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id"="TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" "cl" ON "TCC"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList"="ME"."HRME_Id"
            Left JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            LEFT JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id"="TCC"."ISMTCRCL_CreatedBy"
            INNER JOIN "ApplicationUserRole" "AUR" ON "AUR"."UserId"="AU"."Id"
            INNER JOIN "IVRM_Role_Type" "IRT" ON "IRT"."IVRMRT_Id"="AUR"."RoleTypeId"
            LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id"="TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag"=true
            LEFT join "IVRM_Module" f on "TC"."IVRMM_Id"=f."IVRMM_Id"
            Left join "ISM_Task_Advance_Planner" "ADV" ON "ADV"."ISMTCR_Id"="TC"."ISMTCR_Id" WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TCC"."ISMTCRCL_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
            AND ('','' || "TC"."ISMTCR_Status" || '','' LIKE ''%,'' || ANY(STRING_TO_ARRAY(''' || "status" || ''','','')) || '',%'')
            AND  "CIE"."ISMCIM_IEList" IN  (' || "HRME_Id" || ') AND "IRT"."IVRMRT_RoleFlag"=''ClientUser'' order by crdate desc';

            "Slqdymaic3" := 'CREATE TEMP TABLE "StaffAdmin_Temp3" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            TO_CHAR("ISMTCR_CreationDate", ''DD-MM-YYYY'') as "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id",(case when (COALESCE("ISMMCLT_ClientName",'''') = '''') then ''NA'' else "ISMMCLT_ClientName" end) "ISMMCLT_ClientName","TC"."HRME_Id",
            (select case when "assi"."HRME_Id" is null then "AU"."UserName" else (CASE WHEN COALESCE("HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END) end FROM "ApplicationUser" "AU" LEFT JOIN "IVRM_Staff_User_Login" "UL" ON "UL".id="AU".id LEFT JOIN "HR_Master_Employee" "assi" ON "UL"."Emp_Code"="assi"."HRME_Id" where ("assi"."HRME_Id"="TC"."HRME_Id" OR "AU".id="TC"."ISMTCR_CreatedBy") LIMIT 1) as createdby,
            CURRENT_TIMESTAMP as todaysdate,(select DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''1 year'' - INTERVAL ''1 day'') AS "endOfYear",
            (select ((CASE WHEN COALESCE("ME"."HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END))
            FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id"="TTO"."ISMTCRTRTO_TransferredBy") as assignedby,
            ''Transferred'' as assignedto,3 as tasktag,1 as addtoplannerflag,(case when (COALESCE("IVRMM_ModuleName",'''') = '''') then ''NA'' else "IVRMM_ModuleName" end) "IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime,"ISMTAPL_Periodicity","TC"."ISMMTCAT_Id",(select case when count(*)>0 then count(*) else 0 end from "ISM_TaskCreation_Attachment" "TCATT" where "TCATT"."ISMTCR_Id"="TC"."ISMTCR_Id" and "ISMTCRAT_Attatchment" is not NULL) as attachement,TO_CHAR("ISMTCRTRTO_StartDate", ''DD-MM-YYYY'')|| '' To '' ||TO_CHAR("ISMTCRTRTO_EndDate", ''DD-MM-YYYY'') as taskdate,"ISMTCRTRTO_StartDate" as strdate,"ISMTCRTRTO_EndDate" as flttodate,(case when "TC"."ISMIMPPL_Id" is not NULL then ''Yearly Planner :''||"ISMMIMPPL_PlannerName" else NULL end) as yrplan,(select count(*) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") priorityswitch,(select (case when count(*)>0 then ''switch'' else '''' end) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") switch
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            LEFT JOIN "ISM_Master_Implementation_Planner" "impl" on "TC"."ISMIMPPL_Id"="impl"."ISMMIMPPL_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TTO"."HRME_Id"="ME"."HRME_Id"
            LEFT join "IVRM_Module" f on "TC"."IVRMM_Id"=f."IVRMM_Id"
            LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id"="TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag"=true
            Left join "ISM_Task_Advance_Planner" "ADV" ON "ADV"."ISMTCR_Id"="TC"."ISMTCR_Id" WHERE "TC"."ISMTCR_ActiveFlg"=true
            AND ("TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" Where ("HRME_Id" in (' || "HRME_Id" || ')))
            or "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" Where ("ISMTCRASTO_AssignedBy" in (' || "HRME_Id" || '))))
            AND ('','' || "TC"."ISMTCR_Status" || '','' LIKE ''%,'' || ANY(STRING_TO_ARRAY(''' || "status" || ''','','')) || '',%'')
            AND "TTO"."HRME_Id" IN (' || "HRME_Id" || ') order by crdate desc';

            "Slqdymaic4" := 'CREATE TEMP TABLE "StaffAdmin_Temp4" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            TO_CHAR("ISMTCR_CreationDate", ''DD-MM-YYYY'') as "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id",(case when (COALESCE("ISMMCLT_ClientName",'''') = '''') then ''NA'' else "ISMMCLT_ClientName" end) "ISMMCLT_ClientName","TC"."HRME_Id",
            (select case when "assi"."HRME_Id" is null then "AU"."UserName" else (CASE WHEN COALESCE("HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END) end FROM "ApplicationUser" "AU" LEFT JOIN "IVRM_Staff_User_Login" "UL" ON "UL".id="AU".id LEFT JOIN "HR_Master_Employee" "assi" ON "UL"."Emp_Code"="assi"."HRME_Id" where ("assi"."HRME_Id"="TC"."HRME_Id" OR "AU".id="TC"."ISMTCR_CreatedBy") LIMIT 1) as createdby,
            CURRENT_TIMESTAMP as todaysdate,(select DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''1 year'' - INTERVAL ''1 day'') AS "endOfYear",
            (select ((CASE WHEN COALESCE("ME"."HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END))
            FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") as assignedby,
            ((CASE WHEN COALESCE("ME"."HRME_EmployeeFirstName",'''') = '''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''',''0'') IN ('''',''0'') then '''' ELSE '' '' || "HRME_EmployeeLastName" END)) as assignedto,
            4 as tasktag,0 as addtoplannerflag,(case when (COALESCE("IVRMM_ModuleName",'''') = '''') then ''NA'' else "IVRMM_ModuleName" end) "IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime,"ISMTAPL_Periodicity","TC"."ISMMTCAT_Id",(select case when count(*)>0 then count(*) else 0 end from "ISM_TaskCreation_Attachment" "TCATT" where "TCATT"."ISMTCR_Id"="TC"."ISMTCR_Id" and "ISMTCRAT_Attatchment" is not NULL) as attachement,TO_CHAR("ISMTCRASTO_StartDate", ''DD-MM-YYYY'')|| '' To '' ||TO_CHAR("ISMTCRASTO_EndDate", ''DD-MM-YYYY'') as taskdate,"ISMTCRASTO_StartDate" as strdate,"ISMTCRASTO_EndDate" as flttodate,(case when "TC"."ISMIMPPL_Id" is not NULL then ''Yearly Planner :''||"ISMMIMPPL_PlannerName" else NULL end) as yrplan,(select count(*) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") priorityswitch,(select (case when count(*)>0 then ''switch'' else '''' end) from "ISM_TaskPriorityStatusChanges_Details" where "ISMTCR_Id"="TC"."ISMTCR_Id") switch
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Implementation_Planner" "impl" on "TC"."ISMIMPPL_Id"="impl"."ISMMIMPPL_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=true
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            Left JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_Active