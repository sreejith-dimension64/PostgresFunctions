CREATE OR REPLACE FUNCTION "dbo"."ApplicationUser_UPDATE_mobile"
(
	p_PhoneNo BIGINT,
	p_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
	v_RECORD_COUNT BIGINT;
BEGIN

	SELECT COUNT(*) INTO v_RECORD_COUNT FROM "applicationuser" WHERE "id" = p_ID;

	UPDATE "ApplicationUser" AS "AU" 
	SET "PhoneNumber" = p_PhoneNo
	FROM "IVRM_Staff_User_Login" AS "SUL" 
	WHERE "AU"."Id" = "SUL"."Id" 
	AND "SUL"."Emp_Code" = p_ID;

END;
$$;