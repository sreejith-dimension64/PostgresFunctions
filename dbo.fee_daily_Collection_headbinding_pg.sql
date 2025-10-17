CREATE OR REPLACE FUNCTION "dbo"."fee_daily_Collection_headbinding"(
    "@fromdate" TEXT,
    "@todate" TEXT,
    "@groupids" TEXT
)
RETURNS TABLE(
    "monthyear" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@sql1" TEXT;
BEGIN
    "@sql1" := 'SELECT DISTINCT "dbo"."Fee_Master_Head"."FMH_FeeName" as monthyear FROM "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Amount" ON 
"dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Amount"."FMH_Id" and "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Amount"."FMG_Id" 
inner join "Fee_T_Payment" on "Fee_Master_Amount"."FMA_Id"="Fee_T_Payment"."FMA_Id" INNER JOIN "dbo"."Fee_Y_Payment" ON 
"dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" inner join "Fee_Y_Payment_School_Student" on "Fee_Y_Payment"."FYP_Id"="Fee_Y_Payment_School_Student"."FYP_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" Where "Fee_Y_Payment"."FYP_Id" in
 (SELECT "dbo"."Fee_T_Payment"."FYP_Id" FROM "dbo"."Fee_Master_Amount" INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" and
"dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Amount"."FMG_Id" INNER JOIN "dbo"."Fee_Yearly_Group" ON 
"dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" Where "Fee_Yearly_Group_Head_Mapping"."FMG_Id" in (' || "@groupids" || '))  and 
TO_DATE("FYP_Date", ''DD/MM/YYYY'') between TO_DATE(''' || "@fromdate" || ''', ''DD/MM/YYYY'') and TO_DATE(''' || "@todate" || ''', ''DD/MM/YYYY'') or 
("dbo"."Fee_Y_Payment_School_Student"."AMST_Id" is null or "dbo"."Fee_Y_Payment_School_Student"."Amst_id"=0)';

    RETURN QUERY EXECUTE "@sql1";
    
    RETURN;
END;
$$;