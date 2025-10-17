CREATE OR REPLACE FUNCTION "dbo"."AllInOneJSHSReport"(
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
RETURNS TABLE(
    "MI_Id" bigint,
    "EmailID" text,
    "Mobileno" text,
    "FirstName" text,
    "MiddleName" text,
    "LastName" text,
    "UserRegDate" timestamp,
    "Class" text,
    "RegDate" timestamp,
    "Gender" text,
    "RegNo" text,
    "FatherName" text,
    "Receipt" text,
    "Paydate" timestamp,
    "ScheduleDate" timestamp,
    "ScheduleTime" text,
    "ScheduleTimeTo" text,
    "PSname" text,
    "psclass" text,
    "psboard" text,
    "psaddress" text,
    "status" text,
    "transferflag" boolean,
    "PASR_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_userId bigint;
    v_fdate timestamp;
    v_tdate timestamp;
BEGIN

    SELECT p_From_Date::date INTO v_fdate;
    SELECT p_To_Date::date INTO v_tdate;

    IF p_type = 'btwdates' THEN
        IF p_option = 1 THEN
            RETURN QUERY
            SELECT "IVRM_User_Login_Institutionwise"."MI_Id",
                   "ApplicationUser"."Email" AS "EmailID",
                   "ApplicationUser"."PhoneNumber" AS "Mobileno",
                   UPPER("ApplicationUser"."Name") AS "FirstName",
                   NULL::text AS "MiddleName",
                   NULL::text AS "LastName",
                   "ApplicationUser"."Entry_Date" AS "UserRegDate",
                   NULL::text AS "Class",
                   NULL::timestamp AS "RegDate",
                   NULL::text AS "Gender",
                   NULL::text AS "RegNo",
                   NULL::text AS "FatherName",
                   NULL::text AS "Receipt",
                   NULL::timestamp AS "Paydate",
                   NULL::timestamp AS "ScheduleDate",
                   NULL::text AS "ScheduleTime",
                   NULL::text AS "ScheduleTimeTo",
                   NULL::text AS "PSname",
                   NULL::text AS "psclass",
                   NULL::text AS "psboard",
                   NULL::text AS "psaddress",
                   NULL::text AS "status",
                   NULL::boolean AS "transferflag",
                   NULL::bigint AS "PASR_Id"
            FROM "ApplicationUser"
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId"
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id"
            WHERE "IVRM_User_Login_Institutionwise"."MI_Id" = p_miid::bigint
              AND "ApplicationUserRole"."RoleId" IN (SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser')
              AND "Entry_Date"::date BETWEEN v_fdate::date AND v_tdate::date;

        ELSIF p_option = 2 THEN
            RETURN QUERY
            SELECT DISTINCT "IVRM_User_Login_Institutionwise"."MI_Id",
                   "ApplicationUser"."Email" AS "EmailID",
                   "ApplicationUser"."PhoneNumber" AS "Mobileno",
                   UPPER("ApplicationUser"."Name") AS "FirstName",
                   NULL::text AS "MiddleName",
                   NULL::text AS "LastName",
                   "ApplicationUser"."Entry_Date" AS "UserRegDate",
                   NULL::text AS "Class",
                   NULL::timestamp AS "RegDate",
                   NULL::text AS "Gender",
                   NULL::text AS "RegNo",
                   NULL::text AS "FatherName",
                   NULL::text AS "Receipt",
                   NULL::timestamp AS "Paydate",
                   NULL::timestamp AS "ScheduleDate",
                   NULL::text AS "ScheduleTime",
                   NULL::text AS "ScheduleTimeTo",
                   NULL::text AS "PSname",
                   NULL::text AS "psclass",
                   NULL::text AS "psboard",
                   NULL::text AS "psaddress",
                   NULL::text AS "status",
                   NULL::boolean AS "transferflag",
                   NULL::bigint AS "PASR_Id"
            FROM "ApplicationUser"
            INNER JOIN "ApplicationUserRole" ON "ApplicationUser"."Id" = "ApplicationUserRole"."UserId"
            INNER JOIN "IVRM_User_Login_Institutionwise" ON "IVRM_User_Login_Institutionwise"."Id" = "ApplicationUser"."Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."MI_Id" = "IVRM_User_Login_Institutionwise"."MI_Id"
            WHERE "ApplicationUser"."Id" NOT IN (SELECT "Id" FROM "Preadmission_School_Registration" WHERE "MI_Id" = p_miid::bigint)
              AND "ApplicationUserRole"."RoleId" IN (SELECT "id" FROM "ApplicationRole" WHERE "Name" = 'OnlinePreadmissionUser')
              AND "IVRM_User_Login_Institutionwise"."MI_Id" = p_miid::bigint
              AND "Entry_Date"::date BETWEEN v_fdate::date AND v_tdate::date;

        ELSIF p_option = 3 THEN
            IF p_ASMCL_Id = 0 THEN
                RETURN QUERY
                SELECT NULL::bigint AS "MI_Id",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "ApplicationUser"."CreatedDate" AS "UserRegDate",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       COALESCE("Preadmission_School_Registration"."PASR_FatherName", '') || ' ' || COALESCE("Preadmission_School_Registration"."PASR_FatherSurname", '') AS "FatherName",
                       fee."FYP_Receipt_No" AS "Receipt",
                       fee."FYP_Date" AS "Paydate",
                       b."PAOTSS_Date" AS "ScheduleDate",
                       b."PAOTSS_Time" AS "ScheduleTime",
                       b."PAOTSS_Time_To" AS "ScheduleTimeTo",
                       ps."PASRPS_PrvSchoolName" AS "PSname",
                       ps."PASRPS_PreviousClass" AS "psclass",
                       ps."PASRPS_Board" AS "psboard",
                       ps."PASRPS_Address" AS "psaddress",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" AS "transferflag",
                       "Preadmission_School_Registration"."PASR_Id"
                FROM "Preadmission_School_Registration"
                LEFT JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                LEFT JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                LEFT JOIN "Preadmission_OralTest_Schedule_Student" b ON b."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                LEFT JOIN "Preadmission_School_Registration_PrevSchool" ps ON "Preadmission_School_Registration"."PASR_Id" = ps."PASR_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                WHERE "PASR_Date"::date BETWEEN v_fdate::date AND v_tdate::date
                  AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint;
            ELSE
                RETURN QUERY
                SELECT NULL::bigint AS "MI_Id",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "ApplicationUser"."CreatedDate" AS "UserRegDate",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       COALESCE("Preadmission_School_Registration"."PASR_FatherName", '') || ' ' || COALESCE("Preadmission_School_Registration"."PASR_FatherSurname", '') AS "FatherName",
                       fee."FYP_Receipt_No" AS "Receipt",
                       fee."FYP_Date" AS "Paydate",
                       b."PAOTSS_Date" AS "ScheduleDate",
                       b."PAOTSS_Time" AS "ScheduleTime",
                       b."PAOTSS_Time_To" AS "ScheduleTimeTo",
                       ps."PASRPS_PrvSchoolName" AS "PSname",
                       ps."PASRPS_PreviousClass" AS "psclass",
                       ps."PASRPS_Board" AS "psboard",
                       ps."PASRPS_Address" AS "psaddress",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" AS "transferflag",
                       "Preadmission_School_Registration"."PASR_Id"
                FROM "Preadmission_School_Registration"
                LEFT JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                LEFT JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                LEFT JOIN "Preadmission_OralTest_Schedule_Student" b ON b."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                LEFT JOIN "Preadmission_School_Registration_PrevSchool" ps ON "Preadmission_School_Registration"."PASR_Id" = ps."PASR_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                WHERE "PASR_Date"::date BETWEEN v_fdate::date AND v_tdate::date
                  AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint
                  AND "Preadmission_School_Registration"."ASMCL_Id" = p_ASMCL_Id;
            END IF;

        ELSIF p_option = 4 THEN
            IF p_ASMCL_Id = 0 THEN
                RETURN QUERY
                SELECT NULL::bigint AS "MI_Id",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "ApplicationUser"."CreatedDate" AS "UserRegDate",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       COALESCE("Preadmission_School_Registration"."PASR_FatherName", '') || ' ' || COALESCE("Preadmission_School_Registration"."PASR_FatherSurname", '') AS "FatherName",
                       fee."FYP_Receipt_No" AS "Receipt",
                       fee."FYP_Date" AS "Paydate",
                       b."PAOTSS_Date" AS "ScheduleDate",
                       b."PAOTSS_Time" AS "ScheduleTime",
                       b."PAOTSS_Time_To" AS "ScheduleTimeTo",
                       ps."PASRPS_PrvSchoolName" AS "PSname",
                       ps."PASRPS_PreviousClass" AS "psclass",
                       ps."PASRPS_Board" AS "psboard",
                       ps."PASRPS_Address" AS "psaddress",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" AS "transferflag",
                       "Preadmission_School_Registration"."PASR_Id"
                FROM "Preadmission_School_Registration"
                LEFT JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                LEFT JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                LEFT JOIN "Preadmission_OralTest_Schedule_Student" b ON b."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                LEFT JOIN "Preadmission_School_Registration_PrevSchool" ps ON "Preadmission_School_Registration"."PASR_Id" = ps."PASR_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                WHERE "Preadmission_School_Registration"."PASR_Id" IN (SELECT "pasa_id" FROM "Fee_Y_Payment_PA_Application" WHERE "fyppa_type" = 'R')
                  AND fee."FYP_Date"::date BETWEEN v_fdate::date AND v_tdate::date
                  AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint;
            ELSE
                RETURN QUERY
                SELECT NULL::bigint AS "MI_Id",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "ApplicationUser"."CreatedDate" AS "UserRegDate",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       COALESCE("Preadmission_School_Registration"."PASR_FatherName", '') || ' ' || COALESCE("Preadmission_School_Registration"."PASR_FatherSurname", '') AS "FatherName",
                       fee."FYP_Receipt_No" AS "Receipt",
                       fee."FYP_Date" AS "Paydate",
                       b."PAOTSS_Date" AS "ScheduleDate",
                       b."PAOTSS_Time" AS "ScheduleTime",
                       b."PAOTSS_Time_To" AS "ScheduleTimeTo",
                       ps."PASRPS_PrvSchoolName" AS "PSname",
                       ps."PASRPS_PreviousClass" AS "psclass",
                       ps."PASRPS_Board" AS "psboard",
                       ps."PASRPS_Address" AS "psaddress",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" AS "transferflag",
                       "Preadmission_School_Registration"."PASR_Id"
                FROM "Preadmission_School_Registration"
                LEFT JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                LEFT JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                LEFT JOIN "Preadmission_OralTest_Schedule_Student" b ON b."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                LEFT JOIN "Preadmission_School_Registration_PrevSchool" ps ON "Preadmission_School_Registration"."PASR_Id" = ps."PASR_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                WHERE "Preadmission_School_Registration"."PASR_Id" IN (SELECT "pasa_id" FROM "Fee_Y_Payment_PA_Application" WHERE "fyppa_type" = 'R')
                  AND fee."FYP_Date"::date BETWEEN v_fdate::date AND v_tdate::date
                  AND "Preadmission_Master_Status"."MI_Id" = p_miid::bigint
                  AND "Preadmission_School_Registration"."ASMCL_Id" = p_ASMCL_Id;
            END IF;

        ELSIF p_option = 5 THEN
            IF p_ASMCL_Id = 0 THEN
                RETURN QUERY
                SELECT NULL::bigint AS "MI_Id",
                       "Preadmission_School_Registration"."PASR_emailId" AS "EmailID",
                       "Preadmission_School_Registration"."PASR_MobileNo" AS "Mobileno",
                       UPPER("Preadmission_School_Registration"."PASR_FirstName") AS "FirstName",
                       UPPER("Preadmission_School_Registration"."PASR_MiddleName") AS "MiddleName",
                       UPPER("Preadmission_School_Registration"."PASR_LastName") AS "LastName",
                       "ApplicationUser"."CreatedDate" AS "UserRegDate",
                       "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                       "Preadmission_School_Registration"."PASR_Date" AS "RegDate",
                       "Preadmission_School_Registration"."PASR_Sex" AS "Gender",
                       "Preadmission_School_Registration"."PASR_RegistrationNo" AS "RegNo",
                       COALESCE("Preadmission_School_Registration"."PASR_FatherName", '') || ' ' || COALESCE("Preadmission_School_Registration"."PASR_FatherSurname", '') AS "FatherName",
                       fee."FYP_Receipt_No" AS "Receipt",
                       fee."FYP_Date" AS "Paydate",
                       b."PAOTSS_Date" AS "ScheduleDate",
                       b."PAOTSS_Time" AS "ScheduleTime",
                       b."PAOTSS_Time_To" AS "ScheduleTimeTo",
                       ps."PASRPS_PrvSchoolName" AS "PSname",
                       ps."PASRPS_PreviousClass" AS "psclass",
                       ps."PASRPS_Board" AS "psboard",
                       ps."PASRPS_Address" AS "psaddress",
                       "Preadmission_Master_Status"."PAMST_Status" AS "status",
                       "Preadmission_School_Registration"."PASR_Adm_Confirm_Flag" AS "transferflag",
                       "Preadmission_School_Registration"."PASR_Id"
                FROM "Preadmission_School_Registration"
                LEFT JOIN "IVRM_Master_State" ON "Preadmission_School_Registration"."PASR_ConState" = "IVRM_Master_State"."IVRMMS_Id"
                INNER JOIN "Preadmission_Master_Status" ON "Preadmission_School_Registration"."PAMS_Id" = "Preadmission_Master_Status"."PAMST_Id"
                LEFT JOIN "IVRM_Master_Religion" ON "Preadmission_School_Registration"."Religion_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
                INNER JOIN "ApplicationUser" ON "Preadmission_School_Registration"."Id" = "ApplicationUser"."Id"
                INNER JOIN "Adm_School_M_Class" ON "Preadmission_School_Registration"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Preadmission_School_Registration"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                LEFT JOIN "IVRM_Master_Country" d ON d."IVRMMC_Id" = "Preadmission_School_Registration"."PASR_ConCountry"
                LEFT JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = "Preadmission_School_Registration"."Caste_Id"
                LEFT JOIN "Preadmission_OralTest_Schedule_Student" b ON b."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                LEFT JOIN "Preadmission_School_Registration_PrevSchool" ps ON "Preadmission_School_Registration"."PASR_Id" = ps."PASR_Id"
                INNER JOIN "Fee_Y_Payment_PA_Application" dd ON dd."PASA_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "fee_y_payment" fee ON fee."FYP_Id" = dd."FYP_Id"
                INNER JOIN "Adm_Master_Student_PA" pas ON pas."PASR_Id" = "Preadmission_School_Registration"."PASR_Id"
                INNER JOIN "Adm_M_Student" adm ON adm."AMST_Id" = pas."AMST_Id"
                WHERE "Preadmission_Master_Status"."MI_Id" = p_miid::bigint
                  AND "PASR_Adm_Confirm_Flag" = true
                  AND adm."AMST_Date"::date BETWEEN v_fdate::date AND v_tdate::date
                  AND "