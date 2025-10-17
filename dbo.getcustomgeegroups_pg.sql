CREATE OR REPLACE FUNCTION "dbo"."getcustomgeegroups" (
    p_MI_Id VARCHAR(50),
    p_Asmay_Id VARCHAR(50),
    p_Amst_Id VARCHAR(50),
    p_fmt_id VARCHAR(50)
)
RETURNS TABLE (
    "fmG_GroupName" VARCHAR,
    "fmg_id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlhead TEXT;
BEGIN
    v_sqlhead := 'SELECT DISTINCT "FMGG_GroupName" AS "fmG_GroupName", "Fee_Master_Group_Grouping_Groups"."fmg_id" 
                  FROM "Fee_OnlinePayment_Mapping" 
                  INNER JOIN "Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group_Grouping_Groups"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id"
                  INNER JOIN "Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id"
                  INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
                  WHERE "Fee_OnlinePayment_Mapping"."MI_Id" = ' || p_MI_Id || ' 
                  AND "fmt_id" IN (' || p_fmt_id || ') 
                  AND "AMST_Id" = ' || p_Amst_Id;
    
    RETURN QUERY EXECUTE v_sqlhead;
    
    RETURN;
END;
$$;