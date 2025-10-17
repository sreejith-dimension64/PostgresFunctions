CREATE OR REPLACE FUNCTION "dbo"."exit_employee_relieving_report_pro"(
    "MI_Id" bigint,
    "HRMD_Id" text,
    "HRMDES_Id" text,
    "FROMDATE" timestamp,
    "TODATE" timestamp
)
RETURNS TABLE(
    "employeename3" text,
    "hrme_id" bigint,
    "company_name" text,
    "HRMD_DepartmentName" text,
    "HRMDES_DesignationName" text,
    "ISMRESG_TentativeLeavingDate" timestamp,
    "ISMRESG_MgmtApprRejFlg" text,
    "ISMRESG_ResignationDate" timestamp,
    "ISMRESG_Id" bigint,
    "ISMRESG_Remarks" text,
    "CreatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "FROMDATE1" varchar(50);
    "TODATE1" varchar(50);
    "dynamicsql" text;
BEGIN

    SELECT TO_CHAR("FROMDATE", 'YYYY-MM-DD') INTO "FROMDATE1";
    SELECT TO_CHAR("TODATE", 'YYYY-MM-DD') INTO "TODATE1";

    IF ("FROMDATE" > CURRENT_TIMESTAMP) THEN
        "dynamicsql" := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        as employeename3, em."HRME_Id" as hrme_id, mi."MI_Name" as company_name, md."HRMD_DepartmentName" as "HRMD_DepartmentName", ds."HRMDES_DesignationName" as "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" as "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" as "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" as "ISMRESG_ResignationDate", r."ISMRESG_Id" as "ISMRESG_Id", r."ISMRESG_Remarks" as "ISMRESG_Remarks", rl."CreatedDate" as "CreatedDate" 
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi, "ISM_Resignation_RelievingLetter" rl 
        WHERE r."HRME_Id" = em."HRME_Id" 
        AND r."ISMRESG_Id" = rl."ISMRESG_Id" 
        AND em."HRMD_Id" = md."HRMD_Id" 
        AND em."HRMDES_Id" = ds."HRMDES_Id" 
        AND r."MI_Id" = ' || "MI_Id"::text || ' 
        AND em."MI_Id" = ' || "MI_Id"::text || ' 
        AND mi."MI_Id" = em."MI_Id" 
        AND mi."MI_Id" = ' || "MI_Id"::text || ' 
        AND em."HRMD_Id" IN (' || "HRMD_Id" || ') 
        AND em."HRMDES_Id" IN (' || "HRMDES_Id" || ')';
        
        RETURN QUERY EXECUTE "dynamicsql";
    ELSE
        "dynamicsql" := '
        SELECT DISTINCT COALESCE(em."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(em."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(em."HRME_EmployeeLastName",'''')
        as employeename3, em."HRME_Id" as hrme_id, mi."MI_Name" as company_name, md."HRMD_DepartmentName" as "HRMD_DepartmentName", ds."HRMDES_DesignationName" as "HRMDES_DesignationName", r."ISMRESG_TentativeLeavingDate" as "ISMRESG_TentativeLeavingDate", r."ISMRESG_MgmtApprRejFlg" as "ISMRESG_MgmtApprRejFlg", r."ISMRESG_ResignationDate" as "ISMRESG_ResignationDate", r."ISMRESG_Id" as "ISMRESG_Id", r."ISMRESG_Remarks" as "ISMRESG_Remarks", rl."CreatedDate" as "CreatedDate" 
        FROM "ISM_Resignation" r, "HR_Master_Employee" em, "HR_Master_Department" md, "HR_Master_Designation" ds, "Master_Institution" mi, "ISM_Resignation_RelievingLetter" rl 
        WHERE r."HRME_Id" = em."HRME_Id" 
        AND r."ISMRESG_Id" = rl."ISMRESG_Id" 
        AND em."HRMD_Id" = md."HRMD_Id" 
        AND em."HRMDES_Id" = ds."HRMDES_Id" 
        AND r."MI_Id" = ' || "MI_Id"::text || ' 
        AND em."MI_Id" = ' || "MI_Id"::text || ' 
        AND mi."MI_Id" = em."MI_Id" 
        AND mi."MI_Id" = ' || "MI_Id"::text || ' 
        AND em."HRMD_Id" IN (' || "HRMD_Id" || ') 
        AND em."HRMDES_Id" IN (' || "HRMDES_Id" || ') 
        AND r."ISMRESG_ResignationDate" BETWEEN ''' || "FROMDATE1" || ''' AND ''' || "TODATE1" || '''';
        
        RETURN QUERY EXECUTE "dynamicsql";
    END IF;

    RETURN;
END;
$$;