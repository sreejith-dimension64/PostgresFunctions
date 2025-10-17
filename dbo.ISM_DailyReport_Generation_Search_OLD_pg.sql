CREATE OR REPLACE FUNCTION "ISM_DailyReport_Generation_Search_OLD"(
    p_MI_Id TEXT,
    p_HRME_Id TEXT,
    p_Date TEXT,
    p_Flag BIGINT
)
RETURNS TABLE(
    "ISMTCR_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" TEXT,
    "HRMPR_Id" BIGINT,
    "HRMP_Name" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCR_CreationDate" TIMESTAMP,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_Status" TEXT,
    "ISMTCR_ReOpenFlg" BOOLEAN,
    "ISMTCR_ReOpenDate" TIMESTAMP,
    "ISMTCR_TaskNo" TEXT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" TEXT,
    "HRME_Id" BIGINT,
    "StartDate" TEXT,
    "EndDate" TEXT,
    "ISMTPLTA_EffortInHrs" NUMERIC,
    "createdby" TEXT,
    "assignedby" TEXT,
    "assignedto" TEXT,
    "tasktag" INTEGER,
    "addtoplannerflag" INTEGER,
    "ISMMTCAT_Id" BIGINT,
    "taskcategoryname" TEXT,
    "ISMMTCAT_CompulsoryFlg" BOOLEAN,
    "ISMDRPT_TimeTakenInHrsmin" TEXT,
    "efforts" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_enddate DATE;
    v_Slqdymaic2 TEXT;
    v_Slqdymaic3 TEXT;
    v_Slqdymaic4 TEXT;
BEGIN
    SELECT MAX("ISMTPL_EndDate"::DATE) INTO v_enddate
    FROM "ISM_Task_Planner"
    WHERE "ISMTPL_ActiveFlg" = TRUE AND "HRME_Id"::TEXT = p_HRME_Id;

    DROP TABLE IF EXISTS "StaffAdmin_Temp1";
    DROP TABLE IF EXISTS "StaffAdmin_Temp2";
    DROP TABLE IF EXISTS "StaffAdmin_Temp3";
    DROP TABLE IF EXISTS "StaffAdmin_Temp4";

    IF p_Flag = 1 THEN
        RETURN QUERY
        SELECT DISTINCT 
            "DR"."ISMDRPT_Id",
            "ITPT"."ISMTCR_Id"::BIGINT,
            0::BIGINT AS "HRMD_Id_dummy",
            "HMP"."HRMP_Name",
            "ITC"."ISMTCR_Desc",
            "DR"."ISMDRPT_Status",
            "DR"."ISMDRPT_Date",
            "DR"."ISMDRPT_Remarks",
            CASE WHEN "ITC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' ELSE 'Enhancement/Others' END AS "ISMTCR_BugOREnhancementFlg",
            CAST("DR"."ISMDRPT_TimeTakenInHrs" AS TEXT) || ' Hour' AS "ISMDRPT_TimeTakenInHrs",
            "CL"."ISMMCLT_ClientName",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '') ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '') = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '') = '' OR "HRE"."HRME_EmployeeLastName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END) AS assignedby,
            "CATEG"."ISMMTCAT_TaskCategoryName" AS taskcategoryname,
            "DR"."ISMDRPT_TimeTakenInHrs" AS efforts
        FROM "ISM_DailyReport" "DR"
        INNER JOIN "ISM_Task_Planner" "ITP" ON "DR"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
        INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "DR"."ISMTCR_Id" AND "ITC"."ISMTCR_ActiveFlg" = TRUE
        INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id" AND "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Priority" "HMP" ON "HMP"."HRMPR_Id" = "ITC"."HRMPR_Id"
        INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "ITP"."ISMTPL_PlannedBy" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
        LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "ITC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
        INNER JOIN "ISM_Master_TaskCategory" "CATEG" ON "ITC"."ISMMTCAT_Id" = "CATEG"."ISMMTCAT_Id"
        WHERE "DR"."MI_Id"::TEXT = p_MI_Id 
          AND "DR"."HRME_Id"::TEXT = p_HRME_Id 
          AND "DR"."ISMDRPT_Date"::TEXT = p_Date;

    ELSIF p_Flag = 3 THEN
        RETURN QUERY
        SELECT DISTINCT 
            "TC"."ISMTCR_Id",
            "TC"."HRMD_Id",
            "HRD"."HRMD_DepartmentName",
            "TC"."HRMPR_Id",
            "HRP"."HRMP_Name",
            CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' ELSE 'Enhancement/Others' END AS "ISMTCR_BugOREnhancementFlg",
            "TC"."ISMTCR_CreationDate",
            "TC"."ISMTCR_Title",
            "TC"."ISMTCR_Desc",
            "TC"."ISMTCR_Status",
            "TC"."ISMTCR_ReOpenFlg",
            "TC"."ISMTCR_ReOpenDate",
            "TC"."ISMTCR_TaskNo",
            "AC"."ISMMCLT_Id",
            "CL"."ISMMCLT_ClientName",
            "TC"."HRME_Id",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", 'DD-MM-YYYY') AS "StartDate",
            TO_CHAR("TCAT"."ISMTCRASTO_EndDate", 'DD-MM-YYYY') AS "EndDate",
            "TCAT"."ISMTCRASTO_EffortInHrs",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '') ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '') = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '') = '' OR "HRE"."HRME_EmployeeLastName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END) AS assignedby,
            "CATEG"."ISMMTCAT_TaskCategoryName" AS taskcategoryname,
            "TCAT"."ISMTCRASTO_Remarks",
            "TCAT"."ISMTCRASTO_StartDate",
            "CATEG"."ISMMTCAT_CompulsoryFlg",
            (CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = 'HOURS' THEN 'Hours' ELSE '' END ||
             CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = 'Minutes' THEN 'Minutes' ELSE '' END) AS "ISMDRPT_TimeTakenInHrsmin",
            "CATEG"."ISMMTCAT_EachTaskMaxDuration" AS efforts
        FROM "ISM_TaskCreation" "TC"
        LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
        LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
        LEFT JOIN "ISM_Task_Planner_Tasks" "ITP" ON "ITP"."ISMTCR_Id" = "TC"."ISMTCR_Id"
        LEFT JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
        INNER JOIN "HR_Master_Employee" "HRE" ON "TC"."HRME_Id" = "HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
        INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id" = "HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
        INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "TC"."HRME_Id"
        INNER JOIN "ISM_Master_TaskCategory" "CATEG" ON "TC"."ISMMTCAT_Id" = "CATEG"."ISMMTCAT_Id"
        WHERE "TC"."HRME_Id"::TEXT = p_HRME_Id 
          AND "TC"."ISMTCR_Status" IN ('Open', 'ReOpen')
          AND "TC"."ISMTCR_Id" NOT IN (
              SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = TRUE
          )
          AND "TC"."ISMTCR_Id" NOT IN (
              SELECT DISTINCT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE "ISMTPLTA_ActiveFlg" = TRUE
          )

        UNION ALL

        SELECT DISTINCT 
            "TC"."ISMTCR_Id",
            "TC"."HRMD_Id",
            "HRD"."HRMD_DepartmentName",
            "TC"."HRMPR_Id",
            "HRP"."HRMP_Name",
            CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' ELSE 'Enhancement/Others' END AS "ISMTCR_BugOREnhancementFlg",
            "TC"."ISMTCR_CreationDate",
            "TC"."ISMTCR_Title",
            "TC"."ISMTCR_Desc",
            "TC"."ISMTCR_Status",
            "TC"."ISMTCR_ReOpenFlg",
            "TC"."ISMTCR_ReOpenDate",
            "TC"."ISMTCR_TaskNo",
            "AC"."ISMMCLT_Id",
            "CL"."ISMMCLT_ClientName",
            "TC"."HRME_Id",
            TO_CHAR("TCAT"."ISMTCRASTO_StartDate", 'DD-MM-YYYY') AS "StartDate",
            TO_CHAR("TCAT"."ISMTCRASTO_EndDate", 'DD-MM-YYYY') AS "EndDate",
            "TCAT"."ISMTCRASTO_EffortInHrs",
            (COALESCE("HRE"."HRME_EmployeeFirstName", '') ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeMiddleName", '') = '' OR "HRE"."HRME_EmployeeMiddleName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
             CASE WHEN COALESCE("HRE"."HRME_EmployeeLastName", '') = '' OR "HRE"."HRME_EmployeeLastName" = '0' 
                  THEN '' ELSE ' ' || "HRE"."HRME_EmployeeLastName" END) AS assignedby,
            "CATEG"."ISMMTCAT_TaskCategoryName" AS taskcategoryname,
            "TCAT"."ISMTCRASTO_Remarks",
            "TCAT"."ISMTCRASTO_AssignedDate",
            "CATEG"."ISMMTCAT_CompulsoryFlg",
            (CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = 'HOURS' THEN 'Hours' ELSE '' END ||
             CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = 'Minutes' THEN 'Minutes' ELSE '' END) AS "ISMDRPT_TimeTakenInHrsmin",
            "CATEG"."ISMMTCAT_EachTaskMaxDuration" AS efforts
        FROM "ISM_TaskCreation" "TC"
        INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TC"."ISMTCR_ActiveFlg" = TRUE
        LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
        LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
        LEFT JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
        LEFT JOIN "ISM_Task_Planner" "ITP" ON "ITP"."ISMTPL_Id" = "ITPT"."ISMTPL_Id"
        INNER JOIN "HR_Master_Department" "HRD" ON "TC"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
        INNER JOIN "HR_Master_Employee" "HRE" ON "TCAT"."ISMTCRASTO_AssignedBy" = "HRE"."HRME_Id" AND "HRE"."HRME_ActiveFlag" = TRUE AND "HRE"."HRME_LeftFlag" = FALSE
        INNER JOIN "HR_Master_Priority" "HRP" ON "TC"."HRMPR_Id" = "HRP"."HRMPR_Id" AND "HRP"."HRMP_ActiveFlag" = TRUE
        INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Emp_Code" = "TC"."HRME_Id"
        INNER JOIN "ISM_Master_TaskCategory" "CATEG" ON "TC"."ISMMTCAT_Id" = "CATEG"."ISMMTCAT_Id"
        WHERE "TCAT"."ISMTCRASTO_ActiveFlg" = TRUE 
          AND "TCAT"."HRME_Id"::TEXT = p_HRME_Id
          AND "TCAT"."ISMTCR_Id" NOT IN (
              SELECT DISTINCT "ISMTCR_Id" FROM "ISM_Task_Planner_Tasks" WHERE "ISMTPLTA_ActiveFlg" = TRUE
          )
          AND "TCAT"."ISMTCRASTO_EndDate"::DATE <= v_enddate
          AND "TC"."ISMTCR_Status" IN ('Open', 'open')
        ORDER BY "ISMTCRASTO_AssignedDate";

    ELSIF p_Flag = 2 THEN
        EXECUTE FORMAT('
            CREATE TEMP TABLE "StaffAdmin_Temp2" AS
            SELECT DISTINCT 
                "TC"."ISMTCR_Id",
                "TC"."HRMD_Id",
                "MD"."HRMD_DepartmentName",
                "TC"."HRMPR_Id",
                "MP"."HRMP_Name",
                (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                      WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                      ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
                "TC"."ISMTCR_CreationDate",
                "TC"."ISMTCR_Title",
                "TC"."ISMTCR_Desc",
                "TC"."ISMTCR_Status",
                "TC"."ISMTCR_ReOpenFlg",
                "TC"."ISMTCR_ReOpenDate",
                "TC"."ISMTCR_TaskNo",
                "TCC"."ISMMCLT_Id",
                "CL"."ISMMCLT_ClientName",
                "TC"."HRME_Id",
                '''' AS "StartDate",
                '''' AS "EndDate",
                0::NUMERIC AS "ISMTPLTA_EffortInHrs",
                (SELECT "NormalizedUserName" FROM "ApplicationUser" "appuser" WHERE "appuser"."Id" = "TC"."ISMTCR_CreatedBy") AS createdby,
                ''NA'' AS assignedby,
                ''Not-Assigned'' AS assignedto,
                2 AS tasktag,
                1 AS addtoplannerflag,
                "TC"."ISMMTCAT_Id",
                "CATEG"."ISMMTCAT_TaskCategoryName" AS taskcategoryname,
                "CATEG"."ISMMTCAT_CompulsoryFlg",
                (CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = ''HOURS'' THEN ''Hours'' ELSE '''' END ||
                 CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = ''Minutes'' THEN ''Minutes'' ELSE '''' END) AS "ISMDRPT_TimeTakenInHrsmin",
                "CATEG"."ISMMTCAT_EachTaskMaxDuration" AS efforts
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_Client" "TCC" ON "TC"."ISMTCR_Id" = "TCC"."ISMTCR_Id"
            INNER JOIN "ISM_Master_Client_IEMapping" "CIE" ON "CIE"."ISMMCLT_Id" = "TCC"."ISMMCLT_Id"
            INNER JOIN "ISM_Master_Client" "CL" ON "TCC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id" AND "CL"."ISMMCLT_ActiveFlag" = TRUE
            INNER JOIN "HR_Master_Employee" "ME" ON "CIE"."ISMCIM_IEList" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = TRUE
            LEFT JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = TRUE
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = TRUE
            INNER JOIN "ApplicationUser" "AU" ON "AU"."Id" = "TCC"."ISMTCRCL_CreatedBy"
            INNER JOIN "ApplicationUserRole" "AUR" ON "AUR"."UserId" = "AU"."Id"
            INNER JOIN "IVRM_Role_Type" "IRT" ON "IRT"."IVRMRT_Id" = "AUR"."RoleTypeId"
            INNER JOIN "ISM_Master_TaskCategory" "CATEG" ON "TC"."ISMMTCAT_Id" = "CATEG"."ISMMTCAT_Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = TRUE 
              AND "TCC"."ISMTCRCL_ActiveFlg" = TRUE
              AND "TC"."ISMTCR_Id" NOT IN (
                  SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" WHERE "ISMTCRASTO_ActiveFlg" = TRUE
              )
              AND "TC"."ISMTCR_Id" NOT IN (
                  SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" WHERE "ISMTCRTRTO_ActiveFlg" = TRUE
              )
              AND "TC"."ISMTCR_Id" NOT IN (
                  SELECT DISTINCT B."ISMTCR_Id" 
                  FROM "ISM_Task_Planner" A 
                  INNER JOIN "ISM_Task_Planner_Tasks" B ON A."ISMTPL_Id" = B."ISMTPL_Id" 
                  WHERE A."ISMTPL_ActiveFlg" = TRUE 
                    AND A."HRME_Id"::TEXT IN (%s) 
                    AND %s::DATE BETWEEN A."ISMTPL_StartDate" AND A."ISMTPL_EndDate"
              )
              AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '',Open,ReOpen,'') > 0
              AND "CIE"."ISMCIM_IEList"::TEXT IN (%s) 
              AND "IRT"."IVRMRT_RoleFlag" = ''ClientUser''
            ORDER BY "ISMTCR_CreationDate" DESC',
            p_HRME_Id, p_Date, p_HRME_Id);

        EXECUTE FORMAT('
            CREATE TEMP TABLE "StaffAdmin_Temp3" AS
            SELECT DISTINCT 
                "TC"."ISMTCR_Id",
                "TC"."HRMD_Id",
                "MD"."HRMD_DepartmentName",
                "TC"."HRMPR_Id",
                "MP"."HRMP_Name",
                (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''B'' THEN ''Bug/Complaints''
                      WHEN "TC"."ISMTCR_BugOREnhancementFlg" = ''E'' THEN ''Enhancement''
                      ELSE ''Others'' END) AS "ISMTCR_BugOREnhancementFlg",
                "TC"."ISMTCR_CreationDate",
                "TC"."ISMTCR_Title",
                "TC"."ISMTCR_Desc",
                "TC"."ISMTCR_Status",
                "TC"."ISMTCR_ReOpenFlg",
                "TC"."ISMTCR_ReOpenDate",
                "TC"."ISMTCR_TaskNo",
                "AC"."ISMMCLT_Id",
                "CL"."ISMMCLT_ClientName",
                "TC"."HRME_Id",
                TO_CHAR("TCAT"."ISMTCRASTO_StartDate", ''DD-MM-YYYY'') AS "StartDate",
                TO_CHAR("TCAT"."ISMTCRASTO_EndDate", ''DD-MM-YYYY'') AS "EndDate",
                "TTO"."ISMTCRTRTO_EffortInHrs" AS "ISMTPLTA_EffortInHrs",
                (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
                         CASE WHEN COALESCE("ME"."HRME_EmployeeMiddleName", '''') = '''' OR "ME"."HRME_EmployeeMiddleName" = ''0'' 
                              THEN '''' ELSE '' '' || "ME"."HRME_EmployeeMiddleName" END ||
                         CASE WHEN COALESCE("ME"."HRME_EmployeeLastName", '''') = '''' OR "ME"."HRME_EmployeeLastName" = ''0'' 
                              THEN '''' ELSE '' '' || "ME"."HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" "ME" WHERE "ME"."HRME_Id" = "TC"."HRME_Id") AS createdby,
                (SELECT (COALESCE("ME"."HRME_EmployeeFirstName", '''') ||
                         CASE WHEN COALESCE("ME"."HRME_EmployeeMiddleName", '''') = '''' OR "ME"."HRME_EmployeeMiddleName" = ''0'' 
                              THEN '''' ELSE '' '' || "ME"."HRME_EmployeeMiddleName" END ||
                         CASE WHEN COALESCE("ME"."HRME_EmployeeLastName", '''') = '''' OR "ME"."HRME_EmployeeLastName" = ''0'' 
                              THEN '''' ELSE '' '' || "ME"."HRME_EmployeeLastName" END)
                 FROM "HR_Master_Employee" "ME" WHERE "ME"."HRME_Id" = "TTO"."ISMTCRTRTO_TransferredBy") AS assignedby,
                ''Transferred'' AS assignedto,
                3 AS tasktag,
                1 AS addtoplannerflag,
                "TC"."ISMMTCAT_Id",
                "CATEG"."ISMMTCAT_TaskCategoryName" AS taskcategoryname,
                "CATEG"."ISMMTCAT_CompulsoryFlg",
                (CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = ''HOURS'' THEN ''Hours'' ELSE '''' END ||
                 CASE WHEN "CATEG"."ISMMTCAT_DurationFlg" = ''Minutes'' THEN ''Minutes'' ELSE '''' END) AS "ISMDRPT_TimeTakenInHrsmin",
                "CATEG"."ISMMTCAT_EachTaskMaxDuration" AS efforts
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_TransferredTo" "TTO" ON "TTO"."ISMTCR_Id" = "TC"."ISMTCR_Id" AND "TTO"."ISMTCRTRTO_ActiveFlg" = TRUE
            LEFT JOIN "ISM_TaskCreation_Client" "AC" ON "TC"."ISMTCR_Id" = "AC"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "CL" ON "AC"."ISMMCLT_Id" = "CL"."ISMMCLT_Id"
            LEFT JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = TRUE
            INNER JOIN "HR_Master_Department" "MD" ON "TC"."HRMD_Id" = "MD"."HRMD_Id" AND "MD"."HRMD_ActiveFlag" = TRUE
            INNER JOIN "HR_Master_Employee" "ME" ON "TTO"."HRME_Id" = "ME"."HRME_Id" AND "ME"."HRME_ActiveFlag" = TRUE AND "ME"."HRME_LeftFlag" = FALSE
            INNER JOIN "ISM_Master_TaskCategory" "CATEG" ON "TC"."ISMMTCAT_Id" = "CATEG"."ISMMTCAT_Id"
            WHERE "TC"."ISMTCR_ActiveFlg" = TRUE
              AND POSITION('','' || "TC"."ISMTCR_Status" || '','' IN '',Open,ReOpen,'') > 0
              AND "TC"."ISMTCR_Id" NOT IN (
                  SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_AssignedTo" 
                  WHERE ("HRME_Id"::TEXT IN (%s)) OR ("ISMTCRASTO_AssignedBy"::TEXT IN (%s))
              )
              AND "TC"."ISMTCR_Id" NOT IN (
                  SELECT DISTINCT B."ISMTCR_Id" 
                  FROM "ISM_Task_Planner" A 
                  INNER JOIN "ISM_Task_Planner_Tasks" B ON A."ISMTPL_Id" = B."ISMTPL_Id" 
                  WHERE A."ISMTPL_ActiveFlg" = TRUE 
                    AND A."HRME_Id"::TEXT IN (%s) 
                    AND %s::DATE BETWEEN A."ISMTPL_StartDate" AND A."ISMTPL_EndDate"
              )
              AND "TTO"."HRME_Id"::TEXT IN (%s)
            ORDER BY "ISMTCR_CreationDate" DESC',
            p_