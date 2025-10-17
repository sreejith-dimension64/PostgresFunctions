CREATE OR REPLACE FUNCTION "dbo"."getfeereciptformat"(
    "mi_id" BIGINT,
    "asmay_id" BIGINT,
    "fyp_id" BIGINT,
    "amst_id" BIGINT
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR,
    "FMSFH_Id" BIGINT,
    "FMSFH_Name" VARCHAR,
    "paidamount" NUMERIC,
    "ConcessionAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "new"."FMH_FeeName",
        "new"."FMSFH_Id",
        "new"."FMSFH_Name",
        SUM("new"."FTP_Paid_Amt") AS "paidamount",
        SUM(COALESCE("new"."ConcessionAmount", 0)) AS "ConcessionAmount"
    FROM (
        SELECT DISTINCT 
            H."FMH_FeeName",
            (SELECT DISTINCT b."FMSFH_Id" 
             FROM "Fee_Master_SpecialFeeHead_FeeHead" a 
             INNER JOIN "Fee_Master_SpecialFeeHead" b ON a."FMSFH_Id" = b."FMSFH_Id" 
             WHERE a."FMH_Id" = H."FMH_Id" 
             LIMIT 1) AS "FMSFH_Id",
            (SELECT DISTINCT "FMSFH_Name" 
             FROM "Fee_Master_SpecialFeeHead_FeeHead" a 
             INNER JOIN "Fee_Master_SpecialFeeHead" b ON a."FMSFH_Id" = b."FMSFH_Id" 
             WHERE a."FMH_Id" = H."FMH_Id" 
             LIMIT 1) AS "FMSFH_Name",
            (SELECT SUM(FSS."FTP_Paid_Amt") 
             FROM "Fee_T_Payment" FSS 
             INNER JOIN "Fee_Y_Payment_School_Student" SS ON SS."FYP_Id" = FSS."FYP_Id" 
             WHERE FSS."FTP_Id" = FTP."FTP_Id" 
             AND SS."AMST_Id" = "amst_id" 
             AND SS."ASMAY_Id" = "asmay_id" 
             AND SS."FYP_Id" = "fyp_id" 
             AND FSS."FTP_Paid_Amt" <> 0) AS "FTP_Paid_Amt",
            (SELECT SUM(S."FSS_ConcessionAmount") 
             FROM "fee_student_status" S 
             WHERE S."AMST_Id" = "amst_id" 
             AND S."ASMAY_Id" = "asmay_id" 
             AND S."FMA_Id" IN (SELECT "FMA_Id" FROM "Fee_T_Payment" WHERE "FYP_Id" = "fyp_id") 
             AND S."FMH_Id" = H."FMH_Id") AS "ConcessionAmount"
        FROM "Fee_Master_Head" H 
        LEFT JOIN "Fee_Master_Amount" MA ON MA."FMH_Id" = H."FMH_Id" AND H."MI_Id" = MA."MI_Id" 
        LEFT JOIN "Fee_T_Payment" FTP ON FTP."FMA_Id" = MA."FMA_Id" AND FTP."FYP_Id" = "fyp_id"
        WHERE H."MI_Id" = "mi_id" 
        AND MA."ASMAY_Id" = "asmay_id" 
        AND MA."FMCC_Id" IN (
            SELECT "FMCC_Id" 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = "asmay_id" 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" 
                FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" IN (
                    SELECT "ASMCL_Id" 
                    FROM "Adm_School_Y_Student" 
                    WHERE "ASMAY_Id" = "asmay_id" 
                    AND "AMST_Id" = "amst_id"
                )
            )
        ) 
        AND H."FMH_Id" IN (
            SELECT DISTINCT "FMH_Id" 
            FROM "fee_master_amount" 
            WHERE "fma_id" IN (
                SELECT "FMA_Id" 
                FROM "Fee_T_Payment" 
                WHERE "fyp_id" = "fyp_id"
            )
        )
    ) AS "new" 
    GROUP BY "new"."FMH_FeeName", "new"."FMSFH_Id", "new"."FMSFH_Name";

END;
$$;