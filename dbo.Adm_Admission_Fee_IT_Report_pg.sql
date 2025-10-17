CREATE OR REPLACE FUNCTION "dbo"."Adm_Admission_Fee_IT_Report"(
    p_ASMAY_Id varchar,
    p_MI_Id varchar,
    p_AMST_Id varchar
)
RETURNS TABLE (
    "Receivable" numeric,
    "Concession" numeric,
    "Collectionamount" numeric,
    "Adjusted" numeric,
    "Balance" numeric,
    "acdYear" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  
        SUM("FSS_TotalToBePaid") AS "Receivable", 
        SUM("FSS_ConcessionAmount") AS "Concession", 
        SUM("FSS_PaidAmount") AS "Collectionamount", 
        SUM("FSS_AdjustedAmount") AS "Adjusted", 
        SUM("FSS_ToBePaid") AS "Balance",
        MAX("Adm_School_M_Academic_Year"."ASMAY_Year") AS "acdYear" 
    FROM "Fee_Student_Status"  
    INNER JOIN "Adm_School_M_Academic_Year" 
        ON "Fee_Student_Status"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"  
    WHERE "Fee_Student_Status"."MI_Id" = p_MI_Id 
        AND "Fee_Student_Status"."AMST_Id" = p_AMST_Id 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_Id;
END;
$$;