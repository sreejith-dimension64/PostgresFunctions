CREATE OR REPLACE FUNCTION "dbo"."INV_SalesReturn_Approval"(
    "@MI_Id" bigint,
    "@User_Id" bigint
)
RETURNS TABLE(
    "INVMSLRET_Id" bigint,
    "INVMSLRET_SalesReturnNo" text,
    "INVMSLRET_SalesReturnDate" timestamp,
    "INVMSLRET_TotalReturnAmount" numeric,
    "INVMSLRET_ReturnRemarks" text,
    "INVMSLRETAPP_Id" bigint,
    "INVMSL_Id" bigint,
    "INVMST_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "INVMSLRET_Id", 
        "INVMSLRET_SalesReturnNo", 
        "INVMSLRET_SalesReturnDate", 
        "INVMSLRET_TotalReturnAmount", 
        "INVMSLRET_ReturnRemarks", 
        "INVMSLRETAPP_Id", 
        "INVMSL_Id", 
        "INVMST_Id"
    FROM "INV"."INV_M_Sales_Return" 
    WHERE "MI_Id" = "@MI_Id" AND "INVMSLRETAPP_Id" = 0;
END;
$$;