CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_Task_Cart_New_Temp" (
    "RoleFlg" VARCHAR(100), 
    "TypeFlg" VARCHAR(100), 
    "status" VARCHAR(200), 
    "HRME_Id" VARCHAR(100),
    "IVRMM_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE (
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id_Creator" BIGINT,
    "createdby" TEXT,
    "assignedby" TEXT,
    "assignedto" TEXT,
    "tasktag" INTEGER,
    "addtoplannerflag" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic1" TEXT;
    "Slqdymaic2" TEXT;
    "Slqdymaic3" TEXT;
    "Slqdymaic4" TEXT;
BEGIN
    DROP TABLE IF EXISTS "StaffAdmin_Temp1";
    DROP TABLE IF EXISTS "StaffAdmin_Temp2";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";

    IF "RoleFlg" = 'Staff' OR "RoleFlg" = 'Admin' OR "RoleFlg" = 'COORDINATOR' THEN
        IF "TypeFlg" = 'Default' THEN
            "Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS createdby,
            ''NA'' AS assignedby,
            ''Not-Assigned'' AS assignedto,
            1 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true AND "ME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TC"."HRME_Id" IN (' || "HRME_Id" || ')';

            "Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp2" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS createdby,
            ''NA'' AS assignedby,
            ''Not-Assigned'' AS assignedto, 2 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id" = "TCC"."ISMTCR_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id" = "TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" "cl" ON "TCC"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true
            LEFT JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TCC"."ISMTCRCL_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCC"."ISMTCRCL_ActiveFlg" = true
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "CIE"."ISMCIM_IEList" IN (' || "HRME_Id" || ')';

            "Slqdymaic3" := 'CREATE TEMP TABLE "StaffAdmin_Temp3" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS createdby,
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id" = "TTO"."ISMTCRTRTO_TransferredBy") AS assignedby,
            ''Transferred'' AS assignedto, 3 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = true
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "TTO"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true AND "ME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE ("HRME_Id" IN (' || "HRME_Id" || ')) OR ("ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || ')))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TTO"."HRME_Id" IN (' || "HRME_Id" || ')';

            "Slqdymaic4" := 'CREATE TEMP TABLE "StaffAdmin_Temp4" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS createdby,
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "HMEP" WHERE "HMEP"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS assignedby,
            (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS assignedto,
            4 AS tasktag, 0 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true AND "ME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCAT"."ISMTCRASTO_ActiveFlg" = true
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (("TCAT"."HRME_Id" IN (' || "HRME_Id" || ')) OR ("TCAT"."ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || ')))';

            EXECUTE "Slqdymaic1";
            EXECUTE "Slqdymaic2";
            EXECUTE "Slqdymaic3";
            EXECUTE "Slqdymaic4";

            RETURN QUERY
            SELECT * FROM "StaffAdmin_Temp1"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp2"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp3"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp4"
            ORDER BY tasktag;

        ELSIF "TypeFlg" = 'Search' THEN
            "Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" = "TC"."HRME_Id") AS createdby,
            ''NA'' AS assignedby,
            ''Not-Assigned'' AS assignedto,
            1 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg" = true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true AND "ME"."HRME_LeftFlag" = false
            WHERE "TC"."ISMTCR_ActiveFlg" = true
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TC"."HRME_Id" IN (' || "HRME_Id" || ')';

            "Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp2" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS createdby,
            ''NA'' AS assignedby,
            ''Not-Assigned'' AS assignedto, 2 AS tasktag, 1 AS addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id" = "TCC"."ISMTCR_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id" = "TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" "cl" ON "TCC"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = true
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = true
            LEFT JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = true
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TCC"."ISMTCRCL_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg" = true AND "TCC"."ISMTCRCL_ActiveFlg" = true
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = true)
            AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "CIE"."ISMCIM_IEList" IN (' || "HRME_Id" || ')';

            "Slqdymaic3" := 'CREATE TEMP TABLE "StaffAdmin_Temp3" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
            ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
            CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
            CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "assi" WHERE "assi"."HRME_Id" =