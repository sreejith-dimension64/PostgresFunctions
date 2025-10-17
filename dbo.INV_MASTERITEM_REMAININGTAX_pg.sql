CREATE OR REPLACE FUNCTION "INV"."INV_MASTERITEM_REMAININGTAX"(
    "MI_Id" BIGINT,
    "INVMI_Id" BIGINT
)
RETURNS TABLE(
    "INVMT_Id" BIGINT,
    "INVMT_TaxName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT M."INVMT_Id", M."INVMT_TaxName" 
    FROM "INV"."INV_Master_Tax" M 
    LEFT JOIN "INV"."INV_Master_Item_Tax" MI ON M."INVMT_Id" = MI."INVMT_Id"
    LEFT JOIN "INV"."INV_Master_Item" I ON I."INVMI_Id" = MI."INVMI_Id" 
    WHERE M."INVMT_Id" NOT IN (
        SELECT c."INVMT_Id" 
        FROM "INV"."INV_Master_Item_Tax" c 
        WHERE c."INVMT_Id" = c."INVMT_Id" 
        AND c."INVMI_Id" = "INVMI_Id"
    ) 
    AND M."MI_Id" = "MI_Id";
END;
$$;