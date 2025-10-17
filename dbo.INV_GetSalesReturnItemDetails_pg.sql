CREATE OR REPLACE FUNCTION "INV"."INV_GetSalesReturnItemDetails"(
    "@MI_Id" bigint,
    "@INVMSL_Id" bigint,
    "@INVMI_Id" bigint,
    "@INVMST_Id" bigint,
    "@Type" varchar(20)
)
RETURNS TABLE(
    "INVMST_Id" bigint,
    "INVMI_Id" bigint,
    "INVMUOM_Id" bigint,
    "INVMUOM_UOMName" varchar,
    "INVMUOM_UOMAliasName" varchar,
    "INVTSL_SalesPrice" numeric,
    "INVTSL_SalesQty" numeric,
    "INVTSL_Amount" numeric,
    "INVTSL_BatchNo" varchar,
    "INVMP_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@Type" = 'ItemDetails' THEN
        RETURN QUERY
        SELECT 
            a."INVMST_Id", 
            b."INVMI_Id", 
            c."INVMUOM_Id", 
            c."INVMUOM_UOMName", 
            c."INVMUOM_UOMAliasName", 
            b."INVTSL_SalesPrice", 
            b."INVTSL_SalesQty", 
            b."INVTSL_Amount", 
            b."INVTSL_BatchNo", 
            a."INVMP_Id"
        FROM "INV"."INV_M_Sales" a
        INNER JOIN "INV"."INV_T_Sales" b ON a."INVMSL_Id" = b."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_UOM" c ON c."INVMUOM_Id" = b."INVMUOM_Id"
        WHERE a."INVMSL_Id" = "@INVMSL_Id" 
            AND b."INVMI_Id" = "@INVMI_Id" 
            AND a."INVMST_Id" = "@INVMST_Id" 
            AND a."MI_Id" = "@MI_Id";
    END IF;

    RETURN;

END;
$$;