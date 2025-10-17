CREATE OR REPLACE FUNCTION "dbo"."FeesCautionDepositCollection"(p_MI_Id bigint)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "PaidAmount" NUMERIC,
    "Balance" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        "ASMAY"."ASMAY_Year",
        SUM("FSS"."FSS_PaidAmount") AS "PaidAmount",
        SUM("FSS"."FSS_ToBePaid") AS "Balance"
    FROM "Fee_Student_Status" "FSS"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" 
        ON "FSS"."ASMAY_Id" = "ASMAY"."ASMAY_Id" 
        AND "FSS"."MI_Id" = "ASMAY"."MI_Id"
    WHERE "FSS"."MI_Id" = p_MI_Id 
        AND "FSS"."FMH_Id" IN (
            SELECT DISTINCT "FMH_Id" 
            FROM "Fee_Master_Head" 
            WHERE "MI_Id" = p_MI_Id 
                AND "FMH_FeeName" LIKE 'Caution Deposit%'
        )
    GROUP BY "ASMAY"."ASMAY_Year";

END;
$$;