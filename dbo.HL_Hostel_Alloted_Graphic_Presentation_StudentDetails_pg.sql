CREATE OR REPLACE FUNCTION "dbo"."HL_Hostel_Alloted_Graphic_Presentation_StudentDetails"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "HLMH_Id" TEXT,
    "HLMF_Id" TEXT,
    "HLMRCA_Id" TEXT,
    "HRMRM_Id" TEXT,
    "Type" VARCHAR(10)
)
RETURNS TABLE(
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ClassName" TEXT,
    "SectionName" TEXT,
    "AllotmentDate" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "Sqldynamic" TEXT;
BEGIN

IF("Type" = 'C') THEN

    "Sqldynamic" := '
    SELECT DISTINCT COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''') AS "StudentName",
    "AMCST_AdmNo",
    "AMCO_CourseName",
    "AMB_BranchName",
    "AMSE_SEMName",
    TO_CHAR("HLHSALTC_AllotmentDate", ''DD/MM/YYYY'') AS "HLHSALTC_AllotmentDate"
    FROM "HL_Master_Hostel" "HML"
    INNER JOIN "HL_Master_Floor" "HMF" ON "HMF"."HLMH_Id" = "HML"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "HMR" ON "HMR"."HLMH_Id" = "HMF"."HLMH_Id" AND "HMR"."HLMF_Id" = "HMF"."HLMF_Id"
    INNER JOIN "HL_Master_Room_Category" "HMRC" ON "HMRC"."HLMRCA_Id" = "HMR"."HLMRCA_Id"
    INNER JOIN "HL_Hostel_Student_Allot_College" "AC" ON "AC"."HLMH_Id" = "HMF"."HLMH_Id" AND "AC"."HLMRCA_Id" = "HMRC"."HLMRCA_Id" AND "AC"."HRMRM_Id" = "HMR"."HRMRM_Id"
    AND "HLHSALTC_ActiveFlag" = 1 AND ("HLHSALTC_VacateFlg" = 0 OR "HLHSALTC_VacateFlg" IS NULL) 
    AND "AC"."MI_Id"::TEXT IN (' || "MI_Id" || ') 
    AND "AC"."ASMAY_Id"::TEXT IN (' || "ASMAY_Id" || ')
    AND "AC"."HLMH_Id"::TEXT IN (' || "HLMH_Id" || ') 
    AND "AC"."HLMRCA_Id"::TEXT IN (' || "HLMRCA_Id" || ') 
    AND "AC"."HRMRM_Id"::TEXT IN (' || "HRMRM_Id" || ')
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "ACYS"."ASMAY_Id" = "AC"."ASMAY_Id" AND "ACYS"."AMCST_Id" = "AC"."AMCST_Id" AND "ACYS"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" "AMC" ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "ACYS"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "ACYS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AMCS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" AND "AMCS"."AMCST_SOL" = ''S'' AND "AMCS"."AMCST_ActiveFlag" = 1
    WHERE "HML"."MI_Id"::TEXT IN (' || "MI_Id" || ') 
    AND "HML"."HLMH_Id"::TEXT IN (' || "HLMH_Id" || ') 
    AND "HMR"."HLMF_Id"::TEXT IN (' || "HLMF_Id" || ') 
    AND "HMR"."HLMRCA_Id"::TEXT IN (' || "HLMRCA_Id" || ')
    AND "HMR"."HRMRM_Id"::TEXT IN (' || "HRMRM_Id" || ')';

    RETURN QUERY EXECUTE "Sqldynamic";

ELSIF("Type" = 'S') THEN

    "Sqldynamic" := '
    SELECT DISTINCT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
    "AMST_AdmNo",
    "ASMCL_ClassName",
    "ASMC_SectionName",
    TO_CHAR("HLHSALT_AllotmentDate", ''DD/MM/YYYY'') AS "HLHSALT_AllotmentDate"
    FROM "HL_Master_Hostel" "HML"
    INNER JOIN "HL_Master_Floor" "HMF" ON "HMF"."HLMH_Id" = "HML"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "HMR" ON "HMR"."HLMH_Id" = "HMF"."HLMH_Id" AND "HMR"."HLMF_Id" = "HMF"."HLMF_Id"
    INNER JOIN "HL_Master_Room_Category" "HMRC" ON "HMRC"."HLMRCA_Id" = "HMR"."HLMRCA_Id"
    INNER JOIN "HL_Hostel_Student_Allot" "AC" ON "AC"."HLMH_Id" = "HMF"."HLMH_Id" AND "AC"."HLMRCA_Id" = "HMRC"."HLMRCA_Id" AND "AC"."HRMRM_Id" = "HMR"."HRMRM_Id" 
    AND "HLHSALT_ActiveFlag" = 1 AND ("HLHSALT_VacateFlg" = 0 OR "HLHSALT_VacateFlg" IS NULL) 
    AND "AC"."MI_Id"::TEXT IN (' || "MI_Id" || ') 
    AND "AC"."ASMAY_Id"::TEXT IN (' || "ASMAY_Id" || ') 
    AND "AC"."HLMH_Id"::TEXT IN (' || "HLMH_Id" || ') 
    AND "AC"."HLMRCA_Id"::TEXT IN (' || "HLMRCA_Id" || ') 
    AND "AC"."HRMRM_Id"::TEXT IN (' || "HRMRM_Id" || ')
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "AC"."ASMAY_Id" AND "ASYS"."AMST_Id" = "AC"."AMST_Id" AND "ASYS"."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id"
    INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" = ''S'' AND "AMS"."AMST_ActiveFLag" = 1
    WHERE "HML"."MI_Id"::TEXT IN (' || "MI_Id" || ') 
    AND "HML"."HLMH_Id"::TEXT IN (' || "HLMH_Id" || ') 
    AND "HMR"."HLMF_Id"::TEXT IN (' || "HLMF_Id" || ') 
    AND "HMR"."HLMRCA_Id"::TEXT IN (' || "HLMRCA_Id" || ') 
    AND "HMR"."HRMRM_Id"::TEXT IN (' || "HRMRM_Id" || ')';

    RETURN QUERY EXECUTE "Sqldynamic";

END IF;

END;
$$;