CREATE OR REPLACE FUNCTION clg_Alumni_Student_Report(
    p_mi_id bigint,
    p_asmay_id text,
    p_AMCST_Id bigint
)
RETURNS TABLE(
    "ALCMST_Id" bigint,
    "Name" text,
    "AMCST_RegistrationNo" varchar,
    "AMB_BranchName" varchar,
    "AMCO_CourseName" varchar,
    "AMSE_SEMName" varchar,
    "ASMAY_Year" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        a."ALCMST_Id",
        CONCAT(a."ALCMST_FirstName", ' ', COALESCE(a."ALCMST_MiddleName", ''), ' ', a."ALCMST_LastName", ' ') as "Name",
        b."AMCST_RegistrationNo",
        c."AMB_BranchName",
        d."AMCO_CourseName",
        e."AMSE_SEMName",
        f."ASMAY_Year"
    FROM "clg"."Alumni_College_Master_Student" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b 
        ON b."AMCST_Id" = a."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" c 
        ON c."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Course" d 
        ON d."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e 
        ON e."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "Adm_School_M_Academic_Year" f 
        ON f."ASMAY_Id" = b."ASMAY_Id"
    WHERE a."MI_Id" = p_mi_id;

END;
$$;