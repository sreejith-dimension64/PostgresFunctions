CREATE OR REPLACE FUNCTION "dbo"."GET_Fees_totalPortal"(
    "p_AMST_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_GROUPID" TEXT
)
RETURNS TABLE(
    "ASMAY_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "FSS_NetAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_FineAmount" NUMERIC,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
BEGIN
    "v_query" := 'SELECT ASMAY."ASMAY_Id", ASMAY."ASMAY_Year", 
        SUM("FSS_NetAmount") AS "FSS_NetAmount",
        SUM("FSS_ConcessionAmount") AS "FSS_ConcessionAmount",
        SUM("FSS_FineAmount") AS "FSS_FineAmount",
        SUM("FSS_ToBePaid") AS "FSS_ToBePaid",
        SUM("FSS_PaidAmount") AS "FSS_PaidAmount"
    FROM "Fee_student_status"
    INNER JOIN "Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = "Fee_student_status"."ASMAY_Id"
    WHERE "AMST_Id" IN (' || "p_AMST_Id" || ')
    AND ASMAY."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
    AND "FMG_Id" IN (' || "p_GROUPID" || ')
    GROUP BY ASMAY."ASMAY_Id", ASMAY."ASMAY_Year"';
    
    RETURN QUERY EXECUTE "v_query";
    
END;
$$;