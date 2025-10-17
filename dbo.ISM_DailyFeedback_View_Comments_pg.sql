CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyFeedback_View_Comments"(
    "p_ISMTCR_Id" bigint, 
    "p_HRME_Id" bigint, 
    "p_Dept_Head_Id" bigint, 
    "p_DR_DATE" VARCHAR(10)
)
RETURNS TABLE(
    "empname" TEXT,
    "ISMDRFS_FeedBack" TEXT,
    "ISMDRFS_Status" TEXT,
    "createdate" TIMESTAMP
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT DISTINCT 
            (COALESCE("C"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("C"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("C"."HRME_EmployeeLastName", '')) AS "empname",
            "A"."ISMDRFS_FeedBack",
            "A"."ISMDRFS_Status",
            "A"."createdate"
        FROM "ISM_DailyReport_Feedback_Send" "A" 
        INNER JOIN "ISM_DailyReport_Feedback" "B" ON "A"."ISMDRF_Id" = "B"."ISMDRF_Id"
        INNER JOIN "HR_Master_Employee" "C" ON "C"."HRME_Id" = "B"."ISMDRF_RCV_HRME_Id"
        WHERE "B"."ISMTCR_ID" = "p_ISMTCR_Id" 
            AND "A"."ISMDRFS_Send_HRME_Id" = "p_HRME_Id" 
            AND "B"."ISMDRF_RCV_HRME_Id" = "p_Dept_Head_Id" 
            AND "B"."ISMDRF_Feedback_DR_Date" = TO_DATE("p_DR_DATE", 'DD/MM/YYYY')
        ORDER BY "A"."createdate"
        LIMIT 100
        
        UNION ALL
        
        SELECT DISTINCT 
            (COALESCE("C"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("C"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("C"."HRME_EmployeeLastName", '')) AS "empname",
            "A"."ISMDRFR_FeedBack",
            "A"."ISMDRFR_Status",
            "A"."createdate"
        FROM "ISM_DailyReport_Feedback_Receive" "A" 
        INNER JOIN "ISM_DailyReport_Feedback" "B" ON "A"."ISMDRF_Id" = "B"."ISMDRF_Id"
        INNER JOIN "HR_Master_Employee" "C" ON "C"."HRME_Id" = "A"."ISMDRFR_Receive_HRME_Id"
        WHERE "B"."ISMTCR_Id" = "p_ISMTCR_Id" 
            AND "A"."ISMDRFR_Receive_HRME_Id" = "p_HRME_Id" 
            AND "B"."ISMDRF_Send_HRME_Id" = "p_Dept_Head_Id" 
            AND "B"."ISMDRF_Feedback_DR_Date" = TO_DATE("p_DR_DATE", 'DD/MM/YYYY')
        ORDER BY "A"."createdate"
        LIMIT 100
    ) AS "d" 
    ORDER BY "createdate";
    
    RETURN;
END;
$$;