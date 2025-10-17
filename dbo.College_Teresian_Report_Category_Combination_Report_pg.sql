CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Report_Category_Combination_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT
)
RETURNS TABLE(
    "category" VARCHAR,
    "boys" BIGINT,
    "girls" BIGINT,
    "total" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "d"."ACQC_CategoryName" AS "category",
        SUM("d"."m_s") AS "boys",
        SUM("d"."F_S") AS "girls",
        (SUM("d"."F_S") + SUM("d"."m_s")) AS "total"
    FROM (
        SELECT 
            "d"."ACQC_CategoryName",
            0::BIGINT AS "m_s",
            COUNT(*)::BIGINT AS "F_S"
        FROM "clg"."Adm_Master_College_Student" "a"
        LEFT JOIN "clg"."Adm_College_Quota" "c" ON "c"."ACQ_Id" = "a"."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" "d" ON "d"."ACQC_Id" = "a"."ACQC_Id"
        INNER JOIN "clg"."Adm_Master_Course" "e" ON "e"."AMCO_Id" = "a"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "g" ON "g"."AMSE_Id" = "a"."AMSE_Id"
        WHERE "a"."AMCO_Id" = "p_AMCO_Id"
            AND "a"."AMSE_Id" = "p_AMSE_Id"
            AND "a"."AMCST_Sex" = 'Female'
            AND "a"."ASMAY_Id" = "p_ASMAY_Id"
            AND "a"."MI_Id" = "p_MI_Id"
            AND "a"."AMCST_SOL" = 'S'
            AND "a"."AMCST_ActiveFlag" = 1
        GROUP BY "d"."ACQC_CategoryName"

        UNION ALL

        SELECT 
            "d"."ACQC_CategoryName",
            COUNT(*)::BIGINT AS "m_s",
            0::BIGINT AS "F_S"
        FROM "clg"."Adm_Master_College_Student" "a"
        LEFT JOIN "clg"."Adm_College_Quota" "c" ON "c"."ACQ_Id" = "a"."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" "d" ON "d"."ACQC_Id" = "a"."ACQC_Id"
        INNER JOIN "clg"."Adm_Master_Course" "e" ON "e"."AMCO_Id" = "a"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "f" ON "f"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "g" ON "g"."AMSE_Id" = "a"."AMSE_Id"
        WHERE "a"."AMCO_Id" = "p_AMCO_Id"
            AND "a"."AMSE_Id" = "p_AMSE_Id"
            AND "a"."AMCST_Sex" = 'Male'
            AND "a"."ASMAY_Id" = "p_ASMAY_Id"
            AND "a"."MI_Id" = "p_MI_Id"
            AND "a"."AMCST_SOL" = 'S'
            AND "a"."AMCST_ActiveFlag" = 1
        GROUP BY "d"."ACQC_CategoryName"
    ) "d"
    GROUP BY "d"."ACQC_CategoryName"
    ORDER BY "category"
    LIMIT 100;
END;
$$;