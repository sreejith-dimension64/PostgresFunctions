CREATE OR REPLACE FUNCTION "dbo"."Clg_Admission_Data_Transfer_From_institute_To_Institute"(
    p_MI_Id TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

-- Original commented out INSERT statement preserved as comment
/*INSERT INTO "CLG"."Adm_Master_College_Student" ("MI_Id",
"ASMAY_Id","AMCST_FirstName","AMCST_MiddleName","AMCST_LastName","AMCST_Date","AMCST_RegistrationNo","AMCST_AdmNo","AMCOC_Id","AMCO_Id","AMCST_Sex","AMCST_DOB","AMCST_DOBin_words","AMCST_Age","AMCST_BloodGroup",
"AMCST_MotherTongue","AMCST_BirthCertNo","IVRMMR_Id","IMCC_Id","IMC_Id","AMCST_StudentSubCaste","AMCST_PerStreet","AMCST_PerArea","AMCST_PerCity","AMCST_PerAdd3","AMCST_PerState","IVRMMC_Id","AMCST_PerPincode",
"AMCST_ConStreet","AMCST_ConArea","AMCST_ConAdd3","AMCST_ConCity","AMCST_Village","AMCST_Taluk","AMCST_District","AMCST_ConState","AMCST_ConCountryId","AMCST_ConPincode","AMCST_AadharNo","AMCST_StuBankAccNo",
"AMCST_StuBankIFSCCode","AMCST_StuCasteCertiNo","AMCST_MobileNo","AMCST_emailId","AMCST_FatherAliveFlag","AMCST_FatherName","AMCST_FatherAadharNo","AMCST_FatherSurname","AMCST_FatherEducation",
"AMCST_FatherOccupation","AMCST_FatherOfficeAdd","AMCST_FatherDesignation","AMCST_FatherMonIncome","AMCST_FatherAnnIncome","AMCST_FatherNationality","AMCST_FatherReligion","AMCST_FatherCaste",
"AMCST_FatherSubCaste","AMCST_FatherMobleNo","AMCST_FatheremailId","AMCST_FatherBankAccNo","AMCST_FatherBankIFSCCode","AMCST_FatherCasteCertiNo","AMCST_FatherPhoto","AMCST_FatherSign",
"AMCST_FatherFingerprint","AMCST_MotherAliveFlag","AMCST_MotherName","AMCST_MotherAadharNo","AMCST_MotherSurname","AMCST_MotherEducation","AMCST_MotherOccupation","AMCST_MotherOfficeAdd",
"AMCST_MotherDesignation","AMCST_MotherMonIncome","AMCST_MotherAnnIncome","AMCST_MotherNationality","AMCST_MotherReligion","AMCST_MotherCaste","AMCST_MotherSubCaste","AMCST_MotherMobleNo",
"AMCST_MotheremailId","AMCST_MotherBankAccNo","AMCST_MotherBankIFSCCode","AMCST_MotherCasteCertiNo","AMCST_TotalIncome","AMCST_MotherSign","AMCST_MotherPhoto","AMCST_MotherFingerprint",
"AMCST_BirthPlace","AMCST_Nationality","AMCST_BPLCardFlag","AMCST_BPLCardNo","AMCST_HostelReqdFlag","AMCST_TransportReqdFlag","AMCST_GymReqdFlag","AMCST_ECSFlag","AMCST_PaymentFlag",
"AMCST_AmountPaid","AMCST_PaymentType","AMCST_PaymentDate","AMCST_ReceiptNo","AMCST_EMSINo","AMCST_ApplStatus","AMCST_FinalpaymentFlag","AMCST_StudentPhoto","AMCST_StudentSign","AMCST_StudentFingerprint",
"AMCST_NoofSiblingsSchool","AMCST_NoofSiblings","AMCST_NoOfBrothers","AMCST_NoOfSisters","AMCST_NoofDependencies","AMCST_TPINNO","AMCST_ActiveFlag","CreatedDate","UpdatedDate","AMB_Id","AMSE_Id",
"AMCST_SOL","ACMB_Id","ACQ_Id","ACQC_Id","ACSS_Id","ACST_Id","AMCST_Urban_Rural","AMCST_PassportNo","AMCST_PassportIssuedAt","AMCST_PassportIssueDate","AMCST_PassportIssuedCounrty","AMCST_PassportIssuedPlace",
"AMCST_PassportExpiryDate","AMCST_VisaIssuedBy","AMCST_VISAValidFrom","AMCST_VISAValidTo","AMCST_Divyangjan","AMCST_DifferentlyAbledFlg","AMCST_UDIDNo","AMCST_DisabilityType","AMCST_DisabilityPer" )

SELECT  "MI_Id","ASMAY_Id","AMCST_FirstName","AMCST_MiddleName","AMCST_LastName","AMCST_Date","AMCST_RegistrationNo","AMCST_AdmNo","AMCOC_Id","AMCO_Id","AMCST_Sex","AMCST_DOB","AMCST_DOBin_words","AMCST_Age",
"AMCST_BloodGroup","AMCST_MotherTongue","AMCST_BirthCertNo","IVRMMR_Id","IMCC_Id","IMC_Id","AMCST_StudentSubCaste","AMCST_PerStreet","AMCST_PerArea","AMCST_PerCity","AMCST_PerAdd3","AMCST_PerState","IVRMMC_Id",
"AMCST_PerPincode","AMCST_ConStreet","AMCST_ConArea","AMCST_ConAdd3","AMCST_ConCity","AMCST_Village","AMCST_Taluk","AMCST_District","AMCST_ConState","AMCST_ConCountryId","AMCST_ConPincode","AMCST_AadharNo",
"AMCST_StuBankAccNo","AMCST_StuBankIFSCCode","AMCST_StuCasteCertiNo","AMCST_MobileNo","AMCST_emailId","AMCST_FatherAliveFlag","AMCST_FatherName","AMCST_FatherAadharNo","AMCST_FatherSurname",
"AMCST_FatherEducation","AMCST_FatherOccupation","AMCST_FatherOfficeAdd","AMCST_FatherDesignation","AMCST_FatherMonIncome","AMCST_FatherAnnIncome","AMCST_FatherNationality","AMCST_FatherReligion",
"AMCST_FatherCaste","AMCST_FatherSubCaste","AMCST_FatherMobleNo","AMCST_FatheremailId","AMCST_FatherBankAccNo","AMCST_FatherBankIFSCCode","AMCST_FatherCasteCertiNo","AMCST_FatherPhoto",
"AMCST_FatherSign","AMCST_FatherFingerprint","AMCST_MotherAliveFlag","AMCST_MotherName","AMCST_MotherAadharNo","AMCST_MotherSurname","AMCST_MotherEducation","AMCST_MotherOccupation","AMCST_MotherOfficeAdd",
"AMCST_MotherDesignation","AMCST_MotherMonIncome","AMCST_MotherAnnIncome","AMCST_MotherNationality","AMCST_MotherReligion","AMCST_MotherCaste","AMCST_MotherSubCaste","AMCST_MotherMobleNo",
"AMCST_MotheremailId","AMCST_MotherBankAccNo","AMCST_MotherBankIFSCCode","AMCST_MotherCasteCertiNo","AMCST_TotalIncome","AMCST_MotherSign","AMCST_MotherPhoto","AMCST_MotherFingerprint","AMCST_BirthPlace",
"AMCST_Nationality","AMCST_BPLCardFlag","AMCST_BPLCardNo","AMCST_HostelReqdFlag","AMCST_TransportReqdFlag","AMCST_GymReqdFlag","AMCST_ECSFlag","AMCST_PaymentFlag","AMCST_AmountPaid","AMCST_PaymentType",
"AMCST_PaymentDate","AMCST_ReceiptNo","AMCST_EMSINo","AMCST_ApplStatus","AMCST_FinalpaymentFlag","AMCST_StudentPhoto","AMCST_StudentSign","AMCST_StudentFingerprint","AMCST_NoofSiblingsSchool",
"AMCST_NoofSiblings","AMCST_NoOfBrothers","AMCST_NoOfSisters","AMCST_NoofDependencies","AMCST_TPINNO","AMCST_ActiveFlag","CreatedDate","UpdatedDate","AMB_Id","AMSE_Id","AMCST_SOL","ACMB_Id","ACQ_Id",
"ACQC_Id","ACSS_Id","ACST_Id","AMCST_Urban_Rural","AMCST_PassportNo","AMCST_PassportIssuedAt","AMCST_PassportIssueDate","AMCST_PassportIssuedCounrty","AMCST_PassportIssuedPlace",
"AMCST_PassportExpiryDate","AMCST_VisaIssuedBy","AMCST_VISAValidFrom","AMCST_VISAValidTo","AMCST_Divyangjan","AMCST_DifferentlyAbledFlg","AMCST_UDIDNo","AMCST_DisabilityType",
"AMCST_DisabilityPer" FROM "Clg_Temp_student_data_transfer" WHERE "MI_id"=30 */

    PERFORM * FROM "Master_Institution";
    
    PERFORM "AMCO_Id", * FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_Master_College_Category" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_Master_Course" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_Master_Branch" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_Master_Semester" WHERE "MI_Id"=30;
    
    PERFORM * FROM "Adm_School_M_Academic_Year" WHERE "mi_id"=30;
    
    PERFORM * FROM "CLG"."Adm_College_Student_SMSNo";
    
    PERFORM * FROM "CLG"."Adm_College_Student_Parents_MobileNo";
    
    PERFORM * FROM "CLG"."Adm_College_Quota" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_College_Quota_Category" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_College_SubjectScheme" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_College_SchemeType" WHERE "MI_Id"=30;
    
    PERFORM * FROM "CLG"."Adm_College_Master_Batch" WHERE "MI_Id"=30;
    
    PERFORM * FROM "IVRM_Master_Caste" WHERE "MI_Id"=30;
    
    PERFORM * FROM "IVRM_Master_Caste_Category";

    -- All commented UPDATE statements preserved as comments
    -- UPDATE "Clg_Temp_student_data_transfer" SET "mi_id"=30;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "asmay_id"=10083;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amco_id"= 29;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amb_id"= 82;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=70 WHERE "amse_id"=62;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=71 WHERE "amse_id"=63;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=72 WHERE "amse_id"=64;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=73 WHERE "amse_id"=65;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=74 WHERE "amse_id"=66;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=75 WHERE "amse_id"=67;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=76 WHERE "amse_id"=68;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amse_id"=77 WHERE "amse_id"=69;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "amcoc_id"=20;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "acq_id"=24;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "Acqc_id"=46;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "acss_id"=9;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "ACST_ID"=11;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "ACMB_ID"=10;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "IMC_Id"=2485;
    -- UPDATE "Clg_Temp_student_data_transfer" SET "IMCC_Id"=1;

    -- All commented INSERT statements preserved as comments
    -- INSERT INTO "CLG"."Adm_College_Student_EmailId" ("AMCST_Id","ACSTE_EmailId","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_emailId" AS "ACSTE_EmailId", CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;
    
    -- INSERT INTO "CLG"."Adm_College_Student_SMSNo" ("AMCST_Id","ACSTSMS_MobileNo","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_MobileNo" AS "ACSTSMS_MobileNo", CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;

    -- INSERT INTO "CLG"."Adm_College_Student_Parents_MobileNo" ("AMCST_Id","ACSTPMN_MobileNo","ACSTPMN_Flag","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_MotherMobleNo" AS "ACSTPMN_MobileNo",'M', CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;
    
    -- INSERT INTO "CLG"."Adm_College_Student_Parents_MobileNo" ("AMCST_Id","ACSTPMN_MobileNo","ACSTPMN_Flag","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_FatherMobleNo" AS "ACSTPMN_MobileNo",'F', CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;

    -- INSERT INTO "CLG"."Adm_College_Student_Parents_EmailId"("AMCST_Id","ACSTPE_EmailId","ACSTPE_Flag","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_MotheremailId" AS "ACSTPE_EmailId",'M', CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;
    
    -- INSERT INTO "CLG"."Adm_College_Student_Parents_EmailId" ("AMCST_Id","ACSTPE_EmailId","ACSTPE_Flag","CreatedDate","UpdatedDate") 
    -- SELECT "AMCST_Id", "AMCST_FatheremailId" AS "ACSTPE_EmailId",'F', CURRENT_TIMESTAMP AS "CreatedDate", CURRENT_TIMESTAMP AS "UpdatedDate" 
    -- FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=30 AND "amb_id"=82;

    RETURN;

END;
$$;