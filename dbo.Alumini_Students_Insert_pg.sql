CREATE OR REPLACE FUNCTION "dbo"."Alumini_Students_Insert"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Exec Alumini_Students_Insert 4

    -- Drop temp table if exists
    DROP TABLE IF EXISTS "ALU_M_student";

    -- Create temp table with SELECT INTO equivalent
    CREATE TEMP TABLE "ALU_M_student" AS
    SELECT "MI_Id","AMS"."AMST_Id","AMS"."ASMAY_Id" as "ASMAY_Id_Join","ASYS"."ASMAY_Id" as "ASMAY_Id_Left","AMST_FirstName" as "ALMST_FirstName"
           ,"AMST_MiddleName" as "ALMST_MiddleName" ,"AMST_LastName" as "ALMST_LastName","AMST_Date" as "ALMST_Date","AMST_RegistrationNo" as "ALMST_RegistrationNo"
           ,"AMST_AdmNo" as "ALMST_AdmNo","AMST_Sex" as "ALMST_Sex","AMST_DOB" as "ALMST_DOB","AMST_DOB_Words" as "ALMST_DOBinwords"
           ,"PASR_Age" as "ALMST_Age","AMS"."ASMCL_Id" as "ASMCL_Id_Join","ASYS"."ASMCL_Id" as "ASMCL_Id_Left","AMST_BloodGroup" as "ALMST_BloodGroup","AMST_MotherTongue" as "ALMST_MotherTongue","AMST_MotherTongue" as "ALMST_HomeLaguage" 
           ,"AMST_BirthCertNO" as "ALMST_BirthCertNo","IVRMMR_Id","IMCC_Id","IC_Id" as "IMC_Id",
            "AMST_SubCasteIMC_Id" as "ALMST_StudentSubCaste","AMST_PerStreet" as "ALMST_PerStreet"
           ,"AMST_PerArea" as "ALMST_PerArea" ,"AMST_PerCity" as "ALMST_PerCity","AMST_PerAdd3" as "ALMST_PerAdd3"
           ,"AMST_PerState" as "ALMST_PerState","AMST_PerCountry" as "IVRMMC_Id","AMST_PerPincode" as "ALMST_PerPincode"
           ,"AMST_ConStreet" as "ALMST_ConStreet","AMST_ConArea" as "ALMST_ConArea",(COALESCE("AMST_ConStreet",'')||''||COALESCE("AMST_ConArea",'')||''||COALESCE("AMST_ConCity",'')) as "ALMST_ConAdd3"
           ,"AMST_ConCity" as "ALMST_ConCity",'' as "ALMST_Village",'' as "ALMST_Taluk",'' as "ALMST_District","AMST_ConState" as "ALMST_ConState" 
           ,"AMST_ConCountry" as "ALMST_ConCountryId",CAST("AMST_ConPincode" as bigint) as "ALMST_ConPincode","AMST_AadharNo" as "ALMST_AadharNo","AMST_StuBankAccNo" as "ALMST_StuBankAccNo","AMST_StudentPANNo" as "ALMST_StudentPANCard","AMST_StuBankIFSC_Code" as "ALMST_StuBankIFSCCode"
           ,"AMST_StuCasteCertiNo" as "ALMST_StuCasteCertiNo","AMST_MobileNo" as "ALMST_MobileNo","AMST_emailId" as "ALMST_emailId","AMST_FatherAliveFlag" as "ALMST_FatherAliveFlag"
           ,"AMST_FatherName" as "ALMST_FatherName","AMST_FatherAadharNo" as "ALMST_FatherAadharNo","AMST_FatherSurname" as "ALMST_FatherSurname","AMST_FatherEducation" as "ALMST_FatherEducation"
           ,"AMST_FatherOccupation" as "ALMST_FatherOccupation","AMST_FatherOfficeAdd" as "ALMST_FatherOfficeAdd","AMST_FatherDesignation" as "ALMST_FatherDesignation"
           ,"AMST_FatherMonIncome" as "ALMST_FatherMonIncome"  ,"AMST_FatherAnnIncome" as "ALMST_FatherAnnIncome",
            "AMST_FatherNationality" as "ALMST_FatherNationality", CAST("AMST_FatherReligion" as bigint) as "ALMST_FatherReligion",
            CAST("AMST_FatherCaste" as bigint) as "ALMST_FatherCaste","AMST_FatherSubCaste" as "ALMST_FatherSubCaste" 
           ,"AMST_FatherMobleNo" as "ALMST_FatherMobleNo","AMST_FatheremailId" as "ALMST_FatheremailId","AMST_FatherBankAccNo" as "ALMST_FatherBankAccNo"
           ,"AMST_FatherBankIFSC_Code" as "ALMST_FatherBankIFSCCode","AMST_FatherCasteCertiNo" as "ALMST_FatherCasteCertiNo","ANST_FatherPhoto" as "ALMST_FatherPhoto"
           ,"AMST_Father_Signature" as "ALMST_FatherSign","AMST_Father_FingerPrint" as "ALMST_FatherFingerprint","AMST_FatherPANNo" as "ALMST_FatherPANCardNo","AMST_MotherAliveFlag" as "ALMST_MotherAliveFlag"
           ,"AMST_MotherName" as "ALMST_MotherName","AMST_MotherAadharNo" as "ALMST_MotherAadharNo","AMST_MotherSurname" as "ALMST_MotherSurname","AMST_MotherEducation" as "ALMST_MotherEducation"
           ,"AMST_MotherOccupation" as "ALMST_MotherOccupation","AMST_MotherOfficeAdd" as "ALMST_MotherOfficeAdd","AMST_MotherDesignation" as "ALMST_MotherDesignation","AMST_MotherMonIncome" as "ALMST_MotherMonIncome" ,"AMST_MotherAnnIncome" as "ALMST_MotherAnnIncome"
           ,"AMST_MotherNationality" as "ALMST_MotherNationality","AMST_MotherReligion" as "ALMST_MotherReligion","AMST_MotherCaste" as "ALMST_MotherCaste","AMST_MotherSubCaste" as "ALMST_MotherSubCaste"
           ,"AMST_MotherMobileNo" as "ALMST_MotherMobleNo","AMST_MotherEmailId" as "ALMST_MotheremailId","AMST_MotherBankAccNo" as "ALMST_MotherBankAccNo"
           ,"AMST_MotherBankIFSC_Code" as "ALMST_MotherBankIFSCCode","AMST_MotherCasteCertiNo" as "ALMST_MotherCasteCertiNo","AMST_MotherPANNo" as "ALMST_MotherPANCardNo","AMST_TotalIncome" as "ALMST_TotalIncome","AMST_Mother_Signature" as "ALMST_MotherSign"
           ,"ANST_MotherPhoto" as "ALMST_MotherPhoto","AMST_Mother_FingerPrint" as "ALMST_MotherFingerprint"
           ,"AMST_BirthPlace" as "ALMST_BirthPlace","AMST_Nationality" as "ALMST_Nationality" ,"AMST_BPLCardFlag" as "ALMST_BPLCardFlag","AMST_BPLCardNo" as "ALMST_BPLCardNo"
           ,"AMST_HostelReqdFlag" as "ALMST_HostelReqdFlag","AMST_TransportReqdFlag" as "ALMST_TransportReqdFlag","AMST_GymReqdFlag" as "ALMST_GymReqdFlag"
           ,"AMST_ECSFlag" as "ALMST_ECSFlag","AMST_PaymentFlag" as "ALMST_PaymentFlag","AMST_AmountPaid" as "ALMST_AmountPaid","AMST_PaymentType" as "ALMST_PaymentType","AMST_PaymentDate" as "ALMST_PaymentDate"
           ,"AMST_ReceiptNo" as "ALMST_ReceiptNo",0 as "ALMST_EMSINo",
           "AMST_ApplStatus" as "ALMST_ApplStatus","AMST_FinalpaymentFlag" as "ALMST_FinalpaymentFlag"
           ,"AMST_Photoname" as "ALMST_StudentPhoto" ,'' as "ALMST_StudentSign" ,0 as "ALMST_NoofSiblingsSchool",
            "AMST_Noofsisters"+"AMST_Noofsisters" as "ALMST_NoofSiblings", "AMST_Noofbrothers" as "ALMST_NoOfBrothers"
           ,"AMST_Noofsisters" as "ALMST_NoOfSisters",
           ("AMST_Noofsisters"+"AMST_Noofsisters") as "ALMST_NoofDependencies"
           ,"AMST_Tpin" as "ALMST_TPINNO",1 as "IVRMMB_Id",'' as "ALMST_MOInstruction","AMST_GPSTrackingId" as "ALMST_GPSTrackingId","AMST_AppDownloadedDeviceId" as "ALMST_AppDownloadedDeviceId"
           , 1 as "ALMST_ActiveFlag",0 AS "ALMST_CreatedBy",CURRENT_TIMESTAMP as "CreatedDate" ,0 AS "ALMST_UpdatedBy",CURRENT_TIMESTAMP as "UpdatedDate",0 as "ALMST_PerCountry",
           '' as "ALMST_Marital_Status" , "AMST_MobileNo" as "ALMST_PhoneNo" 
                   
    FROM "Adm_M_student" "AMS"  
    INNER JOIN  "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id" 
    WHERE  "AMST_SOL"='L' AND "AMST_ActiveFlag"=0 AND "AMAY_ActiveFlag"=0 AND "MI_Id"=p_MI_Id;


    INSERT INTO "ALU"."Alumni_Master_Student"
           ("MI_Id","AMST_Id","ASMAY_Id_Join","ASMAY_Id_Left","ALMST_FirstName"
           ,"ALMST_MiddleName","ALMST_LastName","ALMST_Date","ALMST_RegistrationNo"
           ,"ALMST_AdmNo","ALMST_Sex","ALMST_DOB","ALMST_DOBinwords"
           ,"ALMST_Age","ASMCL_Id_Join","ASMCL_Id_Left","ALMST_BloodGroup","ALMST_MotherTongue","ALMST_HomeLaguage"
           ,"ALMST_BirthCertNo","IVRMMR_Id","IMCC_Id","IMC_Id","ALMST_StudentSubCaste","ALMST_PerStreet"
           ,"ALMST_PerArea","ALMST_PerCity","ALMST_PerAdd3"
           ,"ALMST_PerState","IVRMMC_Id","ALMST_PerPincode","ALMST_ConStreet","ALMST_ConArea","ALMST_ConAdd3"
           ,"ALMST_ConCity","ALMST_Village","ALMST_Taluk","ALMST_District"
           ,"ALMST_ConState","ALMST_ConCountryId","ALMST_ConPincode","ALMST_AadharNo","ALMST_StuBankAccNo"
           ,"ALMST_StudentPANCard","ALMST_StuBankIFSCCode","ALMST_StuCasteCertiNo","ALMST_MobileNo"
           ,"ALMST_emailId","ALMST_FatherAliveFlag","ALMST_FatherName","ALMST_FatherAadharNo"
           ,"ALMST_FatherSurname","ALMST_FatherEducation","ALMST_FatherOccupation","ALMST_FatherOfficeAdd"
           ,"ALMST_FatherDesignation","ALMST_FatherMonIncome","ALMST_FatherAnnIncome"
           ,"ALMST_FatherNationality","ALMST_FatherReligion","ALMST_FatherCaste","ALMST_FatherSubCaste"
           ,"ALMST_FatherMobleNo","ALMST_FatheremailId","ALMST_FatherBankAccNo"
           ,"ALMST_FatherBankIFSCCode","ALMST_FatherCasteCertiNo","ALMST_FatherPhoto","ALMST_FatherSign"
           ,"ALMST_FatherFingerprint","ALMST_FatherPANCardNo","ALMST_MotherAliveFlag","ALMST_MotherName"
           ,"ALMST_MotherAadharNo","ALMST_MotherSurname","ALMST_MotherEducation","ALMST_MotherOccupation"
           ,"ALMST_MotherOfficeAdd","ALMST_MotherDesignation","ALMST_MotherMonIncome","ALMST_MotherAnnIncome"
           ,"ALMST_MotherNationality","ALMST_MotherReligion","ALMST_MotherCaste","ALMST_MotherSubCaste"
           ,"ALMST_MotherMobleNo","ALMST_MotheremailId","ALMST_MotherBankAccNo","ALMST_MotherBankIFSCCode"
           ,"ALMST_MotherCasteCertiNo","ALMST_MotherPANCardNo"
           ,"ALMST_TotalIncome","ALMST_MotherSign","ALMST_MotherPhoto","ALMST_MotherFingerprint"
           ,"ALMST_BirthPlace","ALMST_Nationality","ALMST_BPLCardFlag","ALMST_BPLCardNo"
           ,"ALMST_HostelReqdFlag","ALMST_TransportReqdFlag","ALMST_GymReqdFlag"
           ,"ALMST_ECSFlag","ALMST_PaymentFlag","ALMST_AmountPaid","ALMST_PaymentType","ALMST_PaymentDate"
           ,"ALMST_ReceiptNo","ALMST_EMSINo","ALMST_ApplStatus","ALMST_FinalpaymentFlag"
           ,"ALMST_StudentPhoto","ALMST_StudentSign","ALMST_StudentFingerprint","ALMST_NoofSiblingsSchool"
           ,"ALMST_NoofSiblings","ALMST_NoOfBrothers","ALMST_NoOfSisters","ALMST_NoofDependencies"
           ,"ALMST_TPINNO","IVRMMB_Id","ALMST_MOInstruction","ALMST_GPSTrackingId","ALMST_AppDownloadedDeviceId"
           ,"ALMST_ActiveFlag","ALMST_CreatedBy","CreatedDate","ALMST_UpdatedBy","UpdatedDate","ALMST_PerCountry"
           ,"ALMST_Marital_Status","ALMST_PhoneNo")
          
    SELECT "A"."MI_Id","AMST_Id","ASMAY_Id_Join","ASMAY_Id_Left","ALMST_FirstName"
           ,"ALMST_MiddleName","ALMST_LastName","ALMST_Date","ALMST_RegistrationNo"
           ,"ALMST_AdmNo","ALMST_Sex","ALMST_DOB","ALMST_DOBinwords"
           ,"ALMST_Age","ASMCL_Id_Join","ASMCL_Id_Left","ALMST_BloodGroup","ALMST_MotherTongue","ALMST_HomeLaguage"
           ,"ALMST_BirthCertNo","IVRMMR_Id","IMCC_Id","IMC_Id","ALMST_StudentSubCaste","ALMST_PerStreet"
           ,"ALMST_PerArea","ALMST_PerCity","ALMST_PerAdd3"
           ,"ALMST_PerState","IVRMMC_Id","ALMST_PerPincode","ALMST_ConStreet","ALMST_ConArea","ALMST_ConAdd3"
           ,"ALMST_ConCity","ALMST_Village","ALMST_Taluk","ALMST_District"
           ,"ALMST_ConState","ALMST_ConCountryId","ALMST_ConPincode","ALMST_AadharNo","ALMST_StuBankAccNo"
           ,"ALMST_StudentPANCard","ALMST_StuBankIFSCCode","ALMST_StuCasteCertiNo","ALMST_MobileNo"
           ,"ALMST_emailId","ALMST_FatherAliveFlag","ALMST_FatherName","ALMST_FatherAadharNo"
           ,"ALMST_FatherSurname","ALMST_FatherEducation","ALMST_FatherOccupation","ALMST_FatherOfficeAdd"
           ,"ALMST_FatherDesignation","ALMST_FatherMonIncome","ALMST_FatherAnnIncome"
           ,"ALMST_FatherNationality","ALMST_FatherReligion","ALMST_FatherCaste","ALMST_FatherSubCaste"
           ,"ALMST_FatherMobleNo","ALMST_FatheremailId","ALMST_FatherBankAccNo"
           ,"ALMST_FatherBankIFSCCode","ALMST_FatherCasteCertiNo","ALMST_FatherPhoto","ALMST_FatherSign"
           ,"ALMST_FatherFingerprint","ALMST_FatherPANCardNo","ALMST_MotherAliveFlag","ALMST_MotherName"
           ,"ALMST_MotherAadharNo","ALMST_MotherSurname","ALMST_MotherEducation","ALMST_MotherOccupation"
           ,"ALMST_MotherOfficeAdd","ALMST_MotherDesignation","ALMST_MotherMonIncome","ALMST_MotherAnnIncome"
           ,"ALMST_MotherNationality","ALMST_MotherReligion","ALMST_MotherCaste","ALMST_MotherSubCaste"
           ,"ALMST_MotherMobleNo","ALMST_MotheremailId","ALMST_MotherBankAccNo","ALMST_MotherBankIFSCCode"
           ,"ALMST_MotherCasteCertiNo","ALMST_MotherPANCardNo"
           ,"ALMST_TotalIncome","ALMST_MotherSign","ALMST_MotherPhoto","ALMST_MotherFingerprint"
           ,"ALMST_BirthPlace","ALMST_Nationality","ALMST_BPLCardFlag","ALMST_BPLCardNo"
           ,"ALMST_HostelReqdFlag","ALMST_TransportReqdFlag","ALMST_GymReqdFlag"
           ,"ALMST_ECSFlag","ALMST_PaymentFlag","ALMST_AmountPaid","ALMST_PaymentType","ALMST_PaymentDate"
           ,"ALMST_ReceiptNo","ALMST_EMSINo","ALMST_ApplStatus","ALMST_FinalpaymentFlag"
           ,"ALMST_StudentPhoto","ALMST_StudentSign",0 as "ALMST_StudentFingerprint","ALMST_NoofSiblingsSchool"
           ,"ALMST_NoofSiblings","ALMST_NoOfBrothers","ALMST_NoOfSisters","ALMST_NoofDependencies"
           ,"ALMST_TPINNO","B"."IVRMMB_Id","ALMST_MOInstruction","ALMST_GPSTrackingId","ALMST_AppDownloadedDeviceId"
           ,"ALMST_ActiveFlag","ALMST_CreatedBy","A"."CreatedDate","ALMST_UpdatedBy","A"."UpdatedDate","ALMST_PerCountry"
           ,"ALMST_Marital_Status","ALMST_PhoneNo" 
    FROM "ALU_M_student" "A" 
    LEFT JOIN "IVRM_Master_Board" "B" ON "A"."MI_Id"="B"."MI_Id";

END;
$$;