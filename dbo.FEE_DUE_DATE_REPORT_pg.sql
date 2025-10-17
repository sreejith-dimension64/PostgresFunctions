CREATE OR REPLACE FUNCTION "dbo"."FEE_DUE_DATE_REPORT"(
    "asmay_Id" int,
    "mi_id" int,
    "fmcc_id" int,
    "user_id" bigint
)
RETURNS TABLE(
    "FTI_Id" int,
    "FMG_GroupName" text,
    "FMH_FeeName" text,
    "FMI_Name" text,
    "FTI_Name" text,
    "FMCC_Id" int,
    "FTDD_Month" text,
    "FTDD_Day" int,
    "FMFS_Id" int,
    "FMFS_FineType" text,
    "FTFS_Id" int,
    "FTFS_FineType" text,
    "FTFS_Amount" numeric,
    "FTIDD_DueDate" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "Fee_T_Installment"."FTI_Id",
        "Fee_Master_Group"."FMG_GroupName", 
        "Fee_Master_Head"."FMH_FeeName", 
        "Fee_Master_Installment"."FMI_Name", 
        "Fee_T_Installment"."FTI_Name", 
        "Fee_Master_Amount"."FMCC_Id", 
        "Fee_T_Due_Date"."FTDD_Month", 
        "Fee_T_Due_Date"."FTDD_Day",
        "Fee_Master_Fine_Slabs"."FMFS_Id", 
        "Fee_Master_Fine_Slabs"."FMFS_FineType", 
        "Fee_T_Fine_Slabs"."FTFS_Id",
        "Fee_T_Fine_Slabs"."FTFS_FineType", 
        "Fee_T_Fine_Slabs"."FTFS_Amount",
        TO_CHAR("Fee_T_Installment_DueDate"."FTIDD_DueDate", 'DD/MM/YYYY') as "FTIDD_DueDate" 
    FROM "Fee_Master_Amount" 
    INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Amount"."FMG_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
    INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" 
    INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Master_Group"."FMG_Id" 
    INNER JOIN "Fee_Master_Class_Category" ON "Fee_Master_Class_Category"."FMCC_Id" = "Fee_Master_Amount"."FMCC_Id" 
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Master_Amount"."FTI_Id"
    INNER JOIN "Fee_Master_Installment" ON "Fee_Master_Installment"."FMI_Id" = "Fee_T_Installment"."FTI_Id" 
    INNER JOIN "Fee_T_Fine_Slabs" ON "Fee_T_Fine_Slabs"."FMA_Id" = "Fee_Master_Amount"."FMA_Id" 
    INNER JOIN "Fee_Master_Fine_Slabs" ON "Fee_Master_Fine_Slabs"."FMFS_Id" = "Fee_T_Fine_Slabs"."FMFS_Id"
    INNER JOIN "Fee_T_Installment_DueDate" ON "Fee_T_Installment_DueDate"."fti_id" = "Fee_T_Installment"."fti_id" 
    INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."fma_id" = "Fee_Master_Amount"."fma_id"
    WHERE "Fee_Master_Amount"."MI_Id" = "mi_id" 
        AND "Fee_Master_Amount"."ASMAY_Id" = "asmay_Id" 
        AND "Fee_Master_Amount"."FMCC_Id" = "fmcc_id" 
        AND "Fee_Group_Login_Previledge"."User_Id" = "user_id";
END;
$$;