CREATE OR REPLACE FUNCTION "dbo"."INV_OB_Report_proc"(
    "MI_Id" bigint,
    "IMFY_Id" bigint,
    "INVMST_Id" bigint
)
RETURNS TABLE(
    "INVMI_ItemName" TEXT,
    "INVMS_StoreName" TEXT,
    "INVOB_Qty" NUMERIC,
    "INVOB_PurchaseDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (COALESCE("INVMST_Id", 0) = 0) THEN
        RETURN QUERY
        SELECT 
            d."INVMI_ItemName",
            c."INVMS_StoreName",
            a."INVOB_Qty",
            a."INVOB_PurchaseDate"
        FROM 
            "inv"."INV_OpeningBalance" a,
            "inv"."INV_Master_Store" c,
            "IVRM_Master_FinancialYear" b,
            "inv"."INV_Master_Item" d
        WHERE 
            a."INVMI_Id" = d."INVMI_Id" 
            AND a."IMFY_Id" = b."IMFY_Id" 
            AND a."INVMST_Id" = c."INVMST_Id" 
            AND a."MI_Id" = "MI_Id" 
            AND b."IMFY_Id" = "IMFY_Id";
    ELSE
        RETURN QUERY
        SELECT 
            d."INVMI_ItemName",
            c."INVMS_StoreName",
            a."INVOB_Qty",
            a."INVOB_PurchaseDate"
        FROM 
            "inv"."INV_OpeningBalance" a,
            "inv"."INV_Master_Store" c,
            "IVRM_Master_FinancialYear" b,
            "inv"."INV_Master_Item" d
        WHERE 
            a."INVMI_Id" = d."INVMI_Id" 
            AND a."IMFY_Id" = b."IMFY_Id" 
            AND a."INVMST_Id" = c."INVMST_Id" 
            AND a."MI_Id" = "MI_Id" 
            AND b."IMFY_Id" = "IMFY_Id" 
            AND c."INVMST_Id" = "INVMST_Id";
    END IF;
END;
$$;