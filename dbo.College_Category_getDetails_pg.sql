CREATE OR REPLACE FUNCTION "dbo"."College_Category_getDetails" (
    p_mi_id bigint
)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS $$
DECLARE
    ref1 refcursor := 'ref1';
    ref2 refcursor := 'ref2';
    ref3 refcursor := 'ref3';
    ref4 refcursor := 'ref4';
    ref5 refcursor := 'ref5';
BEGIN
    OPEN ref1 FOR
    SELECT "ASMAY_Year" 
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_mi_id AND "Is_Active" = 1
    ORDER BY "ASMAY_Order";
    RETURN NEXT ref1;

    OPEN ref2 FOR
    SELECT "AMCO_CourseName" 
    FROM "clg"."Adm_Master_Course"
    WHERE "MI_Id" = p_mi_id AND "AMCO_ActiveFlag" = 1 
    ORDER BY "AMCO_Order";
    RETURN NEXT ref2;

    OPEN ref3 FOR
    SELECT "AMB_BranchName" 
    FROM "clg"."Adm_Master_Branch"
    WHERE "MI_Id" = p_mi_id AND "AMB_ActiveFlag" = 1 
    ORDER BY "AMB_Order";
    RETURN NEXT ref3;

    OPEN ref4 FOR
    SELECT "AMSE_SEMName" 
    FROM "clg"."Adm_Master_Semester"
    WHERE "MI_Id" = p_mi_id AND "AMSE_ActiveFlg" = 1 
    ORDER BY "AMSE_SEMOrder";
    RETURN NEXT ref4;

    OPEN ref5 FOR
    SELECT "ACQ_QuotaName" 
    FROM "clg"."Adm_College_Quota"
    WHERE "MI_Id" = p_mi_id 
    ORDER BY "ACQ_Id";
    RETURN NEXT ref5;

    RETURN;
END;
$$;