CREATE OR REPLACE FUNCTION "INV"."INV_PI_STATUS_Report" (
    "MI_Id" VARCHAR(50), 
    "startdate" VARCHAR(10), 
    "enddate" VARCHAR(10), 
    "PI_Ids" TEXT,  
    "INVMI_Ids" TEXT, 
    "optionflag" TEXT,
    "status" TEXT
)
RETURNS TABLE (
    "MI_Name" TEXT,
    "INVMPI_Id" INTEGER,
    "INVMPI_PINo" TEXT,
    "INVMPI_PIDate" TIMESTAMP,
    "INVMI_Id" INTEGER,
    "INVMI_ItemName" TEXT,
    "INVMUOM_Id" INTEGER,
    "INVMUOM_UOMName" TEXT,
    "INVTPI_PRQty" NUMERIC,
    "INVTPI_PIQty" NUMERIC,
    "INVTPI_PIUnitRate" NUMERIC,
    "INVTPI_ApproxAmount" NUMERIC,
    "INVMPI_Remarks" TEXT,
    "INVMPI_ApproxTotAmount" NUMERIC,
    "INVMPI_POCreatedFlg" BOOLEAN,
    "INVMPI_ActiveFlg" BOOLEAN,
    "INVTPI_Id" INTEGER,
    "INVTPI_Remarks" TEXT,
    "INVTPI_ActiveFlg" BOOLEAN,
    "INVTPI_ApproveQty" NUMERIC,
    "INVTPI_RejectFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
    "str" TEXT;
BEGIN

    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND "INVMPI_PIDate"::date BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF "status" = 'ALL' THEN
        "str" := '';
    ELSIF "status" = 'REJECT' THEN
        "str" := 'AND ("MPI"."INVMPI_FinalProcessFlag" = 1) AND "TPI"."INVTPI_RejectFlg" = TRUE';
    ELSIF "status" = 'APPROVED' THEN
        "str" := 'AND "MPI"."INVMPI_FinalProcessFlag" = 1 AND "MPI"."INVMPI_RejectFlg" = FALSE AND "TPI"."INVTPI_RejectFlg" = FALSE';
    ELSIF "status" = 'PENDING' THEN
        "str" := 'AND ("MPI"."INVMPI_FinalProcessFlag" = 0 OR "MPI"."INVMPI_FinalProcessFlag" IS NULL)';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "mstr"."MI_Name", "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", 
        "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg", 
        COALESCE("TPI"."INVTPI_ApproveQty", 0) AS "INVTPI_ApproveQty", "TPI"."INVTPI_RejectFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        LEFT JOIN "Master_Institution" "mstr" ON "mstr"."MI_Id" = "MPI"."MI_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = TRUE AND "TPI"."INVTPI_ActiveFlg" = TRUE 
        AND "MPI"."MI_Id"::TEXT IN (' || "MI_Id" || ') ' || "dates" || ' ' || "str";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'PIno' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "mstr"."MI_Name", "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", 
        "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg", 
        COALESCE("TPI"."INVTPI_ApproveQty", 0) AS "INVTPI_ApproveQty", "TPI"."INVTPI_RejectFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        LEFT JOIN "Master_Institution" "mstr" ON "mstr"."MI_Id" = "MPI"."MI_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = TRUE AND "TPI"."INVTPI_ActiveFlg" = TRUE 
        AND "MPI"."INVMPI_Id"::TEXT IN (' || "PI_Ids" || ') AND "MPI"."MI_Id"::TEXT IN(' || "MI_Id" || ') ' || "dates" || ' ' || "str";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "mstr"."MI_Name", "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_PIDate", 
        "TPI"."INVMI_Id", "MI"."INVMI_ItemName", "TPI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "TPI"."INVTPI_PRQty", "TPI"."INVTPI_PIQty", "TPI"."INVTPI_PIUnitRate", "TPI"."INVTPI_ApproxAmount",
        "MPI"."INVMPI_Remarks", "MPI"."INVMPI_ApproxTotAmount", "MPI"."INVMPI_POCreatedFlg",
        "MPI"."INVMPI_ActiveFlg", "TPI"."INVTPI_Id", "TPI"."INVTPI_Remarks", "TPI"."INVTPI_ActiveFlg", 
        COALESCE("TPI"."INVTPI_ApproveQty", 0) AS "INVTPI_ApproveQty", "TPI"."INVTPI_RejectFlg"
        FROM "INV"."INV_M_PurchaseIndent" "MPI"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
        LEFT JOIN "Master_Institution" "mstr" ON "mstr"."MI_Id" = "MPI"."MI_Id"
        WHERE "MPI"."INVMPI_ActiveFlg" = TRUE AND "TPI"."INVTPI_ActiveFlg" = TRUE 
        AND "TPI"."INVMI_Id"::TEXT IN (' || "INVMI_Ids" || ') AND "MPI"."MI_Id"::TEXT IN (' || "MI_Id" || ') ' || "dates" || ' ' || "str";
        
        RETURN QUERY EXECUTE "Slqdymaic";

    END IF;

    RETURN;
END;
$$;