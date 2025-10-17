CREATE OR REPLACE FUNCTION "dbo"."InstituwiseFeeCollectionNew"(
    "p_MI_Id" TEXT,
    "p_fromdate" VARCHAR(10),
    "p_todate" VARCHAR(10)
)
RETURNS TABLE(
    "MI_Id" INTEGER,
    "FYP_DOE" VARCHAR(10),
    "MI_Name" TEXT,
    "collected" NUMERIC,
    "ballance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "receivable" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
BEGIN
    "v_query" := 'SELECT DISTINCT "MI"."MI_Id", TO_CHAR("FYP"."FYP_DOE", ''DD/MM/YYYY'') AS "FYP_DOE", "MI"."MI_Name",
        (SUM(COALESCE("FSS"."FCSS_PaidAmount", 0)) - SUM(COALESCE("FSS"."FCSS_FineAmount", 0))) AS "collected",
        SUM(COALESCE("FSS"."FCSS_ToBePaid", 0)) AS "ballance",
        SUM(COALESCE("FSS"."FCSS_ConcessionAmount", 0)) AS "concession",
        SUM(COALESCE("FSS"."FCSS_WaivedAmount", 0)) AS "waived",
        SUM(COALESCE("FSS"."FCSS_RebateAmount", 0)) AS "rebate",
        SUM(COALESCE("FSS"."FCSS_FineAmount", 0)) AS "fine",
        SUM(COALESCE("FSS"."FCSS_CurrentYrCharges", 0)) AS "receivable"
    FROM "clg"."Fee_College_Student_Status" "FSS"
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" "FYPSS" ON "FYPSS"."AMCST_Id" = "FSS"."AMCST_Id" AND "FYPSS"."ASMAY_Id" = "FSS"."ASMAY_Id"
    INNER JOIN "CLG"."Fee_Y_Payment" "FYP" ON "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
    INNER JOIN "Master_Institution" "MI" ON "FSS"."MI_Id" = "MI"."MI_Id"
    WHERE ("MI"."MI_Id" IN (' || "p_MI_Id" || ') AND "FSS"."MI_Id" IN (' || "p_MI_Id" || '))
    AND CAST("FYP"."FYP_DOE" AS DATE) BETWEEN ''' || "p_fromdate" || ''' AND ''' || "p_todate" || '''
    GROUP BY "MI"."MI_Name", TO_CHAR("FYP"."FYP_DOE", ''DD/MM/YYYY'), "MI"."MI_Id"
    ORDER BY TO_CHAR("FYP"."FYP_DOE", ''DD/MM/YYYY'')';

    RETURN QUERY EXECUTE "v_query";
END;
$$;