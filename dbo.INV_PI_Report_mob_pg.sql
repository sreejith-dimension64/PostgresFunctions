CREATE OR REPLACE FUNCTION "dbo"."INV_PI_Report_mob" (
    p_MI_Id BIGINT,
    p_startdate VARCHAR(10),
    p_enddate VARCHAR(10),
    p_optionflag VARCHAR(50)
)
RETURNS TABLE (
    "INVMPI_Id" BIGINT,
    "INVMPI_PINo" TEXT,
    "INVMPI_ApproxTotAmount" NUMERIC,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVTPI_ApproxAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_dates TEXT;
BEGIN
    IF p_startdate != '' AND p_enddate != '' THEN
        v_dates := 'AND CAST("INVMPI_PIDate" AS DATE) BETWEEN TO_DATE(''' || p_startdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_enddate || ''', ''DD/MM/YYYY'')';
    ELSE
        v_dates := '';
    END IF;

    IF (p_optionflag = 'PI') THEN
        v_Slqdymaic := '
SELECT DISTINCT "MPI"."INVMPI_Id", "MPI"."INVMPI_PINo", "MPI"."INVMPI_ApproxTotAmount",
NULL::BIGINT AS "INVMI_Id", NULL::TEXT AS "INVMI_ItemName", NULL::NUMERIC AS "INVTPI_ApproxAmount"
FROM "INV"."INV_M_PurchaseIndent" "MPI"
INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
WHERE "MPI"."INVMPI_ActiveFlg" = 1 AND "TPI"."INVTPI_ActiveFlg" = 1 AND "MPI"."MI_Id" = ' || p_MI_Id::TEXT || ' ' || v_dates;

        RETURN QUERY EXECUTE v_Slqdymaic;

    ELSIF p_optionflag = 'Itm' THEN
        v_Slqdymaic := '
SELECT NULL::BIGINT AS "INVMPI_Id", NULL::TEXT AS "INVMPI_PINo", NULL::NUMERIC AS "INVMPI_ApproxTotAmount",
"TPI"."INVMI_Id", "MI"."INVMI_ItemName",
SUM("TPI"."INVTPI_ApproxAmount") AS "INVTPI_ApproxAmount"
FROM "INV"."INV_M_PurchaseIndent" "MPI"
INNER JOIN "INV"."INV_T_PurchaseIndent" "TPI" ON "MPI"."INVMPI_Id" = "TPI"."INVMPI_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPI"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPI"."INVMUOM_Id"
WHERE "MPI"."INVMPI_ActiveFlg" = 1 AND "TPI"."INVTPI_ActiveFlg" = 1 AND "MPI"."MI_Id" = ' || p_MI_Id::TEXT || ' ' || v_dates || '
GROUP BY "TPI"."INVMI_Id", "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE v_Slqdymaic;

    END IF;

    RETURN;
END;
$$;