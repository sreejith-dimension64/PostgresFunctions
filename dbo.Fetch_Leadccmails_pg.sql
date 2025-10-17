CREATE OR REPLACE FUNCTION "dbo"."Fetch_Leadccmails"(
    "HRME_Id" bigint
)
RETURNS TABLE(
    "cc" text,
    "bcc" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        'siddesh@vapstech.com,pstomd@vapstech.com,mktgcoord@vapstech.com'::text AS "cc",
        'rakesh.reddy@vapstech.com'::text AS "bcc";

END;
$$;