CREATE OR REPLACE FUNCTION "AllInOneReport"(
    p_RoleId bigint,
    p_RoleTypeId bigint,
    p_From_Date timestamp,
    p_To_Date timestamp,
    p_option int,
    p_year bigint,
    p_type varchar(10),
    p_miid varchar(10),
    p_predate date,
    p_prenddate date,
    p_ASMCL_Id bigint
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_userId bigint;
BEGIN
    IF p_type = 'btwdates' THEN
        IF p_option = 1 THEN
            RETURN QUERY
            SELECT "IVRM_User_Login_Institutionwise"."MI_Id", 
                   "ApplicationUser"."Email" AS "EmailID", 
                   "ApplicationUser"."PhoneNumber" AS "Mobileno", 
                   "ApplicationUser"."Name" AS "FatherName", 
                   "ApplicationUser"."Entry_Date" AS "RegDate"
            FROM "ApplicationUser" 
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId" 
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id" 
            WHERE "IVRM_User_Login_Institutionwise"."MI_Id" = p_miid::bigint
            AND "ApplicationUserRole"."RoleId" IN (SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser')
            AND "Entry_Date" BETWEEN p_From_Date AND p_To_Date;

        ELSIF p_option = 2 THEN
            RETURN QUERY
            SELECT DISTINCT "IVRM_User_Login_Institutionwise"."MI_Id", 
                   "ApplicationUser"."Email" AS "EmailID", 
                   "ApplicationUser"."PhoneNumber" AS "Mobileno", 
                   "ApplicationUser"."Name" AS "FatherName", 
                   "ApplicationUser"."Entry_Date" AS "RegDate"
            FROM "ApplicationUser" 
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId" 
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id" 
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."MI_Id" = "IVRM_User_Login_Institutionwise"."MI_Id"
            WHERE "ApplicationUser"."Id" NOT IN (
                SELECT "Id" FROM "Preadmission_School_Registration" WHERE "MI_Id" = p_miid::bigint
            )
            AND "ApplicationUserRole"."RoleId" IN (SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser')
            AND "IVRM_User_Login_Institutionwise"."MI_Id" = p_miid::bigint
            AND "Entry_Date" BETWEEN p_From_Date AND p_To_Date;

        ELSIF p_option = 3 THEN
            IF p_ASMCL_Id = 0 THEN
                RETURN QUERY
                SELECT UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_BloodGroup" AS "Bloodgroup",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_DOB" AS "DOB",
                       "Preadmission_School_Registration"."PASR_DOBWords" AS "DOBinwords",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_MotherTongue" AS "MotherTounge",
                       "IVRM_Master_Religion"."IVRMMR_Name" AS "ReligionName",
                       c."IMC_CasteName" AS "CasteName",
                       "Preadmission_School_Registration"."PASR_PerStreet" AS "PermanentStreet",
                       "Preadmission_School_Registration"."PASR_PerArea" AS "PermanentArea",
                       "Preadmission_School_Registration"."PASR_PerCity" AS "PermanentCity",
                       "Preadmission_School_Registration"."PASR_PerPincode" AS "PermanentPincode",
                       "Preadmission_School_Registration"."PASR_ConStreet" AS "CurrentStreet",
                       "Preadmission_School_Registration"."PASR_ConArea" AS "CurrentArea",
                       "IVRM_Master_State"."IVRMMS_Name" AS "State",
                       d."IVRMMC_CountryName" AS "Country",
                       "Preadmission_School_Registration"."PASR_ConPincode" AS "CurrentPincode",
                       "Preadmission_School_Registration"."PASR_AadharNo" AS "AadharNo",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_FatherName" || ' ' || "Preadmission_School_Registration"."PASR_FatherSurname" AS "FatherName",
                       "Preadmission_School_Registration"."PASR_FatherEducation" AS "FatherEducation",
                       "Preadmission_School_Registration"."PASR_FatherOccupation" AS "FatherOccupation",
                       "Preadmission_School_Registration"."PASR_FatherDesignation" AS "FatherDesignation",
                       "Preadmission_School_Registration"."PASR_FatherIncome" AS "FatherIncome",
                       "Preadmission_School_Registration"."PASR_FatherMobleNo" AS "FatherMobileno",
                       "Preadmission_School_Registration"."PASR_MotherName" || '' || "Preadmission_School_Registration"."PASR_MotherSurname" AS "MotherName",
                       "Preadmission_School_Registration"."PASR_MotherEducation" AS "MotherEducation",
                       "Preadmission_School_Registration"."PASR_MotherOccupation" AS "MotherOccupation",
                       "Preadmission_School_Registration"."PASR_MotherDesignation" AS "MotherDesignation",
                       "Preadmission_School_Registration"."PASR_MotherIncome" AS "MotherIncome",
                       "Preadmission_School_Registration"."PASR_MotherMobleNo" AS "MotherMobileno",
                       "Preadmission_School_Registration"."PASR_BirthPlace" AS "BirthPlace",
                       "Preadmission_School_Registration"."PASR_LastPlayGrndAttnd" AS "LastClassAttendance",
                       "Preadmission_School_Registration"."PASR_ExtraActivity" AS "ExtraActivity",
                       "Preadmission_School_Registration"."PASR_FatherOfficeAddr" AS "FatherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_MotherOfficeAddr" AS "MotherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_AltContactNo" AS "Contactno",
                       "Preadmission_School_Registration"."PASR_AltContactEmail" AS "ContactEmail"
                FROM "Preadmission_School_Registration"
                LEFT OUTER JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                INNER JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                WHERE "PASR_Date" BETWEEN p_From_Date AND p_To_Date
                AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint;
            ELSE
                RETURN QUERY
                SELECT UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_BloodGroup" AS "Bloodgroup",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_DOB" AS "DOB",
                       "Preadmission_School_Registration"."PASR_DOBWords" AS "DOBinwords",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_MotherTongue" AS "MotherTounge",
                       "IVRM_Master_Religion"."IVRMMR_Name" AS "ReligionName",
                       c."IMC_CasteName" AS "CasteName",
                       "Preadmission_School_Registration"."PASR_PerStreet" AS "PermanentStreet",
                       "Preadmission_School_Registration"."PASR_PerArea" AS "PermanentArea",
                       "Preadmission_School_Registration"."PASR_PerCity" AS "PermanentCity",
                       "Preadmission_School_Registration"."PASR_PerPincode" AS "PermanentPincode",
                       "Preadmission_School_Registration"."PASR_ConStreet" AS "CurrentStreet",
                       "Preadmission_School_Registration"."PASR_ConArea" AS "CurrentArea",
                       "IVRM_Master_State"."IVRMMS_Name" AS "State",
                       d."IVRMMC_CountryName" AS "Country",
                       "Preadmission_School_Registration"."PASR_ConPincode" AS "CurrentPincode",
                       "Preadmission_School_Registration"."PASR_AadharNo" AS "AadharNo",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_FatherName" || ' ' || "Preadmission_School_Registration"."PASR_FatherSurname" AS "FatherName",
                       "Preadmission_School_Registration"."PASR_FatherEducation" AS "FatherEducation",
                       "Preadmission_School_Registration"."PASR_FatherOccupation" AS "FatherOccupation",
                       "Preadmission_School_Registration"."PASR_FatherDesignation" AS "FatherDesignation",
                       "Preadmission_School_Registration"."PASR_FatherIncome" AS "FatherIncome",
                       "Preadmission_School_Registration"."PASR_FatherMobleNo" AS "FatherMobileno",
                       "Preadmission_School_Registration"."PASR_MotherName" || '' || "Preadmission_School_Registration"."PASR_MotherSurname" AS "MotherName",
                       "Preadmission_School_Registration"."PASR_MotherEducation" AS "MotherEducation",
                       "Preadmission_School_Registration"."PASR_MotherOccupation" AS "MotherOccupation",
                       "Preadmission_School_Registration"."PASR_MotherDesignation" AS "MotherDesignation",
                       "Preadmission_School_Registration"."PASR_MotherIncome" AS "MotherIncome",
                       "Preadmission_School_Registration"."PASR_MotherMobleNo" AS "MotherMobileno",
                       "Preadmission_School_Registration"."PASR_BirthPlace" AS "BirthPlace",
                       "Preadmission_School_Registration"."PASR_LastPlayGrndAttnd" AS "LastClassAttendance",
                       "Preadmission_School_Registration"."PASR_ExtraActivity" AS "ExtraActivity",
                       "Preadmission_School_Registration"."PASR_FatherOfficeAddr" AS "FatherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_MotherOfficeAddr" AS "MotherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_AltContactNo" AS "Contactno",
                       "Preadmission_School_Registration"."PASR_AltContactEmail" AS "ContactEmail"
                FROM "Preadmission_School_Registration"
                LEFT OUTER JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                INNER JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                WHERE "PASR_Date" BETWEEN p_From_Date AND p_To_Date
                AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint
                AND "Preadmission_School_Registration"."ASMCL_Id" = p_ASMCL_Id;
            END IF;

        ELSIF p_option = 4 THEN
            IF p_ASMCL_Id = 0 THEN
                RETURN QUERY
                SELECT UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_BloodGroup" AS "Bloodgroup",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_DOB" AS "DOB",
                       "Preadmission_School_Registration"."PASR_DOBWords" AS "DOBinwords",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_MotherTongue" AS "MotherTounge",
                       "IVRM_Master_Religion"."IVRMMR_Name" AS "ReligionName",
                       c."IMC_CasteName" AS "CasteName",
                       "Preadmission_School_Registration"."PASR_PerStreet" AS "PermanentStreet",
                       "Preadmission_School_Registration"."PASR_PerArea" AS "PermanentArea",
                       "Preadmission_School_Registration"."PASR_PerCity" AS "PermanentCity",
                       "Preadmission_School_Registration"."PASR_PerPincode" AS "PermanentPincode",
                       "Preadmission_School_Registration"."PASR_ConStreet" AS "CurrentStreet",
                       "Preadmission_School_Registration"."PASR_ConArea" AS "CurrentArea",
                       "IVRM_Master_State"."IVRMMS_Name" AS "State",
                       d."IVRMMC_CountryName" AS "Country",
                       "Preadmission_School_Registration"."PASR_ConPincode" AS "CurrentPincode",
                       "Preadmission_School_Registration"."PASR_AadharNo" AS "AadharNo",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_FatherName" || ' ' || "Preadmission_School_Registration"."PASR_FatherSurname" AS "FatherName",
                       "Preadmission_School_Registration"."PASR_FatherEducation" AS "FatherEducation",
                       "Preadmission_School_Registration"."PASR_FatherOccupation" AS "FatherOccupation",
                       "Preadmission_School_Registration"."PASR_FatherDesignation" AS "FatherDesignation",
                       "Preadmission_School_Registration"."PASR_FatherIncome" AS "FatherIncome",
                       "Preadmission_School_Registration"."PASR_FatherMobleNo" AS "FatherMobileno",
                       "Preadmission_School_Registration"."PASR_MotherName" || '' || "Preadmission_School_Registration"."PASR_MotherSurname" AS "MotherName",
                       "Preadmission_School_Registration"."PASR_MotherEducation" AS "MotherEducation",
                       "Preadmission_School_Registration"."PASR_MotherOccupation" AS "MotherOccupation",
                       "Preadmission_School_Registration"."PASR_MotherDesignation" AS "MotherDesignation",
                       "Preadmission_School_Registration"."PASR_MotherIncome" AS "MotherIncome",
                       "Preadmission_School_Registration"."PASR_MotherMobleNo" AS "MotherMobileno",
                       "Preadmission_School_Registration"."PASR_BirthPlace" AS "BirthPlace",
                       "Preadmission_School_Registration"."PASR_LastPlayGrndAttnd" AS "LastClassAttendance",
                       "Preadmission_School_Registration"."PASR_ExtraActivity" AS "ExtraActivity",
                       "Preadmission_School_Registration"."PASR_FatherOfficeAddr" AS "FatherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_MotherOfficeAddr" AS "MotherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_AltContactNo" AS "Contactno",
                       "Preadmission_School_Registration"."PASR_AltContactEmail" AS "ContactEmail"
                FROM "Preadmission_School_Registration"
                LEFT OUTER JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                INNER JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                WHERE "Preadmission_School_Registration"."PASR_Id" IN (
                    SELECT "pasa_id" FROM "Fee_Y_Payment_PA_Application" WHERE "fyppa_type" = 'R'
                )
                AND fee."FYP_Date" BETWEEN p_From_Date AND p_To_Date
                AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint;
            ELSE
                RETURN QUERY
                SELECT UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_BloodGroup" AS "Bloodgroup",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_DOB" AS "DOB",
                       "Preadmission_School_Registration"."PASR_DOBWords" AS "DOBinwords",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_MotherTongue" AS "MotherTounge",
                       "IVRM_Master_Religion"."IVRMMR_Name" AS "ReligionName",
                       c."IMC_CasteName" AS "CasteName",
                       "Preadmission_School_Registration"."PASR_PerStreet" AS "PermanentStreet",
                       "Preadmission_School_Registration"."PASR_PerArea" AS "PermanentArea",
                       "Preadmission_School_Registration"."PASR_PerCity" AS "PermanentCity",
                       "Preadmission_School_Registration"."PASR_PerPincode" AS "PermanentPincode",
                       "Preadmission_School_Registration"."PASR_ConStreet" AS "CurrentStreet",
                       "Preadmission_School_Registration"."PASR_ConArea" AS "CurrentArea",
                       "IVRM_Master_State"."IVRMMS_Name" AS "State",
                       d."IVRMMC_CountryName" AS "Country",
                       "Preadmission_School_Registration"."PASR_ConPincode" AS "CurrentPincode",
                       "Preadmission_School_Registration"."PASR_AadharNo" AS "AadharNo",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_FatherName" || ' ' || "Preadmission_School_Registration"."PASR_FatherSurname" AS "FatherName",
                       "Preadmission_School_Registration"."PASR_FatherEducation" AS "FatherEducation",
                       "Preadmission_School_Registration"."PASR_FatherOccupation" AS "FatherOccupation",
                       "Preadmission_School_Registration"."PASR_FatherDesignation" AS "FatherDesignation",
                       "Preadmission_School_Registration"."PASR_FatherIncome" AS "FatherIncome",
                       "Preadmission_School_Registration"."PASR_FatherMobleNo" AS "FatherMobileno",
                       "Preadmission_School_Registration"."PASR_MotherName" || '' || "Preadmission_School_Registration"."PASR_MotherSurname" AS "MotherName",
                       "Preadmission_School_Registration"."PASR_MotherEducation" AS "MotherEducation",
                       "Preadmission_School_Registration"."PASR_MotherOccupation" AS "MotherOccupation",
                       "Preadmission_School_Registration"."PASR_MotherDesignation" AS "MotherDesignation",
                       "Preadmission_School_Registration"."PASR_MotherIncome" AS "MotherIncome",
                       "Preadmission_School_Registration"."PASR_MotherMobleNo" AS "MotherMobileno",
                       "Preadmission_School_Registration"."PASR_BirthPlace" AS "BirthPlace",
                       "Preadmission_School_Registration"."PASR_LastPlayGrndAttnd" AS "LastClassAttendance",
                       "Preadmission_School_Registration"."PASR_ExtraActivity" AS "ExtraActivity",
                       "Preadmission_School_Registration"."PASR_FatherOfficeAddr" AS "FatherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_MotherOfficeAddr" AS "MotherOfficeAddress",
                       "Preadmission_School_Registration"."PASR_AltContactNo" AS "Contactno",
                       "Preadmission_School_Registration"."PASR_AltContactEmail" AS "ContactEmail"
                FROM "Preadmission_School_Registration"
                LEFT OUTER JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState