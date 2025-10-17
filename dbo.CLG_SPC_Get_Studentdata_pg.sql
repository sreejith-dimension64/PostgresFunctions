CREATE OR REPLACE FUNCTION "dbo"."CLG_SPC_Get_Studentdata"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "studentName" TEXT,
    "amsT_AdmNo" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "asmC_SectionName" VARCHAR,
    "spccmH_Id" BIGINT,
    "spccmH_HouseName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "m"."AMCST_Id" AS "amsT_Id",
        COALESCE("n"."AMCST_FirstName", '') || ' ' || COALESCE("n"."AMCST_MiddleName", '') || ' ' || COALESCE("n"."AMCST_LastName", '') AS "studentName",
        "n"."AMCST_AdmNo" AS "amsT_AdmNo",
        "c"."AMCO_CourseName" AS "AMCO_CourseName",
        "s"."ACMS_SectionName" AS "asmC_SectionName",
        "hs"."SPCCMH_Id" AS "spccmH_Id",
        "h"."SPCCMH_HouseName" AS "spccmH_HouseName"
    FROM "CLG"."Adm_college_Yearly_Student" AS "m"
    INNER JOIN "SPC"."SPCC_Student_House_College" AS "hs" 
        ON "m"."ASMAY_Id" = "hs"."ASMAY_Id" 
        AND "hs"."SPCCMHC_ActiveFlag" = 1 
        AND "m"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_College_Student" AS "n" 
        ON "m"."AMCST_Id" = "n"."AMCST_Id" 
        AND "hs"."AMCST_Id" = "n"."AMCST_Id" 
        AND "n"."AMCST_SOL" = 'S' 
        AND "m"."ACYST_ActiveFlag" = 1 
        AND "n"."AMCST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" AS "c" 
        ON "m"."AMCO_Id" = "hs"."AMCO_Id" 
        AND "hs"."AMCO_Id" = "c"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "AMB" 
        ON "AMB"."AMB_Id" = "m"."AMB_Id" 
        AND "hs"."AMB_Id" = "m"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" 
        ON "AMSE"."AMSE_Id" = "m"."AMSE_Id" 
        AND "hs"."AMSE_Id" = "m"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" AS "s" 
        ON "m"."ACMS_Id" = "hs"."ACMS_Id" 
        AND "hs"."ACMS_Id" = "s"."ACMS_Id"
    INNER JOIN "SPC"."SPCC_Master_House" AS "h" 
        ON "h"."SPCCMH_Id" = "hs"."SPCCMH_Id"
    WHERE "n"."MI_Id" = "MI_Id" 
        AND "m"."ASMAY_Id" = "ASMAY_Id" 
        AND "m"."AMCO_Id" = "AMCO_Id" 
        AND "m"."ACMS_Id" = "ACMS_Id";
END;
$$;