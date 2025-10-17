CREATE OR REPLACE FUNCTION "dbo"."Admissionmonthend_report"(
    "Year" TEXT,
    "month" TEXT,
    "amay" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE(
    "total_strength" BIGINT,
    "missing_pic" BIGINT,
    "missing_email" BIGINT,
    "missing_phone" BIGINT,
    "newadmission" BIGINT,
    "sent_sms_count" BIGINT,
    "sent_email_count" BIGINT,
    "missingphoto_new" BIGINT,
    "missingemail_new" BIGINT,
    "missingphone_new" BIGINT,
    "tc_count" BIGINT,
    "tot_absent" BIGINT,
    "DOB_Certificate_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "totalcount" BIGINT;
    "missingemail" BIGINT;
    "missingphone" BIGINT;
    "missingphoto" BIGINT;
    "newadmision" BIGINT;
    "Bankcount" BIGINT;
    "cashcount" BIGINT;
    "onlinecount" BIGINT;
    "Ecscount" BIGINT;
    "refountcashcount" BIGINT;
    "refountbankcount" BIGINT;
    "defaulters" BIGINT;
    "smscount" BIGINT;
    "emailcount" BIGINT;
    "kisokcount" BIGINT;
    "portelNdashcount" BIGINT;
    "newadm" BIGINT;
    "todaydate" DATE;
    "totalnew" BIGINT;
    "total_tc" BIGINT;
    "total_absent" BIGINT;
    "missingphoto_new" BIGINT;
    "missingemail_new" BIGINT;
    "missingphone_new" BIGINT;
    "DOB_Certificate_count" BIGINT;
BEGIN
    "Bankcount" := 0;
    "cashcount" := 0;
    "onlinecount" := 0;
    "Ecscount" := 0;
    "refountcashcount" := 0;
    "refountbankcount" := 0;
    "defaulters" := 0;
    "smscount" := 0;
    "emailcount" := 0;
    "kisokcount" := 0;
    "portelNdashcount" := 0;
    "newadm" := 0;
    "todaydate" := NULL;
    "totalnew" := 0;
    "total_tc" := 0;
    "total_absent" := 0;
    "missingphoto_new" := 0;
    "missingemail_new" := 0;
    "missingphone_new" := 0;
    "DOB_Certificate_count" := 0;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "totalcount"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE "AMST_SOL" = 'S' AND "amst_activeflag" = 1 AND "AMAY_ActiveFlag" = 1
    AND "Adm_School_Y_Student"."ASMAY_Id" = "Year"
    AND "Adm_M_Student"."MI_Id" = "mi_id";

    SELECT COUNT(*) INTO "smscount"
    FROM "IVRM_sms_sentBox"
    WHERE "Module_Name" = 'Admission'
    AND "IVRM_sms_sentBox"."MI_Id" = "mi_id"
    AND EXTRACT(MONTH FROM "Datetime") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "Datetime") = "amay"::INTEGER;

    SELECT COUNT(*) INTO "emailcount"
    FROM "IVRM_Email_sentBox"
    WHERE "Module_Name" = 'Admission'
    AND "IVRM_Email_sentBox"."MI_Id" = "mi_id"
    AND EXTRACT(MONTH FROM "Datetime") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "Datetime") = "amay"::INTEGER;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingphoto"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '')
    AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
    AND "Adm_School_Y_Student"."ASMAY_Id" = "Year"
    AND "Adm_M_Student"."MI_Id" = "mi_id";

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingemail"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_M_Student"."AMST_emailId" IS NULL OR "Adm_M_Student"."AMST_emailId" = '' OR "Adm_M_Student"."AMST_emailId" = 'test@gmail.com')
    AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
    AND "Adm_School_Y_Student"."ASMAY_Id" = "Year"
    AND "Adm_M_Student"."MI_Id" = "mi_id";

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingphone"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_M_Student"."AMST_MobileNo" IS NULL
        OR "Adm_M_Student"."AMST_MobileNo" = ''
        OR "Adm_M_Student"."AMST_MobileNo" = '0'
        OR LENGTH("Adm_M_Student"."AMST_MobileNo") < 10)
    AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
    AND "Adm_School_Y_Student"."ASMAY_Id" = "Year"
    AND "Adm_M_Student"."MI_Id" = "mi_id";

    SELECT COUNT(DISTINCT "Adm_Student_TC"."AMST_Id") INTO "total_tc"
    FROM "Adm_Student_TC"
    WHERE "Adm_Student_TC"."ASMAY_Id" = "Year"
    AND "Adm_Student_TC"."MI_Id" = "mi_id"
    AND EXTRACT(MONTH FROM "ASTC_TCDate") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "astc_tcdate") = "amay"::INTEGER;

    SELECT COUNT(DISTINCT "aas"."AMST_Id") INTO "total_absent"
    FROM "Adm_Student_Attendance_Students" "aas"
    INNER JOIN "Adm_Student_Attendance" "asa" ON "aas"."ASAS_Id" = "asa"."ASA_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "asa"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "asa"."ASMS_Id"
    WHERE "aas"."ASA_Class_Attended" = 0
    AND "asa"."ASMAY_Id" = "Year"
    AND "asa"."MI_Id" = "mi_id"
    AND EXTRACT(MONTH FROM "ASA_FromDate") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "ASA_FromDate") = "amay"::INTEGER;

    "todaydate" := CURRENT_DATE;

    SELECT "ASMAY_Id" INTO "newadm"
    FROM "Adm_School_M_Academic_Year"
    WHERE TO_CHAR("todaydate", 'DD/MM/YYYY') BETWEEN TO_CHAR("ASMAY_From_Date", 'DD/MM/YYYY') AND TO_CHAR("ASMAY_To_Date", 'DD/MM/YYYY')
    AND "MI_Id" = "mi_id"
    LIMIT 1;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "totalnew"
    FROM "Adm_M_Student"
    WHERE "Adm_M_Student"."MI_Id" = "mi_id"
    AND "ASMAY_Id" = "Year"
    AND "AMST_SOL" = 'S'
    AND "AMST_ActiveFlag" = 1
    AND EXTRACT(MONTH FROM "AMST_Date") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "amst_date") = "amay"::INTEGER;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingphoto_new"
    FROM "Adm_M_Student"
    WHERE ("AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '')
    AND "Adm_M_Student"."AMST_SOL" = 'S'
    AND "AMST_ActiveFlag" = 1
    AND "Adm_M_Student"."ASMAY_Id" = "Year"
    AND EXTRACT(MONTH FROM "AMST_Date") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "amst_date") = "amay"::INTEGER;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingemail_new"
    FROM "Adm_M_Student"
    WHERE ("AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '')
    AND "Adm_M_Student"."AMST_SOL" = 'S'
    AND "AMST_ActiveFlag" = 1
    AND "Adm_M_Student"."ASMAY_Id" = "Year"
    AND EXTRACT(MONTH FROM "AMST_Date") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "amst_date") = "amay"::INTEGER;

    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO "missingphone_new"
    FROM "Adm_M_Student"
    WHERE ("Adm_M_Student"."AMST_MobileNo" IS NULL
        OR "Adm_M_Student"."AMST_MobileNo" = ''
        OR "Adm_M_Student"."AMST_MobileNo" = '0'
        OR LENGTH("Adm_M_Student"."AMST_MobileNo") < 10)
    AND "AMST_SOL" = 'S'
    AND "AMST_ActiveFlag" = 1
    AND "Adm_M_Student"."ASMAY_Id" = "Year"
    AND EXTRACT(MONTH FROM "AMST_Date") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "amst_date") = "amay"::INTEGER
    AND "Adm_M_Student"."ASMAY_Id" = "Year";

    SELECT COUNT(*) INTO "DOB_Certificate_count"
    FROM "Adm_Study_Certificate_Report"
    WHERE "Adm_Study_Certificate_Report"."MI_Id" = "mi_id"
    AND EXTRACT(MONTH FROM "Adm_Study_Certificate_Report"."ASC_Date") = "month"::INTEGER
    AND EXTRACT(YEAR FROM "Adm_Study_Certificate_Report"."ASC_Date") = "amay"::INTEGER;

    RETURN QUERY
    SELECT 
        "totalcount" AS "total_strength",
        "missingphoto" AS "missing_pic",
        "missingemail" AS "missing_email",
        "missingphone" AS "missing_phone",
        "totalnew" AS "newadmission",
        "smscount" AS "sent_sms_count",
        "emailcount" AS "sent_email_count",
        "missingphoto_new" AS "missingphoto_new",
        "missingemail_new" AS "missingemail_new",
        "missingphone_new" AS "missingphone_new",
        "total_tc" AS "tc_count",
        "total_absent" AS "tot_absent",
        "DOB_Certificate_count" AS "DOB_Certificate_count";

    RETURN;
END;
$$;