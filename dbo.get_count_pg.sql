CREATE OR REPLACE FUNCTION "dbo"."get_count" (
    p_MI_Id bigint
)
RETURNS TABLE (
    "Module_Name" VARCHAR,
    "Smscount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "A"."Module_Name", 
        COUNT("A"."Message") as "Smscount"
    FROM "IVRM_sms_sentBox" AS "A"
    INNER JOIN "IVRM_Email_sentBox" AS "B" ON "A"."MI_Id" = "B"."MI_Id"
    WHERE "A"."MI_Id" = p_MI_Id 
        AND "A"."Datetime" = TO_TIMESTAMP('07/04/2017', 'DD/MM/YYYY')
    GROUP BY "A"."Module_Name";
END;
$$;