CREATE OR REPLACE FUNCTION "dbo"."AT_Dispose_Report_NEW"(
    "@MI_Id" BIGINT,
    "@startdate" VARCHAR(10),
    "@enddate" VARCHAR(10),
    "@IMFY_Id" BIGINT,
    "@selectionflag" VARCHAR(50),
    "@INVMI_Id" TEXT,
    "@INVMLO_Id" TEXT,
    "@ASMAY_Id" BIGINT
)
RETURNS TABLE(
    "INVADI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVSTO_SalesRate" NUMERIC,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVADI_DisposedDate" TIMESTAMP,
    "INVADI_DisposedQty" NUMERIC,
    "INVADI_DisposedRemarks" TEXT,
    "INVADI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@dynamic" TEXT;
    "@dates" VARCHAR(200);
    "@FromDate" VARCHAR(20);
    "@ToDate" VARCHAR(20);
BEGIN

    IF "@IMFY_Id" != 0 AND "@IMFY_Id" IS NOT NULL THEN
        SELECT TO_CHAR("IMFY_FromDate"::DATE, 'YYYY-MM-DD'), TO_CHAR("IMFY_ToDate"::DATE, 'YYYY-MM-DD')
        INTO "@FromDate", "@ToDate"
        FROM "IVRM_Master_FinancialYear"
        WHERE "IMFY_Id" = "@IMFY_Id";
    ELSIF "@ASMAY_Id" != 0 AND "@ASMAY_Id" IS NOT NULL THEN
        SELECT TO_CHAR("ASMAY_From_Date"::DATE, 'YYYY-MM-DD'), TO_CHAR("ASMAY_To_Date"::DATE, 'YYYY-MM-DD')
        INTO "@FromDate", "@ToDate"
        FROM "Adm_School_M_Academic_Year"
        WHERE "ASMAY_Id" = "@ASMAY_Id";
    END IF;

    IF "@startdate" != '' AND "@startdate" IS NOT NULL AND "@enddate" != '' AND "@enddate" IS NOT NULL THEN
        "@dates" := 'AND "a"."INVADI_DisposedDate"::DATE BETWEEN TO_DATE(''' || "@startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "@enddate" || ''', ''DD/MM/YYYY'')';
    ELSIF "@FromDate" != '' AND "@FromDate" IS NOT NULL AND "@ToDate" != '' AND "@ToDate" IS NOT NULL THEN
        "@dates" := 'AND "a"."INVADI_DisposedDate"::DATE BETWEEN ''' || "@FromDate" || '''::DATE AND ''' || "@ToDate" || '''::DATE';
    ELSE
        "@IMFY_Id" := 0;
        "@startdate" := '';
        "@enddate" := '';
        "@dates" := '';
    END IF;

    IF "@selectionflag" = 'All' THEN
        "@dynamic" := '
        SELECT DISTINCT "a"."INVADI_Id", "a"."INVMST_Id", "a"."INVMI_Id", "a"."INVMLO_Id", "b"."INVMS_StoreName", "c"."INVMI_ItemName", 
        "a"."INVSTO_SalesRate", "d"."INVMLO_LocationRoomName",
        "a"."INVADI_DisposedDate", "a"."INVADI_DisposedQty", "a"."INVADI_DisposedRemarks", "a"."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" "a",
        "INV"."INV_Master_Store" "b",
        "INV"."INV_Master_Item" "c",
        "INV"."INV_Master_Location" "d"
        WHERE "a"."INVMST_Id" = "b"."INVMST_Id" AND "a"."INVMI_Id" = "c"."INVMI_Id" AND "a"."INVMLO_Id" = "d"."INVMLO_Id" 
        AND "a"."MI_Id" = "b"."MI_Id" AND "a"."INVADI_ActiveFlg" = TRUE
        AND "a"."MI_Id" = ' || "@MI_Id"::VARCHAR || ' ' || "@dates";
    ELSIF "@selectionflag" = 'Item' THEN
        "@dynamic" := '
        SELECT DISTINCT "a"."INVADI_Id", "a"."INVMST_Id", "a"."INVMI_Id", "a"."INVMLO_Id", "b"."INVMS_StoreName", "c"."INVMI_ItemName", 
        "a"."INVSTO_SalesRate", "d"."INVMLO_LocationRoomName",
        "a"."INVADI_DisposedDate", "a"."INVADI_DisposedQty", "a"."INVADI_DisposedRemarks", "a"."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" "a",
        "INV"."INV_Master_Store" "b",
        "INV"."INV_Master_Item" "c",
        "INV"."INV_Master_Location" "d"
        WHERE "a"."INVMST_Id" = "b"."INVMST_Id" AND "a"."INVMI_Id" = "c"."INVMI_Id" AND "a"."INVMLO_Id" = "d"."INVMLO_Id" 
        AND "a"."MI_Id" = "b"."MI_Id" AND "a"."INVADI_ActiveFlg" = TRUE
        AND "a"."MI_Id" = ' || "@MI_Id"::VARCHAR || ' ' || "@dates" || ' AND "a"."INVMI_Id" IN (' || "@INVMI_Id" || ')';
    ELSIF "@selectionflag" = 'Location' THEN
        "@dynamic" := '
        SELECT DISTINCT "a"."INVADI_Id", "a"."INVMST_Id", "a"."INVMI_Id", "a"."INVMLO_Id", "b"."INVMS_StoreName", "c"."INVMI_ItemName", 
        "a"."INVSTO_SalesRate", "d"."INVMLO_LocationRoomName",
        "a"."INVADI_DisposedDate", "a"."INVADI_DisposedQty", "a"."INVADI_DisposedRemarks", "a"."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" "a",
        "INV"."INV_Master_Store" "b",
        "INV"."INV_Master_Item" "c",
        "INV"."INV_Master_Location" "d"
        WHERE "a"."INVMST_Id" = "b"."INVMST_Id" AND "a"."INVMI_Id" = "c"."INVMI_Id" AND "a"."INVMLO_Id" = "d"."INVMLO_Id" 
        AND "a"."MI_Id" = "b"."MI_Id" AND "a"."INVADI_ActiveFlg" = TRUE
        AND "a"."MI_Id" = ' || "@MI_Id"::VARCHAR || ' ' || "@dates" || ' AND "a"."INVMLO_Id" IN (' || "@INVMLO_Id" || ')';
    END IF;

    RETURN QUERY EXECUTE "@dynamic";

END;
$$;