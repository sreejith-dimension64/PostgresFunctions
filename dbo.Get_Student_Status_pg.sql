CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status"(
    "ASMAY_Ids" TEXT,
    "ASMCL_Ids" TEXT,
    "PAMST_Ids" TEXT,
    "Mi_id" BIGINT,
    "type_" VARCHAR(10)
)
RETURNS TABLE(
    "PASR_Id" BIGINT,
    "PAMS_Id" BIGINT,
    "Remark" TEXT,
    "PASR_FirstName" TEXT,
    "PASR_MiddleName" TEXT,
    "PASR_LastName" TEXT,
    "ASMCL_Id" BIGINT,
    "PASR_emailId" TEXT,
    "PASR_MobileNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "PAMST_Status" TEXT,
    "PAMST_StatusFlag" TEXT,
    "PASR_Sex" TEXT,
    "PASR_RegistrationNo" TEXT,
    "PASR_ConCity" TEXT,
    "PASR_ConStreet" TEXT,
    "PASR_ConArea" TEXT,
    "PASR_ConPincode" TEXT,
    "PASR_FatherName" TEXT,
    "PASR_FatherSurname" TEXT,
    "PASR_DOB" TIMESTAMP,
    "Repeat_Class_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "where" INT;
    "payment_flag" INT;
    "status" BIGINT;
    "where_condition" TEXT;
BEGIN

    SELECT "PAMST_Id" INTO "status" 
    FROM "Preadmission_Master_Status" 
    WHERE "PAMST_StatusFlag" = 'INP' AND "MI_Id" = "Mi_id";

    "where" := 0;
    "where_condition" := '';

    IF "ASMAY_Ids" != '0' THEN
        IF "where" = 0 THEN
            "where" := 1;
            "where_condition" := 'AND r."ASMAY_Id" = ' || "ASMAY_Ids" || '';
        END IF;
    END IF;

    IF "ASMCL_Ids" != '0' THEN
        IF "where" = 0 THEN
            "where" := 1;
            "where_condition" := 'AND r."ASMCL_Id" = ' || "ASMCL_Ids" || '';
        ELSE
            "where_condition" := "where_condition" || ' AND r."ASMCL_Id" = ' || "ASMCL_Ids" || '';
        END IF;
    END IF;

    SELECT "ISPAC_ApplFeeFlag" INTO "payment_flag"
    FROM "IVRM_School_Preadmission_Configuration" 
    WHERE "MI_Id" = "Mi_id";

    IF "payment_flag" = 1 THEN
        IF "type_" = 'Appsts' THEN
            IF "PAMST_Ids" != '0' THEN
                IF "where" = 0 THEN
                    "where" := 1;
                    "where_condition" := 'AND r."PASRAPS_ID" = ' || "PAMST_Ids" || '';
                ELSE
                    "where_condition" := "where_condition" || ' AND r."PASRAPS_ID" = ' || "PAMST_Ids" || '';
                END IF;
            END IF;

            IF "ASMAY_Ids" = '0' AND "ASMCL_Ids" = '0' AND "PAMST_Ids" = '0' THEN
                RETURN QUERY
                SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                       r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                       c."ASMCL_ClassName",
                       CASE WHEN r."PASRAPS_ID" = 787926 THEN 'APP WAITING' 
                            WHEN r."PASRAPS_ID" = 787927 THEN 'APP REJECTED' 
                            ELSE 'APP ACCEPTED' END AS "PAMST_Status",
                       CASE WHEN r."PASRAPS_ID" = 787926 THEN 'APP WAITING' 
                            WHEN r."PASRAPS_ID" = 787927 THEN 'APP REJECTED' 
                            ELSE 'APP ACCEPTED' END AS "PAMST_StatusFlag",
                       r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                       CAST(NULL AS TEXT) AS "PASR_ConCity", CAST(NULL AS TEXT) AS "PASR_ConStreet",
                       CAST(NULL AS TEXT) AS "PASR_ConArea", CAST(NULL AS TEXT) AS "PASR_ConPincode",
                       r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                FROM "Preadmission_School_Registration" r
                LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                WHERE r."MI_Id" = "Mi_id" AND r."PASRAPS_ID" IN (787926, 787927, 787928)
                  AND r."PASR_Id" IN (SELECT "PASA_Id" FROM "Fee_Y_Payment_PA_Application") 
                  AND r."PASR_Adm_Confirm_Flag" = 0;
            ELSE
                RETURN QUERY EXECUTE
                'SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                        r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                        c."ASMCL_ClassName",
                        CASE WHEN r."PASRAPS_ID" = 787926 THEN ''APP WAITING'' 
                             WHEN r."PASRAPS_ID" = 787927 THEN ''APP REJECTED'' 
                             ELSE ''APP ACCEPTED'' END AS "PAMST_Status",
                        CASE WHEN r."PASRAPS_ID" = 787926 THEN ''APP WAITING'' 
                             WHEN r."PASRAPS_ID" = 787927 THEN ''APP REJECTED'' 
                             ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                        r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                        CAST(NULL AS TEXT) AS "PASR_ConCity", CAST(NULL AS TEXT) AS "PASR_ConStreet",
                        CAST(NULL AS TEXT) AS "PASR_ConArea", CAST(NULL AS TEXT) AS "PASR_ConPincode",
                        r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                 FROM "Preadmission_School_Registration" r
                 LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                 WHERE r."MI_Id" = ' || "Mi_id" || ' ' || "where_condition" || '
                   AND r."PASR_Id" IN (SELECT "PASA_Id" FROM "Fee_Y_Payment_PA_Application") 
                   AND r."PASR_Adm_Confirm_Flag" = 0';
            END IF;
        ELSE
            IF "PAMST_Ids" != '0' THEN
                IF "where" = 0 THEN
                    "where" := 1;
                    "where_condition" := 'AND r."PAMS_Id" = ' || "PAMST_Ids" || '';
                ELSE
                    "where_condition" := "where_condition" || ' AND r."PAMS_Id" = ' || "PAMST_Ids" || '';
                END IF;
            END IF;

            IF "ASMAY_Ids" = '0' AND "ASMCL_Ids" = '0' AND "PAMST_Ids" = '0' THEN
                RETURN QUERY
                SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                       r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                       c."ASMCL_ClassName", s."PAMST_Status", s."PAMST_StatusFlag",
                       r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                       CAST(NULL AS TEXT) AS "PASR_ConCity", CAST(NULL AS TEXT) AS "PASR_ConStreet",
                       CAST(NULL AS TEXT) AS "PASR_ConArea", CAST(NULL AS TEXT) AS "PASR_ConPincode",
                       r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                FROM "Preadmission_School_Registration" r
                LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                LEFT JOIN "Preadmission_Master_Status" s ON s."PAMST_Id" = r."PAMS_Id"
                WHERE r."MI_Id" = "Mi_id"
                  AND r."PASR_Id" IN (SELECT "PASA_Id" FROM "Fee_Y_Payment_PA_Application") 
                  AND r."PASR_Adm_Confirm_Flag" = 0 AND r."PASRAPS_ID" = 787928;
            ELSE
                RETURN QUERY EXECUTE
                'SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                        r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                        c."ASMCL_ClassName", s."PAMST_Status", s."PAMST_StatusFlag",
                        r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                        CAST(NULL AS TEXT) AS "PASR_ConCity", CAST(NULL AS TEXT) AS "PASR_ConStreet",
                        CAST(NULL AS TEXT) AS "PASR_ConArea", CAST(NULL AS TEXT) AS "PASR_ConPincode",
                        r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                 FROM "Preadmission_School_Registration" r
                 LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                 LEFT JOIN "Preadmission_Master_Status" s ON s."PAMST_Id" = r."PAMS_Id"
                 WHERE r."MI_Id" = ' || "Mi_id" || ' ' || "where_condition" || '
                   AND r."PASR_Id" IN (SELECT "PASA_Id" FROM "Fee_Y_Payment_PA_Application") 
                   AND r."PASR_Adm_Confirm_Flag" = 0 AND r."PASRAPS_ID" = 787928';
            END IF;
        END IF;
    ELSE
        IF "type_" = 'Appsts' THEN
            IF "PAMST_Ids" != '0' THEN
                IF "where" = 0 THEN
                    "where" := 1;
                    "where_condition" := 'AND r."PASRAPS_ID" = ' || "PAMST_Ids" || '';
                ELSE
                    "where_condition" := "where_condition" || ' AND r."PASRAPS_ID" = ' || "PAMST_Ids" || '';
                END IF;
            END IF;

            IF "ASMAY_Ids" = '0' AND "ASMCL_Ids" = '0' AND "PAMST_Ids" = '0' THEN
                RETURN QUERY
                SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                       r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                       c."ASMCL_ClassName",
                       CASE WHEN r."PASRAPS_ID" = 787926 THEN 'APP WAITING' 
                            WHEN r."PASRAPS_ID" = 787927 THEN 'APP REJECTED' 
                            ELSE 'APP ACCEPTED' END AS "PAMST_Status",
                       CASE WHEN r."PASRAPS_ID" = 787926 THEN 'APP WAITING' 
                            WHEN r."PASRAPS_ID" = 787927 THEN 'APP REJECTED' 
                            ELSE 'APP ACCEPTED' END AS "PAMST_StatusFlag",
                       r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                       r."PASR_ConCity", r."PASR_ConStreet", r."PASR_ConArea", r."PASR_ConPincode",
                       r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                FROM "Preadmission_School_Registration" r
                LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                WHERE r."MI_Id" = "Mi_id" AND r."PASRAPS_ID" IN (787926, 787927, 787928)
                  AND r."PASR_Id" NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students") 
                  AND r."PASR_Adm_Confirm_Flag" = 0;
            ELSE
                RETURN QUERY EXECUTE
                'SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                        r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                        c."ASMCL_ClassName",
                        CASE WHEN r."PASRAPS_ID" = 787926 THEN ''APP WAITING'' 
                             WHEN r."PASRAPS_ID" = 787927 THEN ''APP REJECTED'' 
                             ELSE ''APP ACCEPTED'' END AS "PAMST_Status",
                        CASE WHEN r."PASRAPS_ID" = 787926 THEN ''APP WAITING'' 
                             WHEN r."PASRAPS_ID" = 787927 THEN ''APP REJECTED'' 
                             ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                        r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                        r."PASR_ConCity", r."PASR_ConStreet", r."PASR_ConArea", r."PASR_ConPincode",
                        r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                 FROM "Preadmission_School_Registration" r
                 LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                 WHERE r."MI_Id" = ' || "Mi_id" || ' ' || "where_condition" || '
                   AND r."PASR_Id" NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students") 
                   AND r."PASR_Adm_Confirm_Flag" = 0';
            END IF;
        ELSE
            IF "PAMST_Ids" != '0' THEN
                IF "where" = 0 THEN
                    "where" := 1;
                    "where_condition" := 'AND r."PAMS_Id" = ' || "PAMST_Ids" || '';
                ELSE
                    "where_condition" := "where_condition" || ' AND r."PAMS_Id" = ' || "PAMST_Ids" || '';
                END IF;
            END IF;

            IF "ASMAY_Ids" = '0' AND "ASMCL_Ids" = '0' AND "PAMST_Ids" = '0' THEN
                RETURN QUERY
                SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                       r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                       c."ASMCL_ClassName", s."PAMST_Status", s."PAMST_StatusFlag",
                       r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                       r."PASR_ConCity", r."PASR_ConStreet", r."PASR_ConArea", r."PASR_ConPincode",
                       r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                FROM "Preadmission_School_Registration" r
                LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                LEFT JOIN "Preadmission_Master_Status" s ON s."PAMST_Id" = r."PAMS_Id"
                WHERE r."MI_Id" = "Mi_id"
                  AND r."PASR_Id" NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students") 
                  AND r."PASR_Adm_Confirm_Flag" = 0 AND r."PASRAPS_ID" = 787928;
            ELSE
                RETURN QUERY EXECUTE
                'SELECT r."PASR_Id", r."PAMS_Id", r."Remark", r."PASR_FirstName", r."PASR_MiddleName", r."PASR_LastName", 
                        r."ASMCL_Id", r."PASR_emailId", r."PASR_MobileNo",
                        c."ASMCL_ClassName", s."PAMST_Status", s."PAMST_StatusFlag",
                        r."PASR_Sex", r."PASR_RegistrationNo", r."PASR_emailId", r."PASR_MobileNo",
                        r."PASR_ConCity", r."PASR_ConStreet", r."PASR_ConArea", r."PASR_ConPincode",
                        r."PASR_FatherName", r."PASR_FatherSurname", r."PASR_DOB", r."Repeat_Class_Id"
                 FROM "Preadmission_School_Registration" r
                 LEFT JOIN "Adm_School_M_Class" c ON r."ASMCL_Id" = c."ASMCL_Id"
                 LEFT JOIN "Preadmission_Master_Status" s ON s."PAMST_Id" = r."PAMS_Id"
                 WHERE r."MI_Id" = ' || "Mi_id" || ' ' || "where_condition" || '
                   AND r."PASR_Id" NOT IN (SELECT "PASR_Id" FROM "Preadmission_SeatBlocked_Students") 
                   AND r."PASR_Adm_Confirm_Flag" = 0';
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;