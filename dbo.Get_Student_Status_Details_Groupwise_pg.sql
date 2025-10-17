CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_Details_Groupwise"(
    "p_MI_Id" VARCHAR(10),
    "p_ASMAY_Id" VARCHAR(10),
    "p_FromDate" VARCHAR(10),
    "p_Todate" VARCHAR(10)
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "FMG_Id" BIGINT,
    "FCMAS_Id" BIGINT,
    "FMH_Id" BIGINT,
    "FTI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FCSS_ToBePaid" NUMERIC,
    "FCSS_PaidAmount" NUMERIC,
    "FCSS_ConcessionAmount" NUMERIC,
    "FCSS_NetAmount" NUMERIC,
    "FCSS_FineAmount" NUMERIC,
    "FCSS_RefundAmount" NUMERIC,
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FMG_GroupName" VARCHAR,
    "FCSS_CurrentYrCharges" NUMERIC,
    "FCSS_TotalCharges" NUMERIC,
    "FCSS_OBArrearAmount" NUMERIC,
    "FCSS_WaivedAmount" NUMERIC,
    "FMH_Order" INTEGER,
    "FYP_Id" BIGINT,
    "FTCP_PaidAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
BEGIN
    "v_query" := 'SELECT a."AMCST_Id", a."FMG_Id", a."FCMAS_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", 
        a."FCSS_ToBePaid", a."FCSS_PaidAmount", a."FCSS_ConcessionAmount",
        a."FCSS_NetAmount", a."FCSS_FineAmount", a."FCSS_RefundAmount",
        g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FCSS_CurrentYrCharges", 
        a."FCSS_TotalCharges", a."FCSS_OBArrearAmount", a."FCSS_WaivedAmount",
        g."FMH_Order", j."FYP_Id", k."FTCP_PaidAmount"
    FROM "CLG"."Fee_College_Student_Status" a,
        "Fee_Group_Login_Previledge" b,
        "clg"."Fee_College_Master_Amount" c,
        "CLG"."Fee_College_Master_Amount_Semesterwise" d,
        "CLG"."Adm_College_Yearly_Student" e,
        "Fee_Master_Group" f,
        "Fee_Master_Head" g,
        "Fee_T_Installment" h,
        "clg"."Fee_Y_Payment_College_Student" i,
        "clg"."Fee_Y_Payment" j,
        "clg"."Fee_T_College_Payment" k
    WHERE a."MI_Id" = ' || "p_MI_Id" || ' 
        AND b."MI_ID" = a."MI_Id" 
        AND c."MI_Id" = a."MI_Id" 
        AND d."MI_Id" = a."MI_Id" 
        AND f."MI_Id" = a."MI_Id" 
        AND g."MI_Id" = a."MI_Id"
        AND h."MI_ID" = a."MI_Id"
        AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || '
        AND CAST(j."FYP_ReceiptDate" AS DATE) BETWEEN TO_DATE(''' || "p_FromDate" || ''', ''DD/MM/YYYY'') 
            AND TO_DATE(''' || "p_Todate" || ''', ''DD/MM/YYYY'')
        AND b."FMG_ID" = a."FMG_Id" 
        AND b."FMH_Id" = a."FMH_Id"
        AND c."FMG_Id" = a."FMG_Id" 
        AND c."FMH_Id" = a."FMH_Id"
        AND i."AMCST_Id" = a."AMCST_Id" 
        AND j."FYP_Id" = i."FYP_Id"
        AND c."FCMA_ActiveFlg" = 1 
        AND d."FCMA_Id" = c."FCMA_Id" 
        AND d."FCMAS_Id" = a."FCMAS_Id" 
        AND k."FCMAS_Id" = a."FCMAS_Id" 
        AND k."FCMAS_Id" = d."FCMAS_Id" 
        AND k."fyp_id" = i."fyp_id"
        AND e."ACYST_ActiveFlag" = 1 
        AND e."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
        AND e."AMCO_Id" = c."AMCO_Id" 
        AND e."AMB_Id" = c."AMB_Id"
        AND f."FMG_ActiceFlag" = 1 
        AND f."FMG_Id" = a."FMG_Id"
        AND g."FMH_ActiveFlag" = 1 
        AND g."FMH_Id" = a."FMH_Id" 
        AND h."FTI_Id" = a."FTI_Id"
    GROUP BY a."AMCST_Id", a."FMG_Id", a."FCMAS_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", 
        a."FCSS_ToBePaid", a."FCSS_PaidAmount", a."FCSS_ConcessionAmount", a."FCSS_NetAmount", 
        a."FCSS_FineAmount", a."FCSS_RefundAmount",
        g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FCSS_CurrentYrCharges", 
        a."FCSS_TotalCharges", a."FCSS_OBArrearAmount", a."FCSS_WaivedAmount",
        g."FMH_Order", j."FYP_Id", k."FTCP_PaidAmount"
    ORDER BY g."FMH_Order"';
    
    RETURN QUERY EXECUTE "v_query";
    
END;
$$;