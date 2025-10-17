CREATE OR REPLACE FUNCTION "dbo"."Clg_Get_Teacherwise_Subject_Details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCO_Id bigint,
    p_AMB_Id bigint,
    p_AMSE_Id bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "TeacherName" text,
    "AMCO_CourseName" text,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "AMSE_Id" bigint,
    "ISMS_SubjectName" text,
    "hrmeid" bigint,
    "role" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        g."ISMS_Id",
        (COALESCE(c."HRME_EmployeeFirstName",'') || ' ' || COALESCE(c."HRME_EmployeeMiddleName",'') || ' ' || COALESCE(c."HRME_EmployeeLastName",'')) AS "TeacherName",
        de."AMCO_CourseName",
        e."AMB_BranchName",
        f."AMSE_SEMName",
        f."AMSE_Id",
        g."ISMS_SubjectName",
        c."HRME_Id" AS "hrmeid",
        'SubjectTeacher'::text AS "role"
    FROM "clg"."Adm_College_Atten_Login_User" a
    INNER JOIN "clg"."Adm_College_Atten_Login_Details" b ON a."ACALU_Id" = b."ACALU_Id"
    INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = a."HRME_Id" AND c."HRME_ActiveFlag" = true
    INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "clg"."Adm_Master_Course" de ON de."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = b."ISMS_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND b."AMCO_Id" = p_AMCO_Id 
        AND b."AMB_Id" = p_AMB_Id 
        AND b."AMSE_Id" = p_AMSE_Id;
    
    RETURN;
END;
$$;