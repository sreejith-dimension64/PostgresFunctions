CREATE OR REPLACE FUNCTION "INV"."INV_GetSalesTaxDetails"(
    "p_MI_Id" bigint,
    "p_INVMSL_Id" bigint,
    "p_INVMI_Id" bigint,
    "p_Type" varchar(20)
)
RETURNS TABLE(
    "INVMIT_Id" bigint,
    "INVMI_Id" bigint,
    "INVMI_ItemName" varchar,
    "INVMT_Id" bigint,
    "INVMT_TaxName" varchar,
    "INVMT_TaxAliasName" varchar,
    "INVTSLT_TaxPer" numeric,
    "invtslT_TaxAmt" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "p_Type" = 'Tax' THEN
        RETURN QUERY
        SELECT 
            b."INVMIT_Id",
            a."INVMI_Id",
            a."INVMI_ItemName",
            b."INVMT_Id",
            c."INVMT_TaxName",
            c."INVMT_TaxAliasName",
            b."INVMIT_TaxValue" as "INVTSLT_TaxPer",
            d."INVTSL_TaxAmt" as "invtslT_TaxAmt"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Master_Item_Tax" b ON a."INVMI_Id" = b."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Tax" c ON c."INVMT_Id" = b."INVMT_Id"
        INNER JOIN "INV"."INV_T_Sales" d ON d."INVMI_Id" = a."INVMI_Id"
        INNER JOIN "INV"."INV_M_Sales" e ON d."INVMSL_Id" = e."INVMSL_Id"
        WHERE a."INVMI_Id" = "p_INVMI_Id" 
            AND a."INVMI_ActiveFlg" = 1 
            AND d."INVMSL_Id" = "p_INVMSL_Id" 
            AND a."MI_Id" = "p_MI_Id";
    END IF;
END;
$$;