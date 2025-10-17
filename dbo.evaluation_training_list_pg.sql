CREATE OR REPLACE FUNCTION "dbo"."evaluation_training_list"(
    "p_HRTCR_Id" bigint,
    "p_user_id" bigint
)
RETURNS TABLE(
    "HRMET_Id" bigint,
    "HRME_EmployeeName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_count" int;
    "v_ixf" int;
    "v_hrmeid" int;
    "v_empcode" int;
BEGIN
    SELECT "ar"."id" INTO "v_count"
    FROM "ApplicationUserRole" "aur"
    INNER JOIN "ApplicationRole" "ar" ON "aur"."RoleId" = "ar"."Id"
    WHERE "aur"."UserId" = "p_user_id";

    IF ("v_count" = 1 OR "v_count" = 2 OR "v_count" = 3 OR "v_count" = 4) THEN
        SELECT "HRTCR_InternalORExternalFlg" INTO "v_ixf"
        FROM "HR_Training_Create"
        WHERE "HRTCR_Id" = "p_HRTCR_Id";

        IF "v_ixf" = 0 THEN
            RETURN QUERY
            SELECT "ci"."HRME_Id" AS "HRMET_Id",
                   COALESCE("me"."HRME_EmployeeFirstName", '') || ' ' || 
                   COALESCE("me"."HRME_EmployeeMiddleName", '') || ' ' || 
                   COALESCE("me"."HRME_EmployeeLastName", '') AS "HRME_EmployeeName"
            FROM "HR_Master_Employee" "me"
            INNER JOIN "HR_Training_Create_IntTrainer" "ci" ON "me"."HRME_Id" = "ci"."HRME_Id"
            WHERE "ci"."HRTCR_Id" = "p_HRTCR_Id"
              AND "ci"."HRTCRINTTR_Rating" = 0;
        ELSE
            RETURN QUERY
            SELECT "ci"."HRME_Id" AS "HRMET_Id",
                   "me"."HRMETR_Name" AS "HRME_EmployeeName"
            FROM "HR_Master_External_Trainer_Creation" "me"
            INNER JOIN "HR_Training_Create_ExtTrainer" "ci" ON "me"."HRMETR_Id" = "ci"."HRME_Id"
            WHERE "ci"."HRTCR_Id" = "p_HRTCR_Id"
              AND "ci"."HRTCREXTTR_Rating" = 0;
        END IF;
    ELSE
        SELECT "Emp_Code" INTO "v_empcode"
        FROM "IVRM_Staff_User_Login"
        WHERE "id" = "p_user_id";

        RETURN QUERY
        SELECT "HRME_Id" AS "HRMET_Id",
               COALESCE("HRME_EmployeeFirstName", '') || ' ' || 
               COALESCE("HRME_EmployeeMiddleName", '') || ' ' || 
               COALESCE("HRME_EmployeeLastName", '') AS "HRME_EmployeeName"
        FROM "HR_Master_Employee"
        WHERE "HRME_Id" = "v_empcode";
    END IF;

    RETURN;
END;
$$;