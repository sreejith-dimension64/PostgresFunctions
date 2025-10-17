CREATE OR REPLACE FUNCTION "dbo"."Clg_IVRM_Interaction_StudentList"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@AMCO_Id" VARCHAR(20),
    "@AMB_Id" VARCHAR(20),
    "@AMSE_Id" VARCHAR(20),
    "@ACMS_Id" VARCHAR(20)
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "studentName" TEXT,
    "AMCST_AdmNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMS"."AMCST_Id",
        "AMS"."AMCO_Id",
        "AMS"."AMB_Id",
        "AMS"."AMSE_Id",
        "AMCE"."ACMS_Id",
        (CASE WHEN "ADM"."AMCST_FirstName" IS NULL OR "ADM"."AMCST_FirstName" = '' THEN '' ELSE "ADM"."AMCST_FirstName" END ||
         CASE WHEN "ADM"."AMCST_MiddleName" IS NULL OR "ADM"."AMCST_MiddleName" = '' OR "ADM"."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMCST_MiddleName" END ||
         CASE WHEN "ADM"."AMCST_LastName" IS NULL OR "ADM"."AMCST_LastName" = '' OR "ADM"."AMCST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMCST_LastName" END) AS "studentName",
        "ADM"."AMCST_AdmNo"
    FROM "clg"."Adm_Master_College_Student" "ADM"
    INNER JOIN "clg"."Adm_College_Yearly_Student" "AMS" ON "AMS"."AMCST_Id" = "ADM"."AMCST_Id" AND "AMS"."ACYST_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Academic_Year" "AMY" ON "AMY"."ASMAY_Id" = "AMS"."ASMAY_Id" AND "AMY"."ASMAY_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_Master_Course" "AMC" ON "AMC"."AMCO_Id" = "AMS"."AMCO_Id" AND "AMC"."AMCO_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "AMS"."AMB_Id" AND "AMB"."AMB_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_Master_Semester" "AMSC" ON "AMSC"."AMSE_Id" = "AMS"."AMSE_Id" AND "AMSC"."AMSE_ActiveFlg" = 1
    INNER JOIN "clg"."Adm_College_Master_Section" "AMCE" ON "AMCE"."ACMS_Id" = "AMS"."ACMS_Id" AND "AMCE"."ACMS_ActiveFlag" = 1
    WHERE "ADM"."AMCST_ActiveFlag" = 1 
        AND "ADM"."AMCST_SOL" = 'S' 
        AND "ADM"."MI_Id" = "@MI_Id" 
        AND "AMS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "AMS"."AMCO_Id"::VARCHAR = "@AMCO_Id" 
        AND "AMS"."AMB_Id"::VARCHAR = "@AMB_Id" 
        AND "AMS"."AMSE_Id"::VARCHAR = "@AMSE_Id" 
        AND "AMCE"."ACMS_Id"::VARCHAR = "@ACMS_Id"
    ORDER BY "studentName";
END;
$$;