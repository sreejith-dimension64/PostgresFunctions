CREATE OR REPLACE FUNCTION "dbo"."INV_VendorPaymentReport_Details"(
    "p_MI_Id" BIGINT,
    "p_optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "id" BIGINT,
    "name" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF ("p_optionflag" = 'Supplier') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMS_Id",
            b."INVMS_SupplierName"::TEXT
        FROM "INV"."INV_Supplier_Payment" a
        INNER JOIN "INV"."INV_Master_Supplier" b ON a."INVMS_Id" = b."INVMS_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" = "p_MI_Id" AND a."INVSPT_ActiveFlg" = 1
        ORDER BY b."INVMS_SupplierName";
        
    ELSIF ("p_optionflag" = 'GRN') THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."INVMGRN_Id",
            a."INVMGRN_GRNNo"::TEXT
        FROM "INV"."INV_M_GRN" a
        INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVMGRN_Id" = b."INVMGRN_Id" AND a."INVMGRN_ActiveFlg" = 1 AND b."INVSPTGRN_ActiveFlg" = 1
        INNER JOIN "INV"."INV_Supplier_Payment" c ON c."INVSPT_Id" = b."INVSPT_Id" AND a."MI_Id" = c."MI_Id"
        WHERE a."MI_Id" = "p_MI_Id"
        ORDER BY b."INVMGRN_Id";
        
    END IF;

    RETURN;

END;
$$;