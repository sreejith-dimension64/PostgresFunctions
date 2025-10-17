CREATE OR REPLACE FUNCTION "dbo"."CLG_TR_GET_TRNAPPLN_STUDENT_DETAILS"(
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
    "acmS_SectionCode" varchar,
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
    "amcsT_BloodGroup" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_FLAG = 'S' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            (COALESCE(A."AMCST_FirstName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '')) AS "amcsT_FirstName",
            D."amcO_CourseName",
            D."amcO_Id",
            E."amB_Id",
            E."amB_BranchName",
            F."amsE_Id",
            F."amsE_SEMName",
            G."acmS_Id",
            G."acmS_SectionCode",
            H."asmaY_Id",
            H."asmaY_Year",
            A."amcsT_AdmNo",
            A."amcsT_emailId",
            A."amcsT_MobileNo",
            A."amcsT_PerStreet",
            A."amcsT_PerCity",
            A."amcsT_PerArea",
            A."amcsT_PerPincode",
            I."IVRMMC_CountryName" AS "ivrmmC_CountryName",
            J."IVRMMS_Name" AS "ivrmmS_Name",
            A."amcsT_FatherName",
            A."amcsT_MotherName",
            A."amcsT_StudentPhoto",
            A."amcsT_FatherOfficeAdd",
            J."ivrmmS_Id",
            A."amcsT_BloodGroup"
        FROM "CLG"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON B."AMCST_Id" = A."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS D ON D."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS E ON E."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS F ON F."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS G ON G."ACMS_Id" = B."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" AS H ON H."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" AS I ON I."IVRMMC_Id" = A."IVRMMC_Id"
        INNER JOIN "IVRM_Master_State" AS J ON J."IVRMMC_Id" = I."IVRMMC_Id" AND J."IVRMMS_Id" = A."AMCST_ConState"
        WHERE A."MI_Id" = p_MI_Id AND A."AMCST_Id" = p_AMCST_Id AND H."ASMAY_Id" = p_ASMAY_Id;
    ELSIF p_FLAG = 'N' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            (COALESCE(A."AMCST_FirstName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '') || ' ' || COALESCE(A."AMCST_MiddleName", '')) AS "amcsT_FirstName",
            D."amcO_CourseName",
            D."amcO_Id",
            E."amB_Id",
            E."amB_BranchName",
            F."amsE_Id",
            F."amsE_SEMName",
            NULL::bigint AS "acmS_Id",
            NULL::varchar AS "acmS_SectionCode",
            H."asmaY_Id",
            H."asmaY_Year",
            A."amcsT_AdmNo",
            A."amcsT_emailId",
            A."amcsT_MobileNo",
            A."amcsT_PerStreet",
            A."amcsT_PerCity",
            A."amcsT_PerArea",
            A."amcsT_PerPincode",
            I."IVRMMC_CountryName" AS "ivrmmC_CountryName",
            J."IVRMMS_Name" AS "ivrmmS_Name",
            A."amcsT_FatherName",
            A."amcsT_MotherName",
            A."amcsT_StudentPhoto",
            A."amcsT_FatherOfficeAdd",
            J."ivrmmS_Id",
            A."amcsT_BloodGroup"
        FROM "CLG"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_Master_Course" AS D ON D."AMCO_Id" = A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS E ON E."AMB_Id" = A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS F ON F."AMSE_Id" = A."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" AS H ON H."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "IVRM_Master_Country" AS I ON I."IVRMMC_Id" = A."IVRMMC_Id"
        INNER JOIN "IVRM_Master_State" AS J ON J."IVRMMC_Id" = I."IVRMMC_Id" AND J."IVRMMS_Id" = A."AMCST_ConState"
        WHERE A."MI_Id" = p_MI_Id AND A."AMCST_Id" = p_AMCST_Id;
    END IF;
    
    RETURN;
END;
$$;