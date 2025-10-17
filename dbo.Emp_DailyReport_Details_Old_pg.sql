CREATE OR REPLACE FUNCTION "dbo"."Emp_DailyReport_Details_Old" (
    "p_MI_Id" bigint,
    "p_HRME_Id" TEXT,
    "p_Fromdate" TEXT,
    "p_Todate" TEXT,
    "p_feedbackflg" boolean
)
RETURNS TABLE (
    "Employee_name" TEXT,
    "HRME_Id" bigint,
    "ISMTCR_TaskNo" TEXT,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Id" bigint,
    "ISMDRPT_Status" TEXT,
    "ISMDRPT_Remarks" TEXT,
    "ISMTPL_Id" bigint,
    "MI_Id" bigint,
    "ISMDRPT_Id" bigint,
    "ISMDRPT_Date" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" TEXT;
BEGIN
    IF "p_feedbackflg" = false THEN
        "v_dates" := 'AND CAST(a."ISMDRPT_Date" AS DATE) BETWEEN TO_DATE(''' || "p_Fromdate" || ''', ''YYYY-MM-DD'') AND TO_DATE(''' || "p_Fromdate" || ''', ''YYYY-MM-DD'')';
        
        "v_Slqdymaic" := '
        SELECT DISTINCT
        ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '''' THEN '''' ELSE
        b."HRME_EmployeeFirstName" END || CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = ''''
        OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = ''''
        OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END)) AS "Employee_name",
        a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
        FROM "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
        WHERE a."HRME_Id" = b."HRME_Id" AND a."ISMTCR_Id" = c."ISMTCR_Id" AND a."MI_Id" = ' || "p_MI_Id"::TEXT || ' AND b."HRME_Id" IN (' || "p_HRME_Id" || ') ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
    ELSE
        IF "p_Fromdate" != '' AND "p_Todate" != '' THEN
            "v_dates" := 'AND CAST(a."ISMDRPT_Date" AS DATE) BETWEEN TO_DATE(''' || "p_Fromdate" || ''', ''YYYY-MM-DD'') AND TO_DATE(''' || "p_Todate" || ''', ''YYYY-MM-DD'')';
            
            "v_Slqdymaic" := '
            SELECT DISTINCT
            ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '''' THEN '''' ELSE
            b."HRME_EmployeeFirstName" END || CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = ''''
            OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = ''''
            OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END)) AS "Employee_name",
            a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
            FROM "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
            WHERE a."HRME_Id" = b."HRME_Id" AND a."ISMTCR_Id" = c."ISMTCR_Id" AND a."MI_Id" = ' || "p_MI_Id"::TEXT || ' AND b."HRME_Id" IN (' || "p_HRME_Id" || ') ' || "v_dates";
            
            RETURN QUERY EXECUTE "v_Slqdymaic";
        ELSE
            "v_Slqdymaic" := '
            SELECT DISTINCT
            ((CASE WHEN b."HRME_EmployeeFirstName" IS NULL OR b."HRME_EmployeeFirstName" = '''' THEN '''' ELSE
            b."HRME_EmployeeFirstName" END || CASE WHEN b."HRME_EmployeeMiddleName" IS NULL OR b."HRME_EmployeeMiddleName" = ''''
            OR b."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" IS NULL OR b."HRME_EmployeeLastName" = ''''
            OR b."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || b."HRME_EmployeeLastName" END)) AS "Employee_name",
            a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
            FROM "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
            WHERE a."HRME_Id" = b."HRME_Id" AND a."ISMTCR_Id" = c."ISMTCR_Id" AND a."MI_Id" = ' || "p_MI_Id"::TEXT || ' AND b."HRME_Id" IN (' || "p_HRME_Id" || ')';
            
            RETURN QUERY EXECUTE "v_Slqdymaic";
        END IF;
    END IF;
END;
$$;