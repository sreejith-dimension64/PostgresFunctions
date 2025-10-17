CREATE OR REPLACE FUNCTION "INV"."INV_StockupdatesCheckOut"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMLO_Id bigint,
    p_INVMI_Id bigint,
    p_INVSTO_SalesRate decimal(18,2),
    p_INVACO_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AvailableStock decimal(18,2);
    v_CheckOutQty decimal(18,2);
    v_CheckInQty decimal(18,2);
    v_INVACI_ActiveFlg int;
    v_MasterCheckOutQty decimal(18,2);
    v_INVSTO_Id bigint;
    v_lifo varchar(100);
    v_soldqty FLOAT;
    v_CMI_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_SalesPrice FLOAT;
    stock_rec RECORD;
BEGIN

    SELECT SUM(COALESCE("INVSTO_AvaiableStock",0)), SUM(COALESCE("INVSTO_CheckedOutQty",0)) 
    INTO v_AvailableStock, v_CheckOutQty
    FROM "INV"."INV_Stock" 
    WHERE "MI_Id"=p_MI_Id 
        AND "INVMST_Id"=p_INVMST_Id 
        AND "INVMI_Id"=p_INVMI_Id 
        AND "INVSTO_AvaiableStock"<>0 
        AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
        AND "INVSTO_PurchaseDate" IS NOT NULL;

    IF (v_CheckOutQty=0 OR v_CheckOutQty IS NULL) THEN
        
        SELECT SUM(COALESCE("INVACO_CheckOutQty",0)) 
        INTO v_MasterCheckOutQty
        FROM "INV"."INV_Asset_CheckOut" 
        WHERE "MI_Id"=p_MI_Id 
            AND "INVMLO_Id"=p_INVMLO_Id 
            AND "INVMST_Id"=p_INVMST_Id 
            AND "INVMI_Id"=p_INVMI_Id 
            AND "INVACO_ActiveFlg"=1 
            AND "INVACO_Id"=p_INVACO_Id;
        
        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo
        FROM "INV"."INV_Configuration"  
        WHERE "MI_Id"=p_MI_Id 
            AND "INVMST_Id"=p_INVMST_Id 
            AND "INVC_ProcessApplFlg"=1;

        IF v_lifo = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                    SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id 
                    AND "INVMI_Id"=p_INVMI_Id 
                    AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                    AND "INVSTO_AvaiableStock"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                    CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"  
                ORDER BY "INVSTO_PurchaseDate" DESC
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";

                IF v_soldqty > 0 AND v_MasterCheckOutQty > 0 THEN
                    
                    IF (v_MasterCheckOutQty <= v_soldqty) THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=(v_soldqty - v_MasterCheckOutQty),
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_MasterCheckOutQty  
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_MasterCheckOutQty > v_soldqty) THEN
                        
                        v_MasterCheckOutQty := v_MasterCheckOutQty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=0,
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_soldqty   
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                    
                    END IF;

                END IF;

            END LOOP;
            
        ELSE
            
            RAISE NOTICE 'FIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                    SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id 
                    AND "INVMI_Id"=p_INVMI_Id 
                    AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                    AND "INVSTO_AvaiableStock"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                    CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id" 
                ORDER BY "INVSTO_PurchaseDate"
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";

                RAISE NOTICE 'fifo mfg';
                
                IF v_soldqty > 0 AND v_MasterCheckOutQty > 0 THEN
                    
                    IF (v_MasterCheckOutQty <= v_soldqty) THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=(v_soldqty - v_MasterCheckOutQty),
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_MasterCheckOutQty  
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_MasterCheckOutQty > v_soldqty) THEN
                        
                        v_MasterCheckOutQty := v_MasterCheckOutQty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=0,
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_soldqty 
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                    
                    END IF;

                END IF;

            END LOOP;

        END IF;

    ELSIF (v_CheckOutQty != 0) THEN

        SELECT SUM("INVACO_CheckOutQty") 
        INTO v_MasterCheckOutQty
        FROM "INV"."INV_Asset_CheckOut" 
        WHERE "MI_Id"=p_MI_Id 
            AND "INVMLO_Id"=p_INVMLO_Id 
            AND "INVMST_Id"=p_INVMST_Id 
            AND "INVMI_Id"=p_INVMI_Id 
            AND "INVACO_ActiveFlg"=1 
            AND "INVACO_Id"=p_INVACO_Id;
        
        SELECT "INVC_LIFOFIFOFlg" INTO v_lifo
        FROM "INV"."INV_Configuration"  
        WHERE "MI_Id"=p_MI_Id 
            AND "INVMST_Id"=p_INVMST_Id 
            AND "INVC_ProcessApplFlg"=1;

        IF v_lifo = 'LIFO' THEN
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                    SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id 
                    AND "INVMI_Id"=p_INVMI_Id 
                    AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                    AND "INVSTO_AvaiableStock"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                    CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"  
                ORDER BY "INVSTO_PurchaseDate" DESC
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";

                IF v_soldqty > 0 AND v_MasterCheckOutQty > 0 THEN
                    
                    IF (v_MasterCheckOutQty <= v_soldqty) THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=(v_soldqty - v_MasterCheckOutQty),
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_MasterCheckOutQty  
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_MasterCheckOutQty > v_soldqty) THEN
                        
                        v_MasterCheckOutQty := v_MasterCheckOutQty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=0,
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_soldqty 
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                    
                    END IF;

                END IF;

            END LOOP;
            
        ELSE
            
            RAISE NOTICE 'FIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id",
                    CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate",
                    "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate",
                    SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id 
                    AND "INVMI_Id"=p_INVMI_Id 
                    AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                    AND "INVSTO_AvaiableStock"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                    CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id" 
                ORDER BY "INVSTO_PurchaseDate"
            LOOP
                v_CMI_Id := stock_rec."MI_Id";
                v_INVSTO_Id := stock_rec."INVSTO_Id";
                v_PurchaseDate := stock_rec."INVSTO_PurchaseDate";
                v_citem := stock_rec."INVMI_Id";
                v_Cstoreid := stock_rec."INVMST_Id";
                v_SalesPrice := stock_rec."INVSTO_SalesRate";
                v_soldqty := stock_rec."AvaiableStock";

                RAISE NOTICE 'fifo mfg';
                
                IF v_soldqty > 0 AND v_MasterCheckOutQty > 0 THEN
                    
                    IF (v_MasterCheckOutQty <= v_soldqty) THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=(v_soldqty - v_MasterCheckOutQty),
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_MasterCheckOutQty  
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_MasterCheckOutQty > v_soldqty) THEN
                        
                        v_MasterCheckOutQty := v_MasterCheckOutQty - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=0,
                            "INVSTO_CheckedOutQty"=COALESCE("INVSTO_CheckedOutQty",0) + v_soldqty 
                        WHERE "MI_Id"=p_MI_Id 
                            AND "INVMI_Id"=p_INVMI_Id 
                            AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                    
                    END IF;

                END IF;

            END LOOP;

        END IF;

    END IF;

    RETURN;

END;
$$;