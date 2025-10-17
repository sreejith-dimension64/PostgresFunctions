CREATE OR REPLACE FUNCTION "INV"."INV_SalesReturnItem_Approval"(
    "@MI_Id" bigint,
    "@INVMSLRET_Id" bigint,
    "@User_Id" bigint
)
RETURNS TABLE(
    "INVMSLRET_Id" bigint,
    "INVMI_ItemName" varchar,
    "INVTSLRET_BatchNo" varchar,
    "INVTSLRET_SalesReturnQty" numeric,
    "INVTSLRET_SalesReturnAmount" numeric,
    "INVTSLRET_SalesReturnNaration" text,
    "INVMSLRETAPP_Id" bigint,
    "invtpI_ApproxAmount" numeric,
    "INVMP_Id" bigint,
    "INVMI_Id" bigint,
    "INVMUOM_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."INVMSLRET_Id",
        b."INVMI_ItemName",
        a."INVTSLRET_BatchNo",
        a."INVTSLRET_SalesReturnQty",
        a."INVTSLRET_SalesReturnAmount",
        a."INVTSLRET_SalesReturnNaration",
        c."INVMSLRETAPP_Id",
        (a."INVTSLRET_SalesReturnQty" * a."INVTSLRET_SalesReturnAmount") as "invtpI_ApproxAmount",
        a."INVMP_Id",
        a."INVMI_Id",
        a."INVMUOM_Id"
    FROM "INV"."INV_T_Sales_Return" a
    INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id"
    INNER JOIN "INV"."INV_M_Sales_Return" c ON a."INVMSLRET_Id" = c."INVMSLRET_Id"
    WHERE c."MI_Id" = "@MI_Id" AND a."INVMSLRET_Id" = "@INVMSLRET_Id";
END;
$$;