CREATE OR REPLACE FUNCTION "INV"."AT_CheckIn_Report"(
    "p_MI_Id" BIGINT,
    "p_selectionflag" VARCHAR(50),
    "p_INVMI_Id" VARCHAR(50),
    "p_INVMLO_Id" VARCHAR(50)
)
RETURNS TABLE(
    "INVACI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_Id" BIGINT,
    "HRME_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVACI_CheckInDate" TIMESTAMP,
    "INVACI_CheckInQty" NUMERIC,
    "INVACI_ReceivedBy" VARCHAR,
    "INVACI_CheckInRemarks" TEXT,
    "INVACI_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_dynamic" TEXT;
BEGIN
    
    IF "p_selectionflag" = 'All' THEN
        
        "v_dynamic" := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
                        b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
                        a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
                        a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a,
             "INV"."INV_Master_Store" b,
             "INV"."INV_Master_Item" c,
             "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" 
          AND a."INVMI_Id" = c."INVMI_Id" 
          AND a."INVMLO_Id" = d."INVMLO_Id" 
          AND a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = TRUE 
          AND a."MI_Id" = ' || "p_MI_Id";
        
    ELSIF "p_selectionflag" = 'Item' THEN
        
        "v_dynamic" := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
                        b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
                        a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
                        a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a,
             "INV"."INV_Master_Store" b,
             "INV"."INV_Master_Item" c,
             "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" 
          AND a."INVMI_Id" = c."INVMI_Id" 
          AND a."INVMLO_Id" = d."INVMLO_Id" 
          AND a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = TRUE 
          AND a."MI_Id" = ' || "p_MI_Id" || ' 
          AND a."INVMI_Id" IN (' || "p_INVMI_Id" || ')';
        
    ELSIF "p_selectionflag" = 'Location' THEN
        
        "v_dynamic" := '
        SELECT DISTINCT a."INVACI_Id", a."INVMST_Id", a."INVMI_Id", a."INVMLO_Id", a."HRME_Id", 
                        b."INVMS_StoreName", c."INVMI_ItemName", d."INVMLO_LocationRoomName",
                        a."INVACI_CheckInDate", a."INVACI_CheckInQty", a."INVACI_ReceivedBy", 
                        a."INVACI_CheckInRemarks", a."INVACI_ActiveFlg"
        FROM "INV"."INV_Asset_CheckIn" a,
             "INV"."INV_Master_Store" b,
             "INV"."INV_Master_Item" c,
             "INV"."INV_Master_Location" d
        WHERE a."INVMST_Id" = b."INVMST_Id" 
          AND a."INVMI_Id" = c."INVMI_Id" 
          AND a."INVMLO_Id" = d."INVMLO_Id" 
          AND a."MI_Id" = b."MI_Id" 
          AND a."INVACI_ActiveFlg" = TRUE 
          AND a."MI_Id" = ' || "p_MI_Id" || ' 
          AND a."INVMLO_Id" IN (' || "p_INVMLO_Id" || ')';
        
    END IF;
    
    RETURN QUERY EXECUTE "v_dynamic";
    
END;
$$;