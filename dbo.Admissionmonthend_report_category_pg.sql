CREATE OR REPLACE FUNCTION "dbo"."Admissionmonthend_report_category" (
    "Year" BIGINT,
    "month" BIGINT,
    "amay" BIGINT, 
    "mi_id" BIGINT,
    "AMC_Id" BIGINT
)
RETURNS TABLE (
    "totalcount" BIGINT,
    "missingphoto" BIGINT,
    "missingemail" BIGINT,
    "missingphone" BIGINT,
    "totalnew" BIGINT,
    "smscount" BIGINT,
    "emailcount" BIGINT,
    "missingphoto_new" BIGINT,
    "missingemail_new" BIGINT,
    "missingphone_new" BIGINT,
    "total_tc" BIGINT,
    "total_absent" BIGINT,
    "DOB_Certificate_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_totalcount" BIGINT;
    "v_missingemail" BIGINT;
    "v_missingphone" BIGINT;
    "v_missingphoto" BIGINT;
    "v_newadmision" TEXT;
    "v_Bankcount" TEXT;
    "v_cashcount" TEXT;
    "v_onlinecount" TEXT;
    "v_Ecscount" TEXT;
    "v_refountcashcount" TEXT;
    "v_refountbankcount" TEXT;
    "v_defaulters" TEXT;
    "v_smscount" BIGINT;
    "v_emailcount" BIGINT;
    "v_kisokcount" TEXT;
    "v_portelNdashcount" TEXT;
    "v_newadm" TEXT;
    "v_todaydate" DATE;
    "v_totalnew" BIGINT;
    "v_total_tc" BIGINT;
    "v_total_absent" BIGINT;
    "v_missingphoto_new" BIGINT;
    "v_missingemail_new" BIGINT;
    "v_missingphone_new" BIGINT;
    "v_DOB_Certificate_count" BIGINT;
BEGIN
    "v_Bankcount" := '0';
    "v_cashcount" := '0';
    "v_onlinecount" := '0';
    "v_Ecscount" := '0';
    "v_refountcashcount" := '0';
    "v_refountbankcount" := '0';
    "v_defaulters" := '0';
    "v_smscount" := 0;
    "v_emailcount" := 0;
    "v_kisokcount" := '0';
    "v_portelNdashcount" := '0';
    "v_newadm" := '0';
    "v_todaydate" := NULL;
    "v_totalnew" := 0;
    "v_total_tc" := 0;
    "v_total_absent" := 0;
    "v_missingphoto_new" := 0;
    "v_missingemail_new" := 0;
    "v_missingphone_new" := 0;
    "v_DOB_Certificate_count" := 0;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_totalcount"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_M_Student"."AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_totalcount"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_M_Student"."AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    SELECT COUNT(*) INTO "v_smscount"
    FROM "IVRM_sms_sentBox"
    WHERE EXTRACT(YEAR FROM "IVRM_sms_sentBox"."Datetime") = "amay" 
    AND EXTRACT(MONTH FROM "IVRM_sms_sentBox"."Datetime") = "month"
    AND "IVRM_sms_sentBox"."Module_Name" = 'Admission' 
    AND "IVRM_sms_sentBox"."MI_Id" = "mi_id";

    SELECT COUNT(*) INTO "v_emailcount" 
    FROM "IVRM_Email_sentBox"
    WHERE EXTRACT(YEAR FROM "IVRM_Email_sentBox"."Datetime") = "amay"
    AND EXTRACT(MONTH FROM "IVRM_Email_sentBox"."Datetime") = "month"
    AND "IVRM_Email_sentBox"."Module_Name" = 'Admission'
    AND "IVRM_Email_sentBox"."MI_Id" = "mi_id";

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphoto"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '' OR "Adm_M_Student"."AMST_Photoname" = '0')
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphoto"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '' OR "Adm_M_Student"."AMST_Photoname" = '0')
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingemail"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_emailId" IS NULL OR "Adm_M_Student"."AMST_emailId" = '' OR "Adm_M_Student"."AMST_emailId" = '0' 
               OR "Adm_M_Student"."AMST_emailId" = 'N' OR "Adm_M_Student"."AMST_emailId" != 'test@gmail.com')
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingemail"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_emailId" IS NULL OR "Adm_M_Student"."AMST_emailId" = '' OR "Adm_M_Student"."AMST_emailId" = '0' 
               OR "Adm_M_Student"."AMST_emailId" = 'N' OR "Adm_M_Student"."AMST_emailId" != 'test@gmail.com')
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphone"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_MobileNo" IS NULL OR "Adm_M_Student"."AMST_MobileNo" = '' 
               OR "Adm_M_Student"."AMST_MobileNo" = '0' OR LENGTH("Adm_M_Student"."AMST_MobileNo") < 10)
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphone"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_MobileNo" IS NULL OR "Adm_M_Student"."AMST_MobileNo" = '' 
               OR "Adm_M_Student"."AMST_MobileNo" = '0' OR LENGTH("Adm_M_Student"."AMST_MobileNo") < 10)
        AND "AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_School_Y_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_Student_TC"."AMST_Id") INTO "v_total_tc"
        FROM "Adm_Student_TC"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_Student_TC"."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_Student_TC"."ASMAY_Id" = "Year" 
        AND EXTRACT(YEAR FROM "Adm_Student_TC"."ASTC_TCDate") = "amay"
        AND EXTRACT(MONTH FROM "Adm_Student_TC"."ASTC_TCDate") = "month" 
        AND "Adm_Student_TC"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_Student_TC"."AMST_Id") INTO "v_total_tc"
        FROM "Adm_Student_TC"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_Student_TC"."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_Student_TC"."ASMAY_Id" = "Year" 
        AND EXTRACT(YEAR FROM "Adm_Student_TC"."ASTC_TCDate") = "amay"
        AND EXTRACT(MONTH FROM "Adm_Student_TC"."ASTC_TCDate") = "month" 
        AND "Adm_Student_TC"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT aas."AMST_Id") INTO "v_total_absent"
        FROM "Adm_Student_Attendance_Students" aas
        INNER JOIN "Adm_Student_Attendance" asa ON aas."ASA_Id" = asa."ASA_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = aas."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = asa."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = asa."ASMS_Id"
        WHERE aas."ASA_Class_Attended" = 0 
        AND asa."ASMAY_Id" = "Year" 
        AND asa."MI_Id" = "mi_id"
        AND EXTRACT(YEAR FROM asa."ASA_FromDate") = "amay" 
        AND EXTRACT(MONTH FROM asa."ASA_FromDate") = "month";
    ELSE
        SELECT COUNT(DISTINCT aas."AMST_Id") INTO "v_total_absent"
        FROM "Adm_Student_Attendance_Students" aas
        INNER JOIN "Adm_Student_Attendance" asa ON aas."ASA_Id" = asa."ASA_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = aas."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = asa."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = asa."ASMS_Id"
        WHERE aas."ASA_Class_Attended" = 0 
        AND asa."ASMAY_Id" = "Year" 
        AND asa."MI_Id" = "mi_id"
        AND EXTRACT(YEAR FROM asa."ASA_FromDate") = "amay" 
        AND EXTRACT(MONTH FROM asa."ASA_FromDate") = "month" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_totalnew"
        FROM "Adm_M_Student"
        LEFT JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        LEFT JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_M_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id"
        AND EXTRACT(YEAR FROM "Adm_M_Student"."AMST_Date") = "amay" 
        AND EXTRACT(MONTH FROM "Adm_M_Student"."AMST_Date") = "month"
        AND "Adm_M_Student"."AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1;
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_totalnew"
        FROM "Adm_M_Student"
        LEFT JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        LEFT JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE "Adm_M_Student"."ASMAY_Id" = "Year" 
        AND "Adm_M_Student"."MI_Id" = "mi_id"
        AND EXTRACT(YEAR FROM "Adm_M_Student"."AMST_Date") = "amay" 
        AND EXTRACT(MONTH FROM "Adm_M_Student"."AMST_Date") = "month"
        AND "Adm_M_Student"."AMST_SOL" = 'S' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphoto_new"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '' OR "Adm_M_Student"."AMST_Photoname" = '0') 
        AND "Adm_M_Student"."AMST_SOL" = 'S'
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_M_Student"."ASMAY_Id" = "Year" 
        AND EXTRACT(MONTH FROM "Adm_M_Student"."AMST_Date") = "month"
        AND EXTRACT(YEAR FROM "Adm_M_Student"."AMST_Date") = "amay" 
        AND "Adm_M_Student"."MI_Id" = "mi_id";
    ELSE
        SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "v_missingphoto_new"
        FROM "Adm_M_Student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."AMC_Id" = "Adm_M_Student"."AMC_Id"
        WHERE ("Adm_M_Student"."AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '' OR "Adm_M_Student"."AMST_Photoname" = '0') 
        AND "Adm_M_Student"."AMST_SOL" = 'S'
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        AND "Adm_M_Student"."ASMAY_Id" = "Year" 
        AND EXTRACT(MONTH FROM "Adm_M_Student"."AMST_Date") = "month"
        AND EXTRACT(YEAR FROM "Adm_M_Student"."AMST_Date") = "amay" 
        AND "Adm_M_Student"."MI_Id" = "mi_id" 
        AND "Adm_M_Student"."AMC_Id" = "AMC_Id";
    END IF;

    IF ("AMC_Id" != 0 AND "AMC_Id" != '') THEN