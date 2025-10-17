CREATE OR REPLACE FUNCTION "dbo"."exit_employee_report_pro"(
    p_MI_Id bigint,
    p_HRMD_Id text,
    p_HRMDES_Id text,
    p_FROMDATE timestamp,
    p_TODATE timestamp,
    p_ACCEPT bigint,
    p_REJECT bigint
)
RETURNS TABLE(
    employeename3 text,
    company_name text,
    "HRMD_DepartmentName" text,
    "HRMDES_DesignationName" text,
    "ISMRESG_TentativeLeavingDate" timestamp,
    "ISMRESG_MgmtApprRejFlg" text,
    "ISMRESG_ResignationDate" timestamp,
    "ISMRESG_Id" bigint,
    "ISMRESG_Remarks" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FROMDATE1 varchar(50);
    v_TODATE1 varchar(50);
    v_dynamicsql text;
BEGIN
    SELECT TO_CHAR(p_FROMDATE, 'YYYY-MM-DD') INTO v_FROMDATE1;
    SELECT TO_CHAR(p_TODATE, 'YYYY-MM-DD') INTO v_TODATE1;

    IF (p_ACCEPT = 3 AND p_REJECT = 2) THEN
        v_dynamicsql := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        AS employeename3, mi."MI_Name" AS company_name, md."HRMD_DepartmentName" AS "HRMD_DepartmentName", ds."HRMDES_DesignationName" AS "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" AS "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" AS "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" AS "ISMRESG_ResignationDate", r."ISMRESG_Id" AS "ISMRESG_Id", r."ISMRESG_Remarks" AS "ISMRESG_Remarks"
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi
        WHERE r."HRME_Id" = em."HRME_Id" AND em."HRMD_Id" = md."HRMD_Id" AND em."HRMDES_Id" = ds."HRMDES_Id" AND r."MI_Id" = ' || p_MI_Id || ' AND em."MI_Id" = ' || p_MI_Id || ' AND mi."MI_Id" = em."MI_Id" AND mi."MI_Id" = ' || p_MI_Id || ' AND em."HRMD_Id" IN (' || p_HRMD_Id || ') AND em."HRMDES_Id" IN (' || p_HRMDES_Id || ') AND r."ISMRESG_ResignationDate" BETWEEN ''' || v_FROMDATE1 || ''' AND ''' || v_TODATE1 || ''' AND r."ISMRESG_MgmtApprRejFlg" = ''REJECT''';
        RETURN QUERY EXECUTE v_dynamicsql;

    ELSIF (p_ACCEPT = 1 AND p_REJECT = 4) THEN
        v_dynamicsql := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        AS employeename3, mi."MI_Name" AS company_name, md."HRMD_DepartmentName" AS "HRMD_DepartmentName", ds."HRMDES_DesignationName" AS "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" AS "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" AS "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" AS "ISMRESG_ResignationDate", r."ISMRESG_Id" AS "ISMRESG_Id", r."ISMRESG_Remarks" AS "ISMRESG_Remarks"
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi
        WHERE r."HRME_Id" = em."HRME_Id" AND em."HRMD_Id" = md."HRMD_Id" AND em."HRMDES_Id" = ds."HRMDES_Id" AND r."MI_Id" = ' || p_MI_Id || ' AND em."MI_Id" = ' || p_MI_Id || ' AND mi."MI_Id" = em."MI_Id" AND mi."MI_Id" = ' || p_MI_Id || ' AND em."HRMD_Id" IN (' || p_HRMD_Id || ') AND em."HRMDES_Id" IN (' || p_HRMDES_Id || ') AND r."ISMRESG_ResignationDate" BETWEEN ''' || v_FROMDATE1 || ''' AND ''' || v_TODATE1 || ''' AND r."ISMRESG_MgmtApprRejFlg" = ''ACCEPT''';
        RETURN QUERY EXECUTE v_dynamicsql;

    ELSIF (p_ACCEPT = 1 AND p_REJECT = 2) THEN
        v_dynamicsql := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        AS employeename3, mi."MI_Name" AS company_name, md."HRMD_DepartmentName" AS "HRMD_DepartmentName", ds."HRMDES_DesignationName" AS "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" AS "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" AS "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" AS "ISMRESG_ResignationDate", r."ISMRESG_Id" AS "ISMRESG_Id", r."ISMRESG_Remarks" AS "ISMRESG_Remarks"
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi
        WHERE r."HRME_Id" = em."HRME_Id" AND em."HRMD_Id" = md."HRMD_Id" AND em."HRMDES_Id" = ds."HRMDES_Id" AND r."MI_Id" = ' || p_MI_Id || ' AND em."MI_Id" = ' || p_MI_Id || ' AND mi."MI_Id" = em."MI_Id" AND mi."MI_Id" = ' || p_MI_Id || ' AND em."HRMD_Id" IN (' || p_HRMD_Id || ') AND em."HRMDES_Id" IN (' || p_HRMDES_Id || ') AND r."ISMRESG_ResignationDate" BETWEEN ''' || v_FROMDATE1 || ''' AND ''' || v_TODATE1 || '''';
        RETURN QUERY EXECUTE v_dynamicsql;

    ELSIF (p_FROMDATE > NOW()) THEN
        v_dynamicsql := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        AS employeename3, mi."MI_Name" AS company_name, md."HRMD_DepartmentName" AS "HRMD_DepartmentName", ds."HRMDES_DesignationName" AS "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" AS "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" AS "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" AS "ISMRESG_ResignationDate", r."ISMRESG_Id" AS "ISMRESG_Id", r."ISMRESG_Remarks" AS "ISMRESG_Remarks"
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi
        WHERE r."HRME_Id" = em."HRME_Id" AND em."HRMD_Id" = md."HRMD_Id" AND em."HRMDES_Id" = ds."HRMDES_Id" AND r."MI_Id" = ' || p_MI_Id || ' AND em."MI_Id" = ' || p_MI_Id || ' AND mi."MI_Id" = em."MI_Id" AND mi."MI_Id" = ' || p_MI_Id || ' AND em."HRMD_Id" IN (' || p_HRMD_Id || ') AND em."HRMDES_Id" IN (' || p_HRMDES_Id || ')';
        RETURN QUERY EXECUTE v_dynamicsql;
    END IF;

    RETURN;
END;
$$;