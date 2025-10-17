CREATE OR REPLACE FUNCTION "dbo"."INV_Supplier_Payment_Details" (
    p_MI_Id BIGINT,
    p_INVSPT_Id BIGINT
)
RETURNS TABLE (
    "invspT_Id" BIGINT,
    "invsptgrN_Id" BIGINT,
    "invmgrN_Id" BIGINT,
    "invmgrN_GRNNo" VARCHAR,
    "invmgrN_PurchaseValue" NUMERIC,
    "invmgrN_TotalPaid" NUMERIC,
    "invmgrN_TotalBalance" NUMERIC,
    "invsptgrN_Amount" NUMERIC,
    "invsptgrN_Remarks" TEXT,
    "invsptgrN_ActiveFlg" BOOLEAN,
    "invmS_Id" BIGINT,
    "Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        a."INVSPT_Id" AS "invspT_Id",
        b."INVSPTGRN_Id" AS "invsptgrN_Id",
        b."INVMGRN_Id" AS "invmgrN_Id",
        c."INVMGRN_GRNNo" AS "invmgrN_GRNNo",
        c."INVMGRN_PurchaseValue" AS "invmgrN_PurchaseValue",
        c."INVMGRN_TotalPaid" AS "invmgrN_TotalPaid",
        c."INVMGRN_TotalBalance" AS "invmgrN_TotalBalance",
        b."INVSPTGRN_Amount" AS "invsptgrN_Amount",
        b."INVSPTGRN_Remarks" AS "invsptgrN_Remarks",
        b."INVSPTGRN_ActiveFlg" AS "invsptgrN_ActiveFlg",
        a."INVMS_Id" AS "invmS_Id",
        (SELECT COALESCE(SUM(SP."INVSPT_Amount"), 0) 
         FROM "INV"."INV_Supplier_Payment" SP 
         WHERE SP."INVMS_Id" = a."INVMS_Id"
         AND SP."INVSPT_Id" != p_INVSPT_Id) AS "Amount"
    FROM 
        "INV"."INV_Supplier_Payment" a
    INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id"
    INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
    INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
    WHERE
        a."MI_Id" = p_MI_Id
        AND a."INVSPT_Id" = p_INVSPT_Id
    ORDER BY
        b."INVMGRN_Id";
END;
$$;