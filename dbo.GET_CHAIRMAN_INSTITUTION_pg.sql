CREATE OR REPLACE FUNCTION "dbo"."GET_CHAIRMAN_INSTITUTION"(
    p_USERId BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT "MI_Id", "MI_Name"
FROM "Master_Institution" 
WHERE 
"MI_Id" IN(
    SELECT DISTINCT "MI_Id" 
    FROM "IVRM_User_Login_Institutionwise" 
    WHERE "id" IN (
        SELECT DISTINCT "UserId" 
        FROM "ApplicationUserRole" 
        WHERE "UserId" = p_USERId
    )
);

END;
$$;