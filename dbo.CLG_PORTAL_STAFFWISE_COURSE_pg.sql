CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STAFFWISE_COURSE"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@HRME_Id" BIGINT
)
RETURNS TABLE(
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "AMCO_CourseCode" VARCHAR,
    "AMCO_CourseFlag" VARCHAR,
    "AMCO_ActiveFlag" INTEGER,
    "AMCO_Order" INTEGER
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMCO_Id",
        a."AMCO_CourseName",
        a."AMCO_CourseCode",
        a."AMCO_CourseFlag",
        a."AMCO_ActiveFlag",
        a."AMCO_Order" 
    FROM "CLG"."Adm_Master_Course" a,
        "Adm_School_M_Academic_Year" b,
        "HR_Master_Employee" c,
        "CLG"."Adm_College_Atten_Login_User" d,
        "CLG"."Adm_College_Atten_Login_Details" e
    WHERE a."MI_Id" = d."MI_Id" 
        AND b."ASMAY_Id" = d."ASMAY_Id" 
        AND c."HRME_Id" = d."HRME_Id" 
        AND d."ACALU_Id" = e."ACALU_Id" 
        AND a."AMCO_Id" = e."AMCO_Id" 
        AND a."AMCO_ActiveFlag" = 1 
        AND a."MI_Id" = "@MI_Id" 
        AND d."ASMAY_Id" = "@ASMAY_Id" 
        AND d."HRME_Id" = "@HRME_Id";
END;
$$;