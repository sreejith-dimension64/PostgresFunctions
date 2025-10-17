CREATE OR REPLACE FUNCTION "dbo"."Chairman_Exm_passfail_count_allclass"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_EME_Id INT
)
RETURNS TABLE(
    "ASMCL_Order" INT,
    "ASMCL_ClassName" VARCHAR,
    "Pass" VARCHAR,
    "Fail" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH cte AS (
        SELECT DISTINCT 
            pvt."ASMCL_Order",
            pvt."ASMCL_ClassName",
            CASE WHEN pvt."pass" IS NULL THEN '' ELSE pvt."pass" END AS "Pass",
            CASE WHEN pvt."Fail" IS NULL THEN '' ELSE pvt."Fail" END AS "Fail"
        FROM (
            SELECT DISTINCT 
                "ASMCL_Order",
                "ASMCL_ClassName",
                "ESTMP_Result",
                COUNT("ESTMP_Result") AS "CountList"
            FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
            INNER JOIN "Adm_School_M_Class" "ASMC" 
                ON "ESMP"."MI_Id" = "ASMC"."MI_Id" 
                AND "ESMP"."ASMCL_Id" = "ASMC"."ASMCL_Id"
            WHERE "ESMP"."MI_Id" = p_MI_Id 
                AND "ESMP"."ASMAY_Id" = p_ASMAY_Id 
                AND "ESMP"."EME_Id" = p_EME_Id
            GROUP BY "ASMCL_Order", "ASMCL_ClassName", "ESTMP_Result"
            ORDER BY "ASMCL_Order"
            LIMIT 100
        ) a
        CROSS JOIN LATERAL (
            SELECT
                MAX(CASE WHEN a."ESTMP_Result" = 'pass' THEN a."CountList"::VARCHAR END) AS "pass",
                MAX(CASE WHEN a."ESTMP_Result" = 'fail' THEN a."CountList"::VARCHAR END) AS "Fail"
        ) pvt
        GROUP BY a."ASMCL_Order", a."ASMCL_ClassName", pvt."pass", pvt."Fail"
    )
    SELECT 
        cte."ASMCL_Order",
        cte."ASMCL_ClassName",
        cte."Pass",
        cte."Fail"
    FROM cte 
    ORDER BY cte."ASMCL_Order";
END;
$$;