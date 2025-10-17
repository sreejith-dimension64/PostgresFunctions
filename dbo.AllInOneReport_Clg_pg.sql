CREATE OR REPLACE FUNCTION "dbo"."AllInOneReport_Clg"(
    p_RoleId BIGINT,
    p_RoleTypeId BIGINT,
    p_From_Date TIMESTAMP,
    p_To_Date TIMESTAMP,
    p_option INT,
    p_year BIGINT,
    p_type VARCHAR(10),
    p_miid VARCHAR(10),
    p_predate DATE,
    p_prenddate DATE,
    p_AMCO_Id BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "EmailID" TEXT,
    "Mobileno" TEXT,
    "FatherName" TEXT,
    "RegDate" TIMESTAMP,
    "FirstName" TEXT,
    "MiddleName" TEXT,
    "LastName" TEXT,
    "Course" TEXT,
    "Bloodgroup" TEXT,
    "RegNo" TEXT,
    "Gender" TEXT,
    "DOB" TIMESTAMP,
    "DOBinwords" TEXT,
    "MotherTounge" TEXT,
    "ReligionName" TEXT,
    "CasteName" TEXT,
    "PermanentStreet" TEXT,
    "PermanentArea" TEXT,
    "PermanentCity" TEXT,
    "PermanentPincode" TEXT,
    "CurrentStreet" TEXT,
    "CurrentArea" TEXT,
    "State" TEXT,
    "Country" TEXT,
    "CurrentPincode" TEXT,
    "AadharNo" TEXT,
    "FatherEducation" TEXT,
    "FatherOccupation" TEXT,
    "FatherDesignation" TEXT,
    "FatherIncome" NUMERIC,
    "FatherMobileno" TEXT,
    "MotherName" TEXT,
    "MotherEducation" TEXT,
    "MotherOccupation" TEXT,
    "MotherDesignation" TEXT,
    "MotherIncome" NUMERIC,
    "MotherMobileno" TEXT,
    "BirthPlace" TEXT,
    "FatherOfficeAddress" TEXT,
    "MotherOfficeAddress" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_userId BIGINT;
    v_fdate DATE;
    v_tdate DATE;
BEGIN
    v_fdate := p_From_Date::DATE;
    v_tdate := p_To_Date::DATE;

    IF p_type = 'btwdates' THEN
        IF p_option = 1 THEN
            RETURN QUERY
            SELECT 
                "IVRM_User_Login_Institutionwise"."MI_Id",
                "ApplicationUser"."Email" AS "EmailID",
                "ApplicationUser"."PhoneNumber" AS "Mobileno",
                "ApplicationUser"."Name" AS "FatherName",
                "ApplicationUser"."Entry_Date" AS "RegDate",
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::NUMERIC, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT
            FROM "ApplicationUser"
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId"
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id"
            WHERE "IVRM_User_Login_Institutionwise"."MI_Id"::VARCHAR = p_miid
            AND "ApplicationUserRole"."RoleId" IN (
                SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser'
            )
            AND "ApplicationUser"."Entry_Date"::DATE BETWEEN v_fdate AND v_tdate;

        ELSIF p_option = 2 THEN
            RETURN QUERY
            SELECT DISTINCT
                "IVRM_User_Login_Institutionwise"."MI_Id",
                "ApplicationUser"."Email" AS "EmailID",
                "ApplicationUser"."PhoneNumber" AS "Mobileno",
                "ApplicationUser"."Name" AS "FatherName",
                "ApplicationUser"."Entry_Date" AS "RegDate",
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::NUMERIC, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, NULL::TEXT,
                NULL::TEXT, NULL::TEXT
            FROM "ApplicationUser"
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId"
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."MI_Id" = "IVRM_User_Login_Institutionwise"."MI_Id"
            WHERE "ApplicationUser"."Id" NOT IN (
                SELECT "Id" FROM "clg"."PA_College_Application" WHERE "MI_Id"::VARCHAR = p_miid
            )
            AND "ApplicationUserRole"."RoleId" IN (
                SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser'
            )
            AND "IVRM_User_Login_Institutionwise"."MI_Id"::VARCHAR = p_miid
            AND "ApplicationUser"."Entry_Date"::DATE BETWEEN v_fdate AND v_tdate;

        ELSIF p_option = 3 THEN
            IF p_AMCO_Id = 0 THEN
                RETURN QUERY
                SELECT 
                    NULL::BIGINT AS "MI_Id",
                    "paca"."PACA_emailId" AS "EmailID",
                    "paca"."PACA_MobileNo" AS "Mobileno",
                    (CASE WHEN "paca"."PACA_FatherName" IS NULL OR "paca"."PACA_FatherName" = '' THEN '' ELSE "paca"."PACA_FatherName" END ||
                     CASE WHEN "paca"."PACA_FatherSurname" IS NULL OR "paca"."PACA_FatherSurname" = '' OR "paca"."PACA_FatherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_FatherSurname" END) AS "FatherName",
                    "paca"."PACA_Date" AS "RegDate",
                    "paca"."PACA_FirstName" AS "FirstName",
                    "paca"."PACA_MiddleName" AS "MiddleName",
                    "paca"."PACA_LastName" AS "LastName",
                    "course"."AMCO_CourseName" AS "Course",
                    "paca"."PACA_BloodGroup" AS "Bloodgroup",
                    "paca"."PACA_RegistrationNo" AS "RegNo",
                    "paca"."PACA_Sex" AS "Gender",
                    "paca"."PACA_DOB" AS "DOB",
                    "paca"."PACA_DOB_inwords" AS "DOBinwords",
                    "paca"."PACA_MotherTongue" AS "MotherTounge",
                    "religion"."IVRMMR_Name" AS "ReligionName",
                    "caste"."IMC_CasteName" AS "CasteName",
                    "paca"."PACA_PerStreet" AS "PermanentStreet",
                    "paca"."PACA_PerArea" AS "PermanentArea",
                    "paca"."PACA_PerCity" AS "PermanentCity",
                    "paca"."PACA_PerPincode" AS "PermanentPincode",
                    "paca"."PACA_ConStreet" AS "CurrentStreet",
                    "paca"."PACA_ConArea" AS "CurrentArea",
                    "state"."IVRMMS_Name" AS "State",
                    "country"."IVRMMC_CountryName" AS "Country",
                    "paca"."PACA_ConPincode" AS "CurrentPincode",
                    "paca"."PACA_AadharNo" AS "AadharNo",
                    "paca"."PACA_FatherEducation" AS "FatherEducation",
                    "paca"."PACA_FatherOccupation" AS "FatherOccupation",
                    "paca"."PACA_FatherOccupation" AS "FatherDesignation",
                    "paca"."PACA_FatherAnnIncome" AS "FatherIncome",
                    "paca"."PACA_FatherMobleNo" AS "FatherMobileno",
                    (CASE WHEN "paca"."PACA_MotherName" IS NULL OR "paca"."PACA_MotherName" = '' THEN '' ELSE "paca"."PACA_MotherName" END ||
                     CASE WHEN "paca"."PACA_MotherSurname" IS NULL OR "paca"."PACA_MotherSurname" = '' OR "paca"."PACA_MotherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_MotherSurname" END) AS "MotherName",
                    "paca"."PACA_MotherEducation" AS "MotherEducation",
                    "paca"."PACA_MotherOccupation" AS "MotherOccupation",
                    "paca"."PACA_MotherDesignation" AS "MotherDesignation",
                    "paca"."PACA_MotherAnnIncome" AS "MotherIncome",
                    "paca"."PACA_MotherMobleNo" AS "MotherMobileno",
                    "paca"."PACA_BirthPlace" AS "BirthPlace",
                    "paca"."PACA_FatherOfficeAdd" AS "FatherOfficeAddress",
                    "paca"."PACA_MotherOfficeAdd" AS "MotherOfficeAddress"
                FROM "clg"."PA_College_Application" "paca"
                LEFT OUTER JOIN "dbo"."IVRM_Master_State" "state" ON "paca"."PACA_ConState" = "state"."IVRMMS_Id"
                INNER JOIN "dbo"."IVRM_Master_Religion" "religion" ON "paca"."IVRMMR_Id" = "religion"."IVRMMR_Id"
                INNER JOIN "dbo"."ApplicationUser" "appuser" ON "paca"."Id" = "appuser"."Id"
                INNER JOIN "CLG"."Adm_Master_Course" "course" ON "paca"."AMCO_Id" = "course"."AMCO_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" "year" ON "paca"."ASMAY_Id" = "year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" "country" ON "country"."IVRMMC_Id" = "paca"."PACA_ConCountryId"
                LEFT JOIN "IVRM_Master_Caste" "caste" ON "caste"."IMC_Id" = "paca"."IMC_Id"
                WHERE "paca"."PACA_Date"::DATE BETWEEN v_fdate AND v_tdate
                AND "paca"."MI_Id"::VARCHAR = p_miid;
            ELSE
                RETURN QUERY
                SELECT 
                    NULL::BIGINT AS "MI_Id",
                    "paca"."PACA_emailId" AS "EmailID",
                    "paca"."PACA_MobileNo" AS "Mobileno",
                    (CASE WHEN "paca"."PACA_FatherName" IS NULL OR "paca"."PACA_FatherName" = '' THEN '' ELSE "paca"."PACA_FatherName" END ||
                     CASE WHEN "paca"."PACA_FatherSurname" IS NULL OR "paca"."PACA_FatherSurname" = '' OR "paca"."PACA_FatherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_FatherSurname" END) AS "FatherName",
                    "paca"."PACA_Date" AS "RegDate",
                    "paca"."PACA_FirstName" AS "FirstName",
                    "paca"."PACA_MiddleName" AS "MiddleName",
                    "paca"."PACA_LastName" AS "LastName",
                    "course"."AMCO_CourseName" AS "Course",
                    "paca"."PACA_BloodGroup" AS "Bloodgroup",
                    "paca"."PACA_RegistrationNo" AS "RegNo",
                    "paca"."PACA_Sex" AS "Gender",
                    "paca"."PACA_DOB" AS "DOB",
                    "paca"."PACA_DOB_inwords" AS "DOBinwords",
                    "paca"."PACA_MotherTongue" AS "MotherTounge",
                    "religion"."IVRMMR_Name" AS "ReligionName",
                    "caste"."IMC_CasteName" AS "CasteName",
                    "paca"."PACA_PerStreet" AS "PermanentStreet",
                    "paca"."PACA_PerArea" AS "PermanentArea",
                    "paca"."PACA_PerCity" AS "PermanentCity",
                    "paca"."PACA_PerPincode" AS "PermanentPincode",
                    "paca"."PACA_ConStreet" AS "CurrentStreet",
                    "paca"."PACA_ConArea" AS "CurrentArea",
                    "state"."IVRMMS_Name" AS "State",
                    "country"."IVRMMC_CountryName" AS "Country",
                    "paca"."PACA_ConPincode" AS "CurrentPincode",
                    "paca"."PACA_AadharNo" AS "AadharNo",
                    "paca"."PACA_FatherEducation" AS "FatherEducation",
                    "paca"."PACA_FatherOccupation" AS "FatherOccupation",
                    "paca"."PACA_FatherOccupation" AS "FatherDesignation",
                    "paca"."PACA_FatherAnnIncome" AS "FatherIncome",
                    "paca"."PACA_FatherMobleNo" AS "FatherMobileno",
                    (CASE WHEN "paca"."PACA_MotherName" IS NULL OR "paca"."PACA_MotherName" = '' THEN '' ELSE "paca"."PACA_MotherName" END ||
                     CASE WHEN "paca"."PACA_MotherSurname" IS NULL OR "paca"."PACA_MotherSurname" = '' OR "paca"."PACA_MotherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_MotherSurname" END) AS "MotherName",
                    "paca"."PACA_MotherEducation" AS "MotherEducation",
                    "paca"."PACA_MotherOccupation" AS "MotherOccupation",
                    "paca"."PACA_MotherDesignation" AS "MotherDesignation",
                    "paca"."PACA_MotherAnnIncome" AS "MotherIncome",
                    "paca"."PACA_MotherMobleNo" AS "MotherMobileno",
                    "paca"."PACA_BirthPlace" AS "BirthPlace",
                    "paca"."PACA_FatherOfficeAdd" AS "FatherOfficeAddress",
                    "paca"."PACA_MotherOfficeAdd" AS "MotherOfficeAddress"
                FROM "clg"."PA_College_Application" "paca"
                LEFT OUTER JOIN "dbo"."IVRM_Master_State" "state" ON "paca"."PACA_ConState" = "state"."IVRMMS_Id"
                INNER JOIN "dbo"."IVRM_Master_Religion" "religion" ON "paca"."IVRMMR_Id" = "religion"."IVRMMR_Id"
                INNER JOIN "dbo"."ApplicationUser" "appuser" ON "paca"."Id" = "appuser"."Id"
                INNER JOIN "CLG"."Adm_Master_Course" "course" ON "paca"."AMCO_Id" = "course"."AMCO_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" "year" ON "paca"."ASMAY_Id" = "year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" "country" ON "country"."IVRMMC_Id" = "paca"."PACA_ConCountryId"
                LEFT JOIN "IVRM_Master_Caste" "caste" ON "caste"."IMC_Id" = "paca"."IMC_Id"
                WHERE "paca"."PACA_Date"::DATE BETWEEN v_fdate AND v_tdate
                AND "paca"."MI_Id"::VARCHAR = p_miid
                AND "paca"."AMCO_Id" = p_AMCO_Id;
            END IF;

        ELSIF p_option = 4 THEN
            IF p_AMCO_Id = 0 THEN
                RETURN QUERY
                SELECT 
                    NULL::BIGINT AS "MI_Id",
                    "paca"."PACA_emailId" AS "EmailID",
                    "paca"."PACA_MobileNo" AS "Mobileno",
                    (CASE WHEN "paca"."PACA_FatherName" IS NULL OR "paca"."PACA_FatherName" = '' THEN '' ELSE "paca"."PACA_FatherName" END ||
                     CASE WHEN "paca"."PACA_FatherSurname" IS NULL OR "paca"."PACA_FatherSurname" = '' OR "paca"."PACA_FatherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_FatherSurname" END) AS "FatherName",
                    "paca"."PACA_Date" AS "RegDate",
                    "paca"."PACA_FirstName" AS "FirstName",
                    "paca"."PACA_MiddleName" AS "MiddleName",
                    "paca"."PACA_LastName" AS "LastName",
                    "course"."AMCO_CourseName" AS "Course",
                    "paca"."PACA_BloodGroup" AS "Bloodgroup",
                    "paca"."PACA_RegistrationNo" AS "RegNo",
                    "paca"."PACA_Sex" AS "Gender",
                    "paca"."PACA_DOB" AS "DOB",
                    "paca"."PACA_DOB_inwords" AS "DOBinwords",
                    "paca"."PACA_MotherTongue" AS "MotherTounge",
                    "religion"."IVRMMR_Name" AS "ReligionName",
                    "caste"."IMC_CasteName" AS "CasteName",
                    "paca"."PACA_PerStreet" AS "PermanentStreet",
                    "paca"."PACA_PerArea" AS "PermanentArea",
                    "paca"."PACA_PerCity" AS "PermanentCity",
                    "paca"."PACA_PerPincode" AS "PermanentPincode",
                    "paca"."PACA_ConStreet" AS "CurrentStreet",
                    "paca"."PACA_ConArea" AS "CurrentArea",
                    "state"."IVRMMS_Name" AS "State",
                    "country"."IVRMMC_CountryName" AS "Country",
                    "paca"."PACA_ConPincode" AS "CurrentPincode",
                    "paca"."PACA_AadharNo" AS "AadharNo",
                    "paca"."PACA_FatherEducation" AS "FatherEducation",
                    "paca"."PACA_FatherOccupation" AS "FatherOccupation",
                    "paca"."PACA_FatherOccupation" AS "FatherDesignation",
                    "paca"."PACA_FatherAnnIncome" AS "FatherIncome",
                    "paca"."PACA_FatherMobleNo" AS "FatherMobileno",
                    (CASE WHEN "paca"."PACA_MotherName" IS NULL OR "paca"."PACA_MotherName" = '' THEN '' ELSE "paca"."PACA_MotherName" END ||
                     CASE WHEN "paca"."PACA_MotherSurname" IS NULL OR "paca"."PACA_MotherSurname" = '' OR "paca"."PACA_MotherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_MotherSurname" END) AS "MotherName",
                    "paca"."PACA_MotherEducation" AS "MotherEducation",
                    "paca"."PACA_MotherOccupation" AS "MotherOccupation",
                    "paca"."PACA_MotherDesignation" AS "MotherDesignation",
                    "paca"."PACA_MotherAnnIncome" AS "MotherIncome",
                    "paca"."PACA_MotherMobleNo" AS "MotherMobileno",
                    "paca"."PACA_BirthPlace" AS "BirthPlace",
                    "paca"."PACA_FatherOfficeAdd" AS "FatherOfficeAddress",
                    "paca"."PACA_MotherOfficeAdd" AS "MotherOfficeAddress"
                FROM "clg"."PA_College_Application" "paca"
                LEFT OUTER JOIN "dbo"."IVRM_Master_State" "state" ON "paca"."PACA_ConState" = "state"."IVRMMS_Id"
                INNER JOIN "dbo"."IVRM_Master_Religion" "religion" ON "paca"."IVRMMR_Id" = "religion"."IVRMMR_Id"
                INNER JOIN "dbo"."ApplicationUser" "appuser" ON "paca"."Id" = "appuser"."Id"
                INNER JOIN "CLG"."Adm_Master_Course" "course" ON "paca"."AMCO_Id" = "course"."AMCO_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" "year" ON "paca"."ASMAY_Id" = "year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" "country" ON "country"."IVRMMC_Id" = "paca"."PACA_ConCountryId"
                LEFT JOIN "IVRM_Master_Caste" "caste" ON "caste"."IMC_Id" = "paca"."IMC_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" "dd" ON "dd"."PASA_Id" = "paca"."PACA_Id"
                INNER JOIN "fee_y_payment" "fee" ON "fee"."FYP_Id" = "dd"."FYP_Id"
                WHERE "paca"."PACA_Id" IN (
                    SELECT "pasa_id" FROM "Fee_Y_Payment_PA_Application" WHERE "fyppa_type" = 'R'
                )
                AND "fee"."FYP_Date"::DATE BETWEEN v_fdate AND v_tdate
                AND "paca"."MI_Id"::VARCHAR = p_miid;
            ELSE
                RETURN QUERY
                SELECT 
                    NULL::BIGINT AS "MI_Id",
                    "paca"."PACA_emailId" AS "EmailID",
                    "paca"."PACA_MobileNo" AS "Mobileno",
                    (CASE WHEN "paca"."PACA_FatherName" IS NULL OR "paca"."PACA_FatherName" = '' THEN '' ELSE "paca"."PACA_FatherName" END ||
                     CASE WHEN "paca"."PACA_FatherSurname" IS NULL OR "paca"."PACA_FatherSurname" = '' OR "paca"."PACA_FatherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_FatherSurname" END) AS "FatherName",
                    "paca"."PACA_Date" AS "RegDate",
                    "paca"."PACA_FirstName" AS "FirstName",
                    "paca"."PACA_MiddleName" AS "MiddleName",
                    "paca"."PACA_LastName" AS "LastName",
                    "course"."AMCO_CourseName" AS "Course",
                    "paca"."PACA_BloodGroup" AS "Bloodgroup",
                    "paca"."PACA_RegistrationNo" AS "RegNo",
                    "paca"."PACA_Sex" AS "Gender",
                    "paca"."PACA_DOB" AS "DOB",
                    "paca"."PACA_DOB_inwords" AS "DOBinwords",
                    "paca"."PACA_MotherTongue" AS "MotherTounge",
                    "religion"."IVRMMR_Name" AS "ReligionName",
                    "caste"."IMC_CasteName" AS "CasteName",
                    "paca"."PACA_PerStreet" AS "PermanentStreet",
                    "paca"."PACA_PerArea" AS "PermanentArea",
                    "paca"."PACA_PerCity" AS "PermanentCity",
                    "paca"."PACA_PerPincode" AS "PermanentPincode",
                    "paca"."PACA_ConStreet" AS "CurrentStreet",
                    "paca"."PACA_ConArea" AS "CurrentArea",
                    "state"."IVRMMS_Name" AS "State",
                    "country"."IVRMMC_CountryName" AS "Country",
                    "paca"."PACA_ConPincode" AS "CurrentPincode",
                    "paca"."PACA_AadharNo" AS "AadharNo",
                    "paca"."PACA_FatherEducation" AS "FatherEducation",
                    "paca"."PACA_FatherOccupation" AS "FatherOccupation",
                    "paca"."PACA_FatherOccupation" AS "FatherDesignation",
                    "paca"."PACA_FatherAnnIncome" AS "FatherIncome",
                    "paca"."PACA_FatherMobleNo" AS "FatherMobileno",
                    (CASE WHEN "paca"."PACA_MotherName" IS NULL OR "paca"."PACA_MotherName" = '' THEN '' ELSE "paca"."PACA_MotherName" END ||
                     CASE WHEN "paca"."PACA_MotherSurname" IS NULL OR "paca"."PACA_MotherSurname" = '' OR "paca"."PACA_MotherSurname" = '0' THEN '' ELSE ' ' || "paca"."PACA_MotherSurname" END) AS "MotherName",
                    "paca"."PACA_MotherEducation" AS "MotherEducation",
                    "paca"."PACA_MotherOccupation" AS "MotherOccupation",
                    "paca"."PACA_MotherDesignation" AS "MotherDesignation",
                    "paca"."PACA_MotherAnnIncome" AS "MotherIncome",
                    "paca"."PACA_MotherMobleNo" AS "MotherMobileno",
                    "paca"."PACA_BirthPlace" AS "BirthPlace",
                    "paca"."PACA_FatherOfficeAdd" AS "FatherOfficeAddress",
                    "paca"."PACA_MotherOfficeAdd" AS "MotherOfficeAddress"
                FROM "clg"."PA_College_Application" "paca"
                LEFT OUTER JOIN "dbo"."IVRM_Master_State" "state" ON "paca"."PACA_ConState" = "state"."IVRMMS_Id"
                INNER JOIN "dbo"."IVRM_Master_Religion" "religion" ON "paca"."IVRMMR_Id" = "religion"."IVRMMR_Id"
                INNER JOIN "dbo"."ApplicationUser" "appuser" ON "paca"."Id" = "appuser"."Id"
                INNER JOIN "CLG"."Adm_Master_Course" "course" ON "paca"."AMCO_Id" = "course"."AMCO_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" "year" ON "paca"."ASMAY_Id" = "year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" "country" ON "country"."