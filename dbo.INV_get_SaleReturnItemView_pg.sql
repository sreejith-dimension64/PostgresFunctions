CREATE OR REPLACE FUNCTION "INV"."INV_get_SaleReturnItemView"(
    p_MI_Id bigint,
    p_INVMSLRET_Id bigint
)
RETURNS TABLE(
    "INVMI_ItemName" VARCHAR,
    "INVTSLRET_SalesReturnQty" NUMERIC,
    "INVTSLRET_SalesReturnAmount" NUMERIC,
    "INVTSLRET_ReturnDate" TIMESTAMP,
    "INVTSLRET_SalesReturnNaration" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."INVMI_ItemName", 
        b."INVTSLRET_SalesReturnQty", 
        b."INVTSLRET_SalesReturnAmount", 
        b."INVTSLRET_ReturnDate",
        b."INVTSLRET_SalesReturnNaration"  
    FROM "INV"."INV_Master_Item" a
    INNER JOIN "INV"."INV_T_Sales_Return" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_M_Sales_Return" c ON c."INVMSLRET_Id" = b."INVMSLRET_Id"
    WHERE c."MI_Id" = p_MI_Id AND c."INVMSLRET_Id" = p_INVMSLRET_Id;
END;
$$;