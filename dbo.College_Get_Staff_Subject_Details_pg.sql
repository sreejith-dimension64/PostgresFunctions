CREATE OR REPLACE FUNCTION "dbo"."College_Get_Staff_Subject_Details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_AMCST_Id" TEXT,
    "p_ISMS_Id" TEXT
)
RETURNS TABLE(
    "staffname" TEXT,
    "HRME_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE(c."HRME_EmployeeFirstName",'') || ' ' || COALESCE(c."HRME_EmployeeMiddleName",'') || ' ' || COALESCE(c."HRME_EmployeeLastName",'')) as "staffname",
        c."HRME_Id"
    FROM "clg"."Adm_College_Atten_Login_User" a
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" b ON a."ACALU_Id" = b."ACALU_Id"
    INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = a."HRME_Id"
    INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "clg"."Adm_Master_Course" de ON de."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = b."ISMS_Id"
    WHERE a."ASMAY_Id" = "p_ASMAY_Id"
        AND b."AMCO_Id" = "p_AMCO_Id"
        AND b."AMB_Id" = "p_AMB_Id"
        AND b."AMSE_Id" = "p_AMSE_Id"
        AND b."ISMS_Id" = "p_ISMS_Id";
END;
$$;