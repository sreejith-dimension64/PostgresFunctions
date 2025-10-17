CREATE OR REPLACE FUNCTION "dbo"."Emp_DailyReport_Details" (
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
    "v_MI_Id" bigint;
BEGIN
    "v_MI_Id" := 0;

    IF ("p_feedbackflg" = false) THEN
        "v_dates" := 'and a."ISMDRPT_Date"::date between TO_DATE(''' || "p_Fromdate" || ''', ''DD/MM/YYYY'') and TO_DATE(''' || "p_Fromdate" || ''', ''DD/MM/YYYY'')';

        "v_Slqdymaic" := '
        select distinct 
        ((CASE WHEN b."HRME_EmployeeFirstName" is null or b."HRME_EmployeeFirstName"='''' then '''' else 
        b."HRME_EmployeeFirstName" end || CASE WHEN b."HRME_EmployeeMiddleName" is null or b."HRME_EmployeeMiddleName" = '''' 
        or b."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" is null or b."HRME_EmployeeLastName" = '''' 
        or b."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeLastName" END )) as "Employee_name", 
        a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
        from "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
        where a."HRME_Id"=b."HRME_Id" and a."ISMTCR_Id"=c."ISMTCR_Id" and b."HRME_Id" in(' || "p_HRME_Id" || ')';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSE
        IF "p_Fromdate" != '' and "p_Todate" != '' THEN
            "v_dates" := 'and a."ISMDRPT_Date"::date between TO_DATE(''' || "p_Fromdate" || ''', ''DD/MM/YYYY'') and TO_DATE(''' || "p_Todate" || ''', ''DD/MM/YYYY'')';

            "v_Slqdymaic" := '
            select distinct 
            ((CASE WHEN b."HRME_EmployeeFirstName" is null or b."HRME_EmployeeFirstName"='''' then '''' else 
            b."HRME_EmployeeFirstName" end || CASE WHEN b."HRME_EmployeeMiddleName" is null or b."HRME_EmployeeMiddleName" = '''' 
            or b."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" is null or b."HRME_EmployeeLastName" = '''' 
            or b."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeLastName" END )) as "Employee_name", 
            a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
            from "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
            where a."HRME_Id"=b."HRME_Id" and a."ISMTCR_Id"=c."ISMTCR_Id" and b."HRME_Id" in(' || "p_HRME_Id" || ') ' || "v_dates";

            RETURN QUERY EXECUTE "v_Slqdymaic";

        ELSE
            "v_Slqdymaic" := '
            select distinct 
            ((CASE WHEN b."HRME_EmployeeFirstName" is null or b."HRME_EmployeeFirstName"='''' then '''' else 
            b."HRME_EmployeeFirstName" end || CASE WHEN b."HRME_EmployeeMiddleName" is null or b."HRME_EmployeeMiddleName" = '''' 
            or b."HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeMiddleName" END || CASE WHEN b."HRME_EmployeeLastName" is null or b."HRME_EmployeeLastName" = '''' 
            or b."HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || b."HRME_EmployeeLastName" END )) as "Employee_name", 
            a."HRME_Id", c."ISMTCR_TaskNo", c."ISMTCR_Title", c."ISMTCR_Id", a."ISMDRPT_Status", a."ISMDRPT_Remarks", a."ISMTPL_Id", b."MI_Id", a."ISMDRPT_Id", a."ISMDRPT_Date"
            from "ISM_DailyReport" a, "HR_Master_Employee" b, "ISM_TaskCreation" c
            where a."HRME_Id"=b."HRME_Id" and a."ISMTCR_Id"=c."ISMTCR_Id" and b."HRME_Id" in(' || "p_HRME_Id" || ')';

            RETURN QUERY EXECUTE "v_Slqdymaic";

        END IF;
    END IF;

    RETURN;
END;
$$;