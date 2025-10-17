CREATE OR REPLACE FUNCTION "dbo"."INVPOTEMPLATEDETAILS"(
    p_MI_Id bigint,
    p_INVMPO_Id bigint,
    p_Template text,
    p_ISES_Id bigint,
    p_INVMS_Id bigint
)
RETURNS TABLE(
    "[SUPPLIER]" character varying,
    "[MOBILE]" character varying,
    "[EMAIL]" character varying,
    "[ADDRESS]" character varying,
    "[NAME]" character varying
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        "INVMS_SupplierName" AS "[SUPPLIER]",
        "INVMS_SupplierConatctNo" AS "[MOBILE]",
        "INVMS_EmailId" AS "[EMAIL]",
        "INVMS_SupplierAddress" AS "[ADDRESS]",
        "INVMS_SupplierConatctPerson" AS "[NAME]"
    FROM "INV"."INV_Master_Supplier"
    WHERE "INVMS_Id" = p_INVMS_Id
    LIMIT 1;
END;
$$;