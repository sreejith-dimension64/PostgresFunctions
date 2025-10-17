CREATE OR REPLACE FUNCTION "dbo"."GET_SMS_EMAIL_MODULE_LIST"(
    p_MI_Id bigint
)
RETURNS TABLE(
    module text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT UPPER("Module_Name") AS module 
    FROM "IVRM_Email_sentBox" 
    WHERE "MI_Id" = p_MI_Id
    UNION 
    SELECT DISTINCT UPPER("Module_Name") AS module 
    FROM "IVRM_sms_sentBox" 
    WHERE "MI_Id" = p_MI_Id 
    ORDER BY module;
END;
$$;