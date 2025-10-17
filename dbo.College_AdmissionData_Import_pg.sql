CREATE OR REPLACE FUNCTION "dbo"."College_AdmissionData_Import"(p_MI_Id TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FirstName TEXT;
    v_MiddleName TEXT;
    v_LastName TEXT;
    v_AMSTRegistrationNo TEXT;
    v_AMSTAdmNo TEXT;
    v_amstdate TEXT;
    v_JoinedYear TEXT;
    v_JoinedCourse TEXT;
    v_JoinedBranch TEXT;
    v_JoinedSemester TEXT;
    v_PresentYear TEXT;
    v_PresentCourse TEXT;
    v_PresentBranch TEXT;
    v_PresentSemester TEXT;
    v_BloodGroup TEXT;
    v_MotherTongue TEXT;
    v_Religion TEXT;
    v_Caste TEXT;
    v_subcaste TEXT;
    v_Cateagory TEXT;
    v_Quota TEXT;
    v_QuotaCategory TEXT;
    v_PermanentStreet TEXT;
    v_PermanentArea TEXT;
    v_PermanentCity TEXT;
    v_PermanentCountry TEXT;
    v_Permanentstate TEXT;
    v_PermanentPincode TEXT;
    v_PresentStreet TEXT;
    v_PresentArea TEXT;
    v_PresentCity TEXT;
    v_PresentState TEXT;
    v_PresentCountry TEXT;
    v_PresentPincode TEXT;
    v_AadharNo TEXT;
    v_MobileNo TEXT;
    v_EmailID TEXT;
    v_FatherName TEXT;
    v_Fathermobileno TEXT;
    v_FatherEmailId TEXT;
    v_MotherName TEXT;
    v_MotherMobileNo TEXT;
    v_MotherEmailId TEXT;
    v_StudentNationality TEXT;
    v_DOB DATE;
    v_DOBinwords TEXT;
    v_Gender TEXT;
    v_PresentSection BIGINT;
    v_AMCST_Id BIGINT;
    student_rec RECORD;
BEGIN
    RAISE NOTICE 'A';

    FOR student_rec IN 
        SELECT 
            "FirstName",
            "MiddleName",
            "LastName",
            "AMSTRegistrationNo",
            "AMSTAdmNo",
            CASE WHEN REPLACE("amstdate",'null','') = '' THEN NULL ELSE TO_DATE(REPLACE("amstdate",'null',''),'DD-MM-YYYY') END AS amstdate,
            (SELECT DISTINCT "ASMAY_Id" FROM "Adm_School_M_Academic_Year" B WHERE "MI_Id"=32 AND B."ASMAY_Year"=A."JoinedYear") AS "JoinedYear",
            10 AS "JoinedCourse",
            31 AS "JoinedBranch",
            17 AS "JoinedSemester",
            121 AS "PresentYear",
            10 AS "PresentCourse",
            31 AS "PresentBranch",
            24 AS "PresentSemester",
            5 AS "PresentSection",
            "BloodGroup",
            "MotherTongue",
            (SELECT DISTINCT "IVRMMR_Id" FROM "IVRM_Master_Religion" B WHERE B."IVRMMR_Name"=A."Religion") AS "Religion",
            (SELECT DISTINCT "IMC_Id" FROM "IVRM_Master_Caste" B WHERE B."MI_Id"=32 AND B."IMC_CasteName"=A."Caste") AS "Caste",
            "subcaste",
            (SELECT "IMCC_Id" FROM "IVRM_Master_Caste_Category" B WHERE B."IMCC_CategoryName"="Cateagory") AS "Cateagory",
            (SELECT DISTINCT "ACQ_Id" FROM "clg"."Adm_College_Quota" B WHERE "MI_Id"=32 AND B."ACQ_QuotaName"=A."Quota") AS "Quota",
            (SELECT DISTINCT "ACQC_Id" FROM "clg"."Adm_College_Quota_Category" B WHERE "MI_Id"=32 AND B."ACQC_CategoryName"=A."Quota") AS "QuotaCategory",
            "PermanentStreet",
            "PermanentArea",
            "PermanentCity",
            101 AS "PermanentCountry",
            17 AS "Permanentstate",
            0 AS "PermanentPincode",
            "PresentStreet",
            "PresentArea",
            "PresentCity",
            17 AS "PresentState",
            101 AS "PresentCountry",
            0 AS "PresentPincode",
            0 AS "AadharNo",
            REPLACE("MobileNo",'null','') AS "MobileNo",
            "EmailID",
            COALESCE("FatherName",'') AS "FatherName",
            REPLACE("Fathermobileno",'null','') AS "Fathermobileno",
            "FatherEmailId",
            "MotherName",
            REPLACE("MotherMobileNo",'null','') AS "MotherMobileNo",
            "MotherEmailId",
            101 AS "StudentNationality",
            CASE WHEN REPLACE("DOB",'null','') = '' THEN NULL ELSE TO_DATE(REPLACE("DOB",'null',''),'DD-MM-YYYY') END AS "DOB",
            "DOBinwords",
            "Gender" 
        FROM "BGS_college_admission_import_14Dec2020" A 
        WHERE "AMSTRegistrationNo" NOT IN (SELECT DISTINCT "AMCST_RegistrationNo" FROM "clg"."Adm_Master_College_Student" WHERE "MI_Id"=32)
    LOOP
        v_FirstName := student_rec."FirstName";
        v_MiddleName := student_rec."MiddleName";
        v_LastName := student_rec."LastName";
        v_AMSTRegistrationNo := student_rec."AMSTRegistrationNo";
        v_AMSTAdmNo := student_rec."AMSTAdmNo";
        v_amstdate := student_rec.amstdate;
        v_JoinedYear := student_rec."JoinedYear";
        v_JoinedCourse := student_rec."JoinedCourse";
        v_JoinedBranch := student_rec."JoinedBranch";
        v_JoinedSemester := student_rec."JoinedSemester";
        v_PresentYear := student_rec."PresentYear";
        v_PresentCourse := student_rec."PresentCourse";
        v_PresentBranch := student_rec."PresentBranch";
        v_PresentSemester := student_rec."PresentSemester";
        v_PresentSection := student_rec."PresentSection";
        v_BloodGroup := student_rec."BloodGroup";
        v_MotherTongue := student_rec."MotherTongue";
        v_Religion := student_rec."Religion";
        v_Caste := student_rec."Caste";
        v_subcaste := student_rec."subcaste";
        v_Cateagory := student_rec."Cateagory";
        v_Quota := student_rec."Quota";
        v_QuotaCategory := student_rec."QuotaCategory";
        v_PermanentStreet := student_rec."PermanentStreet";
        v_PermanentArea := student_rec."PermanentArea";
        v_PermanentCity := student_rec."PermanentCity";
        v_PermanentCountry := student_rec."PermanentCountry";
        v_Permanentstate := student_rec."Permanentstate";
        v_PermanentPincode := student_rec."PermanentPincode";
        v_PresentStreet := student_rec."PresentStreet";
        v_PresentArea := student_rec."PresentArea";
        v_PresentCity := student_rec."PresentCity";
        v_PresentState := student_rec."PresentState";
        v_PresentCountry := student_rec."PresentCountry";
        v_PresentPincode := student_rec."PresentPincode";
        v_AadharNo := student_rec."AadharNo";
        v_MobileNo := student_rec."MobileNo";
        v_EmailID := student_rec."EmailID";
        v_FatherName := student_rec."FatherName";
        v_Fathermobileno := student_rec."Fathermobileno";
        v_FatherEmailId := student_rec."FatherEmailId";
        v_MotherName := student_rec."MotherName";
        v_MotherMobileNo := student_rec."MotherMobileNo";
        v_MotherEmailId := student_rec."MotherEmailId";
        v_StudentNationality := student_rec."StudentNationality";
        v_DOB := student_rec."DOB";
        v_DOBinwords := student_rec."DOBinwords";
        v_Gender := student_rec."Gender";

        RAISE NOTICE 'AMCST_REgno 0 : %', v_AMSTRegistrationNo;

        INSERT INTO "clg"."Adm_Master_College_Student" (
            "MI_Id","ASMAY_Id","AMCST_FirstName","AMCST_MiddleName","AMCST_LastName","AMCST_Date","AMCST_RegistrationNo","AMCST_AdmNo","AMCOC_Id","AMCO_Id",
            "AMCST_Sex","AMCST_DOB","AMCST_DOBin_words","AMCST_Age","AMCST_BloodGroup","AMCST_MotherTongue","IVRMMR_Id","IMCC_Id","IMC_Id","AMCST_StudentSubCaste",
            "AMCST_PerStreet","AMCST_PerArea","AMCST_PerCity","AMCST_PerState","IVRMMC_Id","AMCST_PerPincode",
            "AMCST_ConStreet","AMCST_ConArea","AMCST_ConCity","AMCST_ConState","AMCST_ConCountryId","AMCST_ConPincode",
            "AMCST_AadharNo","AMCST_MobileNo","AMCST_emailId","AMCST_FatherAliveFlag","AMCST_FatherName","AMCST_MotherAliveFlag","AMCST_MotherName","AMCST_Nationality","AMCST_ActiveFlag",
            "CreatedDate","UpdatedDate","AMB_Id","AMSE_Id","AMCST_SOL","ACMB_Id","ACQ_Id","ACQC_Id","ACSS_Id","ACST_Id","AMCST_Urban_Rural","AMCST_BPLCardFlag","AMCST_ECSFlag","AMCST_Divyangjan",
            "AMCST_NoofSiblings","AMCST_NoofSiblingsSchool","AMCST_NoOfBrothers","AMCST_NoOfSisters","AMCST_NoofDependencies"
        )
        VALUES(
            p_MI_Id::BIGINT,v_JoinedYear::BIGINT,v_FirstName,COALESCE(v_MiddleName,''),COALESCE(v_LastName,''),v_amstdate::DATE,v_AMSTRegistrationNo,v_AMSTAdmNo,4,v_JoinedCourse::BIGINT,v_Gender,
            v_DOB,'',18,v_BloodGroup,v_MotherTongue,v_Religion::BIGINT,v_Cateagory::BIGINT,v_Caste::BIGINT,v_subcaste,
            v_PermanentStreet,v_PermanentArea,v_PermanentCity,v_Permanentstate::BIGINT,v_PermanentCountry::BIGINT,v_PermanentPincode::BIGINT,
            v_PresentStreet,v_PresentArea,v_PresentCity,v_PresentState::BIGINT,v_PresentCountry::BIGINT,v_PresentPincode::BIGINT,
            v_AadharNo::BIGINT,v_MobileNo,v_EmailID,1,v_FatherName,1,v_MotherName,v_StudentNationality::BIGINT,1,
            CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,v_JoinedBranch::BIGINT,v_JoinedSemester::BIGINT,'S',3,v_Quota::BIGINT,v_QuotaCategory::BIGINT,3,4,'Urban',0,0,0,0,0,0,0,0
        );

        RAISE NOTICE 'AMCST_REgno 1 : %', v_AMSTRegistrationNo;

        SELECT "AMCST_Id" INTO v_AMCST_Id 
        FROM "clg"."Adm_Master_College_Student" 
        WHERE "AMCST_RegistrationNo"=v_AMSTRegistrationNo AND "MI_Id"=p_MI_Id::BIGINT;

        INSERT INTO "clg"."Adm_College_Yearly_Student"(
            "AMCST_Id","ASMAY_Id","AMCO_Id","AMB_Id","AMSE_Id","ACMS_Id","ACYST_RollNo","AYST_PassFailFlag","LoginId","ACYST_DateTime","ACYST_ActiveFlag","CreatedDate","UpdatedDate"
        )
        VALUES(v_AMCST_Id,v_PresentYear::BIGINT,v_PresentCourse::BIGINT,v_PresentBranch::BIGINT,v_PresentSemester::BIGINT,5,1,1,3,CURRENT_TIMESTAMP,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

        INSERT INTO "clg"."Adm_College_Student_SMSNo"(
            "AMCST_Id","ACSTSMS_MobileNo","CreatedDate","UpdatedDate"
        )
        VALUES(v_AMCST_Id,v_MobileNo,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

        INSERT INTO "clg"."Adm_College_Student_EmailId"(
            "AMCST_Id","ACSTE_EmailId","CreatedDate","UpdatedDate"
        )
        VALUES(v_AMCST_Id,v_EmailID,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

    END LOOP;

    RETURN;
END;
$$;