CREATE OR REPLACE FUNCTION "dbo"."Fetch_MemoNoticeccmails"(@HRME_Id bigint)
RETURNS TABLE(cc text, bcc text)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT ''::text AS cc, ''::text AS bcc;

END;
$$;