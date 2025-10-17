CREATE OR REPLACE FUNCTION "dbo"."INV_PI_Report" (
    "MI_Id" BIGINT, 
    "startdate" VARCHAR(10), 
    "enddate" VARCHAR(10), 
    "PI_Ids" VARCHAR(100),  
    "INVMI_Ids" VARCHAR(100), 
    "optionflag" VARCHAR(50)
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
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND "INVMPI_PIDate"::date BETWEEN TO_DATE(''' || "startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = true AND "TPI"."INVTPI_ActiveFlg" = true AND "MPI"."MI_Id" = ' || "MI_Id"::VARCHAR || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'PIno' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = true AND "TPI"."INVTPI_ActiveFlg" = true AND "MPI"."INVMPI_Id" IN (' || "PI_Ids" || ') AND "MPI"."MI_Id" = ' || "MI_Id"::VARCHAR || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = true AND "TPI"."INVTPI_ActiveFlg" = true AND "TPI"."INVMI_Id" IN (' || "INVMI_Ids" || ') AND "MPI"."MI_Id" = ' || "MI_Id"::VARCHAR || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    END IF;

    RETURN;
END;
$$;