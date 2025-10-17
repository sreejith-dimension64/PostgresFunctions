CREATE OR REPLACE FUNCTION "dbo"."ISM_PlannerReport_Dashboard"()
RETURNS TABLE (
    "HRME_Id" INTEGER,
    "employeename" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "HRME_Photo" TEXT,
    "HRME_EmailId" TEXT,
    "HRMEMNO_MobileNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_StartDate_N VARCHAR(10);
    v_EndDate_N VARCHAR(10);
    v_betweendates TEXT;
    v_Startdate TIMESTAMP;
    v_EndDate TIMESTAMP;
BEGIN
    SELECT DISTINCT 
        TO_DATE("ISMTPL_StartDate", 'DD/MM/YYYY'),
        TO_DATE("ISMTPL_EndDate", 'DD/MM/YYYY')
    INTO v_Startdate, v_EndDate
    FROM "ISM_Task_Planner"
    WHERE TO_DATE("ISMTPL_StartDate", 'DD/MM/YYYY') <= CURRENT_DATE
        AND TO_DATE("ISMTPL_EndDate", 'DD/MM/YYYY') >= CURRENT_DATE
    ORDER BY TO_DATE("ISMTPL_StartDate", 'DD/MM/YYYY')
    LIMIT 1;

    v_StartDate_N := TO_CHAR(v_Startdate, 'YYYY-MM-DD');
    v_EndDate_N := TO_CHAR(v_EndDate, 'YYYY-MM-DD');

    IF COALESCE(v_StartDate_N, '') != '' AND COALESCE(v_EndDate_N, '') != '' THEN
        v_betweendates := '((TO_DATE("ITP"."ISMTPL_StartDate", ''DD/MM/YYYY''))>=''' || v_StartDate_N || ''' AND (TO_DATE("ITP"."ISMTPL_EndDate", ''DD/MM/YYYY''))<=''' || v_EndDate_N || ''')';
    ELSE
        v_betweendates := '1=1';
    END IF;

    v_Slqdymaic := '
        SELECT DISTINCT "UEM"."HRME_Id", 
        ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName"='''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || 
        CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END ||
        CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename,
        "HRME_EmployeeCode", "HRMD_DepartmentName", COALESCE("HRME_Photo", '''') AS "HRME_Photo", 
        COALESCE("HRME_EmailId", '''') AS "HRME_EmailId", COALESCE("HRMEMNO_MobileNo", '''') AS "HRMEMNO_MobileNo"
        FROM "HR_Master_Employee" "ME"
        INNER JOIN "ISM_User_Employees_Mapping" "UEM" ON "ME"."HRME_Id" = "UEM"."HRME_Id"
        INNER JOIN "HR_Master_Department" "hmd" ON "hmd"."HRMD_Id" = "ME"."HRMD_Id"
        INNER JOIN "HR_Master_Employee_MobileNo" "hmem" ON "hmem"."HRME_Id" = "ME"."HRME_Id"
        WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
        AND "UEM"."HRME_Id" NOT IN (
            SELECT DISTINCT "ITP"."HRME_Id"
            FROM "ISM_Task_Planner" "ITP"
            INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
            INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id" = "ITPT"."ISMTCR_Id"
            INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1
            WHERE "ITP"."ISMTPL_ActiveFlg" = 1 AND ' || v_betweendates || ')
        ORDER BY employeename';

    RETURN QUERY EXECUTE v_Slqdymaic;

END;
$$;