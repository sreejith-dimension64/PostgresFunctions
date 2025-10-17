CREATE OR REPLACE FUNCTION "dbo"."ISM_Pending_AssignedBy_To_Details"(
    "RoleFlg" VARCHAR(100),
    "countflag" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "rolyid" BIGINT;
    "IVRMRT_Id" BIGINT;
    "users" BIGINT;
    result_cursor REFCURSOR := 'result_cursor';
BEGIN
    SELECT "IVRMRT_Id" INTO "rolyid" FROM "IVRM_Role_Type" WHERE "IVRMRT_Role" = "RoleFlg";
    
    SELECT "IVRMRT_Id" INTO "IVRMRT_Id" FROM "ISM_RoleType_Department_Mapping" WHERE "IVRMRT_Id" = "rolyid";
    
    SELECT COUNT(*) INTO "users" 
    FROM "ISM_User_Employees_Mapping" a 
    INNER JOIN "IVRM_Staff_User_Login" b ON a."User_Id" = b."Id" 
    WHERE b."Emp_Code" = "HRME_Id";

    IF "RoleFlg" = 'Staff' OR "RoleFlg" = 'Admin' THEN
        IF "countflag" = 'Pending' THEN
            "Slqdymaic" := 'SELECT DISTINCT TC."ISMTCR_Id", TC."HRMD_Id", MD."HRMD_DepartmentName", TC."HRMPR_Id", MP."HRMP_Name",
            (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName", TC."HRME_Id",
            (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
                          ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
            ''NA'' AS assignedby,
            ''Not-Assigned'' AS assignedto,
            1 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" TC
            LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" TTO ON TTO."ISMTCR_Id" = TC."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = 1
            INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" ME ON TC."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = 1 AND ME."HRME_LeftFlag" = 0
            WHERE TC."ISMTCR_ActiveFlg" = 1
            AND POSITION('','' || TC."ISMTCR_Status" || '','' IN '','' || ''Open'' || '','') > 0
            AND ((TC."HRME_Id" IN (' || "HRME_Id" || ')) OR (TCAT."HRME_Id" IN (' || "HRME_Id" || ')) OR (TTO."HRME_Id" IN (' || "HRME_Id" || '))) 
            ORDER BY "ISMTCR_CreationDate" DESC';
            
            OPEN result_cursor FOR EXECUTE "Slqdymaic";
            RETURN NEXT result_cursor;
            
        ELSIF "countflag" = 'ByMe' THEN
            OPEN result_cursor FOR
            SELECT DISTINCT tc."ISMTCR_Id", me."HRMD_Id", md."HRMD_DepartmentName", TC."HRMPR_Id", MP."HRMP_Name",
            (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints'
                  WHEN TC."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement'
                  ELSE 'Others' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            (CASE WHEN TCAT."ISMTCRASTO_EffortInHrs" = 0 THEN 'Open'
                  ELSE 'Completed' END) AS "ISMTCR_Status",
            "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName", TC."HRME_Id",
            (SELECT COALESCE(a."HRME_EmployeeFirstName", ' ') || COALESCE(a."HRME_EmployeeMiddleName", ' ') || COALESCE(a."HRME_EmployeeLastName", '')
             FROM "HR_Master_Employee" a WHERE a."HRME_Id" = tc."HRME_Id") AS createdby,
            (SELECT COALESCE(b."HRME_EmployeeFirstName", ' ') || COALESCE(b."HRME_EmployeeMiddleName", ' ') || COALESCE(b."HRME_EmployeeLastName", '')
             FROM "HR_Master_Employee" b WHERE b."HRME_Id" = TCAT."ISMTCRASTO_AssignedBy") AS assignedby,
            (SELECT COALESCE(c."HRME_EmployeeFirstName", ' ') || COALESCE(c."HRME_EmployeeMiddleName", ' ') || COALESCE(c."HRME_EmployeeLastName", '')
             FROM "HR_Master_Employee" c WHERE c."HRME_Id" = TCAT."HRME_Id") AS assignedto,
            4 AS tasktag, 0 AS addtoplannerflag
            FROM "ISM_TaskCreation" TC
            INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = 1 AND ME."HRME_LeftFlag" = 0
            WHERE TC."ISMTCR_ActiveFlg" = 1 AND TCAT."ISMTCRASTO_ActiveFlg" = 1
            AND TCAT."ISMTCRASTO_AssignedBy" = "HRME_Id"
            ORDER BY "ISMTCR_CreationDate" DESC;
            RETURN NEXT result_cursor;
            
        ELSIF "countflag" = 'ToMe' THEN
            "Slqdymaic" := 'SELECT DISTINCT TC."ISMTCR_Id", TC."HRMD_Id", MD."HRMD_DepartmentName", TC."HRMPR_Id", MP."HRMP_Name",
            (CASE WHEN TC."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN TC."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", ac."ISMMCLT_Id", cl."ISMMCLT_ClientName", TC."HRME_Id",
            (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
                          ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = TC."HRME_Id") AS createdby,
            (SELECT (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
                          ELSE "HRME_EmployeeFirstName" END ||
                     CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeMiddleName" END ||
                     CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN ''''
                          ELSE '' '' || "HRME_EmployeeLastName" END)
             FROM "HR_Master_Employee" HMEP WHERE HMEP."HRME_Id" = TCAT."ISMTCRASTO_AssignedBy") AS assignedby,
            (CASE WHEN ME."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN ''''
                  ELSE "HRME_EmployeeFirstName" END ||
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN ''''
                  ELSE '' '' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN ''''
                  ELSE '' '' || "HRME_EmployeeLastName" END) AS assignedto,
            4 AS tasktag, 0 AS addtoplannerflag
            FROM "ISM_TaskCreation" TC
            INNER JOIN "ISM_TaskCreation_AssignedTo" TCAT ON TCAT."ISMTCR_Id" = TC."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" ac ON TC."ISMTCR_Id" = ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id" = cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" ITP ON ITP."ISMTCR_Id" = TCAT."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" MP ON TC."HRMPR_Id" = MP."HRMPR_Id" AND MP."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Department" MD ON TC."HRMD_Id" = MD."HRMD_Id" AND MD."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" ME ON TCAT."HRME_Id" = ME."HRME_Id" AND ME."HRME_ActiveFlag" = 1 AND ME."HRME_LeftFlag" = 0
            WHERE TC."ISMTCR_ActiveFlg" = 1 AND TCAT."ISMTCRASTO_ActiveFlg" = 1
            AND TCAT."HRME_Id" IN (' || "HRME_Id" || ')
            ORDER BY "ISMTCR_CreationDate" DESC';
            
            OPEN result_cursor FOR EXECUTE "Slqdymaic";
            RETURN NEXT result_cursor;
            
        ELSIF "countflag" = 'NotAssign' THEN
            IF "IVRMRT_Id" > 0 THEN
                OPEN result_cursor FOR
                SELECT DISTINCT a."ISMTCR_Id", a."ISMTCR_TaskNo", a."ISMTCR_Title", a."ISMTCR_CreationDate", a."ISMTCR_Status",
                (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN ''
                      ELSE "HRME_EmployeeFirstName" END ||
                 CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                 CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeLastName" END) AS createdby,
                'Not Assign' AS assignedby,
                'Not Assign' AS assignedto,
                d."ISMMCLT_ClientName",
                f."IVRMM_ModuleName",
                c."IVRMMMDDE_ModuleIncharge"
                FROM "ISM_TaskCreation" a
                INNER JOIN "ISM_RoleType_Department_Mapping" g ON a."HRMD_Id" = g."HRMD_Id"
                INNER JOIN "ISM_Master_Client" d ON d."ISMMCLT_Id" = a."ISMMCLT_Id"
                INNER JOIN "ISM_Master_Module" b ON b."IVRMM_Id" = a."IVRMM_Id"
                LEFT JOIN "ISM_Master_Module_Developers" c ON c."IVRMMMDDE_ModuleIncharge" = b."ISMMMD_ModuleHeadId"
                INNER JOIN "HR_Master_Employee" hr ON hr."HRME_Id" = c."IVRMMMDDE_ModuleIncharge"
                INNER JOIN "IVRM_Module" f ON a."IVRMM_Id" = f."IVRMM_Id"
                WHERE g."IVRMRT_Id" = "IVRMRT_Id"
                AND a."ISMTCR_Status" = 'Open'
                AND a."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo")
                AND a."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo");
                RETURN NEXT result_cursor;
                
            ELSIF "users" > 1 THEN
                OPEN result_cursor FOR
                SELECT DISTINCT TC."ISMTCR_Id", TC."ISMTCR_TaskNo", TC."ISMTCR_Title", TC."ISMTCR_CreationDate", TC."ISMTCR_Status",
                (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN ''
                      ELSE "HRME_EmployeeFirstName" END ||
                 CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                 CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeLastName" END) AS createdby,
                'Not Assign' AS assignedby,
                'Not Assign' AS assignedto,
                IMC."ISMMCLT_ClientName",
                IVMM."IVRMM_ModuleName",
                ISMMD."IVRMMMDDE_ModuleIncharge"
                FROM "ISM_TaskCreation" TC
                INNER JOIN "ISM_Master_Module" IMM ON TC."IVRMM_Id" = IMM."IVRMM_Id"
                INNER JOIN "ISM_Master_Module_Developers" ISMMD ON ISMMD."ISMMMD_Id" = IMM."ISMMMD_Id"
                INNER JOIN "HR_Master_Employee" HR ON hr."HRME_Id" = ISMMD."IVRMMMDDE_ModuleIncharge"
                INNER JOIN "IVRM_Staff_User_Login" ISU ON ISU."Emp_Code" = HR."HRME_Id"
                LEFT JOIN "ISM_Master_Client" IMC ON IMC."ISMMCLT_Id" = TC."ISMMCLT_Id"
                INNER JOIN "IVRM_Module" IVMM ON IVMM."IVRMM_Id" = IMM."IVRMM_Id"
                WHERE "ISMTCR_Status" = 'Open'
                AND TC."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo")
                AND TC."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo")
                AND HR."HRME_Id" IN (SELECT "HRME_Id" FROM "ISM_User_Employees_Mapping" IUEM 
                                     INNER JOIN "IVRM_Staff_User_Login" ISUL ON IUEM."User_Id" = ISUL."Id"
                                     WHERE ISUL."Emp_Code" = "HRME_Id");
                RETURN NEXT result_cursor;
                
            ELSIF "users" = 1 THEN
                OPEN result_cursor FOR
                SELECT DISTINCT TC."ISMTCR_Id", TC."ISMTCR_TaskNo", TC."ISMTCR_Title", TC."ISMTCR_CreationDate", TC."ISMTCR_Status",
                (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN ''
                      ELSE "HRME_EmployeeFirstName" END ||
                 CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                 CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN ''
                      ELSE ' ' || "HRME_EmployeeLastName" END) AS createdby,
                'Not Assign' AS assignedby,
                'Not Assign' AS assignedto,
                IMC."ISMMCLT_ClientName",
                IVMM."IVRMM_ModuleName",
                ISMMD."IVRMMMDDE_ModuleIncharge"
                FROM "ISM_TaskCreation" TC
                INNER JOIN "ISM_Master_Module" IMM ON TC."IVRMM_Id" = IMM."IVRMM_Id"
                INNER JOIN "ISM_Master_Module_Developers" ISMMD ON ISMMD."ISMMMD_Id" = IMM."ISMMMD_Id"
                INNER JOIN "HR_Master_Employee" HR ON hr."HRME_Id" = ISMMD."IVRMMMDDE_ModuleIncharge"
                INNER JOIN "IVRM_Staff_User_Login" ISU ON ISU."Emp_Code" = HR."HRME_Id"
                LEFT JOIN "ISM_Master_Client" IMC ON IMC."ISMMCLT_Id" = TC."ISMMCLT_Id"
                INNER JOIN "IVRM_Module" IVMM ON IVMM."IVRMM_Id" = IMM."IVRMM_Id"
                WHERE HR."HRME_Id" = "HRME_Id"
                AND "ISMTCR_Status" = 'Open'
                AND TC."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo")
                AND TC."ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo");
                RETURN NEXT result_cursor;
            END IF;
        END IF;
    END IF;
    
    RETURN;
END;
$$;