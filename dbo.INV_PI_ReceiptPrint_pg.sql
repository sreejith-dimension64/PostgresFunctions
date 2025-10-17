CREATE OR REPLACE FUNCTION "dbo"."INV_PI_ReceiptPrint" (
    p_MI_Id BIGINT,
    p_ckd_Ids VARCHAR(100)
)
RETURNS TABLE (
    "INVMPI_Id" BIGINT,
    "INVMPI_PINo" VARCHAR,
    "INVMPI_PIDate" TIMESTAMP,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" VARCHAR,
    "INVTPI_PRQty" NUMERIC,
    "INVTPI_PIQty" NUMERIC,
    "INVTPI_PIUnitRate" NUMERIC,
    "INVTPI_ApproxAmount" NUMERIC,
    "INVMPI_Remarks" TEXT,
    "INVMPI_ApproxTotAmount" NUMERIC,
    "INVMPI_POCreatedFlg" BOOLEAN,
    "INVMPI_ActiveFlg" BOOLEAN,
    "INVTPI_Id" BIGINT,
    "INVTPI_Remarks" TEXT,
    "INVTPI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    v_Slqdymaic := '
    SELECT DISTINCT MPI."INVMPI_Id", MPI."INVMPI_PINo", MPI."INVMPI_PIDate", TPI."INVMI_Id", MI."INVMI_ItemName", 
    TPI."INVMUOM_Id", UOM."INVMUOM_UOMName",
    TPI."INVTPI_PRQty", TPI."INVTPI_PIQty", TPI."INVTPI_PIUnitRate", TPI."INVTPI_ApproxAmount",
    MPI."INVMPI_Remarks", MPI."INVMPI_ApproxTotAmount", MPI."INVMPI_POCreatedFlg",
    MPI."INVMPI_ActiveFlg", TPI."INVTPI_Id", TPI."INVTPI_Remarks", TPI."INVTPI_ActiveFlg"
    FROM "INV"."INV_M_PurchaseIndent" MPI
    INNER JOIN "INV"."INV_T_PurchaseIndent" TPI ON MPI."INVMPI_Id" = TPI."INVMPI_Id"
    INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPI."INVMI_Id"
    INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPI."INVMUOM_Id"
    WHERE MPI."INVMPI_ActiveFlg" = true AND TPI."INVTPI_ActiveFlg" = true 
    AND MPI."INVMPI_Id" IN (' || p_ckd_Ids || ') 
    AND MPI."MI_Id" = ' || p_MI_Id::VARCHAR || '
    ORDER BY MPI."INVMPI_Id"';
    
    RETURN QUERY EXECUTE v_Slqdymaic;
END;
$$;