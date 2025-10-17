CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyFeedback_Transaction_proc"(
    "@ISMTCR_Id" bigint,
    "@HRME_Id" bigint
)
RETURNS TABLE(
    "ISMTCR_Id" bigint,
    "HRME_Id" bigint,
    "ISMDRFS_FeedBack" text,
    "ISMDRFS_Status" varchar(100),
    "createdate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS "ism_dailyfeedback_tfr_temp";
    
    CREATE TEMP TABLE "ism_dailyfeedback_tfr_temp" (
        "ISMDRFS_Id" bigint,
        "MI_Id" bigint,
        "ISMDRF_Id" bigint,
        "ISMTCR_Id" bigint,
        "HRME_Id" bigint,
        "ISMDRFS_FeedBack" text,
        "ISMDRFS_Status" varchar(100),
        "createdate" timestamp,
        "updatetime" timestamp
    );

    INSERT INTO "ism_dailyfeedback_tfr_temp"
    SELECT * FROM "ISM_DailyReport_Feedback_Send" 
    WHERE "ismtcr_id" = "@ISMTCR_Id" AND "ISMDRFS_Send_HRME_Id" = "@HRME_Id"
    UNION ALL
    SELECT * FROM "ISM_DailyReport_Feedback_Receive" 
    WHERE "ISMTCR_Id" = "@ISMTCR_Id" AND "ISMDRFR_Receive_HRME_Id" = "@HRME_Id";

    RETURN QUERY
    SELECT a."ISMTCR_Id", a."HRME_Id", a."ISMDRFS_FeedBack", a."ISMDRFS_Status", a."createdate"
    FROM "ism_dailyfeedback_tfr_temp" a
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    ORDER BY a."createdate";
END;
$$;