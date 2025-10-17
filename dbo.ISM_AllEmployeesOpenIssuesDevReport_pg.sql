CREATE OR REPLACE FUNCTION "dbo"."ISM_AllEmployeesOpenIssuesDevReport"(
    "StartDateN" TEXT,
    "EndDateN" TEXT,
    "HRME_IdS" TEXT,
    "Status" TEXT,
    "NoofDays" BIGINT
)
RETURNS TABLE(
    "ISMTCR_TaskNo" TEXT,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Status" TEXT,
    "EmpName" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "AssignedBy" TEXT,
    "TransBy" TEXT,
    "StartDate" TEXT,
    "EndDate" TEXT,
    "EndDate1" DATE,
    "DiffDays" BIGINT,
    "AssignedStatus" VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id VARCHAR(30);
    v_ISMTCR_TaskNo TEXT;
    v_ISMTCR_Title TEXT;
    v_ISMTCR_Status TEXT;
    v_EmpName TEXT;
    v_ISMTCR_BugOREnhancementFlg TEXT;
    v_AssignedBy TEXT;
    v_StartDate TEXT;
    v_EndDate TEXT;
    v_EndDate1 DATE;
    v_DiffDays BIGINT;
    v_TransBy VARCHAR(200);
    v_StartDate_D VARCHAR(10);
    v_EndDate_D VARCHAR(10);
    v_sqldynamic1 TEXT;
    v_sqldynamic2 TEXT;
    v_EndDate_DF DATE;
    v_sqldynamic3 TEXT;
    rec RECORD;
BEGIN

    v_StartDate_D := TO_CHAR(CAST("StartDateN" AS DATE), 'YYYY-MM-DD');
    v_EndDate_D := TO_CHAR(CAST("EndDateN" AS DATE), 'YYYY-MM-DD');
    v_EndDate_DF := CAST("EndDateN" AS DATE);

    DROP TABLE IF EXISTS "ISM_AllEmpsOpenIssuesDevReprt_Temp";
    
    CREATE TEMP TABLE "ISM_AllEmpsOpenIssuesDevReprt_Temp"(
        "ISMTCR_TaskNo" TEXT,
        "ISMTCR_Title" TEXT,
        "ISMTCR_Status" TEXT,
        "EmpName" TEXT,
        "ISMTCR_BugOREnhancementFlg" TEXT,
        "AssignedBy" TEXT,
        "TransBy" TEXT,
        "StartDate" TEXT,
        "EndDate" TEXT,
        "EndDate1" DATE,
        "DiffDays" BIGINT,
        "AssignedStatus" VARCHAR(100)
    );

    DROP TABLE IF EXISTS "ISM_Empids_Temp";

    v_sqldynamic3 := 'CREATE TEMP TABLE "ISM_Empids_Temp" AS SELECT DISTINCT "HRME_Id" FROM "HR_Master_Employee" WHERE "HRME_ActiveFlag"=1 AND "HRME_LeftFlag"=0 AND "HRME_Id" IN (' || "HRME_IdS" || ')';
    EXECUTE v_sqldynamic3;

    FOR rec IN SELECT DISTINCT "HRME_Id" FROM "ISM_Empids_Temp"
    LOOP
        v_HRME_Id := rec."HRME_Id";

        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp";
        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp1";
        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp2";

        v_sqldynamic1 := '
        CREATE TEMP TABLE "ISM_AllEmprecords_temp1" AS 
        SELECT * FROM (
        SELECT DISTINCT "ISMTCR_TaskNo","ISMTCR_Title","ISMTCR_Status",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END||CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" =''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id"=' || v_HRME_Id || ') AS "EmpName",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END||CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" =''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id"="TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy",'''' AS "TransBy",
        TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate",''DD/MM/YYYY'') AS "StartDate",TO_CHAR("TCAT"."ISMTCRASTO_EndDate",''DD/MM/YYYY'') AS "EndDate","TCAT"."ISMTCRASTO_EndDate" AS "EndDate1",
        (CURRENT_DATE - CAST("ISMTCRASTO_EndDate" AS DATE)) AS "DiffDays"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id"="TC"."ISMTCR_Id"
        LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=1
        INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=1
        INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0
        WHERE "TC"."ISMTCR_ActiveFlg"=1 AND "TCAT"."HRME_Id" IN (' || v_HRME_Id || ')
        AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN (' || v_HRME_Id || '))
        AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "Status" || ''' || '','') > 0
        AND CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE) BETWEEN ''' || v_StartDate_D || ''' AND ''' || v_EndDate_D || ''' AND CAST("ISMTCRASTO_EndDate" AS DATE)>CAST("ISMTCRASTO_AssignedDate" AS DATE)) AS "New" ORDER BY "EndDate1"';

        v_sqldynamic2 := '
        CREATE TEMP TABLE "ISM_AllEmprecords_temp2" AS 
        SELECT * FROM (
        SELECT DISTINCT "ISMTCR_TaskNo","ISMTCR_Title","ISMTCR_Status",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END||CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id"=' || v_HRME_Id || ') AS "EmpName",
        (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''B'' THEN ''Bug/Complaints'' WHEN "TC"."ISMTCR_BugOREnhancementFlg" =''E'' THEN ''Enhancement'' ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",'''' AS "AssignedBy",
        (SELECT DISTINCT ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE "HRME_EmployeeFirstName" END||CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id"="TR"."ISMTCRTRTO_TransferredBy") AS "TransBy",
        TO_CHAR("TR"."ISMTCRTRTO_StartDate",''DD/MM/YYYY'') AS "StartDate",TO_CHAR("TR"."ISMTCRTRTO_EndDate",''DD/MM/YYYY'') AS "EndDate","TR"."ISMTCRTRTO_EndDate" AS "EndDate1",
        (CURRENT_DATE - CAST("ISMTCRTRTO_EndDate" AS DATE)) AS "DiffDays"
        FROM "ISM_TaskCreation" "TC"
        LEFT JOIN "ISM_TaskCreation_TransferredTo" "TR" ON "TR"."ISMTCR_Id"="TC"."ISMTCR_Id"
        LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id"="ac"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id"="cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag"=1
        INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id"="MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag"=1
        INNER JOIN "HR_Master_Employee" "HME" ON "TR"."HRME_Id"="HME"."HRME_Id" AND "HME"."HRME_ActiveFlag"=1 AND "HME"."HRME_LeftFlag"=0
        WHERE "TC"."ISMTCR_ActiveFlg"=1 AND "TR"."HRME_Id" IN (' || v_HRME_Id || ')
        AND "TC"."ISMTCR_Id" NOT IN (SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_TransferredBy" IN (' || v_HRME_Id || '))
        AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '','' || ''' || "Status" || ''' || '','') > 0 
        AND CAST("TR"."ISMTCRTRTO_EndDate" AS DATE) BETWEEN ''' || v_StartDate_D || ''' AND ''' || v_EndDate_D || ''' AND CAST("ISMTCRTRTO_EndDate" AS DATE)>CAST("ISMTCRTRTO_StartDate" AS DATE)
        ) AS "New" ORDER BY "EndDate1"';

        EXECUTE v_sqldynamic1;
        EXECUTE v_sqldynamic2;

        CREATE TEMP TABLE "ISM_AllEmprecords_temp" AS 
        SELECT * FROM (
            SELECT * FROM "ISM_AllEmprecords_temp1" 
            UNION ALL 
            SELECT * FROM "ISM_AllEmprecords_temp2"
        ) AS "New";

        FOR rec IN SELECT * FROM "ISM_AllEmprecords_temp"
        LOOP
            v_ISMTCR_TaskNo := rec."ISMTCR_TaskNo";
            v_ISMTCR_Title := rec."ISMTCR_Title";
            v_ISMTCR_Status := rec."ISMTCR_Status";
            v_EmpName := rec."EmpName";
            v_ISMTCR_BugOREnhancementFlg := rec."ISMTCR_BugOREnhancementFlg";
            v_AssignedBy := rec."AssignedBy";
            v_TransBy := rec."TransBy";
            v_StartDate := rec."StartDate";
            v_EndDate := rec."EndDate";
            v_EndDate1 := rec."EndDate1";
            v_DiffDays := rec."DiffDays";

            INSERT INTO "ISM_AllEmpsOpenIssuesDevReprt_Temp" (
                "ISMTCR_TaskNo","ISMTCR_Title","ISMTCR_Status","EmpName","ISMTCR_BugOREnhancementFlg",
                "AssignedBy","TransBy","StartDate","EndDate","EndDate1","DiffDays","AssignedStatus"
            )
            VALUES(
                v_ISMTCR_TaskNo,v_ISMTCR_Title,v_ISMTCR_Status,v_EmpName,v_ISMTCR_BugOREnhancementFlg,
                v_AssignedBy,v_TransBy,v_StartDate,v_EndDate,v_EndDate1,v_DiffDays,'Assigned'
            );
        END LOOP;

        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp";
        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp1";
        DROP TABLE IF EXISTS "ISM_AllEmprecords_temp2";
    END LOOP;

    IF "NoofDays" = 0 THEN
        RETURN QUERY
        SELECT * FROM "ISM_AllEmpsOpenIssuesDevReprt_Temp"
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        '' AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'NotPlanned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo") OR "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo"))
        AND CAST("ISMTCR_CreationDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE)
        AND "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE CAST("ISMTPLTA_EndDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE))
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        '' AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'Planned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo") OR "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo"))
        AND CAST("ISMTCR_CreationDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE)
        AND "ISMTCR_Id" IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE CAST("ISMTPLTA_EndDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE));

    ELSIF "NoofDays" = 10 THEN
        RETURN QUERY
        SELECT * FROM "ISM_AllEmpsOpenIssuesDevReprt_Temp" WHERE "DiffDays" >= 10
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        v_EndDate_D AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'NotPlanned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo") OR "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo"))
        AND CAST("ISMTCR_CreationDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE)
        AND "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE CAST("ISMTPLTA_EndDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE))
        AND (v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) >= 10
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        '' AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'Planned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo") OR "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo"))
        AND CAST("ISMTCR_CreationDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE)
        AND "ISMTCR_Id" IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE CAST("ISMTPLTA_EndDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE))
        AND (v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) >= 10;

    ELSIF "NoofDays" = 20 THEN
        RETURN QUERY
        SELECT * FROM "ISM_AllEmpsOpenIssuesDevReprt_Temp" WHERE "DiffDays" >= 20
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        v_EndDate_D AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'NotPlanned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo") OR "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo"))
        AND CAST("ISMTCR_CreationDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE)
        AND "ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE CAST("ISMTPLTA_EndDate" AS DATE) BETWEEN CAST("StartDateN" AS DATE) AND CAST("EndDateN" AS DATE))
        AND (v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) >= 20
        UNION ALL
        SELECT "TC"."ISMTCR_TaskNo","TC"."ISMTCR_Title","TC"."ISMTCR_Status",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='' THEN '' ELSE "HRME_EmployeeFirstName" END||
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || 
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END) AS "EmpName",
        "TC"."ISMTCR_BugOREnhancementFlg",'' AS "AssignedBy",'' AS "TransBy",TO_CHAR("ISMTCR_CreationDate",'DD/MM/YYYY') AS "StartDate",
        '' AS "EndDate",NULL::DATE AS "EndDate1",(v_EndDate_DF - CAST("ISMTCR_CreationDate" AS DATE)) AS "DiffDays",'Planned & NotAssigned' AS "AssignedStatus"
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="TC"."HRME_Id"
        WHERE "ISMTCR_Status" = 'Open' AND ("ISMTCR_Id" NOT IN (SELECT "ISMTCR_Id" FROM "ISM_TaskCreation