CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Data_Import_Excel"(p_MI_Id BIGINT)
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
    v_Permanentstate TEXT;
    v_PermanentCountry TEXT;
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
    v_amstdob TEXT;
    v_amstdobwords TEXT;
    v_amstsection TEXT;
    v_gender TEXT;
    v_AMCST_Id BIGINT;
    
    rec RECORD;
BEGIN

    FOR rec IN 
        SELECT 
            "FirstName",
            "MiddleName",
            "LastName",
            "AMSTRegistrationNo",
            "AMSTAdmNo",
            TO_DATE(COALESCE("amstdate",''), 'DD/MM/YYYY') as amstdate,
            "JoinedYear",
            "JoinedCourse",
            "JoinedBranch",
            "JoinedSemester",
            "PresentYear",
            "PresentCourse",
            "PresentBranch",
            "PresentSemester",
            "BloodGroup",
            "MotherTongue",
            "Religion",
            "Caste",
            "subcaste",
            "Cateagory",
            "Quota",
            "QuotaCategory",
            "PermanentStreet",
            "PermanentArea",
            "PermanentCity",
            "Permanentstate",
            "PermanentCountry",
            "PermanentPincode",
            "PresentStreet",
            "PresentArea",
            "PresentCity",
            "PresentState",
            "PresentCountry",
            "PresentPincode",
            "AadharNo",
            "MobileNo",
            "EmailID",
            "FatherName",
            "Fathermobileno",
            "FatherEmailId",
            "MotherName",
            "MotherMobileNo",
            "MotherEmailId",
            "StudentNationality",
            "PresentSection",
            TO_DATE(COALESCE("DOB",''), 'DD/MM/YYYY') as DOB
        FROM "BMC_1year_Temp"  
        WHERE "AMSTADMNO" != 'C-001/19'
    LOOP
        v_FirstName := rec."FirstName";
        v_MiddleName := rec."MiddleName";
        v_LastName := rec."LastName";
        v_AMSTRegistrationNo := rec."AMSTRegistrationNo";
        v_AMSTAdmNo := rec."AMSTAdmNo";
        v_amstdate := rec.amstdate;
        v_JoinedYear := rec."JoinedYear";
        v_JoinedCourse := rec."JoinedCourse";
        v_JoinedBranch := rec."JoinedBranch";
        v_JoinedSemester := rec."JoinedSemester";
        v_PresentYear := rec."PresentYear";
        v_PresentCourse := rec."PresentCourse";
        v_PresentBranch := rec."PresentBranch";
        v_PresentSemester := rec."PresentSemester";
        v_BloodGroup := rec."BloodGroup";
        v_MotherTongue := rec."MotherTongue";
        v_Religion := rec."Religion";
        v_Caste := rec."Caste";
        v_subcaste := rec."subcaste";
        v_Cateagory := rec."Cateagory";
        v_Quota := rec."Quota";
        v_QuotaCategory := rec."QuotaCategory";
        v_PermanentStreet := rec."PermanentStreet";
        v_PermanentArea := rec."PermanentArea";
        v_PermanentCity := rec."PermanentCity";
        v_Permanentstate := rec."Permanentstate";
        v_PermanentCountry := rec."PermanentCountry";
        v_PermanentPincode := rec."PermanentPincode";
        v_PresentStreet := rec."PresentStreet";
        v_PresentArea := rec."PresentArea";
        v_PresentCity := rec."PresentCity";
        v_PresentState := rec."PresentState";
        v_PresentCountry := rec."PresentCountry";
        v_PresentPincode := rec."PresentPincode";
        v_AadharNo := rec."AadharNo";
        v_MobileNo := rec."MobileNo";
        v_EmailID := rec."EmailID";
        v_FatherName := rec."FatherName";
        v_Fathermobileno := rec."Fathermobileno";
        v_FatherEmailId := rec."FatherEmailId";
        v_MotherName := rec."MotherName";
        v_MotherMobileNo := rec."MotherMobileNo";
        v_MotherEmailId := rec."MotherEmailId";
        v_StudentNationality := rec."StudentNationality";
        v_amstsection := rec."PresentSection";
        v_amstdob := rec.DOB;

        RAISE NOTICE '%', v_AMSTRegistrationNo;

        INSERT INTO "CLG"."Adm_Master_College_Student" (
            "MI_Id","ASMAY_Id","AMCST_FirstName","AMCST_MiddleName","AMCST_LastName","AMCST_Date",
            "AMCST_RegistrationNo","AMCST_AdmNo","AMCOC_Id","AMCO_Id","AMCST_Sex","AMCST_BloodGroup","AMCST_MotherTongue",
            "IVRMMR_Id","IMCC_Id","IMC_Id","AMCST_StudentSubCaste","AMCST_PerStreet","AMCST_PerArea","AMCST_PerCity","AMCST_PerAdd3","AMCST_PerState",
            "IVRMMC_Id","AMCST_PerPincode","AMCST_ConStreet","AMCST_ConArea","AMCST_ConAdd3","AMCST_ConCity","AMCST_ConState","AMCST_ConCountryId",
            "AMCST_ConPincode","AMCST_AadharNo","AMCST_MobileNo","AMCST_emailId","AMCST_FatherAliveFlag","AMCST_FatherName","AMCST_FatherMobleNo",
            "AMCST_FatheremailId","AMCST_MotherAliveFlag","AMCST_MotherName","AMCST_MotherMobleNo","AMCST_MotheremailId",
            "AMCST_Nationality","AMB_Id","AMSE_Id","AMCST_SOL","ACMB_Id","ACQ_Id","ACQC_Id","AMCST_ActiveFlag","ACSS_Id","ACST_Id",
            "AMCST_Urban_Rural","CreatedDate","UpdatedDate","AMCST_NoOfBrothers","AMCST_Divyangjan","AMCST_NoofSiblings",
            "AMCST_NoOfSisters","AMCST_NoofDependencies","AMCST_NoofSiblingsSchool","AMCST_FatherNationality",
            "AMCST_MotherNationality","AMCST_DOB"
        )
        VALUES(
            15, v_JoinedYear::BIGINT, v_FirstName, v_MiddleName, v_LastName, v_amstdate::DATE, v_AMSTRegistrationNo, v_AMSTAdmNo, 5, v_JoinedCourse::BIGINT,
            'Female', v_BloodGroup, v_MotherTongue,
            v_Religion::BIGINT, v_Cateagory::BIGINT, v_Caste::BIGINT, v_subcaste, v_PermanentStreet, v_PermanentArea, v_PermanentCity, '', v_Permanentstate::BIGINT, v_PermanentCountry::BIGINT,
            TRIM(v_PermanentPincode)::BIGINT, v_PresentStreet, v_PresentArea, '', v_PresentCity, v_PresentState::BIGINT, v_PresentCountry::BIGINT,
            TRIM(v_PresentPincode)::BIGINT, v_AadharNo, v_MobileNo::BIGINT, v_EmailID, 1, v_FatherName, v_Fathermobileno::BIGINT, v_FatherEmailId, 1,
            v_MotherName, v_MotherMobileNo::BIGINT, v_MotherEmailId, v_StudentNationality::BIGINT, v_JoinedBranch::BIGINT, v_JoinedSemester::BIGINT, 'S', 6,
            v_Quota::BIGINT, v_QuotaCategory::BIGINT, 1, 6, 14, 'Rural', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, 0, 0, 0, 0, 0, 101, 101, v_amstdob::DATE
        );

        SELECT "AMCST_Id" INTO v_AMCST_Id 
        FROM "CLG"."Adm_Master_College_Student" 
        WHERE "AMCST_AdmNo" = v_AMSTAdmNo 
        AND "AMCST_RegistrationNo" = v_AMSTRegistrationNo;

        IF v_MobileNo IS NOT NULL AND v_MobileNo != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_SMSNo" ("AMCST_Id", "ACSTSMS_MobileNo", "CreatedDate", "UpdatedDate") 
            VALUES(v_AMCST_Id, v_MobileNo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        END IF;

        IF v_EmailID IS NOT NULL AND v_EmailID != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_EmailId"("AMCST_Id", "ACSTE_EmailId", "CreatedDate", "UpdatedDate") 
            VALUES(v_AMCST_Id, v_EmailID, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        END IF;

        IF v_Fathermobileno IS NOT NULL AND v_Fathermobileno != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_Parents_MobileNo"("AMCST_Id", "ACSTPMN_MobileNo", "CreatedDate", "UpdatedDate", "ACSTPMN_Flag") 
            VALUES(v_AMCST_Id, v_Fathermobileno, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F');
        END IF;

        IF v_FatherEmailId IS NOT NULL AND v_FatherEmailId != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_Parents_EmailId"("AMCST_Id", "ACSTPE_EmailId", "CreatedDate", "UpdatedDate", "ACSTPE_Flag") 
            VALUES(v_AMCST_Id, v_FatherEmailId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F');
        END IF;

        IF v_MotherMobileNo IS NOT NULL AND v_MotherMobileNo != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_Parents_MobileNo" ("AMCST_Id", "ACSTPMN_MobileNo", "CreatedDate", "UpdatedDate", "ACSTPMN_Flag") 
            VALUES(v_AMCST_Id, v_MotherMobileNo, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'M');
        END IF;

        IF v_MotherEmailId IS NOT NULL AND v_MotherEmailId != '' THEN
            INSERT INTO "CLG"."Adm_College_Student_Parents_EmailId"("AMCST_Id", "ACSTPE_EmailId", "CreatedDate", "UpdatedDate", "ACSTPE_Flag") 
            VALUES(v_AMCST_Id, v_MotherEmailId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'M');
        END IF;

        INSERT INTO "CLG"."Adm_College_Yearly_Student" (
            "AMCST_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", "ACYST_RollNo", "AYST_PassFailFlag", "LoginId",
            "ACYST_DateTime", "ACYST_ActiveFlag", "CreatedDate", "UpdatedDate"
        ) 
        VALUES(
            v_AMCST_Id, v_PresentYear::BIGINT, v_PresentCourse::BIGINT, v_PresentBranch::BIGINT, v_PresentSemester::BIGINT, v_amstsection::BIGINT, 1, 0, 4,
            CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );

    END LOOP;

    RETURN;

END;
$$;