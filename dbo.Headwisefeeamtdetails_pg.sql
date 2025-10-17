CREATE OR REPLACE FUNCTION "dbo"."Headwisefeeamtdetails"(
    p_MI_ID VARCHAR(100),
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "ASMAY_Id" INTEGER,
    "FMH_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "tobepaid" NUMERIC,
    "paid" NUMERIC,
    "Pending" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT DISTINCT "ASMAY"."ASMAY_Id", "FMH"."FMH_Id", "ASMAY"."ASMAY_Year", "FMH"."FMH_FeeName", SUM("FSS"."FSS_CurrentYrCharges") AS tobepaid, SUM("FSS"."FSS_PaidAmount") AS paid, SUM("FSS"."FSS_Tobepaid") AS Pending
    FROM "Fee_Master_Amount" "FMA"
    INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."MI_Id" = "FMA"."MI_Id" AND "FMA"."FMA_Id" = "FSS"."FMA_Id"
    INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = "FSS"."MI_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "FSS"."ASMAY_Id"
    WHERE "FSS"."MI_Id" = ' || p_MI_ID || ' AND "FSS"."ASMAY_ID" IN (' || p_ASMAY_Id || ') AND "FSS"."AMST_Id" IN (' || p_AMST_Id || ')
    AND "FSS"."FSS_ActiveFlag" = 1 AND "ASMAY"."ASMAY_ActiveFlag" = 1 AND "FMH"."FMH_ActiveFlag" = 1
    GROUP BY "ASMAY"."ASMAY_Year", "FMH"."FMH_FeeName", "ASMAY"."ASMAY_Id", "FMH"."FMH_Id"
    ORDER BY "ASMAY"."ASMAY_Year"';
    
    RETURN QUERY EXECUTE v_query;
END;
$$;