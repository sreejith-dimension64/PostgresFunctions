CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_Blocked_Details"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT
)
RETURNS TABLE(
    "ISMBE_Id" BIGINT,
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "employeeName" TEXT,
    "HRME_EmployeeCode" TEXT,
    "HRMD_DepartmentName" TEXT,
    "MI_Name" TEXT,
    "ISMBE_BlockDate" TIMESTAMP,
    "ISEBE_UnblockDate" TIMESTAMP,
    "ISMBE_Reason" TEXT,
    "ISMBE_BlockFlg" BOOLEAN,
    "ISMBE_ActiveFlg" BOOLEAN,
    "blockedby" TEXT,
    "ISMEMN_ID" BIGINT,
    "flag" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
    d."ISMBE_Id",
    d."HRME_Id",
    d."HRMD_Id",
    d."employeeName",
    d."HRME_EmployeeCode",
    d."HRMD_DepartmentName",
    d."MI_Name",
    d."ISMBE_BlockDate",
    d."ISEBE_UnblockDate",
    d."ISMBE_Reason",
    d."ISMBE_BlockFlg",
    d."ISMBE_ActiveFlg",
    d."blockedby",
    d."ISMEMN_ID",
    CASE WHEN d."ISMBE_Reason" = 'Critical tasks over due - AutoBlock' OR d."ISMEMN_ID" IS NOT NULL THEN 1 ELSE 0 END AS "flag"
FROM (
    SELECT DISTINCT 
        "IBE"."ISMBE_Id",
        "HRE"."HRME_Id",
        "HRE"."HRMD_Id",
        ((CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
        OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
        OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "employeeName",
        "HRE"."HRME_EmployeeCode",
        "HRD"."HRMD_DepartmentName",
        "MI"."MI_Name",
        "IBE"."ISMBE_BlockDate",
        "ISEBE_UnblockDate",
        "ISMBE_Reason",
        "ISMBE_BlockFlg",
        "ISMBE_ActiveFlg",
        (SELECT DISTINCT ((CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
        OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
        OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)) AS "blockedby" 
        FROM "HR_Master_Employee" "a" 
        INNER JOIN "ivrm_staff_user_login" "b" ON "a"."HRME_Id" = "b"."Emp_Code" 
        WHERE "id" = "IBE"."ISMBE_CreatedBy" AND "b"."MI_Id" = "HRE"."MI_Id" LIMIT 1) AS "blockedby",
        "ISMEMN_ID"
    FROM "ISM_Block_Employee" "IBE" 
    INNER JOIN "HR_Master_Employee" "HRE" ON "IBE"."HRME_Id" = "HRE"."HRME_Id" AND "IBE"."ISMBE_ActiveFlg" = TRUE
    INNER JOIN "HR_Master_Department" "HRD" ON "HRE"."HRMD_Id" = "HRD"."HRMD_Id" AND "HRD"."HRMD_ActiveFlag" = TRUE
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HRE"."MI_Id" AND "MI"."MI_Id" = "HRD"."MI_Id" AND "MI"."MI_ActiveFlag" = TRUE
    WHERE "HRE"."HRME_ActiveFlag" = TRUE 
        AND "HRE"."HRME_LeftFlag" = FALSE 
        AND "HRE"."HRME_ActiveFlag" = TRUE 
        AND "IBE"."HRME_Id" = "@HRME_Id"::BIGINT 
        AND "ISMBE_BlockFlg" = TRUE 
        AND "ISMBE_ActiveFlg" = TRUE
) AS d
ORDER BY d."ISMBE_BlockDate" DESC;

END;
$$;