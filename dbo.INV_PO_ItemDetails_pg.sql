CREATE OR REPLACE FUNCTION "dbo"."INV_PO_ItemDetails"(
    p_MI_Id bigint,
    p_INVMPO_Id bigint,
    p_Template text
)
RETURNS TABLE(
    "REFNO" varchar,
    "DATE" timestamp,
    "SUPPLIER" varchar,
    "MOBILENO" varchar,
    "EMAIL" varchar,
    "ADDRESS" varchar,
    "NAME" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "MPO"."INVMPO_ReferenceNo" AS "REFNO",
        "MPO"."INVMPO_PODate" AS "DATE",
        "MS"."INVMS_SupplierName" AS "SUPPLIER",
        "MS"."INVMS_SupplierConatctNo" AS "MOBILENO",
        "MS"."INVMS_EmailId" AS "EMAIL",
        "MS"."INVMS_SupplierAddress" AS "ADDRESS",
        "MS"."INVMS_SupplierConatctPerson" AS "NAME"
    FROM "INV"."INV_M_PurchaseOrder" "MPO"
    INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "TPO"."INVMPO_Id" = "MPO"."INVMPO_Id"
    INNER JOIN "INV"."INV_Master_Supplier" "MS" ON "MS"."INVMS_Id" = "MPO"."INVMS_Id" AND "MS"."INVMS_ActiveFlg" = 1
    WHERE "MPO"."MI_Id" = 17 AND "MPO"."INVMPO_Id" = p_INVMPO_Id;

END;
$$;