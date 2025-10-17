CREATE OR REPLACE FUNCTION "FEEGROUPPRO"()
RETURNS TABLE(
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "FMI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN QUERY
    SELECT  "B"."FMG_GroupName", "C"."FMH_FeeName", "D"."FMI_Name"
    FROM  "Fee_Yearly_Group_Head_Mapping" "A"
    INNER JOIN "FEE_MASTER_GROUP" "B" ON "A"."FMG_Id" = "B"."FMG_Id"
    INNER JOIN "FEE_MASTER_HEAD" "C" ON "A"."FMH_Id" = "C"."FMH_Id"
    INNER JOIN "Fee_Master_Installment" "D" ON "D"."FMI_Id" = "A"."FMI_Id"
    INNER JOIN "Fee_T_Installment" "E" ON "D"."FMI_Id" = "E"."FMI_Id"
    WHERE "A"."FYGHM_ActiveFlag" = 1 AND "A"."MI_ID" = 4 AND "A"."ASMAY_Id" = 2;
END;
$$;