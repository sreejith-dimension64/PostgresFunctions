CREATE OR REPLACE FUNCTION "dbo"."IVRM_Email_Outgoing_For_Sports"(
    "EmailId" VARCHAR(50),
    "Message" VARCHAR(1000),
    "module" VARCHAR(50),
    "MI_Id" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "date" TIMESTAMP;
BEGIN
    "date" := CURRENT_TIMESTAMP;
    
    INSERT INTO "IVRM_Email_sentBox"(
        "MI_Id",
        "Email_Id",
        "Message",
        "Datetime",
        "Message_id",
        "Module_Name",
        "CreatedDate",
        "UpdatedDate"
    )
    VALUES(
        "MI_Id",
        "EmailId",
        "Message",
        "date",
        '',
        "module",
        "date",
        "date"
    );
    
    RETURN;
END;
$$;