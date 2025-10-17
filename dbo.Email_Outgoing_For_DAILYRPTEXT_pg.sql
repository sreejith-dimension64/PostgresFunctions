CREATE OR REPLACE FUNCTION "dbo"."Email_Outgoing_For_DAILYRPTEXT"(
    "EmailId" varchar(50),
    "Message" varchar(1000),
    "module" varchar(50),
    "MI_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "date" timestamp;
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
    
END;
$$;