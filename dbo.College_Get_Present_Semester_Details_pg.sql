CREATE OR REPLACE FUNCTION "dbo"."College_Get_Present_Semester_Details"(
    "p_MI_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_ASMAY_Id" TEXT
)
RETURNS TABLE(
    "amsE_Id" BIGINT,
    "amsE_SEMName" VARCHAR,
    "amsE_SEMOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "c"."AMSE_Id" AS "amsE_Id",
        "d"."AMSE_SEMName" AS "amsE_SEMName",
        "d"."AMSE_SEMOrder" AS "amsE_SEMOrder"
    FROM "clg"."Adm_College_AY_Course" "a"
    INNER JOIN "CLG"."Adm_College_AY_Course_Branch" "b" ON "a"."ACAYC_Id" = "b"."ACAYC_Id"
    INNER JOIN "clg"."Adm_College_AY_Course_Branch_Semester" "c" ON "c"."ACAYCB_Id" = "b"."ACAYCB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" "d" ON "d"."amse_id" = "c"."AMSE_Id"
    WHERE "a"."AMCO_Id" = "p_AMCO_Id"
        AND "a"."ASMAY_Id" = "p_ASMAY_Id"
        AND "b"."AMB_Id" = "p_AMB_Id"
        AND "a"."MI_Id" = "p_MI_Id"
        AND (CURRENT_TIMESTAMP BETWEEN "c"."ACAYCBS_SemStartDate" AND "c"."ACAYCBS_SemEndDate")
        AND "a"."ACAYC_ActiveFlag" = 1
        AND "b"."ACAYCB_ActiveFlag" = 1
        AND "c"."ACAYCBS_ActiveFlag" = 1
        AND "d"."AMSE_ActiveFlg" = 1
    ORDER BY "d"."AMSE_SEMOrder";
END;
$$;