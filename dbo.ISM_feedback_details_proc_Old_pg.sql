CREATE OR REPLACE FUNCTION "dbo"."ISM_feedback_details_proc_Old"(
    "p_HRME_Id" bigint,
    "p_SENDER_HRME_Id" bigint
)
RETURNS TABLE(
    "MI_Id" bigint,
    "ISMTCR_Id" bigint,
    "ISMDRF_Send_HRME_Id" bigint,
    "ISMDRF_RCV_HRME_Id" bigint,
    "ISMTCR_TaskNo" varchar,
    "ISMTCR_Title" varchar,
    "ISMDRF_FeedBack" text,
    "CreatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "dbo"."ISM_DailyReport_FeedBack" 
    SET "ISMDRF_OpenFlg" = 1 
    WHERE "ISMDRF_Send_HRME_Id" = "p_SENDER_HRME_Id" 
    AND "ISMDRF_RCV_HRME_Id" = "p_HRME_Id";

    RETURN QUERY
    SELECT 
        b."MI_Id",
        a."ISMTCR_Id",
        a."ISMDRF_Send_HRME_Id",
        a."ISMDRF_RCV_HRME_Id",
        c."ISMTCR_TaskNo",
        c."ISMTCR_Title",
        a."ISMDRF_FeedBack",
        a."CreatedDate"
    FROM "dbo"."ISM_DailyReport_FeedBack" a
    INNER JOIN "dbo"."HR_Master_Employee" b ON a."ISMDRF_Send_HRME_Id" = b."HRME_Id"
    INNER JOIN "dbo"."ISM_TaskCreation" c ON a."ISMTCR_Id" = c."ISMTCR_Id"
    WHERE a."ISMDRF_RCV_HRME_Id" = "p_HRME_Id" 
    AND a."ISMDRF_Send_HRME_Id" = "p_SENDER_HRME_Id"
    ORDER BY a."CreatedDate" DESC;

    RETURN;
END;
$$;