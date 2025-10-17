CREATE OR REPLACE FUNCTION "dbo"."ISM_Blocked_EmployeeList"()
RETURNS TABLE(
    "ISMBE_Id" INTEGER,
    "HRME_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "employeeName" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Name" VARCHAR,
    "ISMBE_BlockDate" TIMESTAMP,
    "ISEBE_UnblockDate" TIMESTAMP,
    "ISMBE_Reason" TEXT,
    "ISMBE_BlockFlg" BOOLEAN,
    "ISMBE_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "IBE"."ISMBE_Id",
        "HRE"."HRME_Id",
        "HRE"."HRMD_Id",
        (
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRE"."HRME_EmployeeFirstName" = '' THEN '' 
                  ELSE "HRE"."HRME_EmployeeFirstName" END ||
             CASE WHEN "HRE"."HRME_EmployeeMiddleName" IS NULL OR "HRE"."HRME_EmployeeMiddleName" = '' 
                       OR "HRE"."HRME_EmployeeMiddleName" = '0' THEN '' 
                  ELSE ' ' || "HRE"."HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRE"."HRME_EmployeeLastName" IS NULL OR "HRE"."HRME_EmployeeLastName" = '' 
                       OR "HRE"."HRME_EmployeeLastName" = '0' THEN '' 
                  ELSE ' ' || "HRE"."HRME_EmployeeLastName" END)
        ) AS "employeeName",
        "HRE"."HRME_EmployeeCode",
        "HRD"."HRMD_DepartmentName",
        "MI"."MI_Name",
        "IBE"."ISMBE_BlockDate",
        "IBE"."ISEBE_UnblockDate",
        "IBE"."ISMBE_Reason",
        "IBE"."ISMBE_BlockFlg",
        "IBE"."ISMBE_ActiveFlg"
    FROM "dbo"."ISM_Block_Employee" "IBE"
    INNER JOIN "dbo"."HR_Master_Employee" "HRE" 
        ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = TRUE
    INNER JOIN "dbo"."HR_Master_Department" "HRD" 
        ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
    INNER JOIN "dbo"."Master_Institution" "MI" 
        ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = TRUE
    WHERE "HRE"."HRME_ActiveFlag" = TRUE 
        AND "HRE"."HRME_LeftFlag" = FALSE 
        AND "HRE"."HRME_ActiveFlag" = TRUE
    ORDER BY "employeeName";
    
    RETURN;
END;
$$;