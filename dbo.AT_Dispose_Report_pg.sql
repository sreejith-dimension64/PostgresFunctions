CREATE OR REPLACE FUNCTION "dbo"."AT_Dispose_Report"(
    "MI_Id" BIGINT,
    "selectionflag" VARCHAR(50),
    "INVMI_Id" VARCHAR(50),
    "INVMLO_Id" VARCHAR(50)
)
RETURNS TABLE(
    "INVADI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVADI_DisposedDate" TIMESTAMP,
    "INVADI_DisposedQty" NUMERIC,
    "INVADI_DisposedRemarks" TEXT,
    "INVADI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "dynamic" TEXT;
BEGIN

    IF "selectionflag" = 'All' THEN
        "dynamic" := '
        SELECT DISTINCT a."INVADI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVADI_DisposedDate", a."INVADI_DisposedQty", a."INVADI_DisposedRemarks", a."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVADI_ActiveFlg" = TRUE
        AND a."MI_Id" = ' || "MI_Id"::VARCHAR;
        
    ELSIF "selectionflag" = 'Item' THEN
        "dynamic" := '
        SELECT DISTINCT a."INVADI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVADI_DisposedDate", a."INVADI_DisposedQty", a."INVADI_DisposedRemarks", a."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVADI_ActiveFlg" = TRUE
        AND a."MI_Id" = ' || "MI_Id"::VARCHAR || ' AND a."INVMI_Id" IN (' || "INVMI_Id" || ')';
        
    ELSIF "selectionflag" = 'Location' THEN
        "dynamic" := '
        SELECT DISTINCT a."INVADI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
        a."INVADI_DisposedDate", a."INVADI_DisposedQty", a."INVADI_DisposedRemarks", a."INVADI_ActiveFlg"
        FROM "INV"."INV_Asset_Dispose" a,
        "INV"."INV_Master_Store" b,
        "INV"."INV_Master_Item" c,
        "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" AND a."INVMI_Id" = c."INVMI_Id" AND a."INVMLO_Id" = d."INVMLO_Id" AND a."MI_Id" = b."MI_Id" AND a."INVADI_ActiveFlg" = TRUE
        AND a."MI_Id" = ' || "MI_Id"::VARCHAR || ' AND a."INVMLO_Id" IN (' || "INVMLO_Id" || ')';
        
    END IF;

    RETURN QUERY EXECUTE "dynamic";
    
END;
$$;