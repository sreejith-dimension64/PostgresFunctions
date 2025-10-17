CREATE OR REPLACE FUNCTION "dbo"."ISM_Daily_Deviation_Employee_Report"(
    "p_HRME_Id" TEXT
)
RETURNS TABLE(
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_Status" VARCHAR,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "AssignedBy" TEXT,
    "StartDate" VARCHAR,
    "EndDate" VARCHAR,
    "TotalDays" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_todate" TIMESTAMP;
    "v_EndDate_N" TIMESTAMP;
BEGIN
    "v_EndDate_N" := CURRENT_TIMESTAMP;
    
    RETURN QUERY
    SELECT DISTINCT 
        "TC"."ISMTCR_TaskNo",
        "TC"."ISMTCR_Title",
        "TC"."ISMTCR_Status", 
        (CASE 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
            ELSE 'Others' 
        END)::TEXT AS "ISMTCR_BugOREnhancementFlg",
        (SELECT DISTINCT (
            (CASE 
                WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
                ELSE "HRME_EmployeeFirstName" 
            END || 
            CASE 
                WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeMiddleName" 
            END || 
            CASE 
                WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeLastName" 
            END)
        ) 
        FROM "HR_Master_Employee" "MME" 
        WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy")::TEXT AS "AssignedBy",
        TO_CHAR("TCAT"."ISMTCRASTO_StartDate", 'DD/MM/YYYY')::VARCHAR AS "StartDate",
        TO_CHAR("TCAT"."ISMTCRASTO_EndDate", 'DD/MM/YYYY')::VARCHAR AS "EndDate",
        (DATE_PART('day', CURRENT_DATE - CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE)))::INTEGER AS "TotalDays"
    FROM "ISM_TaskCreation" "TC"
    INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
    INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
    WHERE "TC"."ISMTCR_ActiveFlg" = 1 
        AND "TCAT"."HRME_Id"::TEXT = "p_HRME_Id"
        AND "TC"."ISMTCR_Id" NOT IN (
            SELECT DISTINCT "ISMTCR_Id" 
            FROM "ISM_TaskCreation_TransferredTo" 
            WHERE "ISMTCRTRTO_TransferredBy"::TEXT = "p_HRME_Id"
        )
        AND "TC"."ISMTCR_Status" IN ('Inprogress', 'Open')
        AND CAST("TCAT"."ISMTCRASTO_EndDate" AS DATE) <= "v_EndDate_N"
    
    UNION ALL
    
    SELECT DISTINCT 
        "TC"."ISMTCR_TaskNo",
        "TC"."ISMTCR_Title",
        "TC"."ISMTCR_Status", 
        (CASE 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
            WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
            ELSE 'Others' 
        END)::TEXT AS "ISMTCR_BugOREnhancementFlg",
        (SELECT DISTINCT (
            (CASE 
                WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
                ELSE "HRME_EmployeeFirstName" 
            END || 
            CASE 
                WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeMiddleName" 
            END || 
            CASE 
                WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' 
                ELSE ' ' || "HRME_EmployeeLastName" 
            END)
        ) 
        FROM "HR_Master_Employee" "MME" 
        WHERE "MME"."HRME_Id" = "TR"."ISMTCRTRTO_TransferredBy")::TEXT AS "AssignedBy",
        TO_CHAR("TR"."ISMTCRTRTO_StartDate", 'DD/MM/YYYY')::VARCHAR AS "StartDate",
        TO_CHAR("TR"."ISMTCRTRTO_EndDate", 'DD/MM/YYYY')::VARCHAR AS "EndDate",
        (DATE_PART('day', CURRENT_DATE - CAST("TR"."ISMTCRTRTO_EndDate" AS DATE)))::INTEGER AS "TotalDays"
    FROM "ISM_TaskCreation" "TC"
    LEFT JOIN "ISM_TaskCreation_TransferredTo" "TR" ON "TR"."ISMTCR_Id" = "TC"."ISMTCR_Id"
    LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
    LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
    INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
    INNER JOIN "HR_Master_Employee" "HME" ON "TR"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
    WHERE "TC"."ISMTCR_ActiveFlg" = 1 
        AND "TR"."HRME_Id"::TEXT = "p_HRME_Id"
        AND "TC"."ISMTCR_Id" NOT IN (
            SELECT DISTINCT "ISMTCR_Id" 
            FROM "ISM_TaskCreation_TransferredTo" 
            WHERE "ISMTCRTRTO_TransferredBy"::TEXT = "p_HRME_Id"
        )
        AND "TC"."ISMTCR_Status" IN ('Inprogress', 'Open')
        AND CAST("TR"."ISMTCRTRTO_EndDate" AS DATE) <= "v_EndDate_N";
END;
$$;