CREATE OR REPLACE FUNCTION "dbo"."IVRM_Email_Outgoing_new_table"(
    "Message" VARCHAR(1000),
    "SSD_HeaderName" VARCHAR(50),
    "MI_Id" BIGINT,
    "SSD_TransactionId" TEXT,
    "SSD_ToFlag" TEXT,
    "SSD_SystemIP" TEXT,
    "SSD_NetworkIP" TEXT,
    "SSD_MAACAddress" TEXT,
    "SSD_SchedulerFlag" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "date" TIMESTAMP;
    "time" TIME;
BEGIN
    "date" := CURRENT_TIMESTAMP;
    "time" := CURRENT_TIMESTAMP::TIME;
    
    INSERT INTO "SMS_Sent_Details"(
        "MI_Id",
        "SSD_HeaderName",
        "SSD_SentDate",
        "SSD_Senttime",
        "SSD_TransactionId",
        "SSD_ToFlag",
        "SSD_SystemIP",
        "SSD_NetworkIP",
        "SSD_MAACAddress",
        "SSD_SchedulerFlag",
        "CreatedDate",
        "UpdatedDate"
    )
    VALUES(
        "MI_Id",
        "SSD_HeaderName",
        "date",
        "time",
        "SSD_TransactionId",
        "SSD_ToFlag",
        "SSD_SystemIP",
        "SSD_NetworkIP",
        "SSD_MAACAddress",
        "SSD_SchedulerFlag",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );
    
    RETURN;
END;
$$;