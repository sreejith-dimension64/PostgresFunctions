CREATE OR REPLACE FUNCTION "dbo"."GET_UPDATE_REQUEST_REPORT"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT,
    p_RoleName VARCHAR(100),
    p_STFLAG TEXT,
    p_FRMDATE DATE,
    p_TODATE DATE
)
RETURNS TABLE(
    studentname TEXT,
    fatherName TEXT,
    mothername TEXT,
    AMST_BloodGroup TEXT,
    AMST_PerStreet TEXT,
    AMST_PerArea TEXT,
    AMST_PerCity TEXT,
    AMST_PerState BIGINT,
    AMST_PerCountry BIGINT,
    AMST_PerPincode TEXT,
    AMST_ConStreet TEXT,
    AMST_ConArea TEXT,
    AMST_ConCity TEXT,
    AMST_ConState BIGINT,
    AMST_ConCountry BIGINT,
    AMST_ConPincode TEXT,
    AMST_emailId TEXT,
    AMST_MobileNo TEXT,
    AMST_FatherMobleNo TEXT,
    AMST_FatheremailId TEXT,
    ANST_FatherPhoto TEXT,
    AMST_MotherMobileNo TEXT,
    AMST_MotherEmailId TEXT,
    ANST_MotherPhoto TEXT,
    AMST_Photoname TEXT,
    admissionno TEXT,
    AMSTG_Id BIGINT,
    AMSTG_GuardianPhoneNo TEXT,
    AMSTG_emailid TEXT,
    ASTUREQ_Id BIGINT,
    ASTUREQ_Date TIMESTAMP,
    AMSTG_GuardianName TEXT,
    AMST_AdmNo TEXT,
    ASMCL_ClassName TEXT,
    ASMC_SectionName TEXT,
    ASTUREQ_ReqStatus TEXT,
    AMST_Id BIGINT,
    pstate TEXT,
    cstate TEXT,
    pcountry TEXT,
    ccountry TEXT,
    ASTUREQ_UpdatedDate TIMESTAMP,
    UserName TEXT,
    EmpName TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_RoleName = 'Student' THEN
        IF p_STFLAG = 'ALL' THEN
            RETURN QUERY
            SELECT   
                CASE WHEN A."ASTUREQ_FirstName" IS NULL OR A."ASTUREQ_FirstName" = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
                CASE WHEN A."ASTUREQ_MiddleName" IS NULL OR A."ASTUREQ_MiddleName" = '' OR A."ASTUREQ_MiddleName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
                CASE WHEN A."ASTUREQ_LastName" IS NULL OR A."ASTUREQ_LastName" = '' OR A."ASTUREQ_LastName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS studentname,
                CASE WHEN A."ASTUREQ_FatherName" IS NULL OR A."ASTUREQ_FatherName" = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
                CASE WHEN A."ASTUREQ_FatherSurname" IS NULL OR A."ASTUREQ_FatherSurname" = '' OR A."ASTUREQ_FatherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS fatherName,
                CASE WHEN A."ASTUREQ_MotherName" IS NULL OR A."ASTUREQ_MotherName" = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
                CASE WHEN A."ASTUREQ_MotherSurname" IS NULL OR A."ASTUREQ_MotherSurname" = '' OR A."ASTUREQ_MotherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS mothername,
                A."ASTUREQ_BloodGroup"::TEXT AS AMST_BloodGroup,
                A."ASTUREQ_PerStreet"::TEXT AS AMST_PerStreet,
                A."ASTUREQ_PerArea"::TEXT AS AMST_PerArea,
                A."ASTUREQ_PerCity"::TEXT AS AMST_PerCity,
                A."ASTUREQ_PerState" AS AMST_PerState,
                A."IVRMMC_Id" AS AMST_PerCountry,
                A."ASTUREQ_PerPincode"::TEXT AS AMST_PerPincode,
                A."ASTUREQ_ConStreet"::TEXT AS AMST_ConStreet,
                A."ASTUREQ_ConArea"::TEXT AS AMST_ConArea,
                A."ASTUREQ_ConCity"::TEXT AS AMST_ConCity,
                A."ASTUREQ_ConState" AS AMST_ConState,
                A."ASTUREQ_ConCountryId" AS AMST_ConCountry,
                A."ASTUREQ_ConPincode"::TEXT AS AMST_ConPincode,
                A."ASTUREQ_EmailId"::TEXT AS AMST_emailId,
                A."ASTUREQ_MobileNo"::TEXT AS AMST_MobileNo,
                A."ASTUREQ_FatherMobleNo"::TEXT AS AMST_FatherMobleNo,
                A."ASTUREQ_FatheremailId"::TEXT AS AMST_FatheremailId,
                A."ASTUREQ_FatherPhoto"::TEXT AS ANST_FatherPhoto,
                A."ASTUREQ_MotherMobleNo"::TEXT AS AMST_MotherMobileNo,
                A."ASTUREQ_MotherEmailId"::TEXT AS AMST_MotherEmailId,
                A."ASTUREQ_MotherPhoto"::TEXT AS ANST_MotherPhoto,
                A."ASTUREQ_StudentPhoto"::TEXT AS AMST_Photoname,
                A."ASTUREQ_AdmNo"::TEXT AS admissionno,
                COALESCE(A."AMSTG_Id", 0) AS AMSTG_Id,
                A."ASTUREQ_GuardianMobileNo"::TEXT AS AMSTG_GuardianPhoneNo,
                A."ASTUREQ_GuardianEmailId"::TEXT AS AMSTG_emailid,
                A."ASTUREQ_Id",
                A."ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                AMS."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                A."ASTUREQ_ReqStatus"::TEXT,
                A."AMST_Id",
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_PerState" = "IVRMMS_Id") AS pstate,
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_ConState" = "IVRMMS_Id") AS cstate,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."IVRMMC_Id" = "IVRMMC_Id") AS pcountry,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."ASTUREQ_ConCountryId" = "IVRMMC_Id") AS ccountry,
                A."ASTUREQ_UpdatedDate",
                (SELECT AU."UserName"::TEXT FROM "ApplicationUser" AU WHERE AU."id" = A."ASTUREQ_ApprovedBy") AS UserName,
                (SELECT COALESCE(H."HRME_EmployeeFirstName", '') || ' ' || COALESCE(H."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(H."HRME_EmployeeLastName", '') 
                 FROM "ApplicationUser" AU
                 INNER JOIN "IVRM_Staff_User_Login" UL ON AU."id" = UL."Id"
                 INNER JOIN "HR_Master_Employee" H ON H."HRME_Id" = UL."Emp_Code"
                 WHERE UL."id" = A."ASTUREQ_ApprovedBy") AS EmpName
            FROM "dbo"."Adm_Student_Update_Request" A
            INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = ASYS."ASMS_Id"
            LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
            WHERE A."AMST_Id" = p_AMST_Id::BIGINT 
              AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND A."MI_Id" = p_MI_Id::BIGINT 
              AND ASYS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND CAST(A."ASTUREQ_Date" AS DATE) BETWEEN p_FRMDATE AND p_TODATE;
        ELSE
            RETURN QUERY
            SELECT   
                CASE WHEN A."ASTUREQ_FirstName" IS NULL OR A."ASTUREQ_FirstName" = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
                CASE WHEN A."ASTUREQ_MiddleName" IS NULL OR A."ASTUREQ_MiddleName" = '' OR A."ASTUREQ_MiddleName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
                CASE WHEN A."ASTUREQ_LastName" IS NULL OR A."ASTUREQ_LastName" = '' OR A."ASTUREQ_LastName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS studentname,
                CASE WHEN A."ASTUREQ_FatherName" IS NULL OR A."ASTUREQ_FatherName" = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
                CASE WHEN A."ASTUREQ_FatherSurname" IS NULL OR A."ASTUREQ_FatherSurname" = '' OR A."ASTUREQ_FatherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS fatherName,
                CASE WHEN A."ASTUREQ_MotherName" IS NULL OR A."ASTUREQ_MotherName" = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
                CASE WHEN A."ASTUREQ_MotherSurname" IS NULL OR A."ASTUREQ_MotherSurname" = '' OR A."ASTUREQ_MotherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS mothername,
                A."ASTUREQ_BloodGroup"::TEXT AS AMST_BloodGroup,
                A."ASTUREQ_PerStreet"::TEXT AS AMST_PerStreet,
                A."ASTUREQ_PerArea"::TEXT AS AMST_PerArea,
                A."ASTUREQ_PerCity"::TEXT AS AMST_PerCity,
                A."ASTUREQ_PerState" AS AMST_PerState,
                A."IVRMMC_Id" AS AMST_PerCountry,
                A."ASTUREQ_PerPincode"::TEXT AS AMST_PerPincode,
                A."ASTUREQ_ConStreet"::TEXT AS AMST_ConStreet,
                A."ASTUREQ_ConArea"::TEXT AS AMST_ConArea,
                A."ASTUREQ_ConCity"::TEXT AS AMST_ConCity,
                A."ASTUREQ_ConState" AS AMST_ConState,
                A."ASTUREQ_ConCountryId" AS AMST_ConCountry,
                A."ASTUREQ_ConPincode"::TEXT AS AMST_ConPincode,
                A."ASTUREQ_EmailId"::TEXT AS AMST_emailId,
                A."ASTUREQ_MobileNo"::TEXT AS AMST_MobileNo,
                A."ASTUREQ_FatherMobleNo"::TEXT AS AMST_FatherMobleNo,
                A."ASTUREQ_FatheremailId"::TEXT AS AMST_FatheremailId,
                A."ASTUREQ_FatherPhoto"::TEXT AS ANST_FatherPhoto,
                A."ASTUREQ_MotherMobleNo"::TEXT AS AMST_MotherMobileNo,
                A."ASTUREQ_MotherEmailId"::TEXT AS AMST_MotherEmailId,
                A."ASTUREQ_MotherPhoto"::TEXT AS ANST_MotherPhoto,
                A."ASTUREQ_StudentPhoto"::TEXT AS AMST_Photoname,
                A."ASTUREQ_AdmNo"::TEXT AS admissionno,
                COALESCE(A."AMSTG_Id", 0) AS AMSTG_Id,
                A."ASTUREQ_GuardianMobileNo"::TEXT AS AMSTG_GuardianPhoneNo,
                A."ASTUREQ_GuardianEmailId"::TEXT AS AMSTG_emailid,
                A."ASTUREQ_Id",
                A."ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                AMS."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                A."ASTUREQ_ReqStatus"::TEXT,
                A."AMST_Id",
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_PerState" = "IVRMMS_Id") AS pstate,
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_ConState" = "IVRMMS_Id") AS cstate,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."IVRMMC_Id" = "IVRMMC_Id") AS pcountry,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."ASTUREQ_ConCountryId" = "IVRMMC_Id") AS ccountry,
                A."ASTUREQ_UpdatedDate",
                (SELECT AU."UserName"::TEXT FROM "ApplicationUser" AU WHERE AU."id" = A."ASTUREQ_ApprovedBy") AS UserName,
                (SELECT COALESCE(H."HRME_EmployeeFirstName", '') || ' ' || COALESCE(H."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(H."HRME_EmployeeLastName", '') 
                 FROM "ApplicationUser" AU
                 INNER JOIN "IVRM_Staff_User_Login" UL ON AU."id" = UL."Id"
                 INNER JOIN "HR_Master_Employee" H ON H."HRME_Id" = UL."Emp_Code"
                 WHERE UL."id" = A."ASTUREQ_ApprovedBy") AS EmpName
            FROM "dbo"."Adm_Student_Update_Request" A
            INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = ASYS."ASMS_Id"
            LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
            WHERE A."AMST_Id" = p_AMST_Id::BIGINT 
              AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND A."MI_Id" = p_MI_Id::BIGINT 
              AND ASYS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND A."ASTUREQ_ReqStatus" = p_STFLAG 
              AND CAST(A."ASTUREQ_Date" AS DATE) BETWEEN p_FRMDATE AND p_TODATE;
        END IF;
    ELSE
        IF p_STFLAG = 'ALL' THEN
            RETURN QUERY
            SELECT DISTINCT
                CASE WHEN A."ASTUREQ_FirstName" IS NULL OR A."ASTUREQ_FirstName" = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
                CASE WHEN A."ASTUREQ_MiddleName" IS NULL OR A."ASTUREQ_MiddleName" = '' OR A."ASTUREQ_MiddleName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
                CASE WHEN A."ASTUREQ_LastName" IS NULL OR A."ASTUREQ_LastName" = '' OR A."ASTUREQ_LastName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS studentname,
                CASE WHEN A."ASTUREQ_FatherName" IS NULL OR A."ASTUREQ_FatherName" = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
                CASE WHEN A."ASTUREQ_FatherSurname" IS NULL OR A."ASTUREQ_FatherSurname" = '' OR A."ASTUREQ_FatherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS fatherName,
                CASE WHEN A."ASTUREQ_MotherName" IS NULL OR A."ASTUREQ_MotherName" = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
                CASE WHEN A."ASTUREQ_MotherSurname" IS NULL OR A."ASTUREQ_MotherSurname" = '' OR A."ASTUREQ_MotherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS mothername,
                A."ASTUREQ_BloodGroup"::TEXT AS AMST_BloodGroup,
                A."ASTUREQ_PerStreet"::TEXT AS AMST_PerStreet,
                A."ASTUREQ_PerArea"::TEXT AS AMST_PerArea,
                A."ASTUREQ_PerCity"::TEXT AS AMST_PerCity,
                A."ASTUREQ_PerState" AS AMST_PerState,
                A."IVRMMC_Id" AS AMST_PerCountry,
                A."ASTUREQ_PerPincode"::TEXT AS AMST_PerPincode,
                A."ASTUREQ_ConStreet"::TEXT AS AMST_ConStreet,
                A."ASTUREQ_ConArea"::TEXT AS AMST_ConArea,
                A."ASTUREQ_ConCity"::TEXT AS AMST_ConCity,
                A."ASTUREQ_ConState" AS AMST_ConState,
                A."ASTUREQ_ConCountryId" AS AMST_ConCountry,
                A."ASTUREQ_ConPincode"::TEXT AS AMST_ConPincode,
                A."ASTUREQ_EmailId"::TEXT AS AMST_emailId,
                A."ASTUREQ_MobileNo"::TEXT AS AMST_MobileNo,
                A."ASTUREQ_FatherMobleNo"::TEXT AS AMST_FatherMobleNo,
                A."ASTUREQ_FatheremailId"::TEXT AS AMST_FatheremailId,
                A."ASTUREQ_FatherPhoto"::TEXT AS ANST_FatherPhoto,
                A."ASTUREQ_MotherMobleNo"::TEXT AS AMST_MotherMobileNo,
                A."ASTUREQ_MotherEmailId"::TEXT AS AMST_MotherEmailId,
                A."ASTUREQ_MotherPhoto"::TEXT AS ANST_MotherPhoto,
                A."ASTUREQ_StudentPhoto"::TEXT AS AMST_Photoname,
                A."ASTUREQ_AdmNo"::TEXT AS admissionno,
                COALESCE(A."AMSTG_Id", 0) AS AMSTG_Id,
                A."ASTUREQ_GuardianMobileNo"::TEXT AS AMSTG_GuardianPhoneNo,
                A."ASTUREQ_GuardianEmailId"::TEXT AS AMSTG_emailid,
                A."ASTUREQ_Id",
                A."ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                AMS."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                A."ASTUREQ_ReqStatus"::TEXT,
                A."AMST_Id",
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_PerState" = "IVRMMS_Id") AS pstate,
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_ConState" = "IVRMMS_Id") AS cstate,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."IVRMMC_Id" = "IVRMMC_Id") AS pcountry,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."ASTUREQ_ConCountryId" = "IVRMMC_Id") AS ccountry,
                A."ASTUREQ_UpdatedDate",
                (SELECT AU."UserName"::TEXT FROM "ApplicationUser" AU WHERE AU."id" = A."ASTUREQ_ApprovedBy") AS UserName,
                (SELECT COALESCE(H."HRME_EmployeeFirstName", '') || ' ' || COALESCE(H."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(H."HRME_EmployeeLastName", '') 
                 FROM "ApplicationUser" AU
                 INNER JOIN "IVRM_Staff_User_Login" UL ON AU."id" = UL."Id"
                 INNER JOIN "HR_Master_Employee" H ON H."HRME_Id" = UL."Emp_Code"
                 WHERE UL."id" = A."ASTUREQ_ApprovedBy") AS EmpName
            FROM "dbo"."Adm_Student_Update_Request" A
            INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = A."AMST_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" AS B ON A."AMST_Id" = B."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = B."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = B."ASMS_Id"
            LEFT JOIN "Adm_Master_Student_Guardian" AS G ON G."AMST_Id" = A."AMST_Id"
            WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND A."MI_Id" = p_MI_Id::BIGINT 
              AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
              AND CAST(A."ASTUREQ_Date" AS DATE) BETWEEN p_FRMDATE AND p_TODATE;
        ELSE
            RETURN QUERY
            SELECT DISTINCT
                CASE WHEN A."ASTUREQ_FirstName" IS NULL OR A."ASTUREQ_FirstName" = '' THEN '' ELSE A."ASTUREQ_FirstName" END ||
                CASE WHEN A."ASTUREQ_MiddleName" IS NULL OR A."ASTUREQ_MiddleName" = '' OR A."ASTUREQ_MiddleName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MiddleName" END ||
                CASE WHEN A."ASTUREQ_LastName" IS NULL OR A."ASTUREQ_LastName" = '' OR A."ASTUREQ_LastName" = '0' THEN '' ELSE ' ' || A."ASTUREQ_LastName" END AS studentname,
                CASE WHEN A."ASTUREQ_FatherName" IS NULL OR A."ASTUREQ_FatherName" = '' THEN '' ELSE A."ASTUREQ_FatherName" END ||
                CASE WHEN A."ASTUREQ_FatherSurname" IS NULL OR A."ASTUREQ_FatherSurname" = '' OR A."ASTUREQ_FatherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_FatherSurname" END AS fatherName,
                CASE WHEN A."ASTUREQ_MotherName" IS NULL OR A."ASTUREQ_MotherName" = '' THEN '' ELSE A."ASTUREQ_MotherName" END ||
                CASE WHEN A."ASTUREQ_MotherSurname" IS NULL OR A."ASTUREQ_MotherSurname" = '' OR A."ASTUREQ_MotherSurname" = '0' THEN '' ELSE ' ' || A."ASTUREQ_MotherSurname" END AS mothername,
                A."ASTUREQ_BloodGroup"::TEXT AS AMST_BloodGroup,
                A."ASTUREQ_PerStreet"::TEXT AS AMST_PerStreet,
                A."ASTUREQ_PerArea"::TEXT AS AMST_PerArea,
                A."ASTUREQ_PerCity"::TEXT AS AMST_PerCity,
                A."ASTUREQ_PerState" AS AMST_PerState,
                A."IVRMMC_Id" AS AMST_PerCountry,
                A."ASTUREQ_PerPincode"::TEXT AS AMST_PerPincode,
                A."ASTUREQ_ConStreet"::TEXT AS AMST_ConStreet,
                A."ASTUREQ_ConArea"::TEXT AS AMST_ConArea,
                A."ASTUREQ_ConCity"::TEXT AS AMST_ConCity,
                A."ASTUREQ_ConState" AS AMST_ConState,
                A."ASTUREQ_ConCountryId" AS AMST_ConCountry,
                A."ASTUREQ_ConPincode"::TEXT AS AMST_ConPincode,
                A."ASTUREQ_EmailId"::TEXT AS AMST_emailId,
                A."ASTUREQ_MobileNo"::TEXT AS AMST_MobileNo,
                A."ASTUREQ_FatherMobleNo"::TEXT AS AMST_FatherMobleNo,
                A."ASTUREQ_FatheremailId"::TEXT AS AMST_FatheremailId,
                A."ASTUREQ_FatherPhoto"::TEXT AS ANST_FatherPhoto,
                A."ASTUREQ_MotherMobleNo"::TEXT AS AMST_MotherMobileNo,
                A."ASTUREQ_MotherEmailId"::TEXT AS AMST_MotherEmailId,
                A."ASTUREQ_MotherPhoto"::TEXT AS ANST_MotherPhoto,
                A."ASTUREQ_StudentPhoto"::TEXT AS AMST_Photoname,
                A."ASTUREQ_AdmNo"::TEXT AS admissionno,
                COALESCE(A."AMSTG_Id", 0) AS AMSTG_Id,
                A."ASTUREQ_GuardianMobileNo"::TEXT AS AMSTG_GuardianPhoneNo,
                A."ASTUREQ_GuardianEmailId"::TEXT AS AMSTG_emailid,
                A."ASTUREQ_Id",
                A."ASTUREQ_Date",
                G."AMSTG_GuardianName"::TEXT,
                AMS."AMST_AdmNo"::TEXT,
                ASMC."ASMCL_ClassName"::TEXT,
                ASMS."ASMC_SectionName"::TEXT,
                A."ASTUREQ_ReqStatus"::TEXT,
                A."AMST_Id",
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_PerState" = "IVRMMS_Id") AS pstate,
                (SELECT "IVRMMS_Name"::TEXT FROM "IVRM_Master_State" WHERE A."ASTUREQ_ConState" = "IVRMMS_Id") AS cstate,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."IVRMMC_Id" = "IVRMMC_Id") AS pcountry,
                (SELECT "IVRMMC_CountryName"::TEXT FROM "IVRM_Master_Country" WHERE A."ASTUREQ_ConCountryId" = "IVRMMC_Id") AS ccountry,
                A."ASTUREQ_UpdatedDate",
                (SELECT AU."UserName"::TEXT FROM "ApplicationUser" AU WHERE AU."id" = A."ASTUREQ_ApprovedBy") AS UserName,
                (SELECT COALESCE(H."HRME_EmployeeFirstName", '') || ' ' || COALESCE(H."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(H."HRME_EmployeeLastName", '') 
                 FROM "Application