CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskRegisterPriority_Report" (
    "TypeFlg" TEXT,
    "SelectionFlag" TEXT,
    "startDate" TIMESTAMP,
    "endDate" TIMESTAMP,
    "status" TEXT,
    "MI_Id" TEXT,
    "HRMD_Id" TEXT,
    "HRME_Id" TEXT,
    "userid" TEXT,
    "HRMPR_Id" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "Slqdymaic2" TEXT;
    "betweendates" TEXT;
    "betweendates1" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
BEGIN
    "StartDate_N" := TO_CHAR("startDate", 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("endDate", 'YYYY-MM-DD');

    IF "StartDate_N" != '' AND "EndDate_N" != '' THEN
        "betweendates" := '((CAST("TCAT"."ISMTCRASTO_StartDate" AS DATE) BETWEEN ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || ''') OR ( CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE)) between ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || ''')';
        "betweendates1" := '((CAST("TCAT"."ISMTCRTRTO_StartDate" AS DATE) BETWEEN ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || ''') OR ( CAST("TCAT"."ISMTCRTRTO_EndDate" AS DATE)) between ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || ''')';
    ELSE
        "betweendates" := '';
        "betweendates1" := '';
    END IF;

    IF "TypeFlg" = 'Consolidated' THEN
        DROP TABLE IF EXISTS "StaffAdmin_Temp01";
        DROP TABLE IF EXISTS "StaffAdmin_Temp02";
        DROP TABLE IF EXISTS "StaffAdmin_Temp5";
        DROP TABLE IF EXISTS "StaffAdmin_Temp6";

        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp01" AS
            Select DISTINCT hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",COUNT("TC"."ISMTCR_Id") AS totalCount,
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename

            FROM "ISM_TaskCreation" "TC"
            left join "HR_Master_Priority" hmp on "TC"."HRMPR_Id"=hmp."HRMPR_Id"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"				
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0	
            Where "TC"."ISMTCR_ActiveFlg"=1 AND ' || "betweendates" || ' and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo") AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0		
            Group By hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp02" AS
            Select DISTINCT hmp."HRMP_Name",  "TCAT"."HRME_Id","TC"."ISMTCR_Status",COUNT("TC"."ISMTCR_Id") AS totalCount,
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename
            FROM "ISM_TaskCreation" "TC"
            left join "HR_Master_Priority" hmp on "TC"."HRMPR_Id"=hmp."HRMPR_Id"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"				
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0	
            Where "TC"."ISMTCR_ActiveFlg"=1 AND ' || "betweendates1" || ' and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0		

            Group By hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))';

            EXECUTE "Slqdymaic";
            EXECUTE "Slqdymaic2";

            RETURN QUERY
            select "HRME_Id","ISMTCR_Status",sum(totalCount)::bigint as totalCount,employeename, "HRMP_Name" from (
                SELECT * FROM "StaffAdmin_Temp01"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp02"
            ) AS "New" group by "HRME_Id","ISMTCR_Status",employeename,"HRMP_Name";

        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp5" AS
            Select DISTINCT hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",COUNT("TC"."ISMTCR_Id") AS totalCount,
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename

            FROM "ISM_TaskCreation" "TC"
            left join "HR_Master_Priority" hmp on "TC"."HRMPR_Id"=hmp."HRMPR_Id"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"			
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0			
            Where "TC"."ISMTCR_ActiveFlg"=1 AND "TCAT"."HRME_Id" IN (' || "HRME_Id" || ') 
            AND ' || "betweendates" || ' and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')			
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo" where "ISMTCRTRTO_TransferredBy" IN(' || "HRME_Id" || '))	AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0
            Group By hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",	
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||	CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp6" AS
            Select DISTINCT hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",COUNT("TC"."ISMTCR_Id") AS totalCount,
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename
            FROM "ISM_TaskCreation" "TC"
            left join "HR_Master_Priority" hmp on "TC"."HRMPR_Id"=hmp."HRMPR_Id"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"			
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0			
            Where "TC"."ISMTCR_ActiveFlg"=1 AND "TCAT"."HRME_Id" IN (' || "HRME_Id" || ') AND "TCAT"."ISMTCRTRTO_TransferredBy" NOT IN (' || "HRME_Id" || ') AND ' || "betweendates1" || '			
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0 and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" where "ISMTCRASTO_AssignedBy" IN (' || "HRME_Id" || '))	
            Group By hmp."HRMP_Name", "TCAT"."HRME_Id","TC"."ISMTCR_Status",	
            ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END ))';

            EXECUTE "Slqdymaic";
            EXECUTE "Slqdymaic2";

            RETURN QUERY
            select "HRME_Id","ISMTCR_Status",sum(totalCount)::bigint as totalCount,employeename, "HRMP_Name" from (
                SELECT * FROM "StaffAdmin_Temp5"
                UNION ALL
                SELECT * FROM "StaffAdmin_Temp6"
            ) AS "New" group by "HRME_Id","ISMTCR_Status",employeename, "HRMP_Name";

        END IF;

    ELSIF "TypeFlg" = 'Detailed' THEN
        DROP TABLE IF EXISTS "StaffAdmin_Temp001";
        DROP TABLE IF EXISTS "StaffAdmin_Temp002";
        DROP TABLE IF EXISTS "StaffAdmin_Temp3";
        DROP TABLE IF EXISTS "StaffAdmin_Temp4";

        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp001" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","TC"."HRMPR_Id","MP"."HRMP_Name",						
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints''  WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement''   ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate",''DD/MM/YYYY HH24:MI'') AS assginedDate,
            (CASE WHEN "TC"."ISMTCR_Status" =''Completed'' then TO_CHAR("TC"."UpdatedDate",''DD/MM/YYYY HH24:MI'') ELSE ''NA''  end) AS "CompletedDate",
            "TCAT"."HRME_Id",((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename,
            (select ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) from "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id" ) as createdby,
            (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) from "HR_Master_Employee" "MME" where "MME"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy" ) AS "AssignedBy", 
            "TCAT"."ISMTCRASTO_StartDate" AS "StartDate","TCAT"."ISMTCRASTO_EndDate" AS "EndDate","TCAT"."ISMTCRASTO_EffortInHrs" AS "EffortInHrs","TC"."ISMTCR_Desc" AS "IssueDesc"

            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"	
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id" 
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=1 
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id" 			
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=1	
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0	
            Where "TC"."ISMTCR_ActiveFlg"=1  AND ' || "betweendates" || ' and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_TransferredTo")	
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0';

            "Slqdymaic2" := '
            CREATE TEMP TABLE "StaffAdmin_Temp002" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","TC"."HRMPR_Id","MP"."HRMP_Name",						
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints'' WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement'' ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRTRTO_TransferredDate",''DD/MM/YYYY HH24:MI'') AS assginedDate,
            (CASE WHEN "TC"."ISMTCR_Status" =''Completed'' then TO_CHAR("TC"."UpdatedDate",''DD/MM/YYYY HH24:MI'') ELSE ''NA''  end) AS "CompletedDate",
            "TCAT"."HRME_Id",((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) as employeename,
            (select ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) from "HR_Master_Employee" assi where assi."HRME_Id"="TC"."HRME_Id" ) as createdby,
            (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else "HRME_EmployeeFirstName" end||CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END )) from "HR_Master_Employee" "MME" where "MME"."HRME_Id"="TCAT"."HRME_Id" ) AS "AssignedBy", 
            "TCAT"."ISMTCRTRTO_StartDate" AS "StartDate","TCAT"."ISMTCRTRTO_EndDate" AS "EndDate","TCAT"."ISMTCRTRTO_EffortInHrs" AS "EffortInHrs","TC"."ISMTCR_Desc" AS "IssueDesc"

            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"	
            LEFT JOIN "ISM_TaskCreation_Client" ac on "TC"."ISMTCR_Id"=ac."ISMTCR_Id" 
            LEFT JOIN "ISM_Master_Client" cl ON ac."ISMMCLT_Id"=cl."ISMMCLT_Id" AND cl."ISMMCLT_ActiveFlag"=1 
            LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id"="TCAT"."ISMTCR_Id" 			
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=1	
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0	
		
            Where "TC"."ISMTCR_ActiveFlg"=1  AND ' || "betweendates1" || ' and "TC"."HRMPR_Id" IN (' || "HRMPR_Id" || ')
            AND "TC"."ISMTCR_Id" NOT IN (Select DISTINCT "ISMTCR_Id" from "ISM_TaskCreation_AssignedTo" where "HRME_Id" IN (' || "HRME_Id" || '))	
            AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "status" || ''' || '','') > 0';

            EXECUTE "Slqdymaic";
            EXECUTE "Slqdymaic2";

            RETURN QUERY
            SELECT * FROM "StaffAdmin_Temp001"
            UNION ALL
            SELECT * FROM "StaffAdmin_Temp002";

        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            CREATE TEMP TABLE "StaffAdmin_Temp3" AS
            SELECT DISTINCT "TC"."ISMTCR_Id","TC"."HRMD_Id","TC"."HRMPR_Id","MP"."HRMP_Name",						
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' then ''Bug/Complaints'' WHEN  "TC"."ISMTCR_BugOREnhancementFlg" =''E'' then ''Enhancement'' ELSE  ''Others'' end) AS "ISMTCR_BugOREnhancementFlg",
            "ISMTCR_CreationDate","ISMTCR_Title","ISMTCR_Desc","ISMTCR_Status","ISMTCR_ReOpenFlg","ISMTCR_ReOpenDate","ISMTCR_TaskNo",ac."ISMMCLT_Id",cl."ISMMCLT_ClientName",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate",''DD/MM/YYYY HH24:MI'') AS assginedDate,
            (CASE WHEN "TC"."ISMTCR_Status" =''