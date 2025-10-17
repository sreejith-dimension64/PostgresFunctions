CREATE OR REPLACE FUNCTION "dbo"."HSMINV_ItemReport"(
    "MI_Id" BIGINT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "INVMI_Ids" TEXT,
    "INVMG_Id" VARCHAR(100),
    "optionflag" VARCHAR(50),
    "INVMST_Id" BIGINT
)
RETURNS TABLE(
    "INVMG_Id" BIGINT,
    "INVMG_GroupName" TEXT,
    "INVMI_Id" BIGINT,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" TEXT,
    "INVMUOM_UOMAliasName" TEXT,
    "INVMI_ItemName" TEXT,
    "INVMI_MaxStock" NUMERIC,
    "INVMI_TaxAplFlg" BOOLEAN,
    "INVMI_ItemCode" TEXT,
    "INVMI_ReorderStock" NUMERIC,
    "INVMI_RawMatFlg" BOOLEAN,
    "INVMI_ForSaleFlg" BOOLEAN,
    "INVMI_MaintenanceAplFlg" BOOLEAN,
    "INVMI_HSNCode" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "INVMST_Id" = 0 THEN
        IF "startdate" != '' AND "enddate" != '' THEN
            "dates" := 'AND "CreatedDate"::date BETWEEN TO_DATE(''' || "startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''', ''DD/MM/YYYY'')';
        ELSE
            "dates" := '';
        END IF;
        
        IF "optionflag" = 'Item' THEN
            "Slqdymaic" := '
            SELECT DISTINCT NULL::BIGINT AS "INVMG_Id", NULL::TEXT AS "INVMG_GroupName", "MI"."INVMI_Id", "MI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName", 
            "MI"."INVMI_ItemName", "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", "MI"."INVMI_ReorderStock",
            "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
            FROM "INV"."INV_Master_Item" "MI"
            INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
            WHERE "MI"."INVMI_ActiveFlg" = true AND "UOM"."INVMUOM_ActiveFlg" = true 
            AND "MI"."INVMI_Id" IN (' || "INVMI_Ids" || ') 
            AND "MI"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates" || '
            ORDER BY "MI"."INVMI_ItemName"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "optionflag" = 'Group' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MI"."INVMG_Id", "MG"."INVMG_GroupName", "MI"."INVMI_Id", "MI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName",
            "MI"."INVMI_ItemName", "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", "MI"."INVMI_ReorderStock",
            "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
            FROM "INV"."INV_Master_Item" "MI"
            INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
            INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id" = "MI"."INVMG_Id"
            WHERE "MI"."INVMI_ActiveFlg" = true AND "UOM"."INVMUOM_ActiveFlg" = true AND "MG"."INVMG_ActiveFlg" = true 
            AND "MI"."INVMG_Id" IN (' || "INVMG_Id" || ') 
            AND "MI"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates" || '
            ORDER BY "MG"."INVMG_GroupName"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
    ELSE
        IF "startdate" != '' AND "enddate" != '' THEN
            "dates" := 'AND "CreatedDate"::date BETWEEN TO_DATE(''' || "startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''', ''DD/MM/YYYY'')';
        ELSE
            "dates" := '';
        END IF;
        
        IF "optionflag" = 'Item' THEN
            "Slqdymaic" := '
            SELECT DISTINCT NULL::BIGINT AS "INVMG_Id", NULL::TEXT AS "INVMG_GroupName", "MI"."INVMI_Id", "MI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName",
            "MI"."INVMI_ItemName", "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", "MI"."INVMI_ReorderStock",
            "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
            FROM "INV"."INV_Master_Item" "MI"
            INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
            INNER JOIN "INV"."INV_T_GRN" "c" ON "c"."INVMI_Id" = "MI"."INVMI_Id"
            INNER JOIN "INV"."INV_M_GRN" "d" ON "d"."INVMGRN_Id" = "c"."INVMGRN_Id"
            INNER JOIN "INV"."INV_M_GRN_Store" "e" ON "e"."INVMGRN_Id" = "c"."INVMGRN_Id"
            WHERE "MI"."INVMI_ActiveFlg" = true AND "UOM"."INVMUOM_ActiveFlg" = true 
            AND "MI"."INVMI_Id" IN (' || "INVMI_Ids" || ') 
            AND "e"."INVMST_Id" = ' || "INVMST_Id"::TEXT || ' 
            AND "MI"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates" || '
            ORDER BY "MI"."INVMI_ItemName"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
            
        ELSIF "optionflag" = 'Group' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MI"."INVMG_Id", "MG"."INVMG_GroupName", "MI"."INVMI_Id", "MI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName",
            "MI"."INVMI_ItemName", "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", "MI"."INVMI_ReorderStock",
            "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
            FROM "INV"."INV_Master_Item" "MI"
            INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
            INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id" = "MI"."INVMG_Id"
            INNER JOIN "INV"."INV_T_GRN" "c" ON "c"."INVMI_Id" = "MI"."INVMI_Id"
            INNER JOIN "INV"."INV_M_GRN" "d" ON "d"."INVMGRN_Id" = "c"."INVMGRN_Id"
            INNER JOIN "INV"."INV_M_GRN_Store" "e" ON "e"."INVMGRN_Id" = "c"."INVMGRN_Id"
            WHERE "MI"."INVMI_ActiveFlg" = true AND "UOM"."INVMUOM_ActiveFlg" = true AND "MG"."INVMG_ActiveFlg" = true 
            AND "MI"."INVMG_Id" IN (' || "INVMG_Id" || ') 
            AND "e"."INVMST_Id" = ' || "INVMST_Id"::TEXT || ' 
            AND "MI"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates" || '
            ORDER BY "MG"."INVMG_GroupName"';
            
            RETURN QUERY EXECUTE "Slqdymaic";
        END IF;
    END IF;
    
    RETURN;
END;
$$;