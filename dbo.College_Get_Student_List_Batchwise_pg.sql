CREATE OR REPLACE FUNCTION "dbo"."College_Get_Student_List_Batchwise"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@ACMS_Id" TEXT,
    "@ACAB_Id" TEXT,
    "@ISMS_Id" TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "AMCST_FirstName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "ACYST_RollNo" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        a."amcst_id" AS "AMCST_Id",
        (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
        a."AMCST_AdmNo" AS "AMCST_AdmNo",
        a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
        b."ACYST_RollNo" AS "ACYST_RollNo"
    FROM "clg"."Adm_Master_College_Student" a
    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
    INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
    INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
    WHERE a."MI_Id" = "@MI_Id"
        AND b."ASMAY_Id" = "@ASMAY_Id"
        AND b."AMCO_Id" = "@AMCO_Id"
        AND b."AMB_Id" = "@AMB_Id"
        AND b."AMSE_Id" = "@AMSE_Id"
        AND b."ACMS_Id" = "@ACMS_Id"
        AND d."ASMAY_Id" = "@ASMAY_Id"
        AND d."AMCO_Id" = "@AMCO_Id"
        AND d."AMB_Id" = "@AMB_Id"
        AND d."AMSE_Id" = "@AMSE_Id"
        AND d."ACMS_Id" = "@ACMS_Id"
        AND d."ISMS_Id" = "@ISMS_Id"
        AND d."ACAB_Id" = "@ACAB_Id"
        AND a."AMCST_SOL" = 'S'
        AND a."AMCST_ActiveFlag" = 1
        AND b."ACYST_ActiveFlag" = 1;

END;
$$;