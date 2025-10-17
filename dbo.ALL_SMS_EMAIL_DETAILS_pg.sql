CREATE OR REPLACE FUNCTION "dbo"."ALL_SMS_EMAIL_DETAILS"(
    "@MI_Id" bigint,
    "@frmdate" date,
    "@todate" date,
    "@type" varchar(20),
    "@template" text
)
RETURNS TABLE(
    "result_column1" varchar,
    "result_column2" text,
    "result_column3" timestamp
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@template" = 'BUSHIRE' THEN
        IF "@type" = 'SMS' THEN
            RETURN QUERY
            SELECT 
                "Mobile_no",
                "Message",
                "Datetime"
            FROM "IVRM_sms_sentBox"
            WHERE "Module_Name" = 'BUSHIRE' 
                AND "MI_Id" = "@MI_Id" 
                AND CAST("Datetime" AS date) BETWEEN "@frmdate" AND "@todate" 
                AND "Mobile_no" <> '0' 
                AND "Mobile_no" <> '';
        
        ELSIF "@type" = 'EMAIL' THEN
            RETURN QUERY
            SELECT 
                "Email_Id",
                "Message",
                "Datetime"
            FROM "IVRM_Email_sentBox"
            WHERE "Module_Name" = 'BUSHIRE' 
                AND "MI_Id" = "@MI_Id" 
                AND CAST("Datetime" AS date) BETWEEN "@frmdate" AND "@todate" 
                AND "Email_Id" <> '';
        
        END IF;
    
    ELSIF "@template" = 'PRINCIPAL DASHBOARD' THEN
        IF "@type" = 'SMS' THEN
            RETURN QUERY
            SELECT 
                "Mobile_no",
                "Message",
                "Datetime"
            FROM "IVRM_sms_sentBox"
            WHERE "Module_Name" = 'PRINCIPAL DASHBOARD' 
                AND "MI_Id" = "@MI_Id" 
                AND CAST("Datetime" AS date) BETWEEN "@frmdate" AND "@todate" 
                AND "Mobile_no" <> '0' 
                AND "Mobile_no" <> '';
        
        ELSIF "@type" = 'EMAIL' THEN
            RETURN QUERY
            SELECT 
                "Email_Id",
                "Message",
                "Datetime"
            FROM "IVRM_Email_sentBox"
            WHERE "Module_Name" = 'PRINCIPAL DASHBOARD' 
                AND "MI_Id" = "@MI_Id" 
                AND CAST("Datetime" AS date) BETWEEN "@frmdate" AND "@todate" 
                AND "Email_Id" <> '';
        
        END IF;
    END IF;

    RETURN;
END;
$$;