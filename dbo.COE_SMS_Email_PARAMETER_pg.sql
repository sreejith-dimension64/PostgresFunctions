CREATE OR REPLACE FUNCTION "dbo"."COE_SMS_Email_PARAMETER" (
    p_eventname VARCHAR(100),
    p_startdate DATE
)
RETURNS TABLE (
    "EVENT" VARCHAR(100),
    "DATE" DATE
)
LANGUAGE plpgsql
AS $$
BEGIN   

    RETURN QUERY
    SELECT DISTINCT 
        p_eventname AS "EVENT", 
        p_startdate AS "DATE";

END;
$$;