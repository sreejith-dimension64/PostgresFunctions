CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_Task_Report"(
    "StartDate" VARCHAR(10),
    "EndDate" VARCHAR(10),
    "HRME_Id" TEXT,
    "HRMDES_Id" TEXT,
    "HRMDC_ID" TEXT,
    "Module_Id" TEXT,
    "Client_Id" TEXT,
    "Status_Id" TEXT
)
RETURNS TABLE(
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "crdate" TIMESTAMP,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" BIGINT,
    "createdby" TEXT,
    "todaysdate" TIMESTAMP,
    "endOfYear" TIMESTAMP,
    "assignedby" TEXT,
    "assignedto" TEXT,
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
    "Slqdymaic1" TEXT;
    "Slqdymaic2" TEXT;
    "Slqdymaic3" TEXT;
    "Slqdymaic" TEXT;
    "Slqdymaic4" TEXT;
    "Slqdymaic5" TEXT;
BEGIN

    DROP TABLE IF EXISTS "CompliantAdmin_Temp1";
    DROP TABLE IF EXISTS "CompliantAdmin_Temp2";
    DROP TABLE IF EXISTS "CompliantAdmin_Temp3";
    DROP TABLE IF EXISTS "CompliantAdmin_Temp4";
    DROP TABLE IF EXISTS "CompliantAdmin_Temp5";

    "Slqdymaic1" := 'CREATE TEMP TABLE "CompliantAdmin_Temp1" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
    ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi where assi."HRME_Id"=TC."HRME_Id") as createdby,
    NOW() as todaysdate,
    (DATE_TRUNC(''year'', NOW()) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::TIMESTAMP AS endOfYear,
    ''NA''::TEXT as assignedby,
    ''Not-Assigned''::TEXT as assignedto,
    1 as tasktag,1 as addtoplannerflag,"IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime
    FROM "ISM_TaskCreation" TC
    LEFT JOIN "ISM_TaskCreation_Client" ac on TC."ISMTCR_Id"=ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
    LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id"=TC."ISMTCR_Id"
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id"=TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id"=TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id"=MP."HRMPR_Id" AND MP."HRMP_ActiveFlag"=true
    INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id"=MD."HRMD_Id" AND MD."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" ME ON TC."HRME_Id"=ME."HRME_Id" AND ME."HRME_ActiveFlag"=true AND ME."HRME_LeftFlag"=false
    LEFT join "IVRM_Module" f on TC."IVRMM_Id"=f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT On CCT."ISMMTCAT_Id"=TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag"=true
    WHERE TC."ISMTCR_ActiveFlg"=true
    AND TC."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
    AND TC."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
    AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "Status_Id" || ''' || '','') > 0
    AND TC."HRME_Id" IN (' || "HRME_Id" || ') order by "ISMTCR_CreationDate" desc';

    "Slqdymaic2" := 'CREATE TEMP TABLE "CompliantAdmin_Temp2" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
    ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",TCC."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    (SELECT "NormalizedUserName" FROM "ApplicationUser" appuser WHERE appuser."Id"=TC."ISMTCR_CreatedBy") AS createdby,
    NOW() as todaysdate,
    (DATE_TRUNC(''year'', NOW()) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::TIMESTAMP AS endOfYear,
    ''NA''::TEXT as assignedby,
    ''Not-Assigned''::TEXT as assignedto,
    2 as tasktag,1 as addtoplannerflag,"IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_Client" TCC ON TC."ISMTCR_Id"=TCC."ISMTCR_Id"
    INNER JOIN "ISM_Master_Client_IEMapping" CIE ON CIE."ISMMCLT_Id"=TCC."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Client" cl ON TCC."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" ME ON CIE."ISMCIM_IEList"=ME."HRME_Id" AND ME."HRME_ActiveFlag"=true
    Left JOIN "HR_Master_Department" MD ON TC."HRMD_Id"=MD."HRMD_Id" AND MD."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id"=MP."HRMPR_Id" AND MP."HRMP_ActiveFlag"=true
    INNER JOIN "ApplicationUser" AU ON AU."Id"=TCC."ISMTCRCL_CreatedBy"
    INNER JOIN "ApplicationUserRole" AUR ON AUR."UserId"=AU."Id"
    INNER JOIN "IVRM_Role_Type" IRT ON IRT."IVRMRT_Id"=AUR."RoleTypeId"
    LEFT join "IVRM_Module" f on TC."IVRMM_Id"=f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT On CCT."ISMMTCAT_Id"=TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag"=true
    WHERE TC."ISMTCR_ActiveFlg"=true AND TCC."ISMTCRCL_ActiveFlg"=true
    AND TC."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
    AND TC."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
    AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "Status_Id" || ''' || '','') > 0
    AND CIE."ISMCIM_IEList" IN (' || "HRME_Id" || ') AND IRT."IVRMRT_RoleFlag"=''ClientUser'' order by "ISMTCR_CreationDate" desc';

    "Slqdymaic3" := 'CREATE TEMP TABLE "CompliantAdmin_Temp3" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
    ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi where assi."HRME_Id"=TC."HRME_Id") as createdby,
    NOW() as todaysdate,
    (DATE_TRUNC(''year'', NOW()) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::TIMESTAMP AS endOfYear,
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP where HMEP."HRME_Id"=TTO."ISMTCRTRTO_TransferredBy") as assignedby,
    ''Transferred''::TEXT as assignedto,
    3 as tasktag,1 as addtoplannerflag,"IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id"=TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
    LEFT JOIN "ISM_TaskCreation_Client" ac on TC."ISMTCR_Id"=ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id"=TC."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id"=MP."HRMPR_Id" AND MP."HRMP_ActiveFlag"=true
    INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id"=MD."HRMD_Id" AND MD."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" ME ON TTO."HRME_Id"=ME."HRME_Id" AND ME."HRME_ActiveFlag"=true AND ME."HRME_LeftFlag"=false
    LEFT join "IVRM_Module" f on TC."IVRMM_Id"=f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT On CCT."ISMMTCAT_Id"=TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag"=true
    WHERE TC."ISMTCR_ActiveFlg"=true
    AND TC."ISMTCR_Id" Not IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" Where ("HRME_Id" in (' || "HRME_Id" || ')) OR ("ISMTCRASTO_AssignedBy" in (' || "HRME_Id" || ')))
    AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "Status_Id" || ''' || '','') > 0
    AND TTO."HRME_Id" IN (' || "HRME_Id" || ') order by "ISMTCR_CreationDate" desc';

    "Slqdymaic4" := 'CREATE TEMP TABLE "CompliantAdmin_Temp4" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
    ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi where assi."HRME_Id"=TC."HRME_Id") as createdby,
    NOW() as todaysdate,
    (DATE_TRUNC(''year'', NOW()) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::TIMESTAMP AS endOfYear,
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP where HMEP."HRME_Id"=TCAT."ISMTCRASTO_AssignedBy") as assignedby,
    (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END) as assignedto,
    4 as tasktag,0 as addtoplannerflag,"IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id"=TC."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" ac on TC."ISMTCR_Id"=ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id"=TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" PTTO ON PTTO."ISMTCR_Id"=TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
    Left JOIN "HR_Master_Department" MD ON TC."HRMD_Id"=MD."HRMD_Id" AND MD."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id"=ME."HRME_Id" AND ME."HRME_ActiveFlag"=true AND ME."HRME_LeftFlag"=false
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id"=MP."HRMPR_Id" AND MP."HRMP_ActiveFlag"=true
    Left JOIN "IVRM_Staff_User_Login" f ON (f."Id"=TC."ISMTCR_CreatedBy")
    Left Join "ApplicationUser" AU ON f."Id"=AU."Id"
    Left JOIN "ISM_User_Employees_Mapping" UEM ON ((UEM."User_Id"=f."Id") OR (UEM."User_Id"=AU."Id"))
    LEFT join "IVRM_Module" ivrm on TC."IVRMM_Id"=ivrm."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT On CCT."ISMMTCAT_Id"=TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag"=true
    WHERE TC."ISMTCR_ActiveFlg"=true AND TCAT."ISMTCRASTO_ActiveFlg"=true
    AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "Status_Id" || ''' || '','') > 0
    AND ((TCAT."HRME_Id" IN (' || "HRME_Id" || ')) OR (TCAT."ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || '))) order by "ISMTCR_CreationDate" desc';

    "Slqdymaic5" := 'CREATE TEMP TABLE "CompliantAdmin_Temp5" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' then ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' then ''Enhancement''
    ELSE ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_CreationDate" as crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi where assi."HRME_Id"=TC."HRME_Id") as createdby,
    NOW() as todaysdate,
    (DATE_TRUNC(''year'', NOW()) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::TIMESTAMP AS endOfYear,
    (select (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP where HMEP."HRME_Id"=TCAT."ISMTCRASTO_AssignedBy") as assignedby,
    (COALESCE(ME."HRME_EmployeeFirstName",'''') ||
    CASE WHEN COALESCE(ME."HRME_EmployeeMiddleName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END ||
    CASE WHEN COALESCE(ME."HRME_EmployeeLastName",''0'') IN ('''',''0'') THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END) as assignedto,
    4 as tasktag,0 as addtoplannerflag,"IVRMM_ModuleName","ISMMTCAT_TaskCategoryName","ISMMTCAT_EachTaskMaxDuration","ISMMTCAT_DurationFlg","ISMMTCAT_EachTaskMaxDuration" as maxtime
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id"=TC."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" ac on TC."ISMTCR_Id"=ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id"=TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" PTTO ON PTTO."ISMTCR_Id"=TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
    Left JOIN "HR_Master_Department" MD ON TC."HRMD_Id"=MD."HRMD_Id" AND MD."HRMD_ActiveFlag"=true
    INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id"=ME."HRME_Id" AND ME."HRME_ActiveFlag"=true AND ME."HRME_LeftFlag"=false
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id"=MP."HRMPR_Id" AND MP."HRMP_ActiveFlag"=true
    Left JOIN "IVRM_Staff_User_Login" f ON (f."Id"=TC."ISMTCR_CreatedBy")
    Left Join "ApplicationUser" AU ON f."Id"=AU."Id"
    Left JOIN "ISM_User_Employees_Mapping" UEM ON ((UEM."User_Id"=f."Id") OR (UEM."User_Id"=AU."Id"))
    LEFT join "IVRM_Module" ivrm on TC."IVRMM_Id"=ivrm."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT On CCT."ISMMTCAT_Id"=TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag"=true
    WHERE TC."ISMTCR_ActiveFlg"=true AND TCAT."ISMTCRASTO_ActiveFlg"=true
    AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "Status_Id" || ''' || '','') > 0
    AND ((TCAT."HRME_Id" not IN (' || "HRME_Id" || ')) and (TCAT."ISMTCRASTO_AssignedBy" not IN (' || "HRME_Id" || '))) and TC."HRME_Id" IN (' || "HRME_Id" || ') order by "ISMTCR_CreationDate" desc';

    EXECUTE "Slqdymaic1";
    EXECUTE "Slqdymaic2";
    EXECUTE "Slqdymaic3";
    EXECUTE "Slqdymaic4";
    EXECUTE "Slqdymaic5";

    RETURN QUERY
    SELECT * FROM "CompliantAdmin_Temp1"
    UNION ALL
    SELECT * FROM "CompliantAdmin_Temp2"
    UNION ALL
    SELECT * FROM "CompliantAdmin_Temp3"
    UNION ALL
    SELECT * FROM "CompliantAdmin_Temp5"
    UNION ALL
    SELECT * FROM "CompliantAdmin_Temp4"
    ORDER BY "ISMTCR_CreationDate" desc;

END;
$$;