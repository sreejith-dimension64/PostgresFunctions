CREATE OR REPLACE FUNCTION "dbo"."INV_GRNReturnItem_Approval"(
    "@MI_Id" bigint,
    "@INVMGRNRET_Id" bigint,
    "@User_Id" bigint
)
RETURNS TABLE(
    "INVMI_ItemName" VARCHAR,
    "INVTGRNRET_ReturnQty" NUMERIC,
    "INVTGRNRET_ReturnAmount" NUMERIC,
    "INVTGRNRET_ReturnNaration" TEXT,
    "INVMGRNRETAPP_Id" BIGINT,
    "invtpI_ApproxAmount" NUMERIC,
    "INVMI_Id" BIGINT,
    "INVMUOM_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."INVMI_ItemName", 
        a."INVTGRNRET_ReturnQty", 
        a."INVTGRNRET_ReturnAmount", 
        a."INVTGRNRET_ReturnNaration", 
        c."INVMGRNRETAPP_Id", 
        (a."INVTGRNRET_ReturnQty" * a."INVTGRNRET_ReturnAmount") as "invtpI_ApproxAmount", 
        a."INVMI_Id", 
        a."INVMUOM_Id"
    FROM "INV"."INV_T_GRN_Return" a
    INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_M_GRN_Return" c ON a."INVMGRNRET_Id" = c."INVMGRNRET_Id"
    WHERE c."MI_Id" = "@MI_Id" AND a."INVMGRNRET_Id" = "@INVMGRNRET_Id";
END;
$$;