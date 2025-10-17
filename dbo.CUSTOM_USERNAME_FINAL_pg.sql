CREATE OR REPLACE FUNCTION "dbo"."CUSTOM_USERNAME_FINAL"(
    p_MI_ID BIGINT,
    p_AMST_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_IVRMGC_UserNameOptionsFlg TEXT;
    v_IVRMGC_FatherLoginCred BOOLEAN;
    v_IVRMGC_MotherLoginCred BOOLEAN;
    v_IVRMGC_GuardianLoginCred BOOLEAN;
    v_IVRMGC_StudentLoginCred BOOLEAN;
    v_IVRMGC_AutoCreateStudentCredFlg BOOLEAN;
    v_FINALNAMENEW VARCHAR(100);
    v_FLAGNEW VARCHAR(20);
    v_AMST_IDNEW BIGINT;
    v_EMAILIDNEW VARCHAR(100);
    v_PHONENONEW VARCHAR(100);
    v_COUNTNEW BIGINT;
    v_IDNEW BIGINT;
    v_STIDNEW BIGINT;
    v_STIDNEW12 BIGINT;
    v_AMST_IdST BIGINT;
    v_AMST_AdmNoST VARCHAR(20);
    v_AMST_MobileNoST VARCHAR(50);
    v_AMST_emailIdST VARCHAR(100);
    v_AMST_RegistrationNo VARCHAR(100);
    v_Name VARCHAR(100);
    v_UserName VARCHAR(100);
    v_AMST_MobileNoNEW VARCHAR(100);
    v_AMST_emailIdNEW VARCHAR(200);
    v_COUNTST BIGINT;
    v_IDNEW1 BIGINT;
    v_STIDNEW1 BIGINT;
    rec_username RECORD;
    rec_usernamecrea RECORD;
BEGIN

    DROP TABLE IF EXISTS "FINALUSERNAME";

    CREATE TEMP TABLE "FINALUSERNAME"(
        "FINALNAME" VARCHAR(500),
        "FLAG" VARCHAR(20),
        "AMST_ID" BIGINT,
        "EMAILID" VARCHAR(500),
        "PHONENO" VARCHAR(200)
    );

    SELECT "IVRMGC_UserNameOptionsFlg", "IVRMGC_AutoCreateStudentCredFlg" 
    INTO v_IVRMGC_UserNameOptionsFlg, v_IVRMGC_AutoCreateStudentCredFlg
    FROM "IVRM_General_Cofiguration_New" 
    WHERE "MI_Id" = p_MI_ID;

    IF (v_IVRMGC_UserNameOptionsFlg = 'Custom' OR v_IVRMGC_AutoCreateStudentCredFlg = TRUE) THEN
    
        RAISE NOTICE 'AAA';

        PERFORM "dbo"."CUSTOM_USERNAME"(p_MI_ID, p_AMST_ID);

        FOR rec_username IN 
            SELECT "FINALNAME", "FLAG", "AMST_ID", "EMAILID", "PHONENO" 
            FROM "FINALUSERNAME" 
            WHERE "AMST_ID" = p_AMST_ID
        LOOP
            v_FINALNAMENEW := rec_username."FINALNAME";
            v_FLAGNEW := rec_username."FLAG";
            v_AMST_IDNEW := rec_username."AMST_ID";
            v_EMAILIDNEW := rec_username."EMAILID";
            v_PHONENONEW := rec_username."PHONENO";

            v_COUNTNEW := 0;

            SELECT COUNT(*) INTO v_COUNTNEW 
            FROM "ApplicationUser" 
            WHERE "UserName" = v_FINALNAMENEW;

            IF (v_COUNTNEW > 0) THEN
                RAISE NOTICE 'DUPLICATE';
            END IF;

            INSERT INTO "ApplicationUser" (
                "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd",
                "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp",
                "TwoFactorEnabled", "UserName", "Entry_Date", "Machine_Ip_Address", "UserImagePath", "RoleTypeFlag", "CreatedDate", "UpdatedDate", "Name", "CreatedBy", "UpdatedBy")
            VALUES(0, 'ConcurrencyStamp', v_EMAILIDNEW, '1', '1', NULL,
                v_EMAILIDNEW, v_FINALNAMENEW, 'AQAAAAEAACcQAAAAEOTCwm3X+V+FxgZlsgee3mWvCK06bZIdqe2qMv4Wh3/YtBryDn0UzDLj1oE+Qe1tLA==', v_PHONENONEW, '1', '1',
                0, v_FINALNAMENEW, CURRENT_TIMESTAMP, NULL, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_FINALNAMENEW, 1452, 1452)
            RETURNING "Id" INTO v_IDNEW;

            INSERT INTO "ApplicationUserRole" ("UserId", "RoleId", "RoleTypeId", "CreatedDate", "UpdatedDate", "CreatedBy", "UpdatedBy")
            VALUES(v_IDNEW,
                (CASE WHEN v_FLAGNEW IN ('F', 'M', 'G') THEN 14
                    WHEN v_FLAGNEW IN ('S') THEN 7 ELSE 7 END),
                (CASE WHEN v_FLAGNEW IN ('F', 'M', 'G') THEN 14
                    WHEN v_FLAGNEW IN ('S') THEN 7 ELSE 7 END),
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);

            INSERT INTO "IVRM_User_Login_Institutionwise" ("MI_Id", "Id", "CreatedDate", "UpdatedDate", "Activeflag", "IVRMULI_PaymentAlertFlg", "IVRMULI_SubExpAlertFlg", "IVRMULI_CreatedBy", "IVRMULI_UpdatedBy")
            VALUES(p_MI_ID, v_IDNEW, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, NULL, NULL, 1452, 1452);

            INSERT INTO "IVRM_Student_User_Login"("MI_Id", "IVRMSTUUL_UserName", "IVRMSTUUL_Password", "AMST_Id", "IVRMSTUUL_ActiveFlag", "IVRMSTUUL_SecurityQns", "IVRMSTUUL_Answer", "CreatedDate", "UpdatedDate", "IVRMSTUUL_CreatedBy", "IVRMSTUUL_UpdatedBy")
            VALUES (p_MI_ID, v_FINALNAMENEW, 'Password@123', v_AMST_IDNEW, 1, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452)
            RETURNING "IVRMSTUUL_Id" INTO v_STIDNEW12;

            INSERT INTO "IVRM_Student_User_Login_Institutionwise" ("IVRMSTUUL_Id", "AMST_Id", "IVRMSTUULI_ActiveFlag", "Previous_AMST_Id", "Previous_MI_Id", "CreatedDate", "UpdatedDate", "IVRMSTUULI_CreatedBy", "IVRMSTUULI_UpdatedBy")
            VALUES(v_STIDNEW12, v_AMST_IDNEW, 1, '', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452);

            INSERT INTO "Ivrm_User_StudentApp_login" ("AMST_ID", "STD_APP_ID", "FAT_APP_ID", "MOT_APP_ID", "IVRMUSLAPP_CreatedDate", "IVRMUSLAPP_UpdatedDate", "IVRMUSLAPP_CreatedBy", "IVRMUSLAPP_UpdatedBy")
            VALUES (v_AMST_IDNEW, v_IDNEW, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452);

        END LOOP;

    ELSE

        RAISE NOTICE 'BBB';

        PERFORM "dbo"."STUDENT_USER_CREATION"(p_MI_ID, p_AMST_ID);

        FOR rec_usernamecrea IN 
            SELECT "AMST_Id", "AMST_AdmNo", "AMST_MobileNo", "AMST_emailId", "AMST_RegistrationNo", "Name" 
            FROM "USERNAMECREATION" 
            WHERE "AMST_ID" = p_AMST_ID
        LOOP
            v_AMST_Id := rec_usernamecrea."AMST_Id";
            v_AMST_AdmNoST := rec_usernamecrea."AMST_AdmNo";
            v_AMST_MobileNoST := rec_usernamecrea."AMST_MobileNo";
            v_AMST_emailIdST := rec_usernamecrea."AMST_emailId";
            v_AMST_RegistrationNo := rec_usernamecrea."AMST_RegistrationNo";
            v_Name := rec_usernamecrea."Name";

            RAISE NOTICE 'AAAAA';

            v_UserName := '';

            IF (v_IVRMGC_UserNameOptionsFlg = 'EmailId') THEN

                RAISE NOTICE 'BBBBB';

                v_UserName := SUBSTRING(COALESCE(v_AMST_emailIdST, ''), 1, POSITION('@' IN COALESCE(v_AMST_emailIdST, '')) - 1);

                SELECT "AMST_emailId" INTO v_AMST_emailIdNEW 
                FROM "USERNAMECREATION" 
                WHERE "AMST_ID" = p_AMST_ID;

            ELSE

                v_UserName := v_AMST_MobileNoST;

                SELECT "AMST_emailId" INTO v_AMST_emailIdNEW 
                FROM "USERNAMECREATION" 
                WHERE "AMST_ID" = p_AMST_ID;

            END IF;

            v_COUNTST := 0;

            SELECT COUNT(*) INTO v_COUNTST 
            FROM "ApplicationUser" 
            WHERE "UserName" = v_UserName;

            IF (v_COUNTST > 0) THEN

                RAISE NOTICE 'DUPLICATE USERNAMES';

            ELSE

                INSERT INTO "ApplicationUser" (
                    "AccessFailedCount", "ConcurrencyStamp", "Email", "EmailConfirmed", "LockoutEnabled", "LockoutEnd",
                    "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "SecurityStamp",
                    "TwoFactorEnabled", "UserName", "Entry_Date", "Machine_Ip_Address", "UserImagePath", "RoleTypeFlag", "CreatedDate", "UpdatedDate", "Name", "CreatedBy", "UpdatedBy")
                VALUES(0, 'ConcurrencyStamp', v_AMST_emailIdNEW, '1', '1', NULL,
                    v_AMST_emailIdNEW, v_UserName, 'AQAAAAEAACcQAAAAEOTCwm3X+V+FxgZlsgee3mWvCK06bZIdqe2qMv4Wh3/YtBryDn0UzDLj1oE+Qe1tLA==', v_AMST_MobileNoST, '1', '1',
                    0, v_UserName, CURRENT_TIMESTAMP, NULL, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_UserName, 1452, 1452)
                RETURNING "Id" INTO v_IDNEW;

                INSERT INTO "ApplicationUserRole" ("UserId", "RoleId", "RoleTypeId", "CreatedDate", "UpdatedDate", "CreatedBy", "UpdatedBy")
                VALUES(v_IDNEW,
                    (CASE WHEN v_FLAGNEW IN ('F', 'M', 'G') THEN 14
                        WHEN v_FLAGNEW IN ('S') THEN 7 ELSE 7 END),
                    (CASE WHEN v_FLAGNEW IN ('F', 'M', 'G') THEN 14
                        WHEN v_FLAGNEW IN ('S') THEN 7 ELSE 7 END),
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, 1);

                INSERT INTO "IVRM_User_Login_Institutionwise" ("MI_Id", "Id", "CreatedDate", "UpdatedDate", "Activeflag", "IVRMULI_PaymentAlertFlg", "IVRMULI_SubExpAlertFlg", "IVRMULI_CreatedBy", "IVRMULI_UpdatedBy")
                VALUES(p_MI_ID, v_IDNEW, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, NULL, NULL, 1452, 1452);

                INSERT INTO "IVRM_Student_User_Login"("MI_Id", "IVRMSTUUL_UserName", "IVRMSTUUL_Password", "AMST_Id", "IVRMSTUUL_ActiveFlag", "IVRMSTUUL_SecurityQns", "IVRMSTUUL_Answer", "CreatedDate", "UpdatedDate", "IVRMSTUUL_CreatedBy", "IVRMSTUUL_UpdatedBy")
                VALUES (p_MI_ID, v_UserName, 'Password@123', p_AMST_ID, 1, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452)
                RETURNING "IVRMSTUUL_Id" INTO v_STIDNEW1;

                INSERT INTO "IVRM_Student_User_Login_Institutionwise" ("IVRMSTUUL_Id", "AMST_Id", "IVRMSTUULI_ActiveFlag", "Previous_AMST_Id", "Previous_MI_Id", "CreatedDate", "UpdatedDate", "IVRMSTUULI_CreatedBy", "IVRMSTUULI_UpdatedBy")
                VALUES(v_STIDNEW1, p_AMST_ID, 1, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452);

                INSERT INTO "Ivrm_User_StudentApp_login" ("AMST_ID", "STD_APP_ID", "FAT_APP_ID", "MOT_APP_ID", "IVRMUSLAPP_CreatedDate", "IVRMUSLAPP_UpdatedDate", "IVRMUSLAPP_CreatedBy", "IVRMUSLAPP_UpdatedBy")
                VALUES (p_AMST_ID, v_IDNEW, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1452, 1452);

            END IF;

        END LOOP;

    END IF;

    RETURN;

END;
$$;