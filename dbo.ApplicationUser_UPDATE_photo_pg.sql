CREATE OR REPLACE FUNCTION "dbo"."ApplicationUser_UPDATE_photo"(
    "Photo" TEXT,
    "ID" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "RECORD_COUNT" BIGINT;
BEGIN
    SELECT COUNT(*) INTO "RECORD_COUNT" FROM "applicationuser" WHERE "id" = "ID";

    UPDATE "ApplicationUser" "AU"
    SET "UserImagePath" = "Photo"
    FROM "IVRM_Staff_User_Login" "SUL"
    WHERE "AU"."Id" = "SUL"."Id"
    AND "SUL"."Emp_Code" = "ID";

END;
$$;