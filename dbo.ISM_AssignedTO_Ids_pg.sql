CREATE OR REPLACE FUNCTION "dbo"."ISM_AssignedTO_Ids" (
    "RoleFlg" VARCHAR(100),
    "TypeFlg" VARCHAR(100),
    "status" VARCHAR(200),
    "HRME_Id" VARCHAR(100),
    "IVRMM_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" INTEGER,
    "createdby" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN

    IF "RoleFlg" = 'Staff' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic" := '
            SELECT DISTINCT TC."ISMTCR_Id", TC."HRMD_Id", MD."HRMD_DepartmentName", TC."HRMPR_Id", MP."HRMP_Name",
            (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            TC."ISMTCR_CreationDate", TC."ISMTCR_Title", TC."ISMTCR_Desc",
            TC."ISMTCR_Status", TC."ISMTCR_ReOpenFlg", TC."ISMTCR_ReOpenDate", TC."ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName", TC."HRME_Id",
            ((CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR ME."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            ME."HRME_EmployeeFirstName" END || CASE WHEN ME."HRME_EmployeeMiddleName" IS NULL OR ME."HRME_EmployeeMiddleName" = '''' 
            OR ME."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END || CASE WHEN ME."HRME_EmployeeLastName" IS NULL OR ME."HRME_EmployeeLastName" = '''' 
            OR ME."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)) AS createdby
            
            FROM "ISM_TaskCreation" TC
            LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id" 
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1 
            LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id" 
            LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = TC."ISMTCR_Id" 

            INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" ME ON TC."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = 1 AND ME."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" f ON ((f."Emp_Code" = TC."HRME_Id") OR (f."Emp_Code" = TCAT."HRME_Id"))
            INNER JOIN "ISM_User_Employees_Mapping" UEM ON UEM."User_Id" = f."Id" 
            
            WHERE TC."ISMTCR_ActiveFlg" = 1 AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo")
            AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (((UEM."User_Id" = ' || "userid" || ') OR (TCAT."HRME_Id" IN (' || "HRME_Id" || '))) OR (TC."HRME_Id" IN (' || "HRME_Id" || ')) OR TTO."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY TC."ISMTCR_Id"';
            
            RAISE NOTICE '%', "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Search' THEN
            "Slqdymaic" := '
            SELECT DISTINCT TC."ISMTCR_Id", TC."HRMD_Id", MD."HRMD_DepartmentName", TC."HRMPR_Id", MP."HRMP_Name",
            (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            TC."ISMTCR_CreationDate", TC."ISMTCR_Title", TC."ISMTCR_Desc",
            TC."ISMTCR_Status", TC."ISMTCR_ReOpenFlg", TC."ISMTCR_ReOpenDate", TC."ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName", TC."HRME_Id",
            ((CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR ME."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            ME."HRME_EmployeeFirstName" END || CASE WHEN ME."HRME_EmployeeMiddleName" IS NULL OR ME."HRME_EmployeeMiddleName" = '''' 
            OR ME."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeMiddleName" END || CASE WHEN ME."HRME_EmployeeLastName" IS NULL OR ME."HRME_EmployeeLastName" = '''' 
            OR ME."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || ME."HRME_EmployeeLastName" END)) AS createdby
            
            FROM "ISM_TaskCreation" TC
            LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id" 
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1 
            LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id" 
            LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = TC."ISMTCR_Id" 

            INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" ME ON TC."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = 1 AND ME."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" f ON ((f."Emp_Code" = TC."HRME_Id") OR (f."Emp_Code" = TCAT."HRME_Id")) OR (f."Emp_Code" = TTO."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" UEM ON UEM."User_Id" = f."Id" 
            
            WHERE TC."ISMTCR_ActiveFlg" = 1 AND TC."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo")
            AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (((TCAT."HRME_Id" IN (' || "HRME_Id" || '))) OR (TC."HRME_Id" IN (' || "HRME_Id" || ')) OR TTO."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY TC."ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        END IF;
    
    ELSIF "RoleFlg" = 'COORDINATOR' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic" := '
            SELECT DISTINCT a."ISMTCR_Id", a."HRMD_Id", b."HRMD_DepartmentName", a."HRMPR_Id", e."HRMP_Name", a."ISMTCR_BugOREnhancementFlg", a."ISMTCR_CreationDate", a."ISMTCR_Title", a."ISMTCR_Desc",
            a."ISMTCR_Status", a."ISMTCR_ReOpenFlg", a."ISMTCR_ReOpenDate", a."ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName",
            ((CASE WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            c."HRME_EmployeeFirstName" END || CASE WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '''' 
            OR c."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || c."HRME_EmployeeMiddleName" END || CASE WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '''' 
            OR c."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || c."HRME_EmployeeLastName" END)) AS createdby
            FROM "ISM_TaskCreation" a
            LEFT JOIN "ISM_TaskCreation_Client" ac ON a."ISMTCR_Id" = ac."ISMTCR_Id" 
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = a."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id" 
            LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = a."ISMTCR_Id" 

            INNER JOIN "HR_Master_Department" b ON a."HRMD_Id" = b."HRMD_Id" AND b."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" c ON b."HRMD_Id" = c."HRMD_Id" AND a."HRME_Id" = c."HRME_Id" AND c."HRME_ActiveFlag" = 1 AND c."HRME_LeftFlag" = 0
            INNER JOIN "ISM_User_Employees_Mapping" UEM ON UEM."HRME_Id" = c."HRME_Id" AND UEM."ISMUSEMM_ActiveFlag" = 1
            INNER JOIN "HR_Master_Priority" e ON a."HRMPR_Id" = e."HRMPR_Id" AND e."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" f ON a."ISMTCR_CreatedBy" = f."Id" AND f."Emp_Code" = a."HRME_Id"

            WHERE a."ISMTCR_ActiveFlg" = 1 
            AND c."HRME_Id" IN (SELECT DISTINCT "HRME_Id" FROM "ISM_User_Employees_Mapping" WHERE "User_Id" = ' || "userid" || ')';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
    END IF;

    RETURN;

END;
$$;