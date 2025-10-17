CREATE OR REPLACE FUNCTION "FEE_MODULE_GROUP_HEAD_INSTALLMENT_PROD"()
RETURNS TABLE(
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "FMI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT B."FMG_GroupName", C."FMH_FeeName", D."FMI_Name"
    FROM "Fee_Yearly_Group_Head_Mapping" A
    INNER JOIN "FEE_MASTER_GROUP" B ON A."FMG_Id" = B."FMG_Id"
    INNER JOIN "FEE_MASTER_HEAD" C ON A."FMH_Id" = C."FMH_Id"
    INNER JOIN "Fee_Master_Installment" D ON A."FMI_Id" = D."FMI_Id"
    INNER JOIN "Fee_T_Installment" E ON D."FMI_Id" = E."FMI_Id"
    WHERE A."FYGHM_ActiveFlag" = 1 
      AND A."MI_Id" = 4 
      AND A."ASMAY_Id" = 2;
END;
$$;