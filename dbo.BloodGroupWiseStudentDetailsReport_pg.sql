CREATE OR REPLACE FUNCTION "dbo"."BloodGroupWiseStudentDetailsReport"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_IDs TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_IDs TEXT,
    p_blood_IDs TEXT
)
RETURNS TABLE(
    "address" TEXT,
    "name" TEXT,
    "usn" VARCHAR,
    "rollno" VARCHAR,
    "bloodgroup" VARCHAR,
    "admno" VARCHAR,
    "dob" TIMESTAMP,
    "fathername" VARCHAR,
    "occupation" VARCHAR,
    "gender" VARCHAR,
    "mobno" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := '
    SELECT 
    (CASE WHEN "AMCST_PerStreet" IS NULL OR "AMCST_PerStreet" = '''' THEN '' '' ELSE "AMCST_PerStreet" END || 
     CASE WHEN "AMCST_PerArea" IS NULL OR "AMCST_PerArea" = '' '' OR "AMCST_PerArea" = ''0'' THEN '' '' ELSE '','' || "AMCST_PerArea" END || 
     CASE WHEN "AMCST_PerCity" IS NULL OR "AMCST_PerCity" = '' '' OR "AMCST_PerCity" = ''0'' THEN '''' ELSE '' ,'' || "AMCST_PerCity" END) AS address,
    (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN '''' ELSE "AMCST_FirstName" END || 
     CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_MiddleName" END || 
     CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS name,
    a."AMCST_RegistrationNo" AS usn,
    b."ACYST_RollNo" AS rollno,
    COALESCE(a."AMCST_BloodGroup", ''NA'') AS bloodgroup,
    a."AMCST_AdmNo" AS admno,
    a."AMCST_DOB" AS dob,
    a."AMCST_FatherName" AS fathername,
    a."AMCST_FatherOccupation" AS occupation,
    a."AMCST_Sex" AS gender,
    a."AMCST_MobileNo" AS mobno 
    FROM "clg"."Adm_Master_College_Student" a
    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" f ON f."ACMS_Id" = b."ACMS_Id"
    WHERE b."AMCO_Id" = ' || p_AMCO_Id || ' 
    AND b."AMSE_Id" = ' || p_AMSE_Id || ' 
    AND b."ASMAY_Id" = ' || p_ASMAY_Id || ' 
    AND b."AMB_Id" IN (' || p_AMB_IDs || ') 
    AND b."ACMS_Id" IN (' || p_ACMS_IDs || ') 
    AND a."mi_id" = ' || p_MI_Id || ' 
    AND (a."AMCST_BloodGroup" IN (' || p_blood_IDs || ') OR a."AMCST_BloodGroup" IS NULL) 
    AND a."amcst_sol" = ''S'' 
    AND a."AMCST_ActiveFlag" = 1 
    AND b."ACYST_ActiveFlag" = 1';

    RETURN QUERY EXECUTE v_sql;
END;
$$;