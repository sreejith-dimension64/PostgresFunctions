CREATE OR REPLACE FUNCTION "dbo"."CLG_IVRM_Email_Outgoing"(
    "EmailId" VARCHAR(50),
    "Message" VARCHAR(1000),
    "module" VARCHAR(50),
    "MI_Id" BIGINT,
    "type" VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "IVRM_Email_sentBox"(
        "MI_Id",
        "Email_Id",
        "Message",
        "Datetime",
        "Message_id",
        "Module_Name",
        "CreatedDate",
        "UpdatedDate",
        "To_FLag"
    )
    VALUES(
        "MI_Id",
        "EmailId",
        "Message",
        CURRENT_TIMESTAMP,
        '',
        "module",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        "type"
    );
END;
$$;