CREATE OR REPLACE FUNCTION "dbo"."Headwise_Details"(
    "Mi_Id" bigint,
    "ASMAY_Id" bigint,
    "FMGG_Id" bigint,
    "FMT_Id" bigint,
    "AMST_ID" bigint
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FSS_NetAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_ToBePaid" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "Fee_Master_Head"."FMH_FeeName",
        "Fee_T_Installment"."FTI_Name",
        "Fee_Student_Status"."FSS_NetAmount",
        "Fee_Student_Status"."FSS_ConcessionAmount",
        "Fee_Student_Status"."FSS_ToBePaid"
    FROM "Fee_Master_Group_Grouping" 
    INNER JOIN "Fee_Master_Group_Grouping_Groups" 
        ON "Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id"
    INNER JOIN "Fee_Student_Status" 
        ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" 
        ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
    INNER JOIN "Fee_Master_Head" 
        ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
        AND "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "Fee_T_Installment" 
        ON "Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        AND "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
    WHERE "Fee_Student_Status"."MI_Id" = "Mi_Id" 
        AND "Fee_Student_Status"."ASMAY_Id" = "ASMAY_Id" 
        AND "Fee_Student_Status"."AMST_Id" = "AMST_ID" 
        AND "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "FMGG_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FMT_Id" = "FMT_Id";

END;
$$;