CREATE OR REPLACE FUNCTION "dbo"."INV_ItemReport" (
    "p_MI_Id" BIGINT,
    "p_startdate" VARCHAR(10),
    "p_enddate" VARCHAR(10),
    "p_INVMI_Ids" TEXT,
    "p_INVMG_Id" VARCHAR(100),
    "p_optionflag" VARCHAR(50)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'and "CreatedDate"::date between to_date(''' || "p_startdate" || ''',''DD/MM/YYYY'') and to_date(''' || "p_enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MI"."INVMI_Id", "MI"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName", 
               "MI"."INVMI_ItemName", "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", 
               "MI"."INVMI_ReorderStock", "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", 
               "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
        FROM "INV"."INV_Master_Item" "MI"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
        WHERE "MI"."INVMI_ActiveFlg" = 1 AND "UOM"."INVMUOM_ActiveFlg" = 1 
              AND "MI"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') 
              AND "MI"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates" || '
        ORDER BY "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Group' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MI"."INVMG_Id", "MG"."INVMG_GroupName", "MI"."INVMI_Id", "MI"."INVMUOM_Id", 
               "UOM"."INVMUOM_UOMName", "UOM"."INVMUOM_UOMAliasName", "MI"."INVMI_ItemName", 
               "MI"."INVMI_MaxStock", "MI"."INVMI_TaxAplFlg", "MI"."INVMI_ItemCode", 
               "MI"."INVMI_ReorderStock", "MI"."INVMI_RawMatFlg", "MI"."INVMI_ForSaleFlg", 
               "MI"."INVMI_MaintenanceAplFlg", "MI"."INVMI_HSNCode"
        FROM "INV"."INV_Master_Item" "MI"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "MI"."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id" = "MI"."INVMG_Id"
        WHERE "MI"."INVMI_ActiveFlg" = 1 AND "UOM"."INVMUOM_ActiveFlg" = 1 
              AND "MG"."INVMG_ActiveFlg" = 1 
              AND "MI"."INVMG_Id" IN (' || "p_INVMG_Id" || ') 
              AND "MI"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates" || '
        ORDER BY "MG"."INVMG_GroupName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    END IF;

    RETURN;
END;
$$;