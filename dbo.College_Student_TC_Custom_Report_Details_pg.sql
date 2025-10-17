CREATE OR REPLACE FUNCTION "dbo"."College_Student_TC_Custom_Report_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCST_Id TEXT,
    p_TEMPORPERTC TEXT,
    p_FLAG TEXT
)
RETURNS TABLE (
    "amcsT_Id" BIGINT,
    "studentName" TEXT,
    "studentname" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "ACSTC_TCNO" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_DOB" DATE,
    "AMCST_Sex" TEXT,
    "AMCST_FatherName" TEXT,
    "AMCST_MotherName" TEXT,
    "nationality" TEXT,
    "religion" TEXT,
    "AMCST_Date" DATE,
    "caste" TEXT,
    "AMCST_DOBin_words" TEXT,
    "langustudies" TEXT,
    "electivestudies" TEXT,
    "ACSTC_Qual_PromotionFlag" TEXT,
    "feedue" TEXT,
    "ACSTC_LastAttendedDate" DATE,
    "ACSTC_TCApplicationDate" DATE,
    "ACSTC_TCIssueDate" DATE,
    "ACSTC_Conduct" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ACTIVEFLAG TEXT;
    v_YACTIVEFLAG TEXT;
    v_SOLFLAG TEXT;
BEGIN

    IF p_TEMPORPERTC = 'temp' THEN
        v_ACTIVEFLAG := '1';
        v_YACTIVEFLAG := '1';
        v_SOLFLAG := 'T';
    ELSE
        v_ACTIVEFLAG := '0';
        v_YACTIVEFLAG := '0';
        v_SOLFLAG := 'L';
    END IF;

    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            (CASE WHEN C."AMCST_FirstName" IS NULL OR C."AMCST_FirstName" = '' THEN '' ELSE C."AMCST_FirstName" END ||
             CASE WHEN C."AMCST_MiddleName" IS NULL OR C."AMCST_MiddleName" = '' THEN '' ELSE ' ' || C."AMCST_MiddleName" END ||
             CASE WHEN C."AMCST_LastName" IS NULL OR C."AMCST_LastName" = '' THEN '' ELSE ' ' || C."AMCST_LastName" END) AS "studentName",
            NULL::TEXT AS "studentname",
            NULL::TEXT AS "AMCO_CourseName",
            NULL::TEXT AS "AMB_BranchName",
            NULL::TEXT AS "AMSE_SEMName",
            NULL::TEXT AS "ACMS_SectionName",
            NULL::TEXT AS "AMCST_RegistrationNo",
            NULL::TEXT AS "ACSTC_TCNO",
            NULL::TEXT AS "AMCST_AdmNo",
            NULL::DATE AS "AMCST_DOB",
            NULL::TEXT AS "AMCST_Sex",
            NULL::TEXT AS "AMCST_FatherName",
            NULL::TEXT AS "AMCST_MotherName",
            NULL::TEXT AS "nationality",
            NULL::TEXT AS "religion",
            NULL::DATE AS "AMCST_Date",
            NULL::TEXT AS "caste",
            NULL::TEXT AS "AMCST_DOBin_words",
            NULL::TEXT AS "langustudies",
            NULL::TEXT AS "electivestudies",
            NULL::TEXT AS "ACSTC_Qual_PromotionFlag",
            NULL::TEXT AS "feedue",
            NULL::DATE AS "ACSTC_LastAttendedDate",
            NULL::DATE AS "ACSTC_TCApplicationDate",
            NULL::DATE AS "ACSTC_TCIssueDate",
            NULL::TEXT AS "ACSTC_Conduct"
        FROM "CLG"."Adm_College_Student_TC" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" AND A."AMCO_Id" = B."AMCO_Id" 
            AND A."AMB_Id" = B."AMB_Id" AND A."AMSE_Id" = B."AMSE_Id" AND A."ACMS_Id" = B."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = A."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = A."ACMS_Id"
        WHERE A."ASMAY_Id"::TEXT = p_ASMAY_Id AND C."AMCST_SOL" = v_SOLFLAG AND C."AMCST_ActiveFlag"::TEXT = v_ACTIVEFLAG 
            AND B."ACYST_ActiveFlag"::TEXT = v_ACTIVEFLAG AND B."ASMAY_Id"::TEXT = p_ASMAY_Id;

    ELSIF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            NULL::TEXT AS "studentName",
            (CASE WHEN C."AMCST_FirstName" IS NULL OR C."AMCST_FirstName" = '' THEN '' ELSE C."AMCST_FirstName" END ||
             CASE WHEN C."AMCST_MiddleName" IS NULL OR C."AMCST_MiddleName" = '' THEN '' ELSE ' ' || C."AMCST_MiddleName" END ||
             CASE WHEN C."AMCST_LastName" IS NULL OR C."AMCST_LastName" = '' THEN '' ELSE ' ' || C."AMCST_LastName" END) AS "studentname",
            D."AMCO_CourseName",
            E."AMB_BranchName",
            F."AMSE_SEMName",
            G."ACMS_SectionName",
            C."AMCST_RegistrationNo",
            NULL::TEXT AS "ACSTC_TCNO",
            NULL::TEXT AS "AMCST_AdmNo",
            NULL::DATE AS "AMCST_DOB",
            NULL::TEXT AS "AMCST_Sex",
            NULL::TEXT AS "AMCST_FatherName",
            NULL::TEXT AS "AMCST_MotherName",
            NULL::TEXT AS "nationality",
            NULL::TEXT AS "religion",
            NULL::DATE AS "AMCST_Date",
            NULL::TEXT AS "caste",
            NULL::TEXT AS "AMCST_DOBin_words",
            NULL::TEXT AS "langustudies",
            NULL::TEXT AS "electivestudies",
            NULL::TEXT AS "ACSTC_Qual_PromotionFlag",
            NULL::TEXT AS "feedue",
            NULL::DATE AS "ACSTC_LastAttendedDate",
            NULL::DATE AS "ACSTC_TCApplicationDate",
            NULL::DATE AS "ACSTC_TCIssueDate",
            NULL::TEXT AS "ACSTC_Conduct"
        FROM "CLG"."Adm_College_Student_TC" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" AND A."AMCO_Id" = B."AMCO_Id" 
            AND A."AMB_Id" = B."AMB_Id" AND A."AMSE_Id" = B."AMSE_Id" AND A."ACMS_Id" = B."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = A."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = A."ACMS_Id"
        WHERE A."ASMAY_Id"::TEXT = p_ASMAY_Id AND C."AMCST_SOL" = v_SOLFLAG AND C."AMCST_ActiveFlag"::TEXT = v_ACTIVEFLAG 
            AND B."ACYST_ActiveFlag"::TEXT = v_ACTIVEFLAG AND B."ASMAY_Id"::TEXT = p_ASMAY_Id
            AND A."AMCST_Id"::TEXT = p_AMCST_Id AND B."AMCST_Id"::TEXT = p_AMCST_Id;

    ELSIF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMCST_Id" AS "amcsT_Id",
            NULL::TEXT AS "studentName",
            (CASE WHEN C."AMCST_FirstName" IS NULL OR C."AMCST_FirstName" = '' THEN '' ELSE C."AMCST_FirstName" END ||
             CASE WHEN C."AMCST_MiddleName" IS NULL OR C."AMCST_MiddleName" = '' THEN '' ELSE ' ' || C."AMCST_MiddleName" END ||
             CASE WHEN C."AMCST_LastName" IS NULL OR C."AMCST_LastName" = '' THEN '' ELSE ' ' || C."AMCST_LastName" END) AS "studentname",
            D."AMCO_CourseName",
            E."AMB_BranchName",
            F."AMSE_SEMName",
            G."ACMS_SectionName",
            C."AMCST_RegistrationNo",
            A."ACSTC_TCNO",
            C."AMCST_AdmNo",
            C."AMCST_DOB"::DATE,
            C."AMCST_Sex",
            COALESCE(C."AMCST_FatherName", '') || ' ' || COALESCE(C."AMCST_FatherSurname", '') AS "AMCST_FatherName",
            COALESCE(C."AMCST_MotherName", '') || ' ' || COALESCE(C."AMCST_MotherSurname", '') AS "AMCST_MotherName",
            H."IVRMMC_Nationality" AS "nationality",
            COALESCE(I."IVRMMR_Name", '') AS "religion",
            C."AMCST_Date"::DATE,
            COALESCE(J."IMC_CasteName", '') AS "caste",
            C."AMCST_DOBin_words",
            A."ACSTC_LanguageStudied" AS "langustudies",
            A."ACSTC_ElectivesStudied" AS "electivestudies",
            A."ACSTC_Qual_PromotionFlag",
            A."AcSTC_FeePaid" AS "feedue",
            A."ACSTC_LastAttendedDate"::DATE,
            A."ACSTC_TCApplicationDate"::DATE,
            A."ACSTC_TCIssueDate"::DATE,
            A."ACSTC_Conduct"
        FROM "CLG"."Adm_College_Student_TC" A 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" B ON A."AMCST_Id" = B."AMCST_Id" AND A."AMCO_Id" = B."AMCO_Id" 
            AND A."AMB_Id" = B."AMB_Id" AND A."AMSE_Id" = B."AMSE_Id" AND A."ACMS_Id" = B."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = A."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = A."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = A."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = A."ACMS_Id"
        INNER JOIN "IVRM_Master_Country" H ON H."IVRMMC_Id" = C."AMCST_Nationality"
        LEFT JOIN "IVRM_Master_Religion" I ON I."IVRMMR_Id" = C."IVRMMR_Id"
        LEFT JOIN "IVRM_Master_Caste" J ON J."IMC_Id" = C."IMC_Id"
        WHERE A."ASMAY_Id"::TEXT = p_ASMAY_Id AND C."AMCST_SOL" = v_SOLFLAG AND C."AMCST_ActiveFlag"::TEXT = v_ACTIVEFLAG 
            AND B."ACYST_ActiveFlag"::TEXT = v_ACTIVEFLAG AND B."ASMAY_Id"::TEXT = p_ASMAY_Id
            AND A."AMCST_Id"::TEXT = p_AMCST_Id AND B."AMCST_Id"::TEXT = p_AMCST_Id;

    END IF;

    RETURN;

END;
$$;