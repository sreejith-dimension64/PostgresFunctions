CREATE OR REPLACE FUNCTION "dbo"."IVRM_Email_Outgoing"(
    "EmailId" VARCHAR(50),
    "Message" VARCHAR(1000),
    "module" VARCHAR(50),
    "MI_Id" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    IF "module" = 'Transport' THEN
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
            'student'
        );
    ELSE
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
            CURRENT_TIMESTAMP,
            '',
            "module",
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );
    END IF;

END;
$$;