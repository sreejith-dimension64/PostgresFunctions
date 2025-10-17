CREATE OR REPLACE FUNCTION "dbo"."GET_SMS_APPROVAL_NEXTLEVEL" (
    "SSD_HeaderName" TEXT,
    "MI_Id" BIGINT,
    "USER_Id" BIGINT,
    "SMA_Level" INT
)
RETURNS TABLE (
    "ssD_TransactionId" BIGINT,
    "ssD_Id" BIGINT,
    "headername" TEXT,
    "ssD_SentDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."ssD_TransactionId",
        a."ssD_Id",
        a."SSD_HeaderName" as "headername",
        a."ssD_SentDate"
    FROM "SMS_Sent_Details" a
    INNER JOIN "SMS_Sent_Details_Nowise" b ON a."SSD_Id" = b."SSD_Id"
    INNER JOIN "SMS_Mail_Approval" c ON a."SSD_HeaderName" = c."SMA_HeaderName"
    INNER JOIN "SMS_Transaction_Approval_Details" d ON a."SSD_TransactionId" = d."STAD_TransNo"
    WHERE a."MI_Id" = "MI_Id" 
        AND a."SSD_HeaderName" = "SSD_HeaderName" 
        AND c."IVRMUL_Id" = "USER_Id" 
        AND d."STAD_ApprStatus" = 'PENDING' 
        AND a."SSD_TransactionId" IN (
            SELECT DISTINCT a2."SSD_TransactionId" 
            FROM "SMS_Sent_Details" a2
            INNER JOIN "SMS_Sent_Details_Nowise" b2 ON a2."SSD_Id" = b2."SSD_Id"
            INNER JOIN "SMS_Mail_Approval" c2 ON a2."SSD_HeaderName" = c2."SMA_HeaderName"
            INNER JOIN "SMS_Transaction_Approval_Details" d2 ON a2."SSD_TransactionId" = d2."STAD_TransNo"
            WHERE a2."MI_Id" = "MI_Id" 
                AND a2."SSD_HeaderName" = "SSD_HeaderName"  
                AND d2."STAD_ApprStatus" != 'PENDING'
                AND c2."SMA_Level" < "SMA_Level"
        );

END;
$$;