CREATE OR REPLACE FUNCTION "College_Admission_Register_Report_New"(
    "mi_id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "column" TEXT
)
RETURNS VOID AS $$
DECLARE
    "gender_" VARCHAR(20);
    "NEWGENDERMALE" TEXT;
    "NEWGENDERFEMALE" TEXT;
    "NEWGENDEROTHERSMALE" TEXT;
    "NEWGENDER" TEXT;
    "sql" TEXT;
BEGIN

    IF "amb_id" = '0' THEN

        "sql" := 'SELECT DISTINCT ' || "column" || ' FROM "clg"."Adm_Master_College_Student" b
        INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id" = b."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id" = b."ACQC_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" Z ON Z."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "clg"."Adm_College_Student_Guardian" ga ON ga."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id" = b."AMCST_Nationality"
        LEFT OUTER JOIN "ivrm_MASTER_STATE" coS ON coS."IVRMMS_Id" = b."AMCST_perstate"
        LEFT OUTER JOIN "IVRM_Master_Caste" ca ON ca."IMC_Id" = b."IMC_Id"
        LEFT OUTER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = ca."IMCC_Id" AND cc."IMCC_Id" = b."IMCC_Id"
        LEFT OUTER JOIN "IVRM_Master_Religion" ra ON ra."IVRMMR_Id" = b."IVRMMR_Id"
        WHERE b."MI_Id" = ' || "mi_id" || ' AND Z."ASMAY_Id" = ' || "asmay_id" || ' AND Z."AMCO_Id" IN (' || "amco_id" || ')
        AND Z."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || "mi_id" || ' AND "AMB_ActiveFlag" = 1)
        AND Z."AMSE_ID" IN (' || "amse_id" || ') AND b."amcst_sol" = ''S'' AND b."amcst_activeflag" = 1';

        EXECUTE "sql";

    ELSE

        "sql" := 'SELECT DISTINCT ' || "column" || ' FROM "clg"."Adm_Master_College_Student" b
        INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id" = b."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id" = b."ACQC_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" Z ON Z."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "clg"."Adm_College_Student_Guardian" ga ON ga."AMCST_Id" = b."AMCST_Id"
        LEFT OUTER JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id" = b."AMCST_Nationality"
        LEFT OUTER JOIN "ivrm_MASTER_STATE" coS ON coS."IVRMMS_Id" = b."AMCST_perstate"
        LEFT OUTER JOIN "IVRM_Master_Caste" ca ON ca."IMC_Id" = b."IMC_Id"
        LEFT OUTER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = ca."IMCC_Id" AND cc."IMCC_Id" = b."IMCC_Id"
        LEFT OUTER JOIN "IVRM_Master_Religion" ra ON ra."IVRMMR_Id" = b."IVRMMR_Id"
        WHERE b."MI_Id" = ' || "mi_id" || ' AND Z."ASMAY_Id" = ' || "asmay_id" || ' AND Z."AMCO_Id" IN (' || "amco_id" || ')
        AND Z."AMB_ID" IN (' || "amb_id" || ') AND Z."AMSE_ID" IN (' || "amse_id" || ') AND b."amcst_sol" = ''S'' AND b."amcst_activeflag" = 1';

        EXECUTE "sql";
        RAISE NOTICE '%', "sql";

    END IF;

END;
$$ LANGUAGE plpgsql;