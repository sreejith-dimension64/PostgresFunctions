CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_Task_Search" (
    "p_TaskNo" VARCHAR(100), 
    "p_HRME_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "crdate" TIMESTAMP,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" INTEGER,
    "createdby" VARCHAR,
    "todaysdate" DATE,
    "endOfYear" DATE,
    "assignedby" VARCHAR,
    "assignedto" VARCHAR,
    "tasktag" INTEGER,
    "addtoplannerflag" INTEGER,
    "IVRMM_ModuleName" VARCHAR,
    "ISMMTCAT_TaskCategoryName" VARCHAR,
    "ISMMTCAT_EachTaskMaxDuration" INTEGER,
    "ISMMTCAT_DurationFlg" VARCHAR,
    "maxtime" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic1" TEXT;
    "v_Slqdymaic2" TEXT;
    "v_Slqdymaic3" TEXT;
    "v_Slqdymaic4" TEXT;
    "v_Slqdymaic5" TEXT;
BEGIN

    DROP TABLE IF EXISTS "StaffAdmin_Temp1231";
    DROP TABLE IF EXISTS "StaffAdmin_Temp1232";
    DROP TABLE IF EXISTS "StaffAdmin_Temp1233";
    DROP TABLE IF EXISTS "StaffAdmin_Temp1234";
    DROP TABLE IF EXISTS "StaffAdmin_Temp1235";
    DROP TABLE IF EXISTS "StaffAdmin_Tempfinal";

    "v_Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1231" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
        ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as "crdate",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "assi" where "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",CURRENT_DATE AS "todaysdate",
    (DATE_TRUNC(''year'', CURRENT_DATE) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    ''NA'' as "assignedby",
    ''Not-Assigned'' as "assignedto",
    1 as "tasktag",1 as "addtoplannerflag","IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as "maxtime"
    FROM "ISM_TaskCreation" "TC"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id"
    INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id" = "ME"."HRME_Id"
    LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
    LEFT join "IVRM_Module" "f" on "TC"."IVRMM_Id" = "f"."IVRMM_Id"
    WHERE "TC"."ISMTCR_ActiveFlg" = true
    AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
    AND "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg" = true)
    AND "TC"."HRME_Id" IN (' || "p_HRME_Id" || ') and "ISMTCR_TaskNo" = ''' || "p_TaskNo" || ''' order by "ISMTCR_CreationDate" desc';

    "v_Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp1232" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
        ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as "crdate",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
    (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS "createdby",
    CURRENT_DATE AS "todaysdate",(DATE_TRUNC(''year'', CURRENT_DATE) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    ''NA'' as "assignedby",
    ''Not-Assigned'' as "assignedto",2 as "tasktag",1 as "addtoplannerflag","IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as "maxtime"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id" = "TCC"."ISMTCR_Id"
    INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id" = "TCC"."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Client" "cl" ON "TCC"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
    INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList" = "ME"."HRME_Id"
    Left JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id"
    INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TCC"."ISMTCRCL_CreatedBy"
    INNER JOIN "ApplicationUserRole" "AUR" ON "AUR"."UserId" = "AU"."Id"
    INNER JOIN "IVRM_Role_Type" "IRT" ON "IRT"."IVRMRT_Id" = "AUR"."RoleTypeId"
    LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
    LEFT join "IVRM_Module" "f" on "TC"."IVRMM_Id" = "f"."IVRMM_Id"
    WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCC"."ISMTCRCL_ActiveFlg" = true
    AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
    AND "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg" = true)
    AND "CIE"."ISMCIM_IEList" IN (' || "p_HRME_Id" || ') and "ISMTCR_TaskNo" = ''' || "p_TaskNo" || ''' AND "IRT"."IVRMRT_RoleFlag" = ''ClientUser'' order by "ISMTCR_CreationDate" desc';

    "v_Slqdymaic3" := 'CREATE TEMP TABLE "StaffAdmin_Temp1233" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
        ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as "crdate",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "assi" where "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
    CURRENT_DATE AS "todaysdate",(DATE_TRUNC(''year'', CURRENT_DATE) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id" = "TTO"."ISMTCRTRTO_TransferredBy") as "assignedby",
    ''Transferred'' as "assignedto",3 as "tasktag",1 as "addtoplannerflag","IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as "maxtime"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id"
    INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Employee" "ME" ON "TTO"."HRME_Id" = "ME"."HRME_Id"
    LEFT join "IVRM_Module" "f" on "TC"."IVRMM_Id" = "f"."IVRMM_Id"
    LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id"
    WHERE "TC"."ISMTCR_ActiveFlg" = true
    AND "TC"."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" Where ("HRME_Id" in (' || "p_HRME_Id" || ')) OR ("ISMTCRASTO_AssignedBy" in (' || "p_HRME_Id" || ')))
    AND "TTO"."HRME_Id" IN (' || "p_HRME_Id" || ') and "ISMTCR_TaskNo" = ''' || "p_TaskNo" || ''' order by "ISMTCR_CreationDate" desc';

    "v_Slqdymaic4" := 'CREATE TEMP TABLE "StaffAdmin_Temp1234" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
        ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as "crdate",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "assi" where "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
    CURRENT_DATE AS "todaysdate",(DATE_TRUNC(''year'', CURRENT_DATE) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") as "assignedby",
    (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = ''''
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) as "assignedto",
    4 as "tasktag",0 as "addtoplannerflag","IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as "maxtime"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
    LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    Left JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id"
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id"
    Left JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Id" = "TC"."ISMTCR_CreatedBy")
    Left Join "ApplicationUser" "AU" ON "f"."Id" = "AU"."Id"
    Left JOIN "ISM_User_Employees_Mapping" "UEM" ON (("UEM"."User_Id" = "f"."Id") OR ("UEM"."User_Id" = "AU"."Id"))
    LEFT join "IVRM_Module" "ivrm" on "TC"."IVRMM_Id" = "ivrm"."IVRMM_Id"
    LEFT JOIN "ISM_Master_TaskCategory" "CCT" On "CCT"."ISMMTCAT_Id" = "TC"."ISMMTCAT_Id" AND "CCT"."ISMMTCAT_ActiveFlag" = true
    WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCAT"."ISMTCRASTO_ActiveFlg" = true
    AND (("TCAT"."HRME_Id" IN (' || "p_HRME_Id" || ')) OR ("TCAT"."ISMTCRASTO_AssignedBy" IN (' || "p_HRME_Id" || '))) and "ISMTCR_TaskNo" = ''' || "p_TaskNo" || ''' order by "ISMTCR_CreationDate" desc';

    "v_Slqdymaic5" := 'CREATE TEMP TABLE "StaffAdmin_Temp1235" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
    (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
        WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
        ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as "crdate",
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "assi" where "assi"."HRME_Id" = "TC"."HRME_Id") as "createdby",
    CURRENT_DATE AS "todaysdate",(DATE_TRUNC(''year'', CURRENT_DATE) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    (select (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") as "assignedby",
    (CASE WHEN "ME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName" = '''' then ''''
        else "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = ''''
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = ''''
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) as "assignedto",
    4 as "tasktag",0 as "addtoplannerflag","IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as "maxtime"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" on "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
    LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    Left JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id"
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id"
    Left JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Id" = "TC"."ISMTCR_CreatedBy")
    Left Join "ApplicationUser" "AU" ON "f"."Id" = "AU"."Id"
    Left JOIN "ISM_User_Employees_Mapping" "U