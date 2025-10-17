CREATE OR REPLACE FUNCTION "dbo"."EmailSmsCountConstwo"(
    "MI_Id" VARCHAR(10),
    "Month" TEXT,
    "optionflag" VARCHAR(50),
    "year" VARCHAR(100)
)
RETURNS TABLE(
    "month" DOUBLE PRECISION,
    "smscount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
BEGIN
    IF "optionflag" = 'Consolited' THEN
        "sqlexec" := 'SELECT EXTRACT(MONTH FROM "datetime") as month, COUNT(*) as smscount ' ||
                     'FROM "IVRM_sms_sentBox" ' ||
                     'WHERE EXTRACT(MONTH FROM "Datetime") IN (' || "Month" || ') ' ||
                     'AND EXTRACT(YEAR FROM "Datetime") = ' || "year" || ' ' ||
                     'AND "MI_Id" = ' || "MI_Id" || ' ' ||
                     'GROUP BY EXTRACT(MONTH FROM "datetime")';
        
        RETURN QUERY EXECUTE "sqlexec";
    END IF;
END;
$$;