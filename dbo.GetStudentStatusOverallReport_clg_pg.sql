CREATE OR REPLACE FUNCTION "dbo"."GetStudentStatusOverallReport_clg"(
    "ASMAY_Ids" TEXT,
    "AMCO_Ids" TEXT,
    "Mi_id" BIGINT,
    "type_" TEXT,
    "all" TEXT,
    "PAMST_Ids" TEXT
)
RETURNS TABLE(
    "fee_status" TEXT,
    "PACA_Id" BIGINT,
    "PACA_FirstName" TEXT,
    "PACA_MiddleName" TEXT,
    "PACA_LastName" TEXT,
    "PACA_Sex" TEXT,
    "PACA_DOB_inwords" TEXT,
    "PACA_RegistrationNo" TEXT,
    "PACA_emailId" TEXT,
    "PACA_MobileNo" TEXT,
    "PACA_FatherName" TEXT,
    "PACA_ConCity" TEXT,
    "PACA_ConStreet" TEXT,
    "PACA_ConArea" TEXT,
    "PACA_ConPincode" TEXT,
    "PACA_ApplStatus" BIGINT,
    "MI_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "PACA_Statusremark" TEXT,
    "AMCO_CourseName" TEXT,
    "PACA_StudentPhoto" TEXT,
    "PACA_FatherPhoto" TEXT,
    "PACA_MotherPhoto" TEXT,
    "PAMST_Status" TEXT,
    "PAMST_StatusFlag" TEXT,
    "PACA_FatherSurname" TEXT,
    "PACA_DOB" TIMESTAMP,
    "PASR_emailId" TEXT,
    "PACA_AdmStatus" BIGINT,
    "Statusadm" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
    "payment_flag" INTEGER;
BEGIN
    SELECT "ISPAC_ApplFeeFlag" 
    INTO "payment_flag" 
    FROM "IVRM_School_Preadmission_Configuration" 
    WHERE "MI_Id" = "Mi_id";

    IF "type_" = 'Appsts' THEN
        IF "payment_flag" = 1 THEN
            IF "all" = 'ALL' THEN
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                r."PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_Status", 
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                NULL::BIGINT AS "PACA_AdmStatus", NULL::TEXT AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                INNER JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            ELSE
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                r."PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_Status", 
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                NULL::BIGINT AS "PACA_AdmStatus", NULL::TEXT AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                INNER JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."PACA_ApplStatus" IN (' || "PAMST_Ids" || ') AND r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            END IF;
        ELSE
            IF "all" = 'ALL' THEN
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                r."PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_Status", 
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                NULL::BIGINT AS "PACA_AdmStatus", NULL::TEXT AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                LEFT JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            ELSE
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                r."PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_Status", 
                CASE WHEN r."PACA_ApplStatus" = 787926 THEN ''APP WAITING'' WHEN r."PACA_ApplStatus" = 787927 THEN ''APP REJECTED'' ELSE ''APP ACCEPTED'' END AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                NULL::BIGINT AS "PACA_AdmStatus", NULL::TEXT AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                LEFT JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."PACA_ApplStatus" IN (' || "PAMST_Ids" || ') AND r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            END IF;
        END IF;
    ELSIF "type_" = 'admsts' THEN
        IF "payment_flag" = 1 THEN
            IF "all" = 'ALL' THEN
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                NULL::BIGINT AS "PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                NULL::TEXT AS "PAMST_Status", NULL::TEXT AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                r."PACA_AdmStatus",
                (SELECT "pamst_status" FROM "Preadmission_Master_Status" WHERE "mi_id" = ' || "Mi_id" || ' AND "PAMST_Id" = r."PACA_AdmStatus") AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                INNER JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            ELSE
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                NULL::BIGINT AS "PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                NULL::TEXT AS "PAMST_Status", NULL::TEXT AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                r."PACA_AdmStatus",
                (SELECT "pamst_status" FROM "Preadmission_Master_Status" WHERE "mi_id" = ' || "Mi_id" || ' AND "PAMST_Id" = r."PACA_AdmStatus") AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                INNER JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."PACA_AdmStatus" IN (' || "PAMST_Ids" || ') AND r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            END IF;
        ELSE
            IF "all" = 'ALL' THEN
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                NULL::BIGINT AS "PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                NULL::TEXT AS "PAMST_Status", NULL::TEXT AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                r."PACA_AdmStatus",
                (SELECT "pamst_status" FROM "Preadmission_Master_Status" WHERE "mi_id" = ' || "Mi_id" || ' AND "PAMST_Id" = r."PACA_AdmStatus") AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                LEFT JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            ELSE
                "sqlexec" := '
                SELECT (CASE WHEN f."FYPPA_TotalPaidAmount" = 5000 THEN ''Completed'' WHEN f."FYPPA_TotalPaidAmount" >= 0 OR f."FYPPA_TotalPaidAmount" < 5000 OR f."FYPPA_TotalPaidAmount" IS NULL THEN ''Pending'' END) AS "fee_status", 
                r."PACA_Id", r."PACA_FirstName", r."PACA_MiddleName", r."PACA_LastName", r."PACA_Sex", r."PACA_DOB_inwords", r."PACA_RegistrationNo",
                r."PACA_emailId", r."PACA_MobileNo", r."PACA_FatherName", r."PACA_ConCity", r."PACA_ConStreet", r."PACA_ConArea", r."PACA_ConPincode",
                NULL::BIGINT AS "PACA_ApplStatus", r."MI_Id", r."AMCO_Id", r."PACA_Statusremark", c."AMCO_CourseName", r."PACA_StudentPhoto", r."PACA_FatherPhoto", r."PACA_MotherPhoto",
                NULL::TEXT AS "PAMST_Status", NULL::TEXT AS "PAMST_StatusFlag",
                r."PACA_FatherSurname", r."PACA_DOB",
                CASE WHEN r."PACA_emailId" IS NULL THEN ''No Email'' WHEN r."PACA_emailId" IS NOT NULL THEN r."PACA_emailId" ELSE r."PACA_emailId" END AS "PASR_emailId",
                r."PACA_AdmStatus",
                (SELECT "pamst_status" FROM "Preadmission_Master_Status" WHERE "mi_id" = ' || "Mi_id" || ' AND "PAMST_Id" = r."PACA_AdmStatus") AS "Statusadm"
                FROM "clg"."PA_College_Application" r  
                LEFT JOIN "CLG"."Adm_Master_Course" c ON r."AMCO_Id" = c."AMCO_Id" 
                LEFT JOIN "clg"."fee_y_payment_pa_application" f ON f."PACA_Id" = r."PACA_Id"  
                WHERE r."PACA_AdmStatus" IN (' || "PAMST_Ids" || ') AND r."AMCO_Id" = ' || "AMCO_Ids" || ' AND r."ASMAY_Id" = ' || "ASMAY_Ids";
            END IF;
        END IF;
    END IF;

    RETURN QUERY EXECUTE "sqlexec";
END;
$$;