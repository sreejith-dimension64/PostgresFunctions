CREATE OR REPLACE FUNCTION "dbo"."INV_GetSalesReturnItem"(
    p_MI_Id bigint,
    p_INVMSL_Id bigint,
    p_Type varchar(20)
)
RETURNS TABLE(
    "INVMI_Id" bigint,
    "INVMI_ItemName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Type = 'Item' THEN
        RETURN QUERY
        SELECT c."INVMI_Id", c."INVMI_ItemName"
        FROM "INV"."INV_M_Sales" a
        INNER JOIN "INV"."INV_T_Sales" b ON a."INVMSL_Id" = b."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON c."INVMI_Id" = b."INVMI_Id"
        WHERE a."INVMSL_Id" = p_INVMSL_Id 
            AND a."MI_Id" = p_MI_Id 
            AND a."MI_Id" = c."MI_Id";
    END IF;
END;
$$;