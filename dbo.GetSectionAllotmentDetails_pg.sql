CREATE OR REPLACE FUNCTION "dbo"."GetSectionAllotmentDetails"(
    "MI_Id" int,
    "ASMAY_Id" int,
    "ASMCL_Id" int,
    "Type" int
)
RETURNS TABLE(
    "AMST_Id" int,
    "MI_Id" int,
    "ASMAY_Id" int,
    "ASMCL_Id" int,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "AMST_LastName" varchar,
    "AMST_Date" timestamp,
    "AMST_RegistrationNo" varchar,
    "AMST_AdmNo" varchar,
    "AMST_Sex" varchar,
    "AMST_DOB" timestamp,
    "AMST_DOB_Words" varchar,
    "AMST_Age" int,
    "ASMCL_Id_Join" int,
    "AMST_PerStreet" varchar,
    "AMST_PerArea" varchar,
    "AMST_PerCity" varchar,
    "AMST_PerAdd4" varchar,
    "IVRMMMS_Id" int,
    "IVRMMC_Id" int,
    "AMST_PerPincode" int,
    "AMST_ConStreet" varchar,
    "AMST_ConArea" varchar,
    "AMST_ConCity" varchar,
    "AMST_ConAdd4" varchar,
    "AMST_ConPincode" int,
    "AMST_AadharNo" bigint,
    "AMST_StuBankAccNo" bigint,
    "AMST_StuBankIFSC_Code" varchar,
    "AMST_StuCasteCertiNo" varchar,
    "AMST_MobileNo" bigint,
    "AMST_emailId" varchar,
    "AMST_PerState" int,
    "AMST_ConState" int,
    "AMST_Photoname" varchar,
    "AMST_FatherAliveFlag" varchar,
    "AMST_FatherName" varchar,
    "AMST_FatherAadharNo" bigint,
    "AMST_FatherSurname" varchar,
    "AMST_FatherEducation" varchar,
    "AMST_FatherOccupation" varchar,
    "AMST_FatherDesignation" varchar,
    "AMST_FatherBankAccNo" bigint,
    "AMST_FatherBankIFSC_Code" varchar,
    "AMST_FatherCasteCertiNo" varchar,
    "AMST_FatherMonIncome" decimal,
    "AMST_FatherMobleNo" bigint,
    "AMST_FatheremailId" varchar,
    "AMST_MotherAliveFlag" varchar,
    "AMST_MotherName" varchar,
    "AMST_MotherAadharNo" bigint,
    "AMST_MotherSurname" varchar,
    "AMST_MotherEducation" varchar,
    "AMST_MotherOccupation" varchar,
    "AMST_MotherDesignation" varchar,
    "AMST_MotherBankAccNo" bigint,
    "AMST_MotherBankIFSC_Code" varchar,
    "AMST_MotherCasteCertiNo" varchar,
    "AMST_MotherMonIncome" decimal,
    "AMST_MotherMobleNo" bigint,
    "AMST_MotheremailId" varchar,
    "AMST_BirthPlace" varchar,
    "AMST_Nationality" int,
    "AMST_BPLCardFlag" boolean,
    "AMST_BPLCardNo" varchar,
    "AMST_HostelReqdFlag" boolean,
    "AMST_TransportReqdFlag" boolean,
    "AMST_GymReqdFlag" boolean,
    "AMST_ECSFlag" boolean,
    "AMST_PaymentFlag" int,
    "AMST_AmountPaid" decimal,
    "AMST_PaymentType" varchar,
    "AMST_PaymentDate" timestamp,
    "AMST_ReceiptNo" varchar,
    "AMST_ActiveFlag" int,
    "AMST_ApplStatus" varchar,
    "AMST_FinalpaymentFlag" int,
    "AMST_StudentPhoto" varchar,
    "AMST_StudentSign" varchar,
    "AMST_FatherSign" varchar,
    "AMST_MotherSign" varchar,
    "AMST_NoofSiblingsSchool" int,
    "AMST_NoofSiblings" int,
    "AMST_NoOfBrothers" int,
    "AMST_NoOfSisters" int,
    "AMST_NoOfElderBrothers" int,
    "AMST_NoOfYoungerBrothers" int,
    "AMST_NoOfElderSisters" int,
    "AMST_NoOfYoungerSisters" int,
    "AMST_Tpin" varchar,
    "AMST_CoutryCode" bigint,
    "AMST_MotherCoutryCode" bigint,
    "AMST_FatherCoutryCode" bigint,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp,
    "AMST_BiometricId" varchar,
    "AMST_RFCardNo" varchar,
    "IMC_Id" int,
    "IMCC_Id" int,
    "AMST_FatherReligion" varchar,
    "AMST_FatherCaste" varchar,
    "AMST_MotherReligion" varchar,
    "AMST_MotherCaste" varchar,
    "AMST_FSubCasteIMC_Id" int,
    "AMST_MSubCasteIMC_Id" int,
    "ASMCL_ClassName" varchar,
    "ASMAY_Year" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "Type" = 1 THEN
        RETURN QUERY
        SELECT  mstd.*, c."ASMCL_ClassName", y."ASMAY_Year"
        FROM  "Adm_M_Student" mstd
        LEFT JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = mstd."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" y ON y."ASMAY_Id" = mstd."ASMAY_Id"
        WHERE  mstd."AMST_Id" NOT IN(SELECT "AMST_Id" FROM "Adm_School_Y_Student")
        AND mstd."MI_Id" = "GetSectionAllotmentDetails"."MI_Id" 
        AND mstd."ASMAY_Id" = "GetSectionAllotmentDetails"."ASMAY_Id" 
        AND mstd."ASMCL_Id" = "GetSectionAllotmentDetails"."ASMCL_Id"
        UNION
        SELECT  mstd.*, c."ASMCL_ClassName", y."ASMAY_Year"
        FROM  "Adm_M_Student" mstd
        LEFT JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = mstd."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Academic_Year" y ON y."ASMAY_Id" = mstd."ASMAY_Id"
        WHERE  mstd."AMST_Id" IN(SELECT "AMST_Id" FROM "Adm_School_Y_Student" WHERE "AMAY_ActiveFlag" = 0)
        AND mstd."MI_Id" = "GetSectionAllotmentDetails"."MI_Id" 
        AND mstd."ASMAY_Id" = "GetSectionAllotmentDetails"."ASMAY_Id" 
        AND mstd."ASMCL_Id" = "GetSectionAllotmentDetails"."ASMCL_Id";
    END IF;
    
    RETURN;
END;
$$;