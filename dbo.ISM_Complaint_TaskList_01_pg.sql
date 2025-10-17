CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskList_01"(
    "RoleFlg" VARCHAR(100),
    "TypeFlg" VARCHAR(100),
    "status" VARCHAR(200),
    "HRME_Id" VARCHAR(100),
    "IVRMM_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE(
    "ISMTCR_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" INTEGER,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
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
    "assignedto" VARCHAR,
    "createdby" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN

    IF "RoleFlg" = 'Staff' OR "RoleFlg" = 'Admin' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "assignedto",

            (SELECT ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
            OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby"
        
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = 1 AND "ME"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Emp_Code" = "TC"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "f"."Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN (' || "HRME_Id" || '))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (("UEM"."User_Id" = ' || "userid" || ') OR "TC"."HRME_Id" IN (' || "HRME_Id" || ') OR "TCAT"."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Search' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "assignedto",

            (SELECT ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
            OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby"
        
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = 1 AND "ME"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Emp_Code" = "TC"."HRME_Id" OR "f"."Emp_Code" = "TCAT"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "f"."Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN (' || "HRME_Id" || '))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND ("TCAT"."HRME_Id" IN (' || "HRME_Id" || ') OR "TC"."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Planner' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "assignedto",

            (SELECT ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
            OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) 
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS "createdby"
        
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = 1 AND "ME"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Emp_Code" = "TC"."HRME_Id" OR "f"."Emp_Code" = "TCAT"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "f"."Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN (' || "HRME_Id" || '))
            AND "TC"."ISMTCR_Status" = ''Open'' AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = 1)
            AND ("UEM"."User_Id" = ' || "userid" || ' OR "TC"."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        END IF;
        
    ELSIF "RoleFlg" = 'COORDINATOR' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "createdby",
            '''' AS "assignedto"
        
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = 1 AND "ME"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Id" = "TC"."ISMTCR_CreatedBy" OR "f"."Id" = "TCAT"."ISMTCRASTO_CreatedBy") AND ("f"."Emp_Code" = "TC"."HRME_Id" OR "f"."Emp_Code" = "TCAT"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "f"."Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND ("UEM"."User_Id" = ' || "userid" || ' OR "TCAT"."HRME_Id" IN (' || "HRME_Id" || ') OR "TC"."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Search' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "createdby",
            '''' AS "assignedto"
        
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = 1 AND "ME"."HRME_LeftFlag" = 0
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "IVRM_Staff_User_Login" "f" ON ("f"."Id" = "TC"."ISMTCR_CreatedBy" OR "f"."Id" = "TCAT"."ISMTCRASTO_CreatedBy") AND ("f"."Emp_Code" = "TC"."HRME_Id" OR "f"."Emp_Code" = "TCAT"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id" = "f"."Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND ("TCAT"."HRME_Id" IN (' || "HRME_Id" || ') OR "TC"."HRME_Id" IN (' || "HRME_Id" || '))
            ORDER BY "ISMTCR_Id"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "TypeFlg" = 'Planner' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TC"."ISMTCR_Id", "TC"."HRMD_Id", "MD"."HRMD_DepartmentName", "TC"."HRMPR_Id", "MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                  ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate", "ISMTCR_Title", "ISMTCR_Desc",
            "ISMTCR_Status", "ISMTCR_ReOpenFlg", "ISMTCR_ReOpenDate", "ISMTCR_TaskNo", "ac"."ISMMCLT_Id", "cl"."ISMMCLT_ClientName", "TC"."HRME_Id",
            ((CASE WHEN "ME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS "createdby",
            '''' AS "assignedto"
        
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"