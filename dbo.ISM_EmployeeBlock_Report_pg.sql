CREATE OR REPLACE FUNCTION "ISM_EmployeeBlock_Report"(
    "TypeFlg" VARCHAR(100),
    "SelectionFlag" VARCHAR(100),
    "startDate" TIMESTAMP,
    "endDate" TIMESTAMP,
    "MI_Id" VARCHAR(100),
    "HRMD_Id" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE(
    "ISMBE_Id" INTEGER,
    "HRME_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "employeename" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Name" VARCHAR,
    "ISMBE_BlockDate" TIMESTAMP,
    "ISEBE_UnblockDate" TIMESTAMP,
    "nofDays" INTEGER,
    "ISMBE_Reason" TEXT,
    "ISMBE_BlockFlg" BOOLEAN,
    "ISMBE_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "betweendates" TEXT;
    "StartDate_N" VARCHAR(10);
    "EndDate_N" VARCHAR(10);
    "v_startDate" TIMESTAMP;
    "v_endDate" TIMESTAMP;
BEGIN
    "v_startDate" := "startDate";
    "v_endDate" := "endDate";
    
    "StartDate_N" := TO_CHAR("v_startDate"::DATE, 'YYYY-MM-DD');
    "EndDate_N" := TO_CHAR("v_endDate"::DATE, 'YYYY-MM-DD');
    
    IF COALESCE("StartDate_N", '') != '' AND COALESCE("EndDate_N", '') != '' THEN
        "betweendates" := '(("IBE"."ISMBE_BlockDate" between ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || ''') OR ("IBE"."ISEBE_UnblockDate" between ''' || "StartDate_N" || ''' and ''' || "EndDate_N" || '''))';
    ELSE
        "betweendates" := '';
    END IF;
    
    IF "TypeFlg" = 'Block' THEN
        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true AND "IBE"."ISMBE_BlockFlg" = true
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true AND "IBE"."HRME_Id" IN (' || "HRME_Id" || ') AND "IBE"."ISMBE_BlockFlg" = true
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
        
    ELSIF "TypeFlg" = 'Unblock' THEN
        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true AND "IBE"."ISMBE_BlockFlg" = false
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true AND "IBE"."HRME_Id" IN (' || "HRME_Id" || ') AND "IBE"."ISMBE_BlockFlg" = true
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
        
    ELSIF "TypeFlg" = 'Both' THEN
        IF "SelectionFlag" = '1' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "SelectionFlag" = '2' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "IBE"."ISMBE_Id", "IBE"."HRME_Id", "HRE"."HRMD_Id",
            ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
            "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
            OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
            OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)) AS employeename, "HRE"."HRME_EmployeeCode",
            "HRD"."HRMD_DepartmentName", "MI"."MI_Name", "IBE"."ISMBE_BlockDate", "ISEBE_UnblockDate",
            ("IBE"."ISEBE_UnblockDate"::DATE - "IBE"."ISMBE_BlockDate"::DATE) + 1 AS nofDays,
            "ISMBE_Reason", "ISMBE_BlockFlg", "ISMBE_ActiveFlg"
            FROM "ISM_Block_Employee" "IBE"
            INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = true
            INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = true
            INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = true
            WHERE ' || "betweendates" || ' AND "HRE"."HRME_ActiveFlag" = true AND "HRE"."HRME_LeftFlag" = false AND "HRE"."HRME_ActiveFlag" = true AND "IBE"."HRME_Id" IN (' || "HRME_Id" || ')
            ORDER BY employeename';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
    END IF;
    
    RETURN;
END;
$$;