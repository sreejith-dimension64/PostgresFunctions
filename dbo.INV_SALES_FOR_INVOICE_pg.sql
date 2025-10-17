CREATE OR REPLACE FUNCTION "dbo"."INV_SALES_FOR_INVOICE"(
    "p_MI_Id" bigint
)
RETURNS TABLE(
    "INVMSL_SalesNo" VARCHAR,
    "INVMSL_SalesDate" TIMESTAMP,
    "INVMSL_TotTaxAmt" NUMERIC,
    "INVMSL_TotDiscount" NUMERIC,
    "INVMSL_TotalAmount" NUMERIC,
    "INVMSL_SalesValue" NUMERIC,
    "INVMSL_Id" BIGINT,
    "INVMSL_PaidFlg" BOOLEAN,
    "INVMST_Id" BIGINT,
    "ISMMCLT_Id" BIGINT,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMMCLT_Address" TEXT,
    "ISMMCLT_Code" VARCHAR,
    "ISMMCLT_Desc" TEXT,
    "INVMS_StoreName" VARCHAR,
    "INVMSL_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "A"."INVMSL_SalesNo",
        "A"."INVMSL_SalesDate",
        "A"."INVMSL_TotTaxAmt",
        "A"."INVMSL_TotDiscount",
        "A"."INVMSL_TotalAmount",
        "A"."INVMSL_SalesValue",
        "A"."INVMSL_Id",
        "A"."INVMSL_PaidFlg",
        "A"."INVMST_Id",
        "C"."ISMMCLT_Id",
        "C"."ISMMCLT_ClientName",
        "C"."ISMMCLT_Address",
        "C"."ISMMCLT_Code",
        "C"."ISMMCLT_Desc",
        "D"."INVMS_StoreName",
        "A"."INVMSL_Remarks"
    FROM "INV"."INV_M_Sales" AS "A"
    INNER JOIN "INV"."INV_M_Sales_Client" AS "B" ON "A"."INVMSL_Id" = "B"."INVMSL_Id"
    INNER JOIN "ISM_Master_Client" AS "C" ON "C"."ISMMCLT_Id" = "B"."ISMMCLT_Id"
    INNER JOIN "INV"."INV_Master_Store" AS "D" ON "D"."INVMST_Id" = "A"."INVMST_Id"
    WHERE "A"."INVMSL_ActiveFlg" = 1 
      AND "B"."INVMSLCL_ActiveFlg" = 1 
      AND "A"."MI_Id" = "p_MI_Id";
END;
$$;