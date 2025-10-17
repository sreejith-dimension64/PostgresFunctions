CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_TC_Cancellation"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_Id" TEXT,
    "Remarks" TEXT,
    "UserId_Update" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "UserId" BIGINT;
    "ALMST_Id" BIGINT;
    "ALSREG_Id" BIGINT;
    "RoleId" BIGINT;
    "RoleTypeId" INT;
BEGIN
    BEGIN
        UPDATE "Adm_Student_TC" 
        SET "ASTC_DeletedFlag" = 1,
            "ASTC_ReadmitRemarks" = "Remarks",
            "UpdatedDate" = CURRENT_TIMESTAMP + INTERVAL '330 minutes',
            "ASTC_UpdatedBy" = "UserId_Update"
        WHERE "AMST_Id" = "AMST_Id" 
          AND "ASMAY_Id" = "ASMAY_Id" 
          AND "MI_Id" = "MI_Id";

        UPDATE "Adm_M_Student" 
        SET "amst_sol" = 'S',
            "AMST_Activeflag" = 1,
            "UpdatedDate" = CURRENT_TIMESTAMP + INTERVAL '330 minutes'
        WHERE "AMST_Id" = "AMST_Id";

        UPDATE "Adm_School_Y_Student" 
        SET "AMAY_ActiveFlag" = 1 
        WHERE "AMST_Id" = (SELECT "AMST_Id" 
                          FROM "Adm_M_Student" 
                          WHERE "AMST_Id" = "AMST_Id" 
                            AND "MI_Id" = "MI_Id") 
          AND "AMAY_ActiveFlag" = 0 
          AND "ASMAY_Id" = "ASMAY_Id";

        SELECT "STD_APP_ID" 
        INTO "UserId"
        FROM "Ivrm_User_StudentApp_login" 
        WHERE "AMST_Id" = "AMST_Id";

        SELECT "IVRMRT_Id" 
        INTO "RoleId"
        FROM "ivrm_role_type" 
        WHERE "IVRMRT_Role" = 'Student';

        SELECT "Id" 
        INTO "RoleTypeId"
        FROM "ApplicationRole" 
        WHERE "Name" = 'STUDENT';

        UPDATE "ApplicationUserRole" 
        SET "RoleId" = "RoleTypeId",
            "RoleTypeId" = "RoleId" 
        WHERE "UserId" = "UserId";

        UPDATE "ALU"."Alumni_Master_Student" 
        SET "ALMST_ActiveFlag" = 0,
            "ALMST_UpdatedBy" = "UserId_Update",
            "UpdatedDate" = CURRENT_TIMESTAMP + INTERVAL '330 minutes'
        WHERE "AMST_Id" = "AMST_Id";

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;