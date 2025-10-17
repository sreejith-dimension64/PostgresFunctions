CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_Task_Cart_Temp" (
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
    "ISMTCR_BugOREnhancementFlg" VARCHAR,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMMCLT_Id" INTEGER,
    "ISMMCLT_ClientName" VARCHAR,
    "HRME_Id" INTEGER,
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
    "Slqdymaic" TEXT;
    "Slqdymaic4" TEXT;
BEGIN
    DROP TABLE IF EXISTS "StaffAdmin_Temp1";
    DROP TABLE IF EXISTS "StaffAdmin_Temp2";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";

    IF "RoleFlg"='Staff' OR "RoleFlg"='Admin' OR "RoleFlg"='COORDINATOR' THEN
        IF "TypeFlg"='Default' THEN
            "Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id") as createdby,
            ''NA'' as assignedby,
            ''Not-Assigned'' as assignedto,
            1 as tasktag, 1 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true AND "ME"."HRME_LeftFlag"=false
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "IVRM_Staff_User_Login" f ON ((f."Emp_Code"="TC"."HRME_Id") OR (f."Emp_Code"="TCAT"."HRME_Id"))
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id"=f."Id"
            WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (("TCAT"."HRME_Id" IN (' || "HRME_Id" || ')) OR ("TC"."HRME_Id" IN (' || "HRME_Id" || ')))';

            "Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp2" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" appuser WHERE appuser."Id"="TC"."ISMTCR_CreatedBy") AS createdby,
            ''NA'' as assignedby,
            ''Not-Assigned'' as assignedto, 2 as tasktag, 1 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id"="TCC"."ISMTCR_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id"="TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" cl ON "TCC"."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true
            LEFT JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id"="TCC"."ISMTCRCL_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TCC"."ISMTCRCL_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "CIE"."ISMCIM_IEList" IN (' || "HRME_Id" || ')';

            "Slqdymaic3" := 'CREATE TEMP TABLE "StaffAdmin_Temp3" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id") as createdby,
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id"="TTO"."ISMTCRTRTO_TransferredBy") as assignedby,
            ''Transferred'' as assignedto, 3 as tasktag, 1 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TTO"."HRME_Id"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true AND "ME"."HRME_LeftFlag"=false
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "IVRM_Staff_User_Login" f ON ((f."Emp_Code"="TC"."HRME_Id") OR (f."Emp_Code"="TTO"."HRME_Id"))
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id"=f."Id"
            WHERE "TC"."ISMTCR_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" Where ("HRME_Id" in (' || "HRME_Id" || ')) OR ("ISMTCRASTO_AssignedBy" in (' || "HRME_Id" || ')))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "TTO"."HRME_Id" IN (' || "HRME_Id" || ')';

            "Slqdymaic4" := 'CREATE TEMP TABLE "StaffAdmin_Temp4" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id") as createdby,
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" "HMEP" where "HMEP"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") as assignedby,
            (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) as assignedto,
            4 as tasktag, 0 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "PTTO" ON "PTTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TCAT"."HRME_Id"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true AND "ME"."HRME_LeftFlag"=false
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "IVRM_Staff_User_Login" f ON (f."Emp_Code"="TC"."HRME_Id")
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id"=f."Id"
            WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TCAT"."ISMTCRASTO_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true AND ("HRME_Id" in (' || "HRME_Id" || ')) OR ("ISMTCRTRTO_TransferredBy" in (' || "HRME_Id" || ')))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND ((("UEM"."User_Id"=' || "userid" || ') OR "TC"."HRME_Id" IN (' || "HRME_Id" || ') OR "TCAT"."HRME_Id" IN (' || "HRME_Id" || ')) OR ("TCAT"."ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || ')))';

            RAISE NOTICE '%', "Slqdymaic1";
            RAISE NOTICE '%', "Slqdymaic2";
            RAISE NOTICE '%', "Slqdymaic3";
            RAISE NOTICE '%', "Slqdymaic4";

            RETURN QUERY
            SELECT * FROM "StaffAdmin_Temp1"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp2"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp3"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp4" ORDER BY tasktag;

        ELSIF "TypeFlg"='Search' THEN
            "Slqdymaic1" := 'CREATE TEMP TABLE "StaffAdmin_Temp1" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","ac"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (select (COALESCE("ME"."HRME_EmployeeFirstName",'''') || CASE WHEN COALESCE("HRME_EmployeeMiddleName",'''')='''' OR "HRME_EmployeeMiddleName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN COALESCE("HRME_EmployeeLastName",'''')='''' OR "HRME_EmployeeLastName"=''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END)
            FROM "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id") as createdby,
            ''NA'' as assignedby,
            ''Not-Assigned'' as assignedto,
            1 as tasktag, 1 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id"="TC"."ISMTCR_Id" AND "ISMTCRTRTO_ActiveFlg"=true
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "TC"."HRME_Id"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true AND "ME"."HRME_LeftFlag"=false
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "IVRM_Staff_User_Login" f ON ((f."Emp_Code"="TC"."HRME_Id") OR (f."Emp_Code"="TCAT"."HRME_Id"))
            INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "UEM"."User_Id"=f."Id"
            WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where ("HRME_Id" in (' || "HRME_Id" || ')) OR ("ISMTCRTRTO_TransferredBy" in (' || "HRME_Id" || ')))
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND (("TCAT"."HRME_Id" IN (' || "HRME_Id" || ')) OR ("TC"."HRME_Id" IN (' || "HRME_Id" || ')))';

            "Slqdymaic2" := 'CREATE TEMP TABLE "StaffAdmin_Temp2" AS SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","MD"."HRMD_DepartmentName","TC"."HRMPR_Id","MP"."HRMP_Name",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''
            WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''
            ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc",
            "ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo","TCC"."ISMMCLT_Id","cl"."ISMMCLT_ClientName","TC"."HRME_Id",
            (SELECT "NormalizedUserName" FROM "ApplicationUser" appuser WHERE appuser."Id"="TC"."ISMTCR_CreatedBy") AS createdby,
            ''NA'' as assignedby,
            ''Not-Assigned'' as assignedto, 2 as tasktag, 1 as addtoplannerflag
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id"="TCC"."ISMTCR_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id"="TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" cl ON "TCC"."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=true
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList"="ME"."HRME_Id" AND "ME"."HRME_ActiveFlag"=true
            LEFT JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id"="MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag"=true
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=true
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id"="TCC"."ISMTCRCL_CreatedBy"
            WHERE "TC"."ISMTCR_ActiveFlg"=true AND "TCC"."ISMTCRCL_ActiveFlg"=true
            AND "TC"."ISMTCR_Id" NOT IN (select distinct "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg"=true)
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" Where "ISMTCRTRTO_ActiveFlg"=true)
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            AND "CIE"."ISMCIM_IEList" IN (' || "HRME_Id" || ')';

            "Slqdym