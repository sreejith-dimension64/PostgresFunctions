CREATE OR REPLACE FUNCTION "dbo"."FeeDateWiseCollection" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text,
    p_FromDate varchar(10),
    p_ToDate varchar(10)
)
RETURNS TABLE (
    "FMH_Id" bigint,
    "FMH_FeeName" varchar,
    "FYP_DOE" timestamp,
    "PaidAmount" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Sqlquery text;
    v_content text;
BEGIN
    IF p_fromdate != '' AND p_todate != '' THEN
        v_content := 'CAST("FYP"."FYP_DOE" AS DATE) BETWEEN ''' || p_FromDate || ''' AND ''' || p_ToDate || '''';
    END IF;

    v_Sqlquery := 'SELECT "FCSS"."FMH_Id", "FMH"."FMH_FeeName", "FYP"."FYP_DOE", SUM("FCSS"."FCSS_PaidAmount") AS "PaidAmount"
FROM "CLG"."Fee_College_Master_Amount" "FCMA"
INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."MI_Id" = ' || p_MI_Id::text || ' AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = ' || p_MI_Id::text || ' AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = ' || p_MI_Id::text || '
INNER JOIN "dbo"."Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCSS"."FMH_Id" AND "FMH"."MI_Id" = ' || p_MI_Id::text || '
INNER JOIN "CLG"."Fee_Y_Payment" "FYP" ON "FYP"."MI_Id" = ' || p_MI_Id::text || ' AND "FYP"."ASMAY_Id" = ' || p_ASMAY_Id::text || '
WHERE "FCSS"."MI_Id" = ' || p_MI_Id::text || ' AND "FCSS"."ASMAY_Id" = ' || p_ASMAY_Id::text || ' AND ' || v_content || '
AND "FCSS"."FMG_Id" IN (' || p_FMG_Id || ') AND "FCSS"."FMH_Id" IN (' || p_FMH_Id || ') 
GROUP BY "FCSS"."FMH_Id", "FMH"."FMH_FeeName", "FYP"."FYP_DOE" 
HAVING SUM("FCSS"."FCSS_PaidAmount") > 0';

    RETURN QUERY EXECUTE v_Sqlquery;

END;
$$;