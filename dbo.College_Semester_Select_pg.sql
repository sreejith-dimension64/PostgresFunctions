CREATE OR REPLACE FUNCTION "dbo"."College_Semester_Select"(
    p_ASMAY_Id bigint,
    p_MI_Id bigint,
    p_amco_ids text,
    p_amb_ids text
)
RETURNS TABLE (
    "AMSE_Id" bigint,
    "AMSE_SEMName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec text;
BEGIN
    v_sqlexec := '
    SELECT DISTINCT a."AMSE_Id", a."AMSE_SEMName"
    FROM "clg"."Adm_Master_Semester" a,
         "clg"."Adm_College_AY_Course" b,
         "clg"."Adm_College_AY_Course_Branch" c,
         "clg"."Adm_College_AY_Course_Branch_Semester" d
    WHERE a."MI_Id" = ' || p_MI_Id::varchar || ' 
      AND a."AMSE_ActiveFlg" = true
      AND b."MI_Id" = ' || p_MI_Id::varchar || '
      AND b."ASMAY_Id" = ' || p_ASMAY_Id::varchar || '
      AND b."ACAYC_ActiveFlag" = true
      AND b."AMCO_Id" IN (' || p_amco_ids || ')
      AND c."ACAYC_Id" = b."ACAYC_Id"
      AND c."MI_Id" = ' || p_MI_Id::varchar || '
      AND c."AMB_Id" IN (' || p_amb_ids || ')
      AND c."ACAYCB_ActiveFlag" = true
      AND d."MI_Id" = ' || p_MI_Id::varchar || '
      AND d."ACAYCB_Id" = c."ACAYCB_Id"
      AND d."AMSE_Id" = a."AMSE_Id"
      AND d."ACAYCBS_ActiveFlag" = true';

    RETURN QUERY EXECUTE v_sqlexec;
END;
$$;