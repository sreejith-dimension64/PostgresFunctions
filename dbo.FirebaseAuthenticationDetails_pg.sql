CREATE OR REPLACE FUNCTION "dbo"."FirebaseAuthenticationDetails"(
    "MI_Id" BIGINT
)
RETURNS TABLE(
    "MI_FirebaseAuthenticationString" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT "Master_Institution"."MI_FirebaseAuthenticationString" 
    FROM "dbo"."Master_Institution" 
    WHERE "Master_Institution"."MI_Id" = "MI_Id";
END;
$$;