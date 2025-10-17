CREATE OR REPLACE FUNCTION "dbo"."GET_DEPUTATION_WEEKLY_PERIOD_COUNT_COLLAGE"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "TPCOUNT" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT "NEW1"."HRME_Id", SUM("NEW1"."PCOUNT") AS "TPCOUNT" 
    FROM (
        SELECT DISTINCT "NEW"."HRME_Id", "NEW"."TTMP_Id", SUM("NEW"."PCOUNT") AS "PCOUNT" 
        FROM (
            SELECT DISTINCT 
                "D"."HRME_Id",
                "D"."TTMP_Id",
                "D"."TTMD_Id",
                COUNT(DISTINCT "D"."TTMP_Id") AS "PCOUNT"
            FROM "dbo"."TT_Final_Generation_Detailed_College" "D"
            INNER JOIN "dbo"."TT_Final_Generation" "FG" ON "FG"."TTFG_Id" = "D"."TTFG_Id"
            INNER JOIN "dbo"."TT_Master_Period" "MC" ON "MC"."TTMP_Id" = "D"."TTMP_Id"
            WHERE "FG"."MI_Id" = p_MI_Id 
                AND "FG"."ASMAY_Id" = p_ASMAY_Id
                AND "FG"."MI_Id" = p_MI_Id
            GROUP BY "D"."HRME_Id", "D"."TTMP_Id", "D"."TTMD_Id"
        ) AS "NEW" 
        GROUP BY "NEW"."HRME_Id", "NEW"."TTMP_Id"
    ) AS "NEW1" 
    GROUP BY "NEW1"."HRME_Id" 
    ORDER BY "NEW1"."HRME_Id";
END;
$$;