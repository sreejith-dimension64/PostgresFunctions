CREATE OR REPLACE FUNCTION "dbo"."INV_PI_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE(
    "INVMPI_Id" BIGINT,
    "INVMPI_PINo" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "optionflag" = 'PIno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INV_M_PurchaseIndent"."INVMPI_Id",
            "INV_M_PurchaseIndent"."INVMPI_PINo",
            NULL::BIGINT AS "INVMI_Id",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode"
        FROM "INV"."INV_M_PurchaseIndent"
        WHERE "INV_M_PurchaseIndent"."MI_Id" = "MI_Id" 
            AND "INV_M_PurchaseIndent"."INVMPI_ActiveFlg" = 1
        ORDER BY "INV_M_PurchaseIndent"."INVMPI_Id";
        
    ELSIF "optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMPI_Id",
            NULL::VARCHAR AS "INVMPI_PINo",
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a,
             "INV"."INV_M_PurchaseIndent" b,
             "INV"."INV_T_PurchaseIndent" c
        WHERE a."INVMI_Id" = c."INVMI_Id" 
            AND b."INVMPI_Id" = c."INVMPI_Id" 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."INVMI_ItemName";
        
    END IF;

END;
$$;