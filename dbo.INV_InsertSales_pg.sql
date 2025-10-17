CREATE OR REPLACE FUNCTION "dbo"."INV_InsertSales"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMSL_Id bigint,
    p_INVMI_Id bigint,
    p_INVTSL_SalesPrice decimal(18,2)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_stssid BIGINT;
    v_qty BIGINT;
    v_remqty BIGINT;
    v_tssid BIGINT;
    v_lifo varchar(30);
    v_mfgdate1 INT;
    v_oldqty FLOAT;
    v_oldfqty FLOAT;
    v_newqty FLOAT;
    v_newfqty FLOAT;
    v_batch VARCHAR(50);
    v_storeid BIGINT;
    v_phyprice FLOAT;
    v_sellprice FLOAT;
    v_mfgdate TIMESTAMP;
    v_expdate TIMESTAMP;
    v_item BIGINT;
    v_soldqty FLOAT;
    v_sbatch VARCHAR(50);
    v_sstoreid FLOAT;
    v_tsaid BIGINT;
    v_newtsaid BIGINT;
    v_sphyprice FLOAT;
    v_ssellprice FLOAT;
    v_smfgdate TIMESTAMP;
    v_sexpdate TIMESTAMP;
    v_sitem BIGINT;
    v_newbatch VARCHAR(50);
    v_newstoreid BIGINT;
    v_newphyprice FLOAT;
    v_newsellprice FLOAT;
    v_newmfgdate TIMESTAMP;
    v_newexpdate TIMESTAMP;
    v_newitem BIGINT;
    v_tmsaid BIGINT;
    v_institution BIGINT;
    v_sMI_Id BIGINT;
    v_CMI_Id bigint;
    v_newtssid BIGINT;
    v_newtmsaid BIGINT;
    v_INVSTO_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_CBatchNo varchar(100);
    v_SalesDate TIMESTAMP;
    v_ReturnQty decimal(18,2);
    v_SalesPrice decimal(18,2);
    
    rec_storeids RECORD;
    rec_stock RECORD;
    rec_stock3 RECORD;
    v_exit_loop BOOLEAN;
BEGIN

FOR rec_storeids IN
    SELECT "ITS"."INVTSL_Id", "INVMST_Id", "INVMI_Id", "INVMSL_SalesDate", 
           COALESCE("INVTSL_SalesQty", 0) AS "SalesQty", "INVTSL_BatchNo", 
           "INVTSL_SalesPrice", COALESCE("INVTSL_ReturnQty", 0) AS "INVTSL_ReturnQty"
    FROM "INV"."INV_T_Sales" "ITS"
    INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id"
    WHERE "ITS"."INVMSL_Id" = p_INVMSL_Id 
      AND "MI_Id" = p_MI_Id 
      AND "INVMST_Id" = p_INVMST_Id 
      AND "INVMI_Id" = p_INVMI_Id 
      AND "INVTSL_SalesPrice" = p_INVTSL_SalesPrice
LOOP
    v_newtsaid := rec_storeids."INVTSL_Id";
    v_newstoreid := rec_storeids."INVMST_Id";
    v_newitem := rec_storeids."INVMI_Id";
    v_SalesDate := rec_storeids."INVMSL_SalesDate";
    v_newqty := rec_storeids."SalesQty";
    v_newbatch := rec_storeids."INVTSL_BatchNo";
    v_newsellprice := rec_storeids."INVTSL_SalesPrice";
    v_ReturnQty := rec_storeids."INVTSL_ReturnQty";

    SELECT COALESCE("INVSTO_Id", 0),
           COALESCE("INVMI_Id", 0),
           COALESCE("INVMST_Id", 0),
           COALESCE("INVSTO_AvaiableStock", 0),
           COALESCE("INVSTO_SalesRate", 0),
           COALESCE("INVSTO_BatchNo", '0'),
           "MI_Id"
    INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, v_sbatch, v_sMI_Id
    FROM "INV"."INV_Stock"
    WHERE "MI_Id" = p_MI_Id
      AND "INVMST_Id" = v_newstoreid
      AND "INVMI_Id" = v_newitem
      AND "INVSTO_SalesRate" = v_newsellprice
    LIMIT 1;

    IF v_newitem = v_sitem
       AND v_newsellprice = v_ssellprice
       AND v_newstoreid = v_sstoreid
       AND v_sMI_Id = p_MI_Id
    THEN

        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo
        FROM "INV"."INV_Configuration"
        WHERE "MI_Id" = p_MI_Id 
          AND "INVMST_Id" = v_newstoreid 
          AND "INVC_ProcessApplFlg" = 1
        LIMIT 1;

        SELECT sum("INVSTO_AvaiableStock") INTO v_qty
        FROM "INV"."INV_Stock"
        WHERE "INVMI_Id" = p_INVMI_Id 
          AND "INVMST_Id" = p_INVMST_Id 
          AND "MI_Id" = p_MI_Id 
          AND "INVSTO_SalesRate" = p_INVTSL_SalesPrice;

        RAISE NOTICE '%', v_oldqty;
        RAISE NOTICE '%', v_newqty;

        v_remqty := 0;

        RAISE NOTICE 'lifo';

        IF v_lifo = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            v_exit_loop := FALSE;
            FOR rec_stock IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       sum(COALESCE("INVSTO_AvaiableStock", 0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = p_MI_Id 
                  AND "INVMI_Id" = p_INVMI_Id 
                  AND "INVMST_Id" = p_INVMST_Id 
                  AND "INVSTO_SalesRate" = p_INVTSL_SalesPrice 
                  AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY "INVSTO_PurchaseDate" DESC
            LOOP
                v_CMI_Id := rec_stock."MI_Id";
                v_INVSTO_Id := rec_stock."INVSTO_Id";
                v_PurchaseDate := rec_stock."INVSTO_PurchaseDate";
                v_citem := rec_stock."INVMI_Id";
                v_Cstoreid := rec_stock."INVMST_Id";
                v_SalesPrice := rec_stock."INVSTO_SalesRate";
                v_soldqty := rec_stock."AvaiableStock";

                IF v_soldqty > 0 AND v_newqty > 0 THEN
                    IF v_newqty <= v_soldqty THEN
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = (v_soldqty - v_newqty),
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_newqty,
                            "INVSTO_SalesRetQty" = v_ReturnQty
                        WHERE "MI_Id" = p_MI_Id 
                          AND "INVMI_Id" = v_newitem 
                          AND "INVMST_Id" = p_INVMST_Id 
                          AND "INVSTO_SalesRate" = v_newsellprice 
                          AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                          AND "INVSTO_Id" = v_INVSTO_Id;

                        v_exit_loop := TRUE;
                        EXIT;
                    ELSIF v_newqty > v_soldqty THEN
                        v_newqty := v_newqty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = 0,
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_soldqty
                        WHERE "MI_Id" = p_MI_Id 
                          AND "INVMI_Id" = v_newitem 
                          AND "INVMST_Id" = p_INVMST_Id 
                          AND "INVSTO_SalesRate" = v_newsellprice 
                          AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                          AND "INVSTO_Id" = v_INVSTO_Id;
                    END IF;
                END IF;
            END LOOP;
        ELSE
            RAISE NOTICE 'FIFO START';

            v_exit_loop := FALSE;
            FOR rec_stock3 IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       sum(COALESCE("INVSTO_AvaiableStock", 0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = p_MI_Id 
                  AND "INVMI_Id" = v_newitem 
                  AND "INVMST_Id" = p_INVMST_Id 
                  AND "INVSTO_SalesRate" = v_newsellprice 
                  AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"
                ORDER BY "INVSTO_PurchaseDate"
            LOOP
                v_CMI_Id := rec_stock3."MI_Id";
                v_INVSTO_Id := rec_stock3."INVSTO_Id";
                v_PurchaseDate := rec_stock3."INVSTO_PurchaseDate";
                v_citem := rec_stock3."INVMI_Id";
                v_Cstoreid := rec_stock3."INVMST_Id";
                v_SalesPrice := rec_stock3."INVSTO_SalesRate";
                v_soldqty := rec_stock3."AvaiableStock";

                RAISE NOTICE 'fifo mfg';

                IF v_soldqty > 0 AND v_newqty > 0 THEN
                    IF v_newqty <= v_soldqty THEN
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = (v_soldqty - v_newqty),
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_newqty,
                            "INVSTO_SalesRetQty" = v_ReturnQty
                        WHERE "MI_Id" = p_MI_Id 
                          AND "INVMI_Id" = v_newitem 
                          AND "INVMST_Id" = p_INVMST_Id 
                          AND "INVSTO_SalesRate" = v_newsellprice 
                          AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                          AND "INVSTO_Id" = v_INVSTO_Id;

                        v_exit_loop := TRUE;
                        EXIT;
                    ELSIF v_newqty > v_soldqty THEN
                        v_newqty := v_newqty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock"
                        SET "INVSTO_AvaiableStock" = 0,
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_soldqty
                        WHERE "MI_Id" = p_MI_Id 
                          AND "INVMI_Id" = v_newitem 
                          AND "INVMST_Id" = p_INVMST_Id 
                          AND "INVSTO_SalesRate" = v_newsellprice 
                          AND CAST("INVSTO_PurchaseDate" AS date) = v_PurchaseDate 
                          AND "INVSTO_Id" = v_INVSTO_Id;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;

END LOOP;

RETURN;
END;
$$;