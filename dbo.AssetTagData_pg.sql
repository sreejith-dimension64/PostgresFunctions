CREATE OR REPLACE FUNCTION "dbo"."AssetTagData"("@MI_Id" bigint, "@INVMST_Id" bigint)
RETURNS TABLE(
    "INVMI_Id" bigint,
    "INVMST_Id" bigint,
    "INVMS_StoreName" varchar(200),
    "INVMI_ItemName" varchar(200),
    "ActualQty" int
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Itemid" bigint;
    "@storeid" bigint;
    "@StoreName" varchar(200);
    "@ItemName" varchar(200);
    "@ActualQty" int;
    "@Rcount" int;
    "@ActualQty_New" int;
    "@i" int;
    "@n" int;
    stockitems_rec RECORD;
BEGIN
    "@i" := 1;

    DROP TABLE IF EXISTS "AssetItems_Temp";

    CREATE TEMP TABLE "AssetItems_Temp" (
        "INVMI_Id" bigint,
        "INVMST_Id" bigint,
        "INVMS_StoreName" varchar(200),
        "INVMI_ItemName" varchar(200),
        "ActualQty" int
    );

    FOR stockitems_rec IN
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMST_Id",
            b."INVMS_StoreName",
            c."INVMI_ItemName",
            CAST(ROUND(a."INVSTO_AvaiableStock" - COALESCE(a."INVSTO_DisposedQty", 0), 0) AS int) AS "ActualQty"
        FROM "INV"."INV_Stock" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id"
        INNER JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
        WHERE a."MI_Id" = "@MI_Id" AND b."INVMST_Id" = "@INVMST_Id"
    LOOP
        "@Itemid" := stockitems_rec."INVMI_Id";
        "@storeid" := stockitems_rec."INVMST_Id";
        "@StoreName" := stockitems_rec."INVMS_StoreName";
        "@ItemName" := stockitems_rec."INVMI_ItemName";
        "@ActualQty" := stockitems_rec."ActualQty";

        SELECT COUNT(*) INTO "@Rcount"
        FROM "INV"."INV_Asset_AssetTag"
        WHERE "MI_Id" = "@MI_Id" AND "INVMST_Id" = "@INVMST_Id" AND "INVMI_Id" = "@Itemid";

        IF ("@Rcount" >= 1) THEN
            "@ActualQty_New" := "@ActualQty" - "@Rcount";
            "@n" := "@ActualQty_New";

            WHILE ("@i" <= "@n") LOOP
                INSERT INTO "AssetItems_Temp" VALUES("@Itemid", "@storeid", "@StoreName", "@ItemName", "@ActualQty_New");
                "@i" := "@i" + 1;
            END LOOP;
            "@i" := 1;

        ELSIF ("@Rcount" = 0) THEN
            "@n" := "@ActualQty";

            WHILE ("@i" <= "@n") LOOP
                INSERT INTO "AssetItems_Temp" VALUES("@Itemid", "@storeid", "@StoreName", "@ItemName", "@ActualQty");
                "@i" := "@i" + 1;
            END LOOP;
            "@i" := 1;
        END IF;

    END LOOP;

    RETURN QUERY SELECT * FROM "AssetItems_Temp";

END;
$$;