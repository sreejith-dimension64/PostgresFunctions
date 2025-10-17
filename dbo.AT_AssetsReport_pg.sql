CREATE OR REPLACE FUNCTION "dbo"."AT_AssetsReport" (
    "p_MI_Id" BIGINT, 
    "p_selectionflag" VARCHAR(50), 
    "p_INVMLO_Id" VARCHAR(100), 
    "p_INVMI_Id" VARCHAR(100), 
    "p_coyear" VARCHAR(100)
)
RETURNS TABLE (
    "INVMLO_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVMLO_InchargeName" VARCHAR,
    "INVMI_ItemName" VARCHAR,
    "checkoutQty" NUMERIC,
    "disposeQty" NUMERIC,
    "avaiableStock" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_fromyear" VARCHAR(10);
    "v_Toyear" VARCHAR(10);
    "v_fromToYear" VARCHAR(20);
BEGIN

    SELECT split_part("p_coyear", '-', 2) INTO "v_Toyear";
    
    SELECT split_part("p_coyear", '-', 1) INTO "v_fromYear";
    
    SELECT "v_fromYear" || ',' || "v_Toyear" INTO "v_fromToYear";
    
    IF ("p_selectionflag" = 'All') THEN
        
        "v_Slqdymaic" := '   
        SELECT c."INVMLO_Id", d."INVMI_Id", b."INVMLO_LocationRoomName", NULL::VARCHAR AS "INVMLO_InchargeName", e."INVMI_ItemName",
        SUM(d."INVSTO_CheckedOutQty") AS checkoutQty,
        SUM(d."INVSTO_DisposedQty") AS disposeQty,
        SUM(d."INVSTO_AvaiableStock") AS avaiableStock
        FROM "INV"."INV_Master_Site" a 
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMSI_Id" = b."INVMSI_Id" AND b."INVMLO_ActiveFlg" = 1
        INNER JOIN "INV"."INV_Asset_CheckOut" c ON b."INVMLO_Id" = c."INVMLO_Id"
        INNER JOIN "INV"."INV_Stock" d ON d."INVMI_Id" = c."INVMI_Id" AND d."INVMST_Id" = c."INVMST_Id" 
        INNER JOIN "INV"."INV_Master_Item" e ON d."INVMI_Id" = e."INVMI_Id" AND e."INVMI_Id" = c."INVMI_Id" 
        WHERE a."MI_Id" = b."MI_Id" AND c."MI_Id" = d."MI_Id" AND d."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' 
        GROUP BY c."INVMLO_Id", d."INVMI_Id", b."INVMLO_LocationRoomName", e."INVMI_ItemName" 
        ORDER BY e."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_selectionflag" = 'Location' THEN
        
        "v_Slqdymaic" := '
        SELECT a."INVMLO_Id", a."INVMI_Id", NULL::VARCHAR AS "INVMLO_LocationRoomName", NULL::VARCHAR AS "INVMLO_InchargeName", b."INVMI_ItemName", 
        SUM(a."INVACO_CheckOutQty") AS checkoutQty, 
        NULL::NUMERIC AS disposeQty,
        NULL::NUMERIC AS avaiableStock
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id" 
        INNER JOIN "INV"."INV_Master_Location" c ON a."INVMLO_Id" = c."INVMLO_Id"
        WHERE a."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND a."INVMLO_Id" IN (' || "p_INVMLO_Id" || ') AND EXTRACT(YEAR FROM a."INVACO_CheckoutDate") IN (' || "v_fromToYear" || ')
        GROUP BY a."INVMLO_Id", a."INVMI_Id", b."INVMI_ItemName" 
        HAVING SUM(a."INVACO_CheckOutQty") > 0';
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_selectionflag" = 'Item' THEN
        
        "v_Slqdymaic" := '
        SELECT c."INVMLO_Id", d."INVMI_Id", b."INVMLO_LocationRoomName", NULL::VARCHAR AS "INVMLO_InchargeName", e."INVMI_ItemName",
        SUM(d."INVSTO_CheckedOutQty") AS checkoutQty,
        SUM(d."INVSTO_DisposedQty") AS disposeQty,
        SUM(d."INVSTO_AvaiableStock") AS avaiableStock
        FROM "INV"."INV_Master_Site" a 
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMSI_Id" = b."INVMSI_Id" AND b."INVMLO_ActiveFlg" = 1
        INNER JOIN "INV"."INV_Asset_CheckOut" c ON b."INVMLO_Id" = c."INVMLO_Id"
        INNER JOIN "INV"."INV_Stock" d ON d."INVMI_Id" = c."INVMI_Id" AND d."INVMST_Id" = c."INVMST_Id" 
        INNER JOIN "INV"."INV_Master_Item" e ON d."INVMI_Id" = e."INVMI_Id" AND e."INVMI_Id" = c."INVMI_Id" 
        WHERE a."MI_Id" = b."MI_Id" AND c."MI_Id" = d."MI_Id" AND d."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' AND c."INVMI_Id" IN (' || "p_INVMI_Id" || ') 
        GROUP BY c."INVMLO_Id", d."INVMI_Id", b."INVMLO_LocationRoomName", e."INVMI_ItemName"
        ORDER BY b."INVMLO_LocationRoomName"';
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    END IF;

    RETURN;

END;
$$;