CREATE OR REPLACE FUNCTION "dbo"."Fee_refundable_amount_proc"(
    p_MI_Id bigint,
    p_userid bigint,
    p_ASMAY_ID bigint,
    p_AMST_ID bigint,
    p_FR_RefundNo text
)
RETURNS TABLE(
    "FR_RefundNo" text,
    "amsT_ID" bigint,
    "fmH_FeeName" varchar,
    "fmA_Amount" numeric,
    "fR_Date" timestamp,
    "fR_RefundNo" text,
    "fR_RefundAmount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."FR_RefundNo"::text AS "FR_RefundNo",
        a."AMST_ID" AS "amsT_ID",
        c."FMH_FeeName" AS "fmH_FeeName",
        b."FSS_PaidAmount" AS "fmA_Amount",
        e."FR_Date" AS "fR_Date",
        e."FR_RefundNo"::text AS "fR_RefundNo",
        e."FR_RefundAmount" AS "fR_RefundAmount"
    FROM "Adm_School_Y_Student" AS a
    INNER JOIN "Fee_Student_Status" AS b 
        ON a."AMST_Id" = b."AMST_Id" 
        AND a."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "Fee_Master_Head" AS c 
        ON c."FMH_Id" = b."FMH_Id"
    INNER JOIN "Fee_T_Installment" AS d 
        ON d."FTI_Id" = b."FTI_Id"
    INNER JOIN "Fee_Refund" AS e 
        ON e."AMST_Id" = b."AMST_Id" 
        AND e."ASMAY_Id" = b."ASMAY_Id" 
        AND b."FMG_Id" = e."FMG_Id" 
        AND b."FMH_Id" = e."FMH_Id" 
        AND b."FTI_Id" = e."FTI_Id"
    WHERE b."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_ID 
        AND e."FR_RefundFlag" = 'true' 
        AND e."User_Id" = p_userid 
        AND b."AMST_Id" = p_AMST_ID 
        AND e."FR_RefundNo" = p_FR_RefundNo;
END;
$$;