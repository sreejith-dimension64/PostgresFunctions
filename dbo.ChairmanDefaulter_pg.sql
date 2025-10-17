CREATE OR REPLACE FUNCTION "dbo"."ChairmanDefaulter"(
    "@Year" VARCHAR,
    "@month" VARCHAR,
    "@amay" VARCHAR,
    "@mi_id" VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@totalregister" BIGINT;
    "@totalregisterpaid" BIGINT;
    "@totaltransfered" BIGINT;
BEGIN
    "@totalregister" := 0;
    "@totalregisterpaid" := 0;
    "@totaltransfered" := 0;

    SELECT COUNT(*) INTO "@totalregister"
    FROM "ApplicationUser"
    INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId"
    INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id"
    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."MI_Id" = "IVRM_User_Login_Institutionwise"."MI_Id"
    WHERE "IVRM_User_Login_Institutionwise"."MI_Id" = "@mi_id"
    AND "ApplicationUserRole"."RoleId" IN (
        SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser'
    )
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" = "@Year" AND "MI_Id" = "@mi_id"
    );

    SELECT COUNT(*) INTO "@totalregisterpaid"
    FROM "dbo"."Preadmission_School_Registration"
    LEFT OUTER JOIN "dbo"."IVRM_Master_State" ON "dbo"."Preadmission_School_Registration"."PASR_ConState" = "dbo"."IVRM_Master_State"."IVRMMS_Id"
    LEFT JOIN "dbo"."Preadmission_Master_Status" ON "dbo"."Preadmission_School_Registration"."PAMS_Id" = "dbo"."Preadmission_Master_Status"."PAMST_Id"
    LEFT JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Preadmission_School_Registration"."Religion_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
    LEFT JOIN "dbo"."ApplicationUser" ON "dbo"."Preadmission_School_Registration"."Id" = "dbo"."ApplicationUser"."Id"
    LEFT JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Preadmission_School_Registration"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    WHERE "Preadmission_School_Registration"."PASR_Id" IN (
        SELECT "pasa_id" FROM "Fee_Y_Payment_PA_Application" WHERE "fyppa_type" = 'R'
    )
    AND "Preadmission_School_Registration"."MI_Id" = "@mi_id";

    SELECT COUNT(*) INTO "@totaltransfered"
    FROM "dbo"."Preadmission_School_Registration"
    LEFT JOIN "dbo"."IVRM_Master_State" ON "dbo"."Preadmission_School_Registration"."PASR_ConState" = "dbo"."IVRM_Master_State"."IVRMMS_Id"
    LEFT JOIN "dbo"."Preadmission_Master_Status" ON "dbo"."Preadmission_School_Registration"."PAMS_Id" = "dbo"."Preadmission_Master_Status"."PAMST_Id"
    LEFT JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Preadmission_School_Registration"."Religion_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
    LEFT JOIN "dbo"."ApplicationUser" ON "dbo"."Preadmission_School_Registration"."Id" = "dbo"."ApplicationUser"."Id"
    LEFT JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Preadmission_School_Registration"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    WHERE "dbo"."Preadmission_Master_Status"."MI_Id" = "@mi_id"
    AND "PASR_Adm_Confirm_Flag" = 1
    AND "Preadmission_School_Registration"."PASR_PaymentFlag" = 0
    AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "@Year"
    AND "Preadmission_School_Registration"."PAMS_Id" IN (
        SELECT "PAMST_Id" FROM "Preadmission_Master_Status" WHERE "PAMST_StatusFlag" = 'CNF'
    );

END;
$$;