CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STAFF_BRANCHWISE_SEMESTER"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@HRME_Id" BIGINT,
    "@AMB_Id" VARCHAR(20)
)
RETURNS TABLE(
    "AMSE_Id" BIGINT,
    "AMSE_SEMName" VARCHAR,
    "AMSE_SEMCode" VARCHAR,
    "AMSE_SEMOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
BEGIN
    v_dynamic := '
    SELECT DISTINCT a."AMSE_Id", a."AMSE_SEMName", a."AMSE_SEMCode", a."AMSE_SEMOrder" 
    FROM "CLG"."Adm_Master_Semester" a,
    "CLG"."Adm_College_AY_Course" b,
    "CLG"."Adm_College_AY_Course_Branch" c,
    "CLG"."Adm_College_AY_Course_Branch_Semester" d,
    "Adm_School_M_Academic_Year" e,
    "HR_Master_Employee" f,
    "CLG"."Adm_College_Atten_Login_User" g,
    "CLG"."Adm_College_Atten_Login_Details" h
    WHERE b."ACAYC_Id" = c."ACAYC_Id" 
    AND c."ACAYCB_Id" = d."ACAYCB_Id" 
    AND a."MI_Id" = g."MI_Id" 
    AND b."ACAYC_Id" = c."ACAYC_Id" 
    AND g."ASMAY_Id" = g."ASMAY_Id" 
    AND f."HRME_Id" = g."HRME_Id" 
    AND g."ACALU_Id" = h."ACALU_Id" 
    AND a."AMSE_Id" = h."AMSE_Id" 
    AND a."AMSE_ActiveFlg" = 1 
    AND a."MI_Id" = ' || "@MI_Id" || ' 
    AND g."ASMAY_Id" = ' || "@ASMAY_Id" || ' 
    AND g."HRME_Id" = ' || "@HRME_Id" || ' 
    AND c."AMB_Id" IN (' || "@AMB_Id" || ')';
    
    RETURN QUERY EXECUTE v_dynamic;
END;
$$;