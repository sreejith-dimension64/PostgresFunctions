CREATE OR REPLACE FUNCTION "INV_Purchase_ExipireDate"(
    p_MI_Id BIGINT,
    p_INVMPR_Id BIGINT
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVTPO_ExpectedDeliveryDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b."INVMI_Id", b."INVTPO_ExpectedDeliveryDate"
    FROM "INV"."INV_M_PurchaseOrder" A
    INNER JOIN "INV"."INV_T_PurchaseOrder" B ON A."INVMPO_Id" = B."INVMPO_Id"
    WHERE A."MI_Id" = p_MI_Id;
END;
$$;