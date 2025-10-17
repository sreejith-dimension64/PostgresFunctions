CREATE OR REPLACE FUNCTION "dbo"."INV_VendorGRN"(
    p_MI_Id BIGINT,
    p_INVMS_Id BIGINT
)
RETURNS TABLE(
    "INVMGRN_Id" BIGINT,
    "INVMS_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVMGRN_PurchaseDate" TIMESTAMP,
    "INVMGRN_PurchaseValue" NUMERIC,
    "INVMGRN_TotalPaid" NUMERIC,
    "INVMGRN_TotalBalance" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."INVMGRN_Id",
        a."INVMS_Id",
        a."INVMGRN_GRNNo",
        a."INVMGRN_PurchaseDate",
        a."INVMGRN_PurchaseValue",
        a."INVMGRN_TotalPaid",
        a."INVMGRN_TotalBalance"
    FROM "INV"."INV_M_GRN" a
    INNER JOIN "INV"."INV_Master_Supplier" b 
        ON a."INVMS_Id" = b."INVMS_Id" 
        AND a."MI_Id" = b."MI_Id"
    WHERE a."MI_Id" = p_MI_Id 
        AND a."INVMS_Id" = p_INVMS_Id 
        AND a."INVMGRN_ActiveFlg" = 1;
END;
$$;