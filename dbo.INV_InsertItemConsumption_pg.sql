CREATE OR REPLACE FUNCTION "dbo"."INV_InsertItemConsumption"(
    p_MI_Id bigint,
    p_INVMIC_Id bigint,
    p_INVMST_Id bigint,
    p_INVMI_Id bigint,
    p_INVTIC_ICPrice decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_tssid BIGINT;
    v_oldqty FLOAT;
    v_newqty FLOAT;
    v_batch VARCHAR(50);
    v_storeid BIGINT;
    v_phyprice FLOAT;
    v_sellprice FLOAT;
    v_item BIGINT;
    v_soldqty FLOAT;
    v_sbatch VARCHAR(50);
    v_sstoreid FLOAT;
    v_sphyprice FLOAT;
    v_ssellprice FLOAT;
    v_sitem BIGINT;
    v_newbatch VARCHAR(50);
    v_newstoreid BIGINT;
    v_newphyprice FLOAT;
    v_SalesPrice FLOAT;
    v_newitem BIGINT;
    v_IMFY_Id bigint;
    v_PurchaseDate date;
    v_newPurchaseDate date;
    v_sPurchaseDate date;
    v_sMI_Id bigint;
    v_newinstitution bigint;
    v_INVTIC_ICQty decimal(18,2);
    v_lifo varchar(60);
    v_CMI_Id bigint;
    v_INVSTO_Id bigint;
    v_citem bigint;
    v_Cstoreid bigint;
    v_ItemConQty FLOAT;
    v_INVMIC_Id bigint;
    
    rec_storeids RECORD;
    rec_stock RECORD;
BEGIN

    FOR rec_storeids IN
        SELECT "INVMST_Id", "IMIC"."INVMIC_Id", "INVMI_Id", SUM(COALESCE("INVTIC_ICQty",0)) as "INVTIC_ICQty"
        FROM "INV"."INV_M_ItemConsumption" "IMIC"
        INNER JOIN "INV"."INV_T_ItemConsumption" "ITIC" ON "IMIC"."INVMIC_Id" = "ITIC"."INVMIC_Id"
        WHERE "IMIC"."MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "IMIC"."INVMIC_Id" = p_INVMIC_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVMIC_ActiveFlg" = 1 
            AND "INVTIC_ActiveFlg" = 1
        GROUP BY "INVMST_Id", "IMIC"."INVMIC_Id", "INVMI_Id"
    LOOP
        v_newstoreid := rec_storeids."INVMST_Id";
        v_INVMIC_Id := rec_storeids."INVMIC_Id";
        v_newitem := rec_storeids."INVMI_Id";
        v_INVTIC_ICQty := rec_storeids."INVTIC_ICQty";

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
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sphyprice, v_sbatch, v_sPurchaseDate, v_sMI_Id
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVSTO_AvaiableStock" <> 0
        LIMIT 1;

        IF (v_newitem = v_sitem AND v_newstoreid = v_sstoreid AND p_MI_Id = v_sMI_Id) THEN
            
            SELECT "INVC_LIFOFIFOFlg" INTO v_lifo
            FROM "INV"."INV_Configuration"
            WHERE "MI_Id" = p_MI_Id 
                AND "INVMST_Id" = v_newstoreid 
                AND "INVC_ProcessApplFlg" = 1
            LIMIT 1;

            IF v_lifo = 'LIFO' THEN
                RAISE NOTICE 'LIFO=1';
                RAISE NOTICE 'LIFO START';
                
                FOR rec_stock IN
                    SELECT 
                        "MI_Id",
                        "INVSTO_Id",
                        CAST("INVSTO_PurchaseDate" AS date) as "INVSTO_PurchaseDate",
                        "INVMI_Id",
                        "INVMST_Id",
                        "INVSTO_SalesRate",
                        "INVSTO_ItemConQty",
                        SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                    FROM "INV"."INV_Stock"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "INVMI_Id" = p_INVMI_Id 
                        AND "INVMST_Id" = p_INVMST_Id 
                        AND "INVSTO_AvaiableStock" <> 0
                    GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", "INVSTO_ItemConQty", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                    ORDER BY CAST("INVSTO_PurchaseDate" AS date) DESC
                LOOP
                    v_CMI_Id := rec_stock."MI_Id";
                    v_INVSTO_Id := rec_stock."INVSTO_Id";
                    v_PurchaseDate := rec_stock."INVSTO_PurchaseDate";
                    v_citem := rec_stock."INVMI_Id";
                    v_Cstoreid := rec_stock."INVMST_Id";
                    v_SalesPrice := rec_stock."INVSTO_SalesRate";
                    v_ItemConQty := rec_stock."INVSTO_ItemConQty";
                    v_soldqty := rec_stock."AvaiableStock";

                    IF v_soldqty > 0 AND v_INVTIC_ICQty > 0 THEN
                        
                        IF (v_INVTIC_ICQty <= v_soldqty) THEN

                            UPDATE "INV"."INV_Stock" 
                            SET "INVSTO_AvaiableStock" = (v_soldqty - v_INVTIC_ICQty),
                                "INVSTO_ItemConQty" = v_INVTIC_ICQty
                            WHERE "MI_Id" = p_MI_Id 
                                AND "INVMI_Id" = v_newitem 
                                AND "INVMST_Id" = p_INVMST_Id 
                                AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                                AND "INVSTO_Id" = v_INVSTO_Id 
                                AND "INVSTO_SalesRate" = v_SalesPrice;

                            EXIT;
                        ELSIF (v_INVTIC_ICQty > v_soldqty) THEN
                            
                            v_INVTIC_ICQty := v_INVTIC_ICQty - v_soldqty;
                            
                            UPDATE "INV"."INV_Stock" 
                            SET "INVSTO_AvaiableStock" = 0,
                                "INVSTO_ItemConQty" = v_INVTIC_ICQty
                            WHERE "MI_Id" = p_MI_Id 
                                AND "INVMI_Id" = v_newitem 
                                AND "INVMST_Id" = p_INVMST_Id 
                                AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                                AND "INVSTO_Id" = v_INVSTO_Id 
                                AND "INVSTO_SalesRate" = v_SalesPrice;
                        
                        END IF;

                    END IF;

                END LOOP;

            ELSE
                
                RAISE NOTICE 'FIFO START';

                FOR rec_stock IN
                    SELECT 
                        "MI_Id",
                        "INVSTO_Id",
                        CAST("INVSTO_PurchaseDate" AS date) as "INVSTO_PurchaseDate",
                        "INVMI_Id",
                        "INVMST_Id",
                        "INVSTO_SalesRate",
                        "INVSTO_ItemConQty",
                        SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                    FROM "INV"."INV_Stock"
                    WHERE "MI_Id" = p_MI_Id 
                        AND "INVMI_Id" = p_INVMI_Id 
                        AND "INVMST_Id" = p_INVMST_Id 
                        AND "INVSTO_AvaiableStock" <> 0
                    GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", "INVSTO_ItemConQty", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                    ORDER BY CAST("INVSTO_PurchaseDate" AS date)
                LOOP
                    v_CMI_Id := rec_stock."MI_Id";
                    v_INVSTO_Id := rec_stock."INVSTO_Id";
                    v_PurchaseDate := rec_stock."INVSTO_PurchaseDate";
                    v_citem := rec_stock."INVMI_Id";
                    v_Cstoreid := rec_stock."INVMST_Id";
                    v_SalesPrice := rec_stock."INVSTO_SalesRate";
                    v_ItemConQty := rec_stock."INVSTO_ItemConQty";
                    v_soldqty := rec_stock."AvaiableStock";

                    IF v_soldqty > 0 AND v_INVTIC_ICQty > 0 THEN
                        
                        IF (v_INVTIC_ICQty <= v_soldqty) THEN

                            UPDATE "INV"."INV_Stock" 
                            SET "INVSTO_AvaiableStock" = (v_soldqty - v_INVTIC_ICQty),
                                "INVSTO_ItemConQty" = v_INVTIC_ICQty
                            WHERE "MI_Id" = p_MI_Id 
                                AND "INVMI_Id" = v_newitem 
                                AND "INVMST_Id" = p_INVMST_Id 
                                AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                                AND "INVSTO_Id" = v_INVSTO_Id 
                                AND "INVSTO_SalesRate" = v_SalesPrice;

                            EXIT;
                        ELSIF (v_INVTIC_ICQty > v_soldqty) THEN
                            
                            v_INVTIC_ICQty := v_INVTIC_ICQty - v_soldqty;
                            
                            UPDATE "INV"."INV_Stock" 
                            SET "INVSTO_AvaiableStock" = 0,
                                "INVSTO_ItemConQty" = v_INVTIC_ICQty
                            WHERE "MI_Id" = p_MI_Id 
                                AND "INVMI_Id" = v_newitem 
                                AND "INVMST_Id" = p_INVMST_Id 
                                AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                                AND "INVSTO_Id" = v_INVSTO_Id 
                                AND "INVSTO_SalesRate" = v_SalesPrice;
                        
                        END IF;

                    END IF;

                END LOOP;

            END IF;

        END IF;

    END LOOP;

    RETURN;

END;
$$;