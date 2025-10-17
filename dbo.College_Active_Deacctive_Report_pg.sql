CREATE OR REPLACE FUNCTION "dbo"."College_Active_Deacctive_Report"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT
)
RETURNS TABLE(
    "activateddate" VARCHAR(10),
    "deactivateddate" VARCHAR(10),
    "activatedreason" VARCHAR,
    "deactivatedreason" VARCHAR,
    "amcsT_Id" BIGINT,
    "studentname" TEXT,
    "admno" VARCHAR,
    "regno" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        COALESCE(TO_CHAR("h"."ACSDE_ActivatedDate", 'DD/MM/YYYY'), '')::VARCHAR(10) AS "activateddate",
        COALESCE(TO_CHAR("h"."ACSDE_DeactivatedDate", 'DD/MM/YYYY'), '')::VARCHAR(10) AS "deactivateddate",
        "h"."ACSDE_ActivatedReason" AS "activatedreason",
        "h"."ACSDE_DeactivatedReason" AS "deactivatedreason",
        "b"."amcst_id" AS "amcsT_Id",
        (COALESCE("b"."AMCST_FirstName", '') || ' ' || COALESCE("b"."AMCST_MiddleName", '') || ' ' || COALESCE("b"."AMCST_LastName", '')) AS "studentname",
        "b"."AMCST_AdmNo" AS "admno",
        "b"."AMCST_RegistrationNo" AS "regno"
    FROM "clg"."Adm_College_Yearly_Student" "a"
    INNER JOIN "CLG"."Adm_Master_College_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
    INNER JOIN "clg"."Adm_Master_Course" "d" ON "d"."AMCO_Id" = "a"."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" "e" ON "e"."AMB_Id" = "a"."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" "f" ON "f"."AMSE_Id" = "a"."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" "g" ON "g"."ACMS_Id" = "a"."ACMS_Id"
    INNER JOIN "clg"."Adm_College_Student_Deactivate" "h" ON "h"."AMCST_Id" = "a"."AMCST_Id" 
        AND "h"."AMCO_Id" = "a"."AMCO_Id" 
        AND "h"."AMB_Id" = "a"."AMB_Id" 
        AND "h"."AMSE_Id" = "a"."AMSE_Id"
        AND "h"."ACMS_Id" = "a"."ACMS_Id" 
        AND "h"."ASMAY_Id" = "a"."ASMAY_Id"
    WHERE "a"."ASMAY_Id" = "@ASMAY_Id" 
        AND "a"."AMCO_Id" = "@AMCO_Id" 
        AND "a"."AMB_Id" = "@AMB_Id" 
        AND "a"."AMSE_Id" = "@AMSE_Id" 
        AND "a"."ACMS_Id" = "@ACMS_Id" 
        AND "a"."ACYST_ActiveFlag" = 1
        AND "b"."AMCST_ActiveFlag" = 1 
        AND "h"."ASMAY_Id" = "@ASMAY_Id" 
        AND "h"."AMCO_Id" = "@AMCO_Id" 
        AND "h"."AMB_Id" = "@AMB_Id" 
        AND "h"."AMSE_Id" = "@AMSE_Id" 
        AND "h"."ACMS_Id" = "@ACMS_Id";
END;
$$;