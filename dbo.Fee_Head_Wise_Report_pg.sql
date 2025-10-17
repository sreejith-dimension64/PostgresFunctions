CREATE OR REPLACE FUNCTION "dbo"."Fee_Head_Wise_Report"(
    p_ASMAY_Id int,
    p_FMCC_Id int,
    p_mi_id int,
    p_user_id bigint
)
RETURNS TABLE (
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "FMCC_ClassCategoryName" VARCHAR,
    "FTI_Name" VARCHAR,
    "amount" NUMERIC,
    "FMG_ActiceFlag" BOOLEAN,
    "FYGHM_FineApplicableFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "dbo"."Fee_Master_Group"."FMG_GroupName", 
        "dbo"."Fee_Master_Head"."FMH_FeeName", 
        "dbo"."Fee_Master_Class_Category"."FMCC_ClassCategoryName", 
        "dbo"."Fee_T_Installment"."FTI_Name",
        "dbo"."Fee_Master_Amount"."FMA_Amount" as amount,
        "dbo"."Fee_Master_Group"."FMG_ActiceFlag",
        "dbo"."Fee_Yearly_Group_Head_Mapping"."FYGHM_FineApplicableFlag"
    FROM "dbo"."Fee_Yearly_Group_Head_Mapping" 
    INNER JOIN "dbo"."Fee_Master_Group" 
        ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" 
    INNER JOIN "dbo"."Fee_Master_Head" 
        ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
    INNER JOIN "dbo"."Fee_Master_Amount" 
    INNER JOIN "dbo"."Fee_Master_Class_Category" 
        ON "dbo"."Fee_Master_Amount"."FMCC_Id" = "dbo"."Fee_Master_Class_Category"."FMCC_Id" 
    INNER JOIN "dbo"."Fee_T_Installment" 
        ON "dbo"."Fee_Master_Amount"."FTI_Id" = "dbo"."Fee_T_Installment"."FTI_Id" 
        ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Amount"."FMG_Id" 
        AND "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Amount"."FMH_Id" 
    INNER JOIN "dbo"."Fee_Group_Login_Previledge"
        ON "dbo"."Fee_Group_Login_Previledge"."FMG_ID" = "dbo"."Fee_Master_Group"."FMG_Id"
    WHERE "dbo"."Fee_Master_Amount"."MI_Id" = p_mi_id 
        AND "dbo"."Fee_Master_Amount"."ASMAY_Id" = p_ASMAY_Id 
        AND "dbo"."Fee_Master_Amount"."FMCC_Id" = p_FMCC_Id 
        AND "dbo"."Fee_Group_Login_Previledge"."User_Id" = p_user_id;
    
    RETURN;
END;
$$;