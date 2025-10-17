CREATE OR REPLACE FUNCTION "dbo"."ISM_Detailed_Category_Group_Report"(
    p_StartDate VARCHAR(10),
    p_EndDate VARCHAR(10),
    p_HRME_Id TEXT,
    p_HRMDC_ID TEXT,
    p_Category_Id TEXT
)
RETURNS TABLE(
    "ISMTCR_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "crdate" VARCHAR,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" INTEGER,
    "createdby" VARCHAR,
    "todaysdate" TIMESTAMP,
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
    v_Slqdymaic1 TEXT;
    v_Slqdymaic2 TEXT;
    v_Slqdymaic3 TEXT;
    v_Slqdymaic4 TEXT;
    v_Slqdymaic5 TEXT;
BEGIN

    DROP TABLE IF EXISTS "CategoryGroupAdmin_Temp1";
    DROP TABLE IF EXISTS "CategoryGroupAdmin_Temp2";
    DROP TABLE IF EXISTS "CategoryGroupAdmin_Temp3";
    DROP TABLE IF EXISTS "CategoryGroupAdmin_Temp4";
    DROP TABLE IF EXISTS "CategoryGroupAdmin_Temp5";

    v_Slqdymaic1 := 'CREATE TEMP TABLE "CategoryGroupAdmin_Temp1" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
    ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
    CURRENT_TIMESTAMP AS todaysdate,
    (DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    ''NA'' AS assignedby,
    ''Not-Assigned'' AS assignedto,
    1 AS tasktag, 1 AS addtoplannerflag, "IVRMM_ModuleName", "ISMMTCAT_TaskCategoryName", 
    "ISMMTCAT_EachTaskMaxDuration", "ISMMTCAT_DurationFlg", "ISMMTCAT_EachTaskMaxDuration" AS maxtime
    
    FROM "ISM_TaskCreation" TC
    LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = TRUE
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" ME ON TC."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = TRUE AND ME."HRME_LeftFlag" = FALSE
    LEFT JOIN "IVRM_Module" f ON TC."IVRMM_Id" = f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT ON CCT."ISMMTCAT_Id" = TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag" = TRUE
    WHERE TC."ISMTCR_ActiveFlg" = TRUE
    AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = TRUE)
    AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = TRUE)
    AND TC."ISMMTCAT_Id" IN (' || p_Category_Id || ')
    AND TC."HRME_Id" IN (' || p_HRME_Id || ')
    ORDER BY "ISMTCR_CreationDate" DESC';

    v_Slqdymaic2 := 'CREATE TEMP TABLE "CategoryGroupAdmin_Temp2" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
    ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",TCC."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    
    (SELECT "NormalizedUserName" FROM "ApplicationUser" appuser WHERE appuser."Id" = TC."ISMTCR_CreatedBy") AS createdby,
    CURRENT_TIMESTAMP AS todaysdate,
    (DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    ''NA'' AS assignedby,
    ''Not-Assigned'' AS assignedto, 2 AS tasktag, 1 AS addtoplannerflag, "IVRMM_ModuleName", "ISMMTCAT_TaskCategoryName",
    "ISMMTCAT_EachTaskMaxDuration", "ISMMTCAT_DurationFlg", "ISMMTCAT_EachTaskMaxDuration" AS maxtime
    
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_Client" TCC ON TC."ISMTCR_Id" = TCC."ISMTCR_Id"
    INNER JOIN "ISM_Master_Client_IEMapping" CIE ON CIE."ISMMCLT_Id" = TCC."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Client" cl ON TCC."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" ME ON CIE."ISMCIM_IEList" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = TRUE
    LEFT JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = TRUE
    INNER JOIN "ApplicationUser" AU ON AU."Id" = TCC."ISMTCRCL_CreatedBy"
    INNER JOIN "ApplicationUserRole" AUR ON AUR."UserId" = AU."Id"
    INNER JOIN "IVRM_Role_Type" IRT ON IRT."IVRMRT_Id" = AUR."RoleTypeId"
    LEFT JOIN "IVRM_Module" f ON TC."IVRMM_Id" = f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT ON CCT."ISMMTCAT_Id" = TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag" = TRUE
    WHERE TC."ISMTCR_ActiveFlg" = TRUE AND TCC."ISMTCRCL_ActiveFlg" = TRUE
    AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = TRUE)
    AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = TRUE)
    AND CIE."ISMCIM_IEList" IN (' || p_HRME_Id || ') AND IRT."IVRMRT_RoleFlag" = ''ClientUser''
    ORDER BY "ISMTCR_CreationDate" DESC';

    v_Slqdymaic3 := 'CREATE TEMP TABLE "CategoryGroupAdmin_Temp3" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
    ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
    CURRENT_TIMESTAMP AS todaysdate,
    (DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP WHERE HMEP."HRME_Id" = TTO."ISMTCRTRTO_TransferredBy") AS assignedby,
    ''Transferred'' AS assignedto, 3 AS tasktag, 1 AS addtoplannerflag, "IVRMM_ModuleName", "ISMMTCAT_TaskCategoryName",
    "ISMMTCAT_EachTaskMaxDuration", "ISMMTCAT_DurationFlg", "ISMMTCAT_EachTaskMaxDuration" AS maxtime
    
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = TRUE
    LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id"
    LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" ME ON TTO."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = TRUE AND ME."HRME_LeftFlag" = FALSE
    LEFT JOIN "IVRM_Module" f ON TC."IVRMM_Id" = f."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT ON CCT."ISMMTCAT_Id" = TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag" = TRUE
    WHERE TC."ISMTCR_ActiveFlg" = TRUE
    AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" 
        WHERE ("HRME_Id" IN (' || p_HRME_Id || ')) OR ("ISMTCRASTO_AssignedBy" IN (' || p_HRME_Id || ')))
    AND TC."ISMMTCAT_Id" IN (' || p_Category_Id || ')
    AND TTO."HRME_Id" IN (' || p_HRME_Id || ')
    ORDER BY "ISMTCR_CreationDate" DESC';

    v_Slqdymaic4 := 'CREATE TEMP TABLE "CategoryGroupAdmin_Temp4" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
    ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
    CURRENT_TIMESTAMP AS todaysdate,
    (DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP WHERE HMEP."HRME_Id" = TCAT."ISMTCRASTO_AssignedBy") AS assignedby,
    
    (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS assignedto,
    4 AS tasktag, 0 AS addtoplannerflag, "IVRMM_ModuleName", "ISMMTCAT_TaskCategoryName",
    "ISMMTCAT_EachTaskMaxDuration", "ISMMTCAT_DurationFlg", "ISMMTCAT_EachTaskMaxDuration" AS maxtime
    
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" PTTO ON PTTO."ISMTCR_Id" = TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = TRUE
    LEFT JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = TRUE AND ME."HRME_LeftFlag" = FALSE
    INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = TRUE
    LEFT JOIN "IVRM_Staff_User_Login" f ON (f."Id" = TC."ISMTCR_CreatedBy")
    LEFT JOIN "ApplicationUser" AU ON f."Id" = AU."Id"
    LEFT JOIN "ISM_User_Employees_Mapping" UEM ON ((UEM."User_Id" = f."Id") OR (UEM."User_Id" = AU."Id"))
    LEFT JOIN "IVRM_Module" ivrm ON TC."IVRMM_Id" = ivrm."IVRMM_Id"
    INNER JOIN "ISM_Master_TaskCategory" CCT ON CCT."ISMMTCAT_Id" = TC."ISMMTCAT_Id" AND CCT."ISMMTCAT_ActiveFlag" = TRUE
    WHERE TC."ISMTCR_ActiveFlg" = TRUE AND TCAT."ISMTCRASTO_ActiveFlg" = TRUE
    AND TC."ISMMTCAT_Id" IN (' || p_Category_Id || ')
    AND ((TCAT."HRME_Id" IN (' || p_HRME_Id || ')) OR (TCAT."ISMTCRASTO_AssignedBy" IN (' || p_HRME_Id || ')))
    ORDER BY "ISMTCR_CreationDate" DESC';

    v_Slqdymaic5 := 'CREATE TEMP TABLE "CategoryGroupAdmin_Temp5" AS 
    SELECT DISTINCT TC."ISMTCR_Id",TC."HRMD_Id",MD."HRMD_DepartmentName",TC."HRMPR_Id",MP."HRMP_Name",
    (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
    WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
    ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
    "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",TO_CHAR("ISMTCR_CreationDate", ''DD/MM/YYYY'') AS crdate,
    "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",TC."HRME_Id",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
    CURRENT_TIMESTAMP AS todaysdate,
    (DATE_TRUNC(''year'', CURRENT_TIMESTAMP) + INTERVAL ''2 years'' - INTERVAL ''1 day'')::DATE AS "endOfYear",
    
    (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
    FROM "HR_Master_Employee" HMEP WHERE HMEP."HRME_Id" = TCAT."ISMTCRASTO_AssignedBy") AS assignedby,
    
    (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
    ELSE "HRME_EmployeeFirstName" END || 
    CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
    CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' 
    THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS assignedto,
    4 AS tasktag, 0 AS addtoplannerflag, "IVRMM_ModuleName", "ISMMTCAT_TaskCategoryName",
    "ISMMTCAT_EachTaskMaxDuration", "ISMMTCAT_DurationFlg", "ISMMTCAT_EachTaskMaxDuration" AS maxtime
    
    FROM "ISM_TaskCreation" TC
    INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = TRUE
    LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" PTTO ON PTTO."ISMTCR_Id" = TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = TRUE
    LEFT JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = TRUE
    INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = TRUE AND ME."HRME_LeftFlag" = FALSE
    