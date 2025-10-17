CREATE OR REPLACE FUNCTION "dbo"."GRN_activ_deactive_proc"(
    "p_MI_Id" bigint,
    "p_INVMGRN_Id" bigint,
    "p_flag" text
)
RETURNS TABLE("outputdata" text)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_count_one" bigint;
    "v_count_two" bigint;
    "v_purchasedate" date;
BEGIN

    CREATE TABLE IF NOT EXISTS "dbo"."INV_Stock_temp"(
        "MI_Id" bigint,
        "INVMST_Id" bigint,
        "INVMI_Id" bigint,
        "INVSTO_PurchaseDate" timestamp,
        "INVSTO_PurchaseRate" decimal(32,2),
        "INVSTO_BatchNo" varchar(500),
        "INVSTO_SalesRate" decimal(32,2),
        "INVSTO_PurOBQty" decimal(32,2),
        "INVSTO_PurRetQty" decimal(32,2),
        "INVSTO_SalesQty" decimal(32,2),
        "INVSTO_SalesRetQty" decimal(32,2),
        "INVSTO_ItemConQty" decimal(32,2),
        "INVSTO_MatIssPlusQty" decimal(32,2),
        "INVSTO_MatIssMinusQty" decimal(32,2),
        "INVSTO_PhyPlusQty" decimal(32,2),
        "INVSTO_PhyMinQty" decimal(32,2),
        "INVSTO_AvaiableStock" decimal(32,2),
        "CreatedDate" timestamp,
        "UpdatedDate" timestamp,
        "INVSTO_CheckedOutQty" decimal(32,2),
        "INVSTO_DisposedQty" decimal(32,2),
        "IMFY_Id" bigint
    );

    SELECT "INVMGRN_PurchaseDate" INTO "v_purchasedate"
    FROM "INV"."INV_M_GRN" 
    WHERE "MI_Id" = "p_MI_Id" AND "INVMGRN_Id" = "p_INVMGRN_Id";

    IF "p_flag" = 'DeActive' THEN

        SELECT COUNT(*) INTO "v_count_one"
        FROM "INV"."INV_Stock" 
        WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date) 
        AND "INVSTO_ItemConQty" IS NULL 
        AND "INVSTO_SalesQty" = 0  
        AND "INVSTO_CheckedOutQty" IS NULL 
        AND "INVSTO_DisposedQty" IS NULL;

        SELECT COUNT(*) INTO "v_count_two"
        FROM "INV"."INV_Stock" 
        WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date);

        IF "v_count_one" = "v_count_two" THEN

            INSERT INTO "dbo"."INV_Stock_Temp" (
                "MI_Id", "INVMST_Id", "INVMI_Id", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", 
                "INVSTO_BatchNo", "INVSTO_SalesRate", "INVSTO_PurOBQty", "INVSTO_PurRetQty", 
                "INVSTO_SalesQty", "INVSTO_SalesRetQty", "INVSTO_ItemConQty", "INVSTO_MatIssPlusQty", 
                "INVSTO_MatIssMinusQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_AvaiableStock", 
                "CreatedDate", "UpdatedDate", "INVSTO_CheckedOutQty", "INVSTO_DisposedQty", "IMFY_Id"
            )
            SELECT "MI_Id", "INVMST_Id", "INVMI_Id", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", 
                "INVSTO_BatchNo", "INVSTO_SalesRate", "INVSTO_PurOBQty", "INVSTO_PurRetQty", 
                "INVSTO_SalesQty", "INVSTO_SalesRetQty", "INVSTO_ItemConQty", "INVSTO_MatIssPlusQty", 
                "INVSTO_MatIssMinusQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_AvaiableStock", 
                "CreatedDate", "UpdatedDate", "INVSTO_CheckedOutQty", "INVSTO_DisposedQty", "IMFY_Id"
            FROM "INV"."INV_STOCK" 
            WHERE "MI_Id" = "p_MI_Id" 
            AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
            AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
            AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date);

            DELETE FROM "INV"."INV_STOCK" 
            WHERE "MI_Id" = "p_MI_Id" 
            AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
            AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
            AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date);

            UPDATE "INV"."INV_M_GRN" 
            SET "INVMGRN_ActiveFlg" = 0 
            WHERE "MI_Id" = "p_MI_Id" AND "INVMGRN_Id" = "p_INVMGRN_Id";

            UPDATE "INV"."INV_T_GRN" 
            SET "INVTGRN_ActiveFlg" = 0 
            WHERE "INVMGRN_Id" = "p_INVMGRN_Id";

            RETURN QUERY SELECT 'DeActive'::text;

        ELSE
            RETURN QUERY SELECT 'notDeActive'::text;
        END IF;

    ELSIF "p_flag" = 'Active' THEN

        INSERT INTO "INV"."INV_STOCK" (
            "MI_Id", "INVMST_Id", "INVMI_Id", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", 
            "INVSTO_BatchNo", "INVSTO_SalesRate", "INVSTO_PurOBQty", "INVSTO_PurRetQty", 
            "INVSTO_SalesQty", "INVSTO_SalesRetQty", "INVSTO_ItemConQty", "INVSTO_MatIssPlusQty", 
            "INVSTO_MatIssMinusQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_AvaiableStock", 
            "CreatedDate", "UpdatedDate", "INVSTO_CheckedOutQty", "INVSTO_DisposedQty", "IMFY_Id"
        )
        SELECT "MI_Id", "INVMST_Id", "INVMI_Id", "INVSTO_PurchaseDate", "INVSTO_PurchaseRate", 
            "INVSTO_BatchNo", "INVSTO_SalesRate", "INVSTO_PurOBQty", "INVSTO_PurRetQty", 
            "INVSTO_SalesQty", "INVSTO_SalesRetQty", "INVSTO_ItemConQty", "INVSTO_MatIssPlusQty", 
            "INVSTO_MatIssMinusQty", "INVSTO_PhyPlusQty", "INVSTO_PhyMinQty", "INVSTO_AvaiableStock", 
            "CreatedDate", "UpdatedDate", "INVSTO_CheckedOutQty", "INVSTO_DisposedQty", "IMFY_Id"
        FROM "dbo"."INV_Stock_Temp" 
        WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date);

        DELETE FROM "dbo"."INV_Stock_Temp" 
        WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" IN (SELECT "INVMST_Id" FROM "INV"."INV_M_GRN_Store" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND "INVMI_Id" IN (SELECT "INVMI_Id" FROM "INV"."INV_T_GRN" WHERE "INVMGRN_Id" = "p_INVMGRN_Id") 
        AND CAST("INVSTO_PurchaseDate" AS date) = CAST("v_purchasedate" AS date);

        UPDATE "INV"."INV_M_GRN" 
        SET "INVMGRN_ActiveFlg" = 1 
        WHERE "MI_Id" = "p_MI_Id" AND "INVMGRN_Id" = "p_INVMGRN_Id";

        UPDATE "INV"."INV_T_GRN" 
        SET "INVTGRN_ActiveFlg" = 1 
        WHERE "INVMGRN_Id" = "p_INVMGRN_Id";

        RETURN QUERY SELECT 'Active'::text;

    END IF;

    RETURN;

END;
$$;