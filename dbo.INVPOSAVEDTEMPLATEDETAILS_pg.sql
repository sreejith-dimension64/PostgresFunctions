CREATE OR REPLACE FUNCTION "dbo"."INVPOSAVEDTEMPLATEDETAILS"(
    p_MI_Id bigint,
    p_INVMPO_Id bigint,
    p_Template text,
    p_ISES_Id bigint
)
RETURNS TABLE(
    "[REFNO]" character varying,
    "[DATE]" timestamp,
    "[SUPPLIER]" character varying,
    "[MOBILE]" character varying,
    "[EMAIL]" character varying,
    "[ADDRESS]" text,
    "[NAME]" character varying
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "MPO"."INVMPO_ReferenceNo" AS "[REFNO]",
        "MPO"."INVMPO_PODate" AS "[DATE]",
        "MS"."INVMS_SupplierName" AS "[SUPPLIER]",
        "MS"."INVMS_SupplierConatctNo" AS "[MOBILE]",
        "MS"."INVMS_EmailId" AS "[EMAIL]",
        "MS"."INVMS_SupplierAddress" AS "[ADDRESS]",
        COALESCE("MS"."INVMS_SupplierConatctPerson", '') AS "[NAME]"
    FROM "INV"."INV_M_PurchaseOrder" "MPO"
    INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "TPO"."INVMPO_Id" = "MPO"."INVMPO_Id"
    INNER JOIN "INV"."INV_Master_Supplier" "MS" ON "MS"."INVMS_Id" = "MPO"."INVMS_Id" AND "MS"."INVMS_ActiveFlg" = 1
    WHERE "MPO"."MI_Id" = p_MI_Id AND "MPO"."INVMPO_Id" = p_INVMPO_Id;
END;
$$;