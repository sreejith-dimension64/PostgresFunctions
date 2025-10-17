CREATE OR REPLACE FUNCTION "dbo"."Clg_Adm_Classwisestudentpromoteddetails"(
    "promotedyear" TEXT,
    "promotedcourse" TEXT,
    "promotedbranch" TEXT,
    "promotedsem" TEXT,
    "presentyear" TEXT,
    "presentcourse" TEXT,
    "presentbranch" TEXT,
    "miid" TEXT,
    "presentsem" TEXT,
    "presentsec" TEXT
)
RETURNS TABLE(
    "amcsT_Id" BIGINT,
    "amcO_CourseName" VARCHAR,
    "amsE_SEMName" VARCHAR,
    "amB_BranchName" VARCHAR,
    "amcsT_AdmNo" VARCHAR,
    "acysT_RollNo" VARCHAR,
    "asmaY_Id" BIGINT,
    "asmaY_Year" VARCHAR,
    "amcsT_FirstName" VARCHAR,
    "amcsT_MiddleName" VARCHAR,
    "amcsT_LastName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ca."AMCST_Id" AS "amcsT_Id",
        cc."AMCO_CourseName" AS "amcO_CourseName",
        cg."AMSE_SEMName" AS "amsE_SEMName",
        cd."AMB_BranchName" AS "amB_BranchName",
        ca."AMCST_AdmNo" AS "amcsT_AdmNo",
        cb."ACYST_RollNo" AS "acysT_RollNo",
        cb."ASMAY_Id" AS "asmaY_Id",
        cf."ASMAY_Year" AS "asmaY_Year",
        ca."AMCST_FirstName" AS "amcsT_FirstName",
        ca."AMCST_MiddleName" AS "amcsT_MiddleName",
        ca."AMCST_LastName" AS "amcsT_LastName"
    FROM "clg"."Adm_Master_College_Student" ca 
    INNER JOIN "CLG"."Adm_College_Yearly_Student" cb ON ca."AMCST_Id" = cb."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" cc ON cc."AMCO_Id" = cb."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" cd ON cd."AMB_Id" = cb."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" cg ON cg."AMSE_Id" = cb."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" ce ON ce."ACMS_Id" = cb."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" cf ON cf."ASMAY_Id" = cb."ASMAY_Id"
    WHERE ca."MI_Id" = "miid" 
        AND cb."ASMAY_Id" = "presentyear" 
        AND cb."AMCO_Id" = "presentcourse" 
        AND cb."AMB_Id" = "presentbranch"
        AND ca."AMCST_SOL" = 'S' 
        AND ca."AMCST_ActiveFlag" = 1 
        AND cb."ACYST_ActiveFlag" = 1 
        AND cb."AMSE_Id" = "presentsem" 
        AND cb."ACMS_Id" = "presentsec"
        AND cb."AMCST_Id" NOT IN (
            SELECT DISTINCT ca2."AMCST_Id"
            FROM "clg"."Adm_Master_College_Student" ca2 
            INNER JOIN "CLG"."Adm_College_Yearly_Student" cb2 ON ca2."AMCST_Id" = cb2."AMCST_Id"
            INNER JOIN "clg"."Adm_Master_Course" cc2 ON cc2."AMCO_Id" = cb2."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" cd2 ON cd2."AMB_Id" = cb2."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" cg2 ON cg2."AMSE_Id" = cb2."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" ce2 ON ce2."ACMS_Id" = cb2."ACMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" cf2 ON cf2."ASMAY_Id" = cb2."ASMAY_Id"
            WHERE cb2."ASMAY_Id" = "promotedyear" 
                AND cb2."AMCO_Id" = "promotedcourse" 
                AND cb2."AMB_Id" = "promotedbranch" 
                AND cb2."AMSE_Id" = "promotedsem"
                AND ca2."AMCST_SOL" = 'S' 
                AND ca2."AMCST_ActiveFlag" = 1 
                AND cb2."ACYST_ActiveFlag" = 1
        );
END;
$$;