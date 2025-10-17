CREATE OR REPLACE FUNCTION "dbo"."AdvanceFeeCollectionDetails"(
    p_MI_ID bigint,
    p_ASMAY_Id bigint,
    p_FromDate varchar(10),
    p_ToDate varchar(10)
)
RETURNS TABLE(
    "FCMAS_Id" bigint,
    "ASMAY_Id" bigint,
    "FTCP_PaidAmount" numeric,
    "FTCP_ConcessionAmount" numeric,
    "FCSS_TotalCharges" integer,
    "FCSS_NetAmount" integer,
    "FCSS_OBArrearAmount" integer,
    "AMSE_Id" bigint,
    "FYP_Id" bigint,
    "FMH_Id" bigint,
    "FMG_Id" bigint,
    "FTI_Id" bigint,
    "FTI_Name" varchar,
    "FMG_GroupName" varchar,
    "FMH_FeeName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ASE"."FCMAS_Id",
        "MA"."ASMAY_Id",
        COALESCE(SUM("TP"."FTCP_PaidAmount"),0) AS "FTCP_PaidAmount",
        COALESCE(SUM("TP"."FTCP_ConcessionAmount"),0) AS "FTCP_ConcessionAmount",
        0 AS "FCSS_TotalCharges",
        0 AS "FCSS_NetAmount",
        0 AS "FCSS_OBArrearAmount",
        "ASE"."AMSE_Id",
        "TP"."FYP_Id",
        "MA"."FMH_Id",
        "MA"."FMG_Id",
        "MA"."FTI_Id",
        "FTI"."FTI_Name",
        "FMG"."FMG_GroupName",
        "FMH"."FMH_FeeName"
    FROM "CLG"."Fee_T_College_Payment" "TP"
    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "ASE" ON "ASE"."FCMAS_Id" = "TP"."FCMAS_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount" "MA" ON "MA"."FCMA_Id" = "ASE"."FCMA_Id"
    INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "MA"."FMG_Id"
    INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "MA"."FMH_Id"
    INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "MA"."FTI_Id"
    WHERE "ASE"."MI_Id" = p_MI_ID 
        AND "FMG"."MI_Id" = p_MI_ID
        AND CAST("TP"."FTCP_CreatedDate" AS DATE) BETWEEN TO_DATE(p_FromDate, 'DD/MM/YYYY') AND TO_DATE(p_ToDate, 'DD/MM/YYYY')
    GROUP BY 
        "MA"."FMG_Id",
        "ASE"."FCMAS_Id",
        "MA"."FMH_Id",
        "MA"."FTI_Id",
        "MA"."ASMAY_Id",
        "ASE"."AMSE_Id",
        "TP"."FYP_Id",
        "MA"."FMH_Id",
        "MA"."FMG_Id",
        "MA"."FTI_Id",
        "FTI"."FTI_Name",
        "FMG"."FMG_GroupName",
        "FMH"."FMH_FeeName";
END;
$$;