CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_Details_Groupwise_updated"(
    "MI_Id" VARCHAR(10),
    "ASMAY_Id" VARCHAR(10),
    "FromDate" VARCHAR(10),
    "Todate" VARCHAR(10),
    "type" VARCHAR(10)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "FMG_Id" BIGINT,
    "FMA_Id" BIGINT,
    "FMH_Id" BIGINT,
    "FTI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_NetAmount" NUMERIC,
    "FSS_FineAmount" NUMERIC,
    "FSS_RefundAmount" NUMERIC,
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FMG_GroupName" VARCHAR,
    "FSS_CurrentYrCharges" NUMERIC,
    "FSS_OBArrearAmount" NUMERIC,
    "FSS_WaivedAmount" NUMERIC,
    "FMH_Order" INTEGER,
    "FYP_Id" BIGINT,
    "FTP_Paid_Amt" NUMERIC,
    "FMT_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF("type" = 'G') THEN
    
        RETURN QUERY
        SELECT a."AMST_Id", a."FMG_Id", a."FMA_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", a."FSS_ToBePaid", a."FSS_PaidAmount", a."FSS_ConcessionAmount",
            a."FSS_NetAmount", a."FSS_FineAmount", a."FSS_RefundAmount",
            g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FSS_CurrentYrCharges", a."FSS_OBArrearAmount", a."FSS_WaivedAmount",
            g."FMH_Order", j."FYP_Id", k."FTP_Paid_Amt", NULL::VARCHAR AS "FMT_Name"
        FROM "Fee_Student_Status" a
        INNER JOIN "Fee_Group_Login_Previledge" b ON b."FMG_Id" = a."FMG_Id" AND b."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_Master_Amount" c ON c."FMG_Id" = a."FMG_Id" AND c."FMH_Id" = a."FMH_Id" AND c."FTI_Id" = a."FTI_Id"
        INNER JOIN "Adm_School_Y_Student" e ON e."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "Fee_Master_Group" f ON f."FMG_Id" = a."FMG_Id"
        INNER JOIN "Fee_Master_Head" g ON g."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_T_Installment" h ON h."FTI_Id" = a."FTI_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" i ON i."AMST_Id" = a."AMST_Id"
        INNER JOIN "Fee_Y_Payment" j ON j."FYP_Id" = i."FYP_Id"
        INNER JOIN "Fee_T_Payment" k ON k."FYP_Id" = j."FYP_Id"
        WHERE a."MI_Id" = "MI_Id"::BIGINT 
            AND a."ASMAY_Id" = "ASMAY_Id"::BIGINT
            AND j."FYP_Date"::DATE BETWEEN TO_DATE("FromDate", 'DD/MM/YYYY') AND TO_DATE("Todate", 'DD/MM/YYYY')
            AND e."AMAY_ActiveFlag" = 1 
            AND e."ASMAY_Id" = "ASMAY_Id"::BIGINT
            AND f."FMG_ActiceFlag" = 1 
            AND g."FMH_ActiveFlag" = 1
        GROUP BY a."AMST_Id", a."FMG_Id", a."FMA_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", a."FSS_ToBePaid", a."FSS_PaidAmount", a."FSS_ConcessionAmount",
            a."FSS_NetAmount", a."FSS_FineAmount", a."FSS_RefundAmount",
            g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FSS_CurrentYrCharges", a."FSS_OBArrearAmount", a."FSS_WaivedAmount",
            g."FMH_Order", j."FYP_Id", k."FTP_Paid_Amt";
    
    ELSIF("type" = 'T') THEN
    
        RETURN QUERY
        SELECT a."AMST_Id", a."FMG_Id", a."FMA_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", a."FSS_ToBePaid", a."FSS_PaidAmount", a."FSS_ConcessionAmount",
            a."FSS_NetAmount", a."FSS_FineAmount", a."FSS_RefundAmount",
            g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FSS_CurrentYrCharges", a."FSS_OBArrearAmount", a."FSS_WaivedAmount",
            g."FMH_Order", j."FYP_Id", k."FTP_Paid_Amt", m."FMT_Name"
        FROM "Fee_Student_Status" a
        INNER JOIN "Fee_Group_Login_Previledge" b ON b."FMG_Id" = a."FMG_Id" AND b."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_Master_Amount" c ON c."FMG_Id" = a."FMG_Id" AND c."FMH_Id" = a."FMH_Id" AND c."FTI_Id" = a."FTI_Id"
        INNER JOIN "Adm_School_Y_Student" e ON e."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "Fee_Master_Group" f ON f."FMG_Id" = a."FMG_Id"
        INNER JOIN "Fee_Master_Head" g ON g."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_T_Installment" h ON h."FTI_Id" = a."FTI_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" i ON i."AMST_Id" = a."AMST_Id"
        INNER JOIN "Fee_Y_Payment" j ON j."FYP_Id" = i."FYP_Id"
        INNER JOIN "Fee_T_Payment" k ON k."FYP_Id" = j."FYP_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" l ON l."FTI_Id" = a."FTI_Id" AND l."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_Master_Terms" m ON m."FMT_Id" = l."FMT_Id"
        WHERE a."MI_Id" = "MI_Id"::BIGINT 
            AND a."ASMAY_Id" = "ASMAY_Id"::BIGINT
            AND j."FYP_Date"::DATE BETWEEN TO_DATE("FromDate", 'DD/MM/YYYY') AND TO_DATE("Todate", 'DD/MM/YYYY')
            AND e."AMAY_ActiveFlag" = 1 
            AND e."ASMAY_Id" = "ASMAY_Id"::BIGINT
            AND f."FMG_ActiceFlag" = 1 
            AND g."FMH_ActiveFlag" = 1
        GROUP BY a."AMST_Id", a."FMG_Id", a."FMA_Id", a."FMH_Id", a."FTI_Id", a."ASMAY_Id", a."FSS_ToBePaid", a."FSS_PaidAmount", a."FSS_ConcessionAmount",
            a."FSS_NetAmount", a."FSS_FineAmount", a."FSS_RefundAmount",
            g."FMH_FeeName", h."FTI_Name", f."FMG_GroupName", a."FSS_CurrentYrCharges", a."FSS_OBArrearAmount", a."FSS_WaivedAmount",
            g."FMH_Order", j."FYP_Id", k."FTP_Paid_Amt", m."FMT_Name";
    
    END IF;

    RETURN;

END;
$$;