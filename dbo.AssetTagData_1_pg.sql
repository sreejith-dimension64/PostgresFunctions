CREATE OR REPLACE FUNCTION "dbo"."AssetTagData_1"(
    "p_MI_Id" bigint,
    "p_INVMST_Id" BIGINT,
    "p_INVMI_Id" BIGINT,
    "p_PurchaseRate" DECIMAL(18,2)
)
RETURNS TABLE(
    "INVMI_Id" bigint,
    "INVMST_Id" bigint,
    "INVMS_StoreName" varchar(200),
    "INVMI_ItemName" varchar(200),
    "ActualQty" int,
    "invaaT_PurchaseDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Itemid" bigint;
    "v_storeid" bigint;
    "v_StoreName" varchar(200);
    "v_ItemName" varchar(200);
    "v_ActualQty" int;
    "v_Rcount" int;
    "v_ActualQty_New" int;
    "v_i" int;
    "v_n" int;
    "v_purchase_date" timestamp;
    "stockitems_rec" RECORD;
BEGIN
    "v_i" := 1;

    DROP TABLE IF EXISTS "AssetItems_Temp_1";

    CREATE TEMP TABLE "AssetItems_Temp_1" (
        "INVMI_Id" bigint,
        "INVMST_Id" bigint,
        "INVMS_StoreName" varchar(200),
        "INVMI_ItemName" varchar(200),
        "ActualQty" int,
        "invaaT_PurchaseDate" timestamp
    );

    FOR "stockitems_rec" IN
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMST_Id",
            b."INVMS_StoreName",
            c."INVMI_ItemName",
            CAST(ROUND(a."INVSTO_AvaiableStock" - COALESCE(a."INVSTO_DisposedQty", 0), 0) AS int) AS "ActualQty",
            e."INVMGRN_PurchaseDate"
        FROM "INV"."INV_Stock" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        INNER JOIN "inv"."INV_M_GRN_Store" d ON a."INVMST_Id" = d."INVMST_Id"
        INNER JOIN "inv"."INV_M_GRN" e ON e."INVMGRN_Id" = d."INVMGRN_Id" AND e."MI_Id" = "p_MI_Id"
        INNER JOIN "inv"."INV_T_GRN" f ON f."INVMGRN_Id" = d."INVMGRN_Id"
        WHERE a."MI_Id" = "p_MI_Id" 
            AND b."INVMST_Id" = "p_INVMST_Id" 
            AND a."INVMI_Id" = "p_INVMI_Id" 
            AND a."INVSTO_PurchaseRate" = "p_PurchaseRate" 
            AND e."MI_Id" = "p_MI_Id"
    LOOP
        "v_Itemid" := "stockitems_rec"."INVMI_Id";
        "v_storeid" := "stockitems_rec"."INVMST_Id";
        "v_StoreName" := "stockitems_rec"."INVMS_StoreName";
        "v_ItemName" := "stockitems_rec"."INVMI_ItemName";
        "v_ActualQty" := "stockitems_rec"."ActualQty";
        "v_purchase_date" := "stockitems_rec"."INVMGRN_PurchaseDate";

        SELECT COUNT(*) INTO "v_Rcount"
        FROM "INV"."INV_Asset_AssetTag"
        WHERE "MI_Id" = "p_MI_Id" 
            AND "INVMST_Id" = "p_INVMST_Id" 
            AND "INVMI_Id" = "v_Itemid";

        IF ("v_Rcount" >= 1) THEN
            "v_ActualQty_New" := "v_ActualQty" - "v_Rcount";
            "v_n" := "v_ActualQty_New";

            WHILE ("v_i" <= "v_n") LOOP
                INSERT INTO "AssetItems_Temp_1" 
                VALUES("v_Itemid", "v_storeid", "v_StoreName", "v_ItemName", "v_ActualQty_New", "v_purchase_date");
                "v_i" := "v_i" + 1;
            END LOOP;
            "v_i" := 1;

        ELSIF ("v_Rcount" = 0) THEN
            "v_n" := "v_ActualQty";

            WHILE ("v_i" <= "v_n") LOOP
                INSERT INTO "AssetItems_Temp_1" 
                VALUES("v_Itemid", "v_storeid", "v_StoreName", "v_ItemName", "v_ActualQty", "v_purchase_date");
                "v_i" := "v_i" + 1;
            END LOOP;
            "v_i" := 1;
        END IF;

    END LOOP;

    RETURN QUERY SELECT * FROM "AssetItems_Temp_1";

    RETURN;
END;
$$;