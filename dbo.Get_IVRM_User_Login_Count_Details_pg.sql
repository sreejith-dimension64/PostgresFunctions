CREATE OR REPLACE FUNCTION "dbo"."Get_IVRM_User_Login_Count_Details"(
    "UserId" BIGINT,
    OUT "ROWCount" BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COUNT(*) INTO "ROWCount" 
    FROM "IVRM_MobileApp_LoginDetails" 
    WHERE "IVRMUL_Id" = "UserId";
END;
$$;