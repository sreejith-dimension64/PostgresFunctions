CREATE OR REPLACE FUNCTION "dbo"."CLG_TR_GET_TRNAPPLN_STUDENT_ROUTE_DETAILS"(
    p_MI_Id bigint,
    p_AMCST_Id bigint,
    p_ASMAY_Id bigint,
    p_FLAG varchar(20)
)
RETURNS TABLE(
    "amcsT_Id" bigint,
    "amcsT_FirstName" text,
    "amcO_CourseName" varchar,
    "amcO_Id" bigint,
    "amB_Id" bigint,
    "amB_BranchName" varchar,
    "amsE_Id" bigint,
    "amsE_SEMName" varchar,
    "acmS_Id" bigint,
    "acmS_SectionName" varchar,
    "asmaY_Id" bigint,
    "asmaY_Year" varchar,
    "amcsT_AdmNo" varchar,
    "amcsT_emailId" varchar,
    "amcsT_MobileNo" varchar,
    "amcsT_PerStreet" varchar,
    "amcsT_PerCity" varchar,
    "amcsT_PerArea" varchar,
    "amcsT_PerPincode" varchar,
    "ivrmmC_CountryName" varchar,
    "ivrmmS_Name" varchar,
    "amcsT_FatherName" varchar,
    "amcsT_MotherName" varchar,
    "amcsT_StudentPhoto" varchar,
    "amcsT_FatherOfficeAdd" varchar,
    "ivrmmS_Id" bigint,
    "amcsT_BloodGroup" varchar,
    "AMCST_DOB" timestamp,
    "AMCST_FatherMobleNo" varchar,
    "AMCST_MotherMobleNo" varchar,
    "AMCST_FatherOfficeAdd_2" varchar,
    "ASTACO_AreaZoneName" varchar,
    "trmA_Id" bigint,
    "ASTACO_Landmark" varchar,
    "ASTACO_Phoneoff" varchar,
    "ASTACO_PhoneRes" varchar,
    "ASTACO_ForAY" bigint,
    "ASTACO_Id" bigint,
    "ASMAY_Order" int,
    "astacO_PickUp_TRMR_Id" bigint,
    "astacO_PickUp_TRML_Id" bigint,
    "astacO_Drop_TRMR_Id" bigint,
    "astacO_Drop_TRML_Id" bigint,
    "ASTACO_DropSMSMobileNo" varchar,
    "ASTACO_PickupSMSMobileNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_FLAG = 'S' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            (COALESCE(A."AMCST_FirstName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '')) AS "amcsT_FirstName",
            D."AMCO_CourseName" AS "amcO_CourseName",
            D."AMCO_Id" AS "amcO_Id",
            E."AMB_Id" AS "amB_Id",
            E."AMB_BranchName" AS "amB_BranchName",
            F."AMSE_Id" AS "amsE_Id",
            F."AMSE_SEMName" AS "amsE_SEMName",
            G."ACMS_Id" AS "acmS_Id",
            G."ACMS_SectionName" AS "acmS_SectionName",
            H."ASMAY_Id" AS "asmaY_Id",
            H."ASMAY_Year" AS "asmaY_Year",
            A."AMCST_AdmNo" AS "amcsT_AdmNo",
            A."AMCST_emailId" AS "amcsT_emailId",
            A."AMCST_MobileNo" AS "amcsT_MobileNo",
            A."AMCST_PerStreet" AS "amcsT_PerStreet",
            A."AMCST_PerCity" AS "amcsT_PerCity",
            A."AMCST_PerArea" AS "amcsT_PerArea",
            A."AMCST_PerPincode" AS "amcsT_PerPincode",
            I."IVRMMC_CountryName" AS "ivrmmC_CountryName",
            J."IVRMMS_Name" AS "ivrmmS_Name",
            A."AMCST_FatherName" AS "amcsT_FatherName",
            A."AMCST_MotherName" AS "amcsT_MotherName",
            A."AMCST_StudentPhoto" AS "amcsT_StudentPhoto",
            A."AMCST_FatherOfficeAdd" AS "amcsT_FatherOfficeAdd",
            J."IVRMMS_Id" AS "ivrmmS_Id",
            A."AMCST_BloodGroup" AS "amcsT_BloodGroup",
            A."AMCST_DOB",
            A."AMCST_FatherMobleNo",
            A."AMCST_MotherMobleNo",
            A."AMCST_FatherOfficeAdd" AS "AMCST_FatherOfficeAdd_2",
            std."ASTACO_AreaZoneName",
            std."TRMA_Id" AS "trmA_Id",
            std."ASTACO_Landmark",
            std."ASTACO_Phoneoff",
            std."ASTACO_PhoneRes",
            std."ASTACO_ForAY",
            std."ASTACO_Id",
            H."ASMAY_Order",
            COALESCE(std."ASTACO_PickUp_TRMR_Id", 0) AS "astacO_PickUp_TRMR_Id",
            COALESCE(std."ASTACO_PickUp_TRML_Id", 0) AS "astacO_PickUp_TRML_Id",
            COALESCE(std."ASTACO_Drop_TRMR_Id", 0) AS "astacO_Drop_TRMR_Id",
            COALESCE(std."ASTACO_Drop_TRML_Id", 0) AS "astacO_Drop_TRML_Id",
            std."ASTACO_DropSMSMobileNo",
            std."ASTACO_PickupSMSMobileNo"
        FROM "Adm_Student_Trans_Appl_College" AS std
        INNER JOIN "CLG"."Adm_Master_College_Student" AS A ON A."AMCST_Id" = std."AMCST_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON B."AMCST_Id" = A."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS D ON D."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS E ON E."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS F ON F."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS G ON G."ACMS_Id" = B."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" AS H ON H."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" AS I ON I."IVRMMC_Id" = A."IVRMMC_Id"
        INNER JOIN "IVRM_Master_State" AS J ON J."IVRMMC_Id" = I."IVRMMC_Id" AND J."IVRMMS_Id" = A."AMCST_ConState"
        WHERE A."MI_Id" = p_MI_Id AND A."AMCST_Id" = p_AMCST_Id AND std."ASTACO_ForAY" = p_ASMAY_Id;
    ELSIF p_FLAG = 'N' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            (COALESCE(A."AMCST_FirstName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '')) AS "amcsT_FirstName",
            D."AMCO_CourseName" AS "amcO_CourseName",
            D."AMCO_Id" AS "amcO_Id",
            E."AMB_Id" AS "amB_Id",
            E."AMB_BranchName" AS "amB_BranchName",
            F."AMSE_Id" AS "amsE_Id",
            F."AMSE_SEMName" AS "amsE_SEMName",
            NULL::bigint AS "acmS_Id",
            NULL::varchar AS "acmS_SectionName",
            H."ASMAY_Id" AS "asmaY_Id",
            H."ASMAY_Year" AS "asmaY_Year",
            A."AMCST_AdmNo" AS "amcsT_AdmNo",
            A."AMCST_emailId" AS "amcsT_emailId",
            A."AMCST_MobileNo" AS "amcsT_MobileNo",
            A."AMCST_PerStreet" AS "amcsT_PerStreet",
            A."AMCST_PerCity" AS "amcsT_PerCity",
            A."AMCST_PerArea" AS "amcsT_PerArea",
            A."AMCST_PerPincode" AS "amcsT_PerPincode",
            I."IVRMMC_CountryName" AS "ivrmmC_CountryName",
            J."IVRMMS_Name" AS "ivrmmS_Name",
            A."AMCST_FatherName" AS "amcsT_FatherName",
            A."AMCST_MotherName" AS "amcsT_MotherName",
            A."AMCST_StudentPhoto" AS "amcsT_StudentPhoto",
            A."AMCST_FatherOfficeAdd" AS "amcsT_FatherOfficeAdd",
            J."IVRMMS_Id" AS "ivrmmS_Id",
            A."AMCST_BloodGroup" AS "amcsT_BloodGroup",
            A."AMCST_DOB",
            A."AMCST_FatherMobleNo",
            A."AMCST_MotherMobleNo",
            A."AMCST_FatherOfficeAdd" AS "AMCST_FatherOfficeAdd_2",
            std."ASTACO_AreaZoneName",
            std."TRMA_Id" AS "trmA_Id",
            std."ASTACO_Landmark",
            std."ASTACO_Phoneoff",
            std."ASTACO_PhoneRes",
            std."ASTACO_ForAY",
            std."ASTACO_Id",
            H."ASMAY_Order",
            COALESCE(std."ASTACO_PickUp_TRMR_Id", 0) AS "astacO_PickUp_TRMR_Id",
            COALESCE(std."ASTACO_PickUp_TRML_Id", 0) AS "astacO_PickUp_TRML_Id",
            COALESCE(std."ASTACO_Drop_TRMR_Id", 0) AS "astacO_Drop_TRMR_Id",
            COALESCE(std."ASTACO_Drop_TRML_Id", 0) AS "astacO_Drop_TRML_Id",
            std."ASTACO_DropSMSMobileNo",
            std."ASTACO_PickupSMSMobileNo"
        FROM "Adm_Student_Trans_Appl_College" AS std
        INNER JOIN "CLG"."Adm_Master_College_Student" AS A ON A."AMCST_Id" = std."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS D ON D."AMCO_Id" = A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS E ON E."AMB_Id" = A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS F ON F."AMSE_Id" = A."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" AS H ON H."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" AS I ON I."IVRMMC_Id" = A."IVRMMC_Id"
        INNER JOIN "IVRM_Master_State" AS J ON J."IVRMMC_Id" = I."IVRMMC_Id" AND J."IVRMMS_Id" = A."AMCST_ConState"
        WHERE A."MI_Id" = p_MI_Id AND A."AMCST_Id" = p_AMCST_Id AND std."ASTACO_ForAY" = p_ASMAY_Id;
    END IF;
    
    RETURN;
END;
$$;