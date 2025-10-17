CREATE OR REPLACE FUNCTION "dbo"."IVRM_Email_Outgoing_1"(
    "EmailId" VARCHAR(50),
    "Message" VARCHAR(1000),
    "module" VARCHAR(50),
    "MI_Id" BIGINT,
    "type" VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "date" TIMESTAMP;
    v_message VARCHAR(1000);
BEGIN
    "date" := CURRENT_TIMESTAMP;
    v_message := "Message";
    
    IF "module" = 'Late-In details' OR "module" = 'Early-Out details' THEN
        v_message := 'FO Mail Sent';
    END IF;
    
    INSERT INTO "dbo"."IVRM_Email_sentBox"(
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
        v_message,
        "date",
        '',
        "module",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        "type"
    );
    
    RETURN;
END;
$$;