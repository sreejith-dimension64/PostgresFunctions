CREATE OR REPLACE FUNCTION "INV"."INV_StockupdatesDispose"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMLO_Id bigint,
    p_INVMI_Id bigint,
    p_INVSTO_SalesRate decimal(18,2),
    p_INVADI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_CheckOutQty decimal(18,2);
    v_INVSTO_Id bigint;
    v_MasterCheckOutQty decimal(18,2);
    v_DisposedQty decimal(18,2);
    v_StockDisQty decimal(18,2);
    v_INVADI_ActiveFlg boolean;
    v_lifo varchar(50);
    v_soldqty FLOAT;
    v_CMI_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_SalesPrice FLOAT;
    v_INVSTO_CheckedOutQty FLOAT;
    v_INVSTO_DisposedQty FLOAT;
    stock_rec RECORD;
BEGIN

    SELECT SUM("INVSTO_CheckedOutQty") INTO v_MasterCheckOutQty 
    FROM "INV"."INV_Stock" 
    WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVMI_Id"=p_INVMI_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate;
    
    SELECT SUM("INVADI_DisposedQty") INTO v_DisposedQty 
    FROM "INV"."INV_Asset_Dispose"  
    WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVADI_Id"=p_INVADI_Id;
    
    SELECT "INVADI_ActiveFlg" INTO v_INVADI_ActiveFlg 
    FROM "INV"."INV_Asset_Dispose"  
    WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate;

    IF (v_MasterCheckOutQty != 0) AND (v_INVADI_ActiveFlg = true) THEN

        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo 
        FROM "INV"."INV_Configuration"  
        WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVC_ProcessApplFlg"=1;

        IF v_lifo = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock", SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0 
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"  
                ORDER BY CAST("INVSTO_PurchaseDate" AS date) DESC
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";
                v_INVSTO_CheckedOutQty := stock_rec."INVSTO_CheckedOutQty";

                IF v_INVSTO_CheckedOutQty > 0 AND v_DisposedQty > 0 THEN
                    IF v_DisposedQty <= v_INVSTO_CheckedOutQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"-v_DisposedQty),
                            "INVSTO_DisposedQty"=COALESCE("INVSTO_DisposedQty",0)+v_DisposedQty
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        EXIT;
                    ELSIF v_DisposedQty > v_INVSTO_CheckedOutQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=0, "INVSTO_DisposedQty"=COALESCE("INVSTO_DisposedQty",0)+v_INVSTO_CheckedOutQty
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        v_DisposedQty := v_DisposedQty - v_INVSTO_CheckedOutQty;
                    END IF;
                END IF;
            END LOOP;

        ELSE
            RAISE NOTICE 'FIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock", SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id" 
                ORDER BY CAST("INVSTO_PurchaseDate" AS date)
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";
                v_INVSTO_CheckedOutQty := stock_rec."INVSTO_CheckedOutQty";

                RAISE NOTICE 'fifo mfg';

                IF v_INVSTO_CheckedOutQty > 0 AND v_DisposedQty > 0 THEN
                    IF v_DisposedQty <= v_INVSTO_CheckedOutQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"-v_DisposedQty),
                            "INVSTO_DisposedQty"=COALESCE("INVSTO_DisposedQty",0)+v_DisposedQty  
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        EXIT;
                    ELSIF v_DisposedQty > v_INVSTO_CheckedOutQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=0, "INVSTO_DisposedQty"=COALESCE("INVSTO_DisposedQty",0)+v_INVSTO_CheckedOutQty  
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        v_DisposedQty := v_DisposedQty - v_INVSTO_CheckedOutQty;
                    END IF;
                END IF;
            END LOOP;

        END IF;

    ELSIF v_INVADI_ActiveFlg = false THEN

        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo 
        FROM "INV"."INV_Configuration"  
        WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVC_ProcessApplFlg"=1;

        IF v_lifo = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock", SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty",
                       SUM(COALESCE("INVSTO_DisposedQty",0)) AS "INVSTO_DisposedQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0 
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"  
                ORDER BY CAST("INVSTO_PurchaseDate" AS date) DESC
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";
                v_INVSTO_CheckedOutQty := stock_rec."INVSTO_CheckedOutQty";
                v_INVSTO_DisposedQty := stock_rec."INVSTO_DisposedQty";

                IF v_INVSTO_DisposedQty > 0 AND v_DisposedQty > 0 THEN
                    IF v_DisposedQty <= v_INVSTO_DisposedQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"+v_DisposedQty),
                            "INVSTO_DisposedQty"="INVSTO_DisposedQty"-v_DisposedQty
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        EXIT;
                    ELSIF v_DisposedQty > v_INVSTO_DisposedQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0)+v_INVSTO_DisposedQty, "INVSTO_DisposedQty"=0
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        v_DisposedQty := v_DisposedQty - v_INVSTO_DisposedQty;
                    END IF;
                END IF;
            END LOOP;

        ELSE
            RAISE NOTICE 'FIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock", SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty",
                       SUM(COALESCE("INVSTO_DisposedQty",0)) AS "INVSTO_DisposedQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id" 
                ORDER BY CAST("INVSTO_PurchaseDate" AS date)
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";
                v_INVSTO_CheckedOutQty := stock_rec."INVSTO_CheckedOutQty";
                v_INVSTO_DisposedQty := stock_rec."INVSTO_DisposedQty";

                RAISE NOTICE 'fifo mfg';

                IF v_INVSTO_DisposedQty > 0 AND v_DisposedQty > 0 THEN
                    IF v_DisposedQty <= v_INVSTO_DisposedQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"+v_DisposedQty),
                            "INVSTO_DisposedQty"="INVSTO_DisposedQty"-v_DisposedQty  
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        EXIT;
                    ELSIF v_DisposedQty > v_INVSTO_DisposedQty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_DisposedQty"=0, "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0)+v_INVSTO_DisposedQty  
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                              AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate AND "INVSTO_Id"=v_INVSTO_Id;
                        v_DisposedQty := v_DisposedQty - v_INVSTO_DisposedQty;
                    END IF;
                END IF;
            END LOOP;

        END IF;

    END IF;

END;
$$;