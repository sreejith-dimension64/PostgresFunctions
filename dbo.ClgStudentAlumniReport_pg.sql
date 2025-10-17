CREATE OR REPLACE FUNCTION "ClgStudentAlumniReport"(
    p_mi_id TEXT,
    p_asmay_id TEXT,
    p_amcst_id TEXT,
    p_amco_id TEXT,
    p_amb_id TEXT,
    p_amse_id TEXT
)
RETURNS TABLE(
    "ALCMST_Id" INTEGER,
    "ALCMST_RegistrationNo" VARCHAR,
    "Name" TEXT,
    "ACYST_Id" INTEGER,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ASMAY_Year" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_clg TEXT;
BEGIN
    v_clg := '
    SELECT a."ALCMST_Id",
           a."ALCMST_RegistrationNo",
           CONCAT(COALESCE(a."ALCMST_FirstName",''''),'''',COALESCE(a."ALCMST_MiddleName",''''),'''',COALESCE(a."ALCMST_LastName",'''')) as "Name",
           b."ACYST_Id",
           c."AMCO_CourseName",
           d."AMB_BranchName",
           e."AMSE_SEMName",
           f."ASMAY_Year"
    FROM "clg"."Alumni_College_Master_Student" a 
    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."ACMS_JOIN_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_JOIN_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_JOIN_Id"
    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id_Join"
    WHERE a."MI_Id" IN ' || p_mi_id || ' 
      AND c."AMCO_Id" = ' || p_amco_id || ' 
      AND d."AMB_Id" = ' || p_amb_id || ' 
      AND d."ASMAY_Id" = ' || p_asmay_id;

    RAISE NOTICE '%', v_clg;

    RETURN QUERY EXECUTE v_clg;
END;
$$;