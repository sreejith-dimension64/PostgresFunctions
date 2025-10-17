CREATE OR REPLACE FUNCTION "dbo"."INV_GRNReturnList"(
    "@MI_Id" bigint,
    "@INVMGRNRET_Id" bigint,
    "@type" varchar(10)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@type" = 'GRNList' THEN
        RETURN QUERY
        SELECT 
            a."INVMGRNRET_Id", 
            b."INVMS_SupplierName", 
            a."INVMGRNRET_GRNRETNo", 
            a."INVMGRNRET_ReturnDate", 
            a."INVMGRNRET_TotalAmount", 
            a."INVMGRNRET_Remarks", 
            a."INVMGRNRET_ActiveFlg"
        FROM "INV"."INV_M_GRN_Return" a
        INNER JOIN "INV"."INV_Master_Supplier" b ON a."INVMS_Id" = b."INVMS_Id"
        WHERE a."MI_Id" = "@MI_Id" AND a."INVMGRNRET_ActiveFlg" = 1 
        ORDER BY a."INVMGRNRET_Id" DESC;
    ELSE
        RETURN QUERY
        SELECT 
            b."INVMI_ItemName", 
            a."INVTGRNRET_ReturnQty", 
            a."INVTGRNRET_ReturnAmount", 
            a."INVTGRNRET_ReturnNaration"
        FROM "INV"."INV_T_GRN_Return" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE a."INVMGRNRET_Id" = "@INVMGRNRET_Id";
    END IF;
END;
$$;