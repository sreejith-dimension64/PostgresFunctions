CREATE OR REPLACE FUNCTION "dbo"."ApplicationUser_UPDATE"
(
	p_Email TEXT,
	p_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
	v_RECORD_COUNT BIGINT;
BEGIN

	SELECT COUNT(*) INTO v_RECORD_COUNT FROM "applicationuser" WHERE "id" = p_ID;

	UPDATE "ApplicationUser" "AU" 
	SET "Email" = p_Email,
	    "NormalizedEmail" = p_Email
	FROM "IVRM_Staff_User_Login" "SUL"
	WHERE "AU"."Id" = "SUL"."Id" 
	  AND "SUL"."Emp_Code" = p_ID;

END;
$$;