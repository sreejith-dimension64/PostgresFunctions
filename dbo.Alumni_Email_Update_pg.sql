CREATE OR REPLACE FUNCTION "dbo"."Alumni_Email_Update"(
    p_Email TEXT,
    p_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "ApplicationUser" 
    SET "Email" = p_Email, 
        "NormalizedEmail" = p_Email
    WHERE "Id" = p_ID;
END;
$$;