CREATE OR REPLACE FUNCTION "dbo"."College_Studentconcession_Report" (
    "amay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "asms_id" TEXT,
    "user_id" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE (
    "regno" VARCHAR,
    "admno" VARCHAR,
    "amse_semname" TEXT,
    "dateofjoin" VARCHAR,
    "studentname" TEXT,
    "paid" NUMERIC,
    "ACQ_QuotaName" VARCHAR,
    "AMCST_MobileNo" VARCHAR,
    "AMCST_ConStreet" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "AMCST_RegistrationNo"::VARCHAR AS "regno", 
        "AMCST_AdmNo"::VARCHAR AS "admno",  
        ("amco_coursename" || ' ' || "amb_branchname" || ' ' || "amse_semname")::TEXT AS "amse_semname", 
        TO_CHAR("amcst_date", 'DD/MM/YYYY')::VARCHAR AS "dateofjoin",
        (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '' THEN '' ELSE "AMCST_FirstName" END || 
         CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_MiddleName" END ||
         CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_LastName" END)::TEXT AS "studentname",
        SUM("FCSS_ConcessionAmount")::NUMERIC AS "paid",  
        "ACQ_QuotaName"::VARCHAR,
        "AMCST_MobileNo"::VARCHAR,
        "AMCST_ConStreet"::VARCHAR
    FROM "clg"."Adm_College_Yearly_Student" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "clg"."Fee_College_Student_Status" g ON g."AMCST_Id" = a."AMCST_Id"
    INNER JOIN "clg"."Adm_College_Quota" k ON k."ACQ_Id" = b."ACQ_Id"
    WHERE "FCSS_ConcessionAmount" > 0
    GROUP BY 
        "AMCST_FirstName",
        "AMCST_MiddleName",
        "AMCST_LastName",
        "AMCST_RegistrationNo",
        "AMCST_AdmNo",
        "amco_coursename",
        "amb_branchname",
        "amse_semname",
        "amcst_date",
        "ACQ_QuotaName",
        "AMCST_MobileNo",
        "AMCST_ConStreet";

END;
$$;