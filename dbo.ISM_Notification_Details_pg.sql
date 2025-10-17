CREATE OR REPLACE FUNCTION "dbo"."ISM_Notification_Details"(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT
)
RETURNS TABLE(
    "ISMNO_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISMNO_Notification" TEXT,
    "genratedby" TEXT,
    "tasktype" TEXT,
    "ISMNO_ReadFlg" BOOLEAN,
    "ISMNO_MakeUnReadFlg" BOOLEAN,
    "ISMNO_NotificationType" TEXT,
    "ISMNO_NoticationDate" TIMESTAMP,
    "ISMNO_ActiveFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "INO"."ISMNO_Id",
        "INO"."HRME_Id",
        "INO"."ISMNO_Notification",
        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HME"."HRME_EmployeeFirstName" = '' THEN '' 
              ELSE "HME"."HRME_EmployeeFirstName" END || 
         CASE WHEN "HME"."HRME_EmployeeMiddleName" IS NULL OR "HME"."HRME_EmployeeMiddleName" = '' 
                   OR "HME"."HRME_EmployeeMiddleName" = '0' THEN '' 
              ELSE ' ' || "HME"."HRME_EmployeeMiddleName" END || 
         CASE WHEN "HME"."HRME_EmployeeLastName" IS NULL OR "HME"."HRME_EmployeeLastName" = '' 
                   OR "HME"."HRME_EmployeeLastName" = '0' THEN '' 
              ELSE ' ' || "HME"."HRME_EmployeeLastName" END) AS "genratedby",
        (CASE WHEN "INO"."ISMNO_NotificationType" = 'DR' THEN 'Daily Report'
              WHEN "INO"."ISMNO_NotificationType" = 'PL' THEN 'Planner'
              ELSE "INO"."ISMNO_NotificationType" END) AS "tasktype",
        "INO"."ISMNO_ReadFlg",
        "INO"."ISMNO_MakeUnReadFlg",
        "INO"."ISMNO_NotificationType",
        "INO"."ISMNO_NoticationDate",
        "INO"."ISMNO_ActiveFlag"
    FROM "ISM_Notifications" "INO"
    INNER JOIN "IVRM_Staff_User_Login" "UL" ON "INO"."ISMNO_CreatedBy" = "UL"."Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "UL"."Emp_Code" 
        AND "HME"."HRME_ActiveFlag" = true 
        AND "HME"."HRME_LeftFlag" = false
    WHERE "INO"."ISMNO_ActiveFlag" = true 
        AND "INO"."HRME_Id" = "HRME_Id"
    ORDER BY "INO"."ISMNO_NoticationDate" DESC;
END;
$$;