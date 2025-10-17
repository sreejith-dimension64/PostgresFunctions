CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_FEE_DETAILS"(
    p_AMCST_ID BIGINT,
    p_ASMAY_Id BIGINT,
    p_mi_id BIGINT,
    p_type VARCHAR(20)
)
RETURNS TABLE (
    "FEE_HEAD" VARCHAR,
    "PAYMENT_OPTION" VARCHAR,
    "Receivable" NUMERIC,
    "Concession" NUMERIC,
    "Collectionamount" NUMERIC,
    "Adjusted" NUMERIC,
    "Balance" NUMERIC,
    "RECEIVABLE" NUMERIC,
    "CONCESSION" NUMERIC,
    "COLLECTION" NUMERIC,
    "ADJUSTMENT" NUMERIC,
    "BALANCE" NUMERIC,
    "FCSS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'overall' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "FEE_HEAD",
            NULL::VARCHAR AS "PAYMENT_OPTION",
            SUM("FCSS_TotalCharges") AS "Receivable",
            SUM("FCSS_ConcessionAmount") AS "Concession",
            SUM("FCSS_PaidAmount") AS "Collectionamount",
            SUM("FCSS_AdjustedAmount") AS "Adjusted",
            SUM("FCSS_ToBePaid") AS "Balance",
            NULL::NUMERIC AS "RECEIVABLE",
            NULL::NUMERIC AS "CONCESSION",
            NULL::NUMERIC AS "COLLECTION",
            NULL::NUMERIC AS "ADJUSTMENT",
            NULL::NUMERIC AS "BALANCE",
            NULL::BIGINT AS "FCSS_Id"
        FROM "CLG"."Fee_College_Student_Status"
        INNER JOIN "Adm_School_M_Academic_Year" ON "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "CLG"."Fee_College_Student_Status"."MI_Id" = "Fee_Master_Terms_FeeHeads"."MI_Id" 
            AND "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "CLG"."Fee_College_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        WHERE "CLG"."Fee_College_Student_Status"."MI_Id" = p_mi_id 
            AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = p_AMCST_ID 
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_Id;

    ELSIF p_type = 'detailed' THEN
        RETURN QUERY
        SELECT DISTINCT 
            UPPER("Fee_Master_Head"."FMH_FeeName") AS "FEE_HEAD",
            UPPER("Fee_T_Installment"."FTI_Name") AS "PAYMENT_OPTION",
            NULL::NUMERIC AS "Receivable",
            NULL::NUMERIC AS "Concession",
            NULL::NUMERIC AS "Collectionamount",
            NULL::NUMERIC AS "Adjusted",
            NULL::NUMERIC AS "Balance",
            "CLG"."Fee_College_Student_Status"."FCSS_TotalCharges" AS "RECEIVABLE",
            "CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount" AS "CONCESSION",
            "CLG"."Fee_College_Student_Status"."FCSS_PaidAmount" AS "COLLECTION",
            "CLG"."Fee_College_Student_Status"."FCSS_AdjustedAmount" AS "ADJUSTMENT",
            "CLG"."Fee_College_Student_Status"."FCSS_ToBePaid" AS "BALANCE",
            "CLG"."Fee_College_Student_Status"."FCSS_Id"
        FROM "CLG"."Fee_College_Student_Status"
        INNER JOIN "Adm_School_M_Academic_Year" ON "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "Fee_Master_Head" ON "CLG"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "CLG"."Fee_College_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
        WHERE "CLG"."Fee_College_Student_Status"."MI_Id" = p_mi_id 
            AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = p_AMCST_ID 
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."Fee_College_Student_Status"."FCSS_CurrentYrCharges" > 0;

    END IF;

    RETURN;

END;
$$;