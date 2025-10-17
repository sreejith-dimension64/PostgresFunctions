CREATE OR REPLACE FUNCTION "dbo"."Clg_Adm_MonthEndReport_New" (
    "Year" TEXT, 
    "month" TEXT,
    "amay" TEXT, 
    "mi_id" TEXT, 
    "AMCOC_Id" TEXT
)
RETURNS TABLE (
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

    ----------Total Strength-----------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "totalcount" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "totalcount" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    -------------------Total SMS sent---------------------------------------

    SELECT COUNT(*) INTO "smscount" 
    FROM "IVRM_sms_sentBox"
    WHERE EXTRACT(YEAR FROM "IVRM_sms_sentBox"."Datetime") = "amay"::INT
    AND EXTRACT(MONTH FROM "IVRM_sms_sentBox"."Datetime") = "month"::INT
    AND "IVRM_sms_sentBox"."Module_Name" = 'College Admission'
    AND "IVRM_sms_sentBox"."MI_Id"::TEXT = "mi_id";

    SELECT "smscount" + COUNT(*) INTO "smscount" 
    FROM "SMS_Sent_Details_Nowise" a 
    INNER JOIN "SMS_Sent_Details" b ON a."SSD_Id" = b."SSD_Id"
    WHERE EXTRACT(MONTH FROM "SSD_SentDate") = "month"::INT
    AND EXTRACT(YEAR FROM "SSD_SentDate") = "amay"::INT
    AND "MI_Id"::TEXT = "mi_id";

    -------------------Total Email sent---------------------------------------------

    SELECT COUNT(*) INTO "emailcount" 
    FROM "IVRM_Email_sentBox"
    WHERE EXTRACT(YEAR FROM "IVRM_Email_sentBox"."Datetime") = "amay"::INT
    AND EXTRACT(MONTH FROM "IVRM_Email_sentBox"."Datetime") = "month"::INT
    AND "IVRM_Email_sentBox"."Module_Name" = 'College Admission'
    AND "IVRM_Email_sentBox"."MI_Id"::TEXT = "mi_id";

    ---------------Missing Photos-------------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphoto"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_StudentPhoto" IS NULL OR a."AMCST_StudentPhoto" = '' OR a."AMCST_StudentPhoto" = '0')
        AND "AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphoto"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_StudentPhoto" IS NULL OR a."AMCST_StudentPhoto" = '' OR a."AMCST_StudentPhoto" = '0')
        AND "AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    -----------Missing Email--------------------------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingemail"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_emailId" IS NULL OR a."AMCST_emailId" = '' OR a."AMCST_emailId" = '0' OR a."AMCST_emailId" = 'NA' OR a."AMCST_emailId" = 'teresianstudent@gmail.com')
        AND a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingemail"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_emailId" IS NULL OR a."AMCST_emailId" = '' OR a."AMCST_emailId" = '0' OR a."AMCST_emailId" = 'NA' OR a."AMCST_emailId" = 'teresianstudent@gmail.com')
        AND a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    ---------Missing Mobile--------------------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphone" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_MobileNo" IS NULL OR a."AMCST_MobileNo" = '' OR a."AMCST_MobileNo" = '0' OR LENGTH(a."AMCST_MobileNo") < 10)
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND b."ASMAY_Id"::TEXT = "Year"
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphone" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE (a."AMCST_MobileNo" IS NULL OR a."AMCST_MobileNo" = '' OR a."AMCST_MobileNo" = '0' OR LENGTH(a."AMCST_MobileNo") < 10)
        AND a."AMCST_SOL" = 'S' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."ASMAY_Id"::TEXT = "Year" 
        AND a."MI_Id"::TEXT = "mi_id";

    END IF;

    -------------------Total Absent Student Count------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT b."AMCST_Id") INTO "total_absent" 
        FROM "clg"."Adm_College_Student_Attendance" a
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
        WHERE a."MI_Id"::TEXT = "mi_id" 
        AND a."ASMAY_Id"::TEXT = "Year" 
        AND b."ACSAS_ClassAttended" = 0
        AND EXTRACT(YEAR FROM a."ACSA_AttendanceDate") = "amay"::INT
        AND EXTRACT(MONTH FROM a."ACSA_AttendanceDate") = "month"::INT
        AND b."AMCST_Id" IN (SELECT "AMCST_Id" FROM "clg"."Adm_Master_College_Student" WHERE "MI_Id"::TEXT = "mi_id");

    END IF;

    ----new admission------------------------------------------------------------------------

    SELECT CURRENT_DATE INTO "todaydate";
    
    SELECT "ASMAY_Id" INTO "newadm" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "todaydate" BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id"::TEXT = "mi_id"
    LIMIT 1;

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "totalnew" 
        FROM "clg"."Adm_Master_College_Student" a
        LEFT JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        LEFT JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        LEFT JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        LEFT JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        LEFT JOIN "clg"."Adm_College_Master_Section" f ON f."ACMS_Id" = b."ACMS_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE a."ASMAY_Id"::TEXT = "Year"
        AND a."MI_Id"::TEXT = "mi_id"
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1;

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "totalnew" 
        FROM "clg"."Adm_Master_College_Student" a
        LEFT JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        LEFT JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
        LEFT JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
        LEFT JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
        LEFT JOIN "clg"."Adm_College_Master_Section" f ON f."ACMS_Id" = b."ACMS_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
        WHERE a."ASMAY_Id"::TEXT = "Year"
        AND a."MI_Id"::TEXT = "mi_id"
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1 
        AND a."AMCO_Id"::TEXT = "AMCOC_Id";

    END IF;

    ---New Admitted missing photos-------------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphoto_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_StudentPhoto" IS NULL OR a."AMCST_StudentPhoto" = '' OR a."AMCST_StudentPhoto" = '0')
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphoto_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_StudentPhoto" IS NULL OR a."AMCST_StudentPhoto" = '' OR a."AMCST_StudentPhoto" = '0')
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    -------New Admitted Missing Email------------------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingemail_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_emailId" IS NULL OR a."AMCST_emailId" = '' OR a."AMCST_emailId" = '0' OR a."AMCST_emailId" = 'NA' OR a."AMCST_emailId" = 'teresianstudent@gmail.com')
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingemail_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_emailId" IS NULL OR a."AMCST_emailId" = '' OR a."AMCST_emailId" = '0' OR a."AMCST_emailId" = 'NA' OR a."AMCST_emailId" = 'teresianstudent@gmail.com')
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    -----------New Admitted Missing Mobile-----------------------------------------------------

    IF "AMCOC_Id" = '0' THEN

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphone_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_MobileNo" IS NULL OR a."AMCST_MobileNo" = '' OR a."AMCST_MobileNo" = '0' OR LENGTH(a."AMCST_MobileNo") < 10)
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id";

    ELSE

        SELECT COUNT(DISTINCT a."AMCST_Id") INTO "missingphone_new" 
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        WHERE (a."AMCST_MobileNo" IS NULL OR a."AMCST_MobileNo" = '' OR a."AMCST_MobileNo" = '0' OR LENGTH(a."AMCST_MobileNo") < 10)
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1
        AND a."ASMAY_Id"::TEXT = "Year"
        AND EXTRACT(MONTH FROM a."AMCST_Date") = "month"::INT
        AND EXTRACT(YEAR FROM a."AMCST_Date") = "amay"::INT
        AND a."MI_Id"::TEXT = "mi_id" 
        AND a."AMCOC_Id"::TEXT = "AMCOC_Id";

    END IF;

    ----------------------------------------Printing Output-------------------

    RETURN QUERY
    SELECT 
        "totalcount",
        "missingphoto",
        "missingemail",
        "missingphone",
        "totalnew",
        "smscount",
        "emailcount",
        "missingphoto_new",
        "missingemail_new",
        "missingphone_new",
        "total_tc",
        "total_absent",
        "DOB_Certificate_count";

END;
$$;