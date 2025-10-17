CREATE OR REPLACE FUNCTION "dbo"."INV_InsertPhysicalStock"(
    "p_MI_Id" bigint,
    "p_INVMST_Id" bigint,
    "p_INVMI_Id" bigint,
    "p_SalesRate" decimal(18,2),
    "p_StockPlus" decimal(18,2),
    "p_StockMinus" decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_tssid" BIGINT;
    "v_oldqty" FLOAT;
    "v_newqty" FLOAT;
    "v_batch" VARCHAR(50);
    "v_storeid" BIGINT;
    "v_phyprice" FLOAT;
    "v_sellprice" FLOAT;
    "v_item" BIGINT;
    "v_soldqty" FLOAT;
    "v_sbatch" VARCHAR(50);
    "v_sstoreid" FLOAT;
    "v_sphyprice" FLOAT;
    "v_ssellprice" FLOAT;
    "v_sitem" BIGINT;
    "v_newbatch" VARCHAR(50);
    "v_newstoreid" BIGINT;
    "v_newphyprice" FLOAT;
    "v_SalesPrice" FLOAT;
    "v_newitem" BIGINT;
    "v_IMFY_Id" bigint;
    "v_PurchaseDate" date;
    "v_newPurchaseDate" date;
    "v_sPurchaseDate" date;
    "v_sMI_Id" bigint;
    "v_newinstitution" bigint;
    "v_INVTIC_ICQty" decimal(18,2);
    "v_lifo" varchar(60);
    "v_CMI_Id" bigint;
    "v_INVSTO_Id" bigint;
    "v_citem" bigint;
    "v_Cstoreid" bigint;
    "v_ItemConQty" FLOAT;
    "rec_stock" RECORD;
BEGIN

    SELECT 
        COALESCE("INVSTO_Id", 0),
        COALESCE("INVMI_Id", 0),
        COALESCE("INVMST_Id", 0),
        COALESCE("INVSTO_AvaiableStock", 0),
        COALESCE("INVSTO_SalesRate", 0),
        COALESCE("INVSTO_PurchaseRate", 0),
        COALESCE("INVSTO_BatchNo", '0'),
        COALESCE(CAST("INVSTO_PurchaseDate" AS date), NULL),
        "MI_Id"
    INTO 
        "v_tssid",
        "v_sitem",
        "v_sstoreid",
        "v_soldqty",
        "v_ssellprice",
        "v_sphyprice",
        "v_sbatch",
        "v_sPurchaseDate",
        "v_sMI_Id"
    FROM "INV"."INV_Stock"
    WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" = "p_INVMST_Id" 
        AND "INVMI_Id" = "p_INVMI_Id" 
        AND "INVSTO_AvaiableStock" <> 0 
        AND "INVSTO_SalesRate" = "p_SalesRate";

    IF ("p_INVMI_Id" = "v_sitem" AND "p_INVMST_Id" = "v_sstoreid" AND "p_MI_Id" = "v_sMI_Id" AND "p_SalesRate" = "v_ssellprice") THEN
    
        SELECT "INVC_LIFOFIFOFlg" 
        INTO "v_lifo"
        FROM "INV"."INV_Configuration"
        WHERE "MI_Id" = "p_MI_Id" 
            AND "INVMST_Id" = "p_INVMST_Id" 
            AND "INVC_ProcessApplFlg" = 1;

        IF "v_lifo" = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';
            
            FOR "rec_stock" IN
                SELECT 
                    "MI_Id",
                    "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id",
                    "INVMST_Id",
                    "INVSTO_SalesRate",
                    "INVSTO_ItemConQty",
                    SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = "p_MI_Id" 
                    AND "INVMI_Id" = "p_INVMI_Id" 
                    AND "INVMST_Id" = "p_INVMST_Id" 
                    AND "INVSTO_AvaiableStock" <> 0 
                    AND "INVSTO_SalesRate" = "p_SalesRate"
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", "INVSTO_ItemConQty", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY CAST("INVSTO_PurchaseDate" AS date) DESC
            LOOP
                "v_CMI_Id" := "rec_stock"."MI_Id";
                "v_INVSTO_Id" := "rec_stock"."INVSTO_Id";
                "v_PurchaseDate" := "rec_stock"."INVSTO_PurchaseDate";
                "v_citem" := "rec_stock"."INVMI_Id";
                "v_Cstoreid" := "rec_stock"."INVMST_Id";
                "v_SalesPrice" := "rec_stock"."INVSTO_SalesRate";
                "v_ItemConQty" := "rec_stock"."INVSTO_ItemConQty";
                "v_soldqty" := "rec_stock"."AvaiableStock";

                IF "v_soldqty" > 0 AND "p_StockMinus" > 0 THEN
                    UPDATE "INV"."INV_Stock" 
                    SET "INVSTO_AvaiableStock" = ("v_soldqty" - "p_StockMinus"),
                        "INVSTO_PhyMinQty" = "INVSTO_PhyMinQty" + "p_StockMinus"
                    WHERE "MI_Id" = "p_MI_Id" 
                        AND "INVMI_Id" = "p_INVMI_Id" 
                        AND "INVMST_Id" = "p_INVMST_Id" 
                        AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                        AND "INVSTO_Id" = "v_INVSTO_Id" 
                        AND "INVSTO_SalesRate" = "v_SalesPrice";
                        
                ELSIF "v_soldqty" > 0 AND "p_StockPlus" > 0 THEN
                    UPDATE "INV"."INV_Stock" 
                    SET "INVSTO_AvaiableStock" = ("v_soldqty" + "p_StockPlus"),
                        "INVSTO_PhyPlusQty" = "INVSTO_PhyPlusQty" + "p_StockPlus"
                    WHERE "MI_Id" = "p_MI_Id" 
                        AND "INVMI_Id" = "p_INVMI_Id" 
                        AND "INVMST_Id" = "p_INVMST_Id" 
                        AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                        AND "INVSTO_Id" = "v_INVSTO_Id" 
                        AND "INVSTO_SalesRate" = "v_SalesPrice";
                END IF;
            END LOOP;

        ELSE
            RAISE NOTICE 'FIFO START';

            FOR "rec_stock" IN
                SELECT 
                    "MI_Id",
                    "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id",
                    "INVMST_Id",
                    "INVSTO_SalesRate",
                    "INVSTO_ItemConQty",
                    SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = "p_MI_Id" 
                    AND "INVMI_Id" = "p_INVMI_Id" 
                    AND "INVMST_Id" = "p_INVMST_Id" 
                    AND "INVSTO_AvaiableStock" <> 0 
                    AND "INVSTO_SalesRate" = "p_SalesRate"
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", "INVSTO_ItemConQty", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY CAST("INVSTO_PurchaseDate" AS date)
            LOOP
                "v_CMI_Id" := "rec_stock"."MI_Id";
                "v_INVSTO_Id" := "rec_stock"."INVSTO_Id";
                "v_PurchaseDate" := "rec_stock"."INVSTO_PurchaseDate";
                "v_citem" := "rec_stock"."INVMI_Id";
                "v_Cstoreid" := "rec_stock"."INVMST_Id";
                "v_SalesPrice" := "rec_stock"."INVSTO_SalesRate";
                "v_ItemConQty" := "rec_stock"."INVSTO_ItemConQty";
                "v_soldqty" := "rec_stock"."AvaiableStock";

                IF "v_soldqty" > 0 AND "p_StockMinus" > 0 THEN
                    UPDATE "INV"."INV_Stock" 
                    SET "INVSTO_AvaiableStock" = ("v_soldqty" - "p_StockMinus"),
                        "INVSTO_PhyMinQty" = "INVSTO_PhyMinQty" + "p_StockMinus"
                    WHERE "MI_Id" = "p_MI_Id" 
                        AND "INVMI_Id" = "p_INVMI_Id" 
                        AND "INVMST_Id" = "p_INVMST_Id" 
                        AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                        AND "INVSTO_Id" = "v_INVSTO_Id" 
                        AND "INVSTO_SalesRate" = "v_SalesPrice";
                        
                ELSIF "v_soldqty" > 0 AND "p_StockPlus" > 0 THEN
                    UPDATE "INV"."INV_Stock" 
                    SET "INVSTO_AvaiableStock" = ("v_soldqty" + "p_StockPlus"),
                        "INVSTO_PhyPlusQty" = "INVSTO_PhyPlusQty" + "p_StockPlus"
                    WHERE "MI_Id" = "p_MI_Id" 
                        AND "INVMI_Id" = "p_INVMI_Id" 
                        AND "INVMST_Id" = "p_INVMST_Id" 
                        AND CAST("INVSTO_PurchaseDate" AS date) = "v_PurchaseDate" 
                        AND "INVSTO_Id" = "v_INVSTO_Id" 
                        AND "INVSTO_SalesRate" = "v_SalesPrice";
                END IF;
            END LOOP;

        END IF;

    END IF;

    RETURN;
END;
$$;