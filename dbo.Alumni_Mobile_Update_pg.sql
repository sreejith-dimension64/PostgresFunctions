CREATE OR REPLACE FUNCTION "dbo"."Alumni_Mobile_Update"
(
    p_mobile VARCHAR(20),
    p_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE "ApplicationUser" 
    SET "PhoneNumber" = p_mobile
    WHERE "Id" = p_ID;

END;
$$;