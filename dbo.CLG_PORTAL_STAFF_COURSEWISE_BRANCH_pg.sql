CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STAFF_COURSEWISE_BRANCH"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@HRME_Id" BIGINT,
    "@AMCO_Id" BIGINT
)
RETURNS TABLE(
    "AMB_Id" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "AMB_ActiveFlag" INTEGER,
    "AMB_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMB_Id",
        a."AMB_BranchName",
        a."AMB_BranchCode",
        a."AMB_ActiveFlag",
        a."AMB_Order" 
    FROM "CLG"."Adm_Master_Branch" a,
        "CLG"."Adm_College_AY_Course" b,
        "CLG"."Adm_College_AY_Course_Branch" c,
        "Adm_School_M_Academic_Year" d,
        "HR_Master_Employee" e,
        "CLG"."Adm_College_Atten_Login_User" f,
        "CLG"."Adm_College_Atten_Login_Details" g
    WHERE a."MI_Id" = f."MI_Id" 
        AND b."ACAYC_Id" = c."ACAYC_Id" 
        AND f."ASMAY_Id" = f."ASMAY_Id" 
        AND e."HRME_Id" = f."HRME_Id" 
        AND f."ACALU_Id" = g."ACALU_Id" 
        AND a."AMB_Id" = g."AMB_Id" 
        AND a."AMB_ActiveFlag" = 1 
        AND a."MI_Id" = "@MI_Id" 
        AND d."ASMAY_Id" = "@ASMAY_Id" 
        AND f."HRME_Id" = "@HRME_Id" 
        AND b."AMCO_Id" = "@AMCO_Id";
END;
$$;