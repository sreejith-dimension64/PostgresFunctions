CREATE OR REPLACE FUNCTION "dbo"."INV_LOAD_STOREMAPPING_USERLOAD"(
    "@MI_Id" BIGINT,
    "@IVRMRT_Id" BIGINT
)
RETURNS TABLE(
    "UserId" INTEGER,
    "NormalizedUserName" TEXT,
    "UserName" TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN 
           
    RETURN QUERY
    SELECT 
        a."UserId" as "UserId",
        c."NormalizedUserName",
        c."UserName" AS "UserName"
    FROM "ApplicationUserRole" a 
    INNER JOIN "IVRM_Role_Type" b ON a."RoleTypeId" = b."IVRMRT_Id"
    INNER JOIN "ApplicationUser" c ON a."UserId" = c."Id"
    INNER JOIN "IVRM_User_Login_Institutionwise" d ON c."Id" = d."Id" 
    WHERE d."MI_Id" = "@MI_Id" 
    AND d."Activeflag" = 1  
    ORDER BY "UserName";

END;
$$;