CREATE OR REPLACE FUNCTION "dbo"."Chairman_Exm_passfail_count_allsection"(
    "@MI_Id" integer,
    "@ASMAY_Id" integer,
    "@EME_Id" integer,
    "@ASMCL_Id" integer
)
RETURNS TABLE(
    "section" VARCHAR,
    "Pass" VARCHAR,
    "Fail" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH cte AS (
        SELECT DISTINCT 
            "ASMC_SectionName" as section,
            (CASE WHEN "pass" IS NULL THEN '' ELSE "pass"::VARCHAR END) AS "Pass",
            (CASE WHEN "Fail" IS NULL THEN '' ELSE "Fail"::VARCHAR END) AS "Fail"
        FROM (
            SELECT DISTINCT 
                "ASMC_SectionName",
                "ESTMP_Result",
                COUNT("ESTMP_Result") AS "CountList"
            FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
            INNER JOIN "Adm_School_M_Class" "ASMC" 
                ON "ESMP"."MI_Id" = "ASMC"."MI_Id" 
                AND "ESMP"."ASMCL_Id" = "ASMC"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "ASMS" 
                ON "ESMP"."MI_Id" = "ASMS"."MI_Id" 
                AND "ESMP"."ASMS_Id" = "ASMS"."ASMS_Id"
            WHERE "ESMP"."MI_Id" = "@MI_Id" 
                AND "ESMP"."ASMAY_Id" = "@ASMAY_Id" 
                AND "ESMP"."EME_Id" = "@EME_Id"
                AND "ESMP"."ASMCL_Id" = "@ASMCL_Id"
            GROUP BY "ASMC_SectionName", "ESTMP_Result"
            LIMIT 100
        ) a
        CROSS JOIN LATERAL (
            SELECT 
                SUM(CASE WHEN "ESTMP_Result" = 'pass' THEN "CountList" ELSE 0 END)::VARCHAR AS "pass",
                SUM(CASE WHEN "ESTMP_Result" = 'fail' THEN "CountList" ELSE 0 END)::VARCHAR AS "Fail"
            FROM (SELECT a."ASMC_SectionName", a."ESTMP_Result", a."CountList") sub
            WHERE sub."ASMC_SectionName" = a."ASMC_SectionName"
        ) aspvt
    )
    SELECT cte.section, cte."Pass", cte."Fail" FROM cte;
END;
$$;