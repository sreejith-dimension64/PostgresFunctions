CREATE OR REPLACE FUNCTION "dbo"."CUSTOM_USERNAME"(p_MI_ID BIGINT, p_AMST_ID BIGINT)
RETURNS TABLE(
    "FINALNAME" VARCHAR(500),
    "FLAG" VARCHAR(20),
    "AMST_ID" BIGINT,
    "EMAILID" VARCHAR(500),
    "PHONENO" VARCHAR(200)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_IVRMGC_UserNameOptionsFlg TEXT;
    v_IVRMGC_FatherLoginCred BOOLEAN;
    v_IVRMGC_MotherLoginCred BOOLEAN;
    v_IVRMGC_GuardianLoginCred BOOLEAN;
    v_IVRMGC_StudentLoginCred BOOLEAN;
    v_IVRMGC_AutoCreateStudentCredFlg BOOLEAN;
    v_AdmnissionNo VARCHAR(20);
    v_MobileNo VARCHAR(20);
    v_Email VARCHAR(100);
    v_RegistartionNo VARCHAR(100);
    v_Name VARCHAR(100);
    v_COUNT1 BIGINT;
    v_ivrm_school_code TEXT;
    v_BaseUserName VARCHAR(255);
    v_NewUserName VARCHAR(255);
    v_MaxSuffix INT;
    v_Suffix INT;
BEGIN
    DROP TABLE IF EXISTS "FINALUSERNAME";

    CREATE TEMP TABLE "FINALUSERNAME"(
        "FINALNAME" VARCHAR(500),
        "FLAG" VARCHAR(20),
        "AMST_ID" BIGINT,
        "EMAILID" VARCHAR(500),
        "PHONENO" VARCHAR(200)
    ) ON COMMIT DROP;

    SELECT "IVRMGC_UserNameOptionsFlg",
           "IVRMGC_FatherLoginCred",
           "IVRMGC_MotherLoginCred",
           "IVRMGC_GuardianLoginCred",
           "IVRMGC_StudentLoginCred"
    INTO v_IVRMGC_UserNameOptionsFlg,
         v_IVRMGC_FatherLoginCred,
         v_IVRMGC_MotherLoginCred,
         v_IVRMGC_GuardianLoginCred,
         v_IVRMGC_StudentLoginCred
    FROM "IVRM_General_Cofiguration_New" 
    WHERE "MI_Id" = p_MI_ID AND "IVRMGC_UserNameOptionsFlg" = 'Custom';

    DROP TABLE IF EXISTS temp_custom;

    CREATE TEMP TABLE temp_custom(
        "C_Order" BIGINT,
        "IVRMCUNP_Field" VARCHAR(200),
        "C_FromOrderFlg" VARCHAR(200),
        "C_Length" BIGINT,
        "C_Newfields" TEXT,
        "EMAILID" VARCHAR(500),
        "PHONENO" VARCHAR(500)
    ) ON COMMIT DROP;

    INSERT INTO temp_custom
    SELECT "IVRMCUNP_Order", "IVRMCUNP_Field", "IVRMCUNP_FromOrderFlg", "IVRMCUNP_Length",
           '' AS "Newfields", '' AS "EMAILID", '' AS "PHONENO"
    FROM "IVRM_Custom_UserName_Password" A 
    INNER JOIN "IVRM_General_Cofiguration_New" B ON A."MI_Id" = B."MI_Id"
    WHERE A."MI_Id" = p_MI_ID AND "IVRMCUNP_Field" IS NOT NULL
    ORDER BY "IVRMCUNP_Order";

    IF(v_IVRMGC_UserNameOptionsFlg = 'Custom') THEN

        IF(v_IVRMGC_StudentLoginCred = TRUE) THEN

            v_AdmnissionNo := '';
            v_MobileNo := '';
            v_RegistartionNo := '';
            v_Email := '';
            v_Name := '';

            SELECT "AMST_AdmNo" INTO v_AdmnissionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_AdmnissionNo WHERE "IVRMCUNP_Field" = 'AdmnissionNo';

            SELECT "AMST_MobileNo" INTO v_MobileNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_MobileNo WHERE "IVRMCUNP_Field" = 'MobileNo';

            SELECT "AMST_RegistrationNo" INTO v_RegistartionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_RegistartionNo WHERE "IVRMCUNP_Field" = 'RegistrationNo';

            SELECT SUBSTRING(COALESCE("AMST_emailId", ''), 1, POSITION('@' IN COALESCE("AMST_emailId", '')) - 1) 
            INTO v_Email 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_Email WHERE "IVRMCUNP_Field" = 'EmailId';

            SELECT CONCAT(COALESCE("AMST_FirstName", ''), ' ', COALESCE("AMST_MiddleName", ''), ' ', COALESCE("AMST_LastName", ''))
            INTO v_Name
            FROM "Adm_M_Student" 
            WHERE "MI_ID" = p_MI_ID AND "AMST_ACTIVEFLAG" = 1 AND "AMST_SOL" = 'S' AND "AMST_ID" = p_AMST_ID;

            UPDATE temp_custom SET "C_Newfields" = v_Name WHERE "IVRMCUNP_Field" = 'Name';

            UPDATE temp_custom
            SET "C_Newfields" = CASE
                WHEN "C_FromOrderFlg" = 'Start' THEN LEFT("C_Newfields", "C_Length"::INT)
                WHEN "C_FromOrderFlg" = 'End' THEN RIGHT("C_Newfields", "C_Length"::INT)
                ELSE "C_Newfields"
            END;

            INSERT INTO "FINALUSERNAME"
            SELECT STRING_AGG("C_Newfields", '' ORDER BY "C_Order") AS "Concatenated_Newfields", 
                   'S' AS "STUDENT", 
                   p_AMST_ID AS "AMST_ID", 
                   v_Email AS "EMAILID", 
                   v_MobileNo AS "PHONENO"
            FROM temp_custom;

        END IF;

        IF(v_IVRMGC_FatherLoginCred = TRUE) THEN

            v_AdmnissionNo := '';
            v_MobileNo := '';
            v_RegistartionNo := '';
            v_Email := '';
            v_Name := '';

            SELECT "AMST_AdmNo" INTO v_AdmnissionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_AdmnissionNo WHERE "IVRMCUNP_Field" = 'AdmnissionNo';

            SELECT COALESCE("AMST_FatherMobleNo", '') INTO v_MobileNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_MobileNo WHERE "IVRMCUNP_Field" = 'MobileNo';

            SELECT "AMST_RegistrationNo" INTO v_RegistartionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_RegistartionNo WHERE "IVRMCUNP_Field" = 'RegistrationNo';

            SELECT SUBSTRING(COALESCE("AMST_FatheremailId", ''), 1, POSITION('@' IN COALESCE("AMST_FatheremailId", '')) - 1) 
            INTO v_Email 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_Email WHERE "IVRMCUNP_Field" = 'EmailId';

            SELECT "AMST_FatherName" INTO v_Name 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_Name WHERE "IVRMCUNP_Field" = 'Name';

            UPDATE temp_custom
            SET "C_Newfields" = CASE
                WHEN "C_FromOrderFlg" = 'Start' THEN LEFT("C_Newfields", "C_Length"::INT)
                WHEN "C_FromOrderFlg" = 'End' THEN RIGHT("C_Newfields", "C_Length"::INT)
                ELSE "C_Newfields"
            END;

            INSERT INTO "FINALUSERNAME"
            SELECT STRING_AGG("C_Newfields", '' ORDER BY "C_Order") AS "Concatenated_Newfields", 
                   'F' AS "FATHERNAME", 
                   p_AMST_ID AS "AMST_ID", 
                   v_Email AS "EMAILID", 
                   v_MobileNo AS "PHONENO"
            FROM temp_custom;

        END IF;

        IF(v_IVRMGC_MotherLoginCred = TRUE) THEN

            v_AdmnissionNo := '';
            v_MobileNo := '';
            v_RegistartionNo := '';
            v_Email := '';
            v_Name := '';

            SELECT "AMST_AdmNo" INTO v_AdmnissionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_AdmnissionNo WHERE "IVRMCUNP_Field" = 'AdmnissionNo';

            SELECT COALESCE("AMST_MotherMobileNo", '') INTO v_MobileNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_MobileNo WHERE "IVRMCUNP_Field" = 'MobileNo';

            SELECT "AMST_RegistrationNo" INTO v_RegistartionNo 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_RegistartionNo WHERE "IVRMCUNP_Field" = 'RegistrationNo';

            SELECT SUBSTRING(COALESCE("AMST_MotherEmailId", ''), 1, POSITION('@' IN COALESCE("AMST_MotherEmailId", '')) - 1) 
            INTO v_Email 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_Email WHERE "IVRMCUNP_Field" = 'EmailId';

            SELECT "AMST_MotherName" INTO v_Name 
            FROM "Adm_M_Student" 
            WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

            UPDATE temp_custom SET "C_Newfields" = v_Name WHERE "IVRMCUNP_Field" = 'Name';

            UPDATE temp_custom
            SET "C_Newfields" = CASE
                WHEN "C_FromOrderFlg" = 'Start' THEN LEFT("C_Newfields", "C_Length"::INT)
                WHEN "C_FromOrderFlg" = 'End' THEN RIGHT("C_Newfields", "C_Length"::INT)
                ELSE "C_Newfields"
            END;

            INSERT INTO "FINALUSERNAME"
            SELECT STRING_AGG("C_Newfields", '' ORDER BY "C_Order") AS "Concatenated_Newfields", 
                   'M' AS "MOTHERNAME", 
                   p_AMST_ID AS "AMST_ID", 
                   v_Email AS "EMAILID", 
                   v_MobileNo AS "PHONENO"
            FROM temp_custom;

        END IF;

        IF(v_IVRMGC_GuardianLoginCred = TRUE) THEN

            v_AdmnissionNo := '';
            v_MobileNo := '';
            v_RegistartionNo := '';
            v_Email := '';
            v_Name := '';

            SELECT COUNT(*) INTO v_COUNT1 
            FROM "Adm_M_Student" A 
            INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
            WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S';

            IF(v_COUNT1 > 0) THEN

                SELECT "AMST_AdmNo" INTO v_AdmnissionNo 
                FROM "Adm_M_Student" A 
                INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
                WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S';

                UPDATE temp_custom SET "C_Newfields" = v_AdmnissionNo WHERE "IVRMCUNP_Field" = 'AdmnissionNo';

                SELECT "AMSTG_GuardianPhoneNo" INTO v_MobileNo 
                FROM "Adm_M_Student" A 
                INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
                WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S'
                LIMIT 1;

                UPDATE temp_custom SET "C_Newfields" = v_MobileNo WHERE "IVRMCUNP_Field" = 'MobileNo';

                SELECT COALESCE("AMST_RegistrationNo", '') INTO v_RegistartionNo 
                FROM "Adm_M_Student" A 
                INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
                WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S';

                UPDATE temp_custom SET "C_Newfields" = v_RegistartionNo WHERE "IVRMCUNP_Field" = 'RegistrationNo';

                SELECT SUBSTRING(COALESCE("AMSTG_emailid", ''), 1, POSITION('@' IN COALESCE("AMSTG_emailid", '')) - 1) 
                INTO v_Email 
                FROM "Adm_M_Student" A 
                INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
                WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S';

                UPDATE temp_custom SET "C_Newfields" = v_Email WHERE "IVRMCUNP_Field" = 'EmailId';

                SELECT COALESCE("AMSTG_GuardianName", '') INTO v_Name 
                FROM "Adm_M_Student" A 
                INNER JOIN "Adm_Master_Student_Guardian" B ON A."AMST_Id" = B."AMST_Id"
                WHERE A."AMST_Id" = p_AMST_ID AND A."AMST_ActiveFlag" = 1 AND A."AMST_SOL" = 'S';

                UPDATE temp_custom SET "C_Newfields" = v_Name WHERE "IVRMCUNP_Field" = 'Name';

                UPDATE temp_custom
                SET "C_Newfields" = CASE
                    WHEN "C_FromOrderFlg" = 'Start' THEN LEFT("C_Newfields", "C_Length"::INT)
                    WHEN "C_FromOrderFlg" = 'End' THEN RIGHT("C_Newfields", "C_Length"::INT)
                    ELSE "C_Newfields"
                END;

                INSERT INTO "FINALUSERNAME"
                SELECT STRING_AGG("C_Newfields", '' ORDER BY "C_Order") AS "Concatenated_Newfields", 
                       'G' AS "GUARDIANNAME", 
                       p_AMST_ID AS "AMST_ID", 
                       v_Email AS "EMAILID", 
                       v_MobileNo AS "PHONENO"
                FROM temp_custom;

            END IF;

        END IF;

    END IF;

    IF EXISTS (SELECT 1 FROM "IVRM_General_Cofiguration_New" WHERE "MI_Id" = p_MI_ID AND "IVRMGC_AutoCreateStudentCredFlg" = TRUE) THEN

        v_AdmnissionNo := '';
        v_MobileNo := '';
        v_RegistartionNo := '';
        v_Email := '';
        v_Name := '';

        SELECT "ivrm_school_code" INTO v_ivrm_school_code 
        FROM "IVRM_Virtual_School" 
        WHERE "IVRM_MI_Id" = p_MI_ID 
        LIMIT 1;

        SELECT RIGHT("AMST_AdmNo", 2) INTO v_AdmnissionNo 
        FROM "Adm_M_Student" 
        WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

        SELECT RIGHT("AMST_MobileNo", 2) INTO v_MobileNo 
        FROM "Adm_M_Student" 
        WHERE "AMST_Id" = p_AMST_ID AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S';

        INSERT INTO "FINALUSERNAME"
        SELECT v_ivrm_school_code || v_AdmnissionNo || v_MobileNo AS "Concatenated_Newfields", 
               'A' AS "STUDENT", 
               p_AMST_ID AS "AMST_ID", 
               v_Email AS "EMAILID", 
               v_MobileNo AS "PHONENO";

    END IF;

    SELECT "FINALNAME" INTO v_BaseUserName 
    FROM "FINALUSERNAME" 
    LIMIT 1;

    IF EXISTS (SELECT 1 FROM "ApplicationUser" WHERE "UserName" IN (v_BaseUserName)) THEN

        SELECT COALESCE(MAX(CAST(SUBSTRING("UserName", LENGTH(v_BaseUserName) + 1, LENGTH("UserName") - LENGTH(v_BaseUserName)) AS INT)), 0)
        INTO v_MaxSuffix
        FROM "ApplicationUser"
        WHERE "UserName" LIKE v_BaseUserName || '%';

        v_Suffix := v_MaxSuffix + 1;

        v_NewUserName := v_BaseUserName || CAST(v_Suffix AS VARCHAR(10));

    ELSE
        v_NewUserName := v_BaseUserName;
    END IF;

    UPDATE "FINALUSERNAME" SET "FINALNAME" = v_NewUserName;

    RETURN QUERY SELECT * FROM "FINALUSERNAME";

END;
$$;