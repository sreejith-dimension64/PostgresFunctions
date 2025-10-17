CREATE OR REPLACE FUNCTION "dbo"."Induction_Training_Create_check_proc"(
    "p_MI_Id" int,
    "p_user_id" int
)
RETURNS TABLE("checkadmin" int)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_count" int;
    "v_ixf" int;
    "v_hrmeid" int;
    "v_P_hrme_id" int;
    "v_I_hrme_id" int;
    "v_E_hrme_id" int;
BEGIN
    SELECT "ar"."id", "ul"."Emp_Code" 
    INTO "v_count", "v_hrmeid"
    FROM "IVRM_Staff_User_Login" "ul"
    INNER JOIN "ApplicationUser" "au" ON "ul"."id" = "au"."id"
    INNER JOIN "ApplicationUserRole" "aur" ON "au"."Id" = "aur"."UserId"
    INNER JOIN "ApplicationRole" "ar" ON "aur"."RoleId" = "ar"."Id"
    WHERE "ul"."id" = "p_user_id";

    SELECT COUNT(*) 
    INTO "v_P_hrme_id"
    FROM "HR_Training_Create_Participants" 
    WHERE "HRME_Id" = "v_hrmeid";

    SELECT COUNT(*) 
    INTO "v_I_hrme_id"
    FROM "HR_Training_Create_IntTrainer" 
    WHERE "HRME_Id" = "v_hrmeid";

    SELECT COUNT(*) 
    INTO "v_E_hrme_id"
    FROM "HR_Training_Create_ExtTrainer" 
    WHERE "HRME_Id" = "v_hrmeid";

    IF ("v_count" = 1 OR "v_count" = 2 OR "v_count" = 3 OR "v_count" = 4 OR "v_count" = 9 OR "v_count" IS NULL) THEN
        RETURN QUERY SELECT 1;
    ELSIF "v_I_hrme_id" > 0 OR "v_E_hrme_id" > 0 THEN
        RETURN QUERY SELECT 2;
    ELSIF "v_P_hrme_id" > 0 THEN
        RETURN QUERY SELECT 3;
    END IF;

    RETURN;
END;
$$;