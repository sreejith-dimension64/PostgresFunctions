CREATE OR REPLACE FUNCTION "dbo"."INV_DashboardGrid"(
    "MI_Id" bigint,
    "expiredays" bigint,
    "typeflg" varchar(100)
)
RETURNS TABLE (
    "INVSTO_Id" bigint,
    "INVMI_Id" bigint,
    "INVMI_ItemName" text,
    "INVSTO_PurchaseDate" timestamp,
    "INVSTO_SalesRate" numeric,
    "INVSTO_AvaiableStock" numeric,
    "INVAAT_Id" bigint,
    "INVMST_Id" bigint,
    "INVMS_StoreName" text,
    "INVAAT_AssetId" text,
    "INVAAT_AssetDescription" text,
    "INVAAT_ManufacturedDate" timestamp,
    "INVAAT_SKU" text,
    "INVAAT_ModelNo" text,
    "INVAAT_SerialNo" text,
    "INVAAT_PurchaseDate" timestamp,
    "INVAAT_WarantyPeriod" text,
    "INVAAT_WarantyExpiryDate" timestamp,
    "INVAAT_UnderAMCFlg" boolean,
    "INVAAT_AMCExpiryDate" timestamp,
    "INVAAT_CheckOutFlg" boolean,
    "INVAAT_DisposedFlg" boolean,
    "INVAAT_ActiveFlg" boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
    v_edays text;
BEGIN
    -- INV_DashboardGrid 4,2,'Tag'
    
    IF "expiredays" IS NOT NULL AND "expiredays" != 0 THEN
        v_edays := "expiredays"::text;
    END IF;

    IF ("typeflg" = 'Stock') THEN
        
        RETURN QUERY
        SELECT DISTINCT 
            a."INVSTO_Id", 
            a."INVMI_Id",
            b."INVMI_ItemName",
            a."INVSTO_PurchaseDate",
            a."INVSTO_SalesRate",
            a."INVSTO_AvaiableStock",
            NULL::bigint,
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::timestamp,
            NULL::text,
            NULL::text,
            NULL::text,
            NULL::timestamp,
            NULL::text,
            NULL::timestamp,
            NULL::boolean,
            NULL::timestamp,
            NULL::boolean,
            NULL::boolean,
            NULL::boolean
        FROM "INV"."INV_Stock" a
        INNER JOIN "INV"."INV_Master_Item" b ON a."INVMI_Id" = b."INVMI_Id" AND a."MI_Id" = b."MI_Id" AND b."INVMI_ActiveFlg" = true
        WHERE a."MI_Id" = "MI_Id";
        
    ELSIF ("typeflg" = 'Tag') THEN
        
        RETURN QUERY
        SELECT DISTINCT  
            NULL::bigint,
            NULL::bigint,
            NULL::text,
            NULL::timestamp,
            NULL::numeric,
            NULL::numeric,
            a."INVAAT_Id",
            a."INVMST_Id",
            c."INVMS_StoreName",
            a."INVMI_Id"::text,
            d."INVMI_ItemName",
            a."INVAAT_AssetId"::text,
            a."INVAAT_AssetDescription",
            a."INVAAT_ManufacturedDate",
            a."INVAAT_SKU",
            a."INVAAT_ModelNo",
            a."INVAAT_SerialNo",
            a."INVAAT_PurchaseDate",
            a."INVAAT_WarantyPeriod",
            a."INVAAT_WarantyExpiryDate",
            a."INVAAT_UnderAMCFlg",
            a."INVAAT_AMCExpiryDate",
            a."INVAAT_CheckOutFlg",
            a."INVAAT_DisposedFlg",
            a."INVAAT_ActiveFlg"
        FROM "INV"."INV_Asset_AssetTag" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id" AND a."MI_Id" = b."MI_Id" AND a."INVAAT_ActiveFlg" = true
        INNER JOIN "INV"."INV_Master_Store" c ON a."INVMST_Id" = c."INVMST_Id" AND c."INVMST_Id" = b."INVMST_Id" AND c."INVMS_ActiveFlg" = true
        INNER JOIN "INV"."INV_Master_Item" d ON a."INVMI_Id" = b."INVMI_Id" AND b."INVMI_Id" = d."INVMI_Id" AND d."INVMI_ActiveFlg" = true
        WHERE a."MI_Id" = "MI_Id" 
        AND CAST(a."INVAAT_WarantyExpiryDate" AS DATE) <= CURRENT_DATE + (v_edays::integer || ' days')::interval;
        
    END IF;

    RETURN;
END;
$$;