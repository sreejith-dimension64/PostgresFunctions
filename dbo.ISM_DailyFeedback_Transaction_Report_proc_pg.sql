CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyFeedback_Transaction_Report_proc"(
    "@HRME_Id" bigint, 
    "@RCVHRME_Id" bigint
)
RETURNS TABLE (
    "ISMDRFS_Id" bigint,
    "ISMDRFS_DailyReportId" bigint,
    "ISMDRFS_Send_HRME_Id" bigint,
    "ISMDRFS_Receive_HRME_Id" bigint,
    "ISMDRFS_Feedback" text,
    "ISMDRFS_Date" timestamp,
    "ISMDRFS_ActiveFlag" boolean,
    "ISMDRFS_CreatedBy" bigint,
    "ISMDRFS_CreatedDate" timestamp,
    "ISMDRFS_UpdatedBy" bigint,
    "ISMDRFS_UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS "feedback_temp1";
    DROP TABLE IF EXISTS "feedback_temp2";

    CREATE TEMP TABLE "feedback_temp1" AS 
    SELECT * FROM "ISM_DailyReport_Feedback_Send" 
    WHERE "ISMDRFS_Send_HRME_Id" = "@HRME_Id";

    CREATE TEMP TABLE "feedback_temp2" AS 
    SELECT * FROM "ISM_DailyReport_Feedback_Receive" 
    WHERE "ISMDRFR_Receive_HRME_Id" = "@RCVHRME_Id";

    RETURN QUERY
    SELECT * FROM "feedback_temp1"
    UNION ALL
    SELECT * FROM "feedback_temp2";

    DROP TABLE IF EXISTS "feedback_temp1";
    DROP TABLE IF EXISTS "feedback_temp2";
END;
$$;