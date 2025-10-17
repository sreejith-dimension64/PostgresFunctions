CREATE OR REPLACE FUNCTION "INV"."INV_StockupdatesCheckIn"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMLO_Id bigint,
    p_INVMI_Id bigint,
    p_INVSTO_SalesRate decimal(18,2),
    p_INVACI_Id bigint
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
    v_lifo varchar(50);
    v_INVSTO_Id bigint;
    v_soldqty FLOAT;
    v_CMI_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_SalesPrice FLOAT;
    v_INVSTO_CheckedOutQty FLOAT;
    stock_rec RECORD;
BEGIN

    SELECT SUM("INVSTO_AvaiableStock"), SUM("INVSTO_CheckedOutQty") 
    INTO v_AvailableStock, v_CheckOutQty 
    FROM "INV"."INV_Stock" 
    WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVMI_Id"=p_INVMI_Id 
        AND "INVSTO_AvaiableStock"<>0 AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
        AND "INVSTO_PurchaseDate" IS NOT NULL;

    SELECT SUM("INVACO_CheckOutQty") 
    INTO v_MasterCheckOutQty 
    FROM "INV"."INV_Asset_CheckOut" 
    WHERE "MI_Id"=p_MI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVMST_Id"=p_INVMST_Id 
        AND "INVMI_Id"=p_INVMI_Id AND "INVACO_ActiveFlg"=1;

    SELECT SUM("INVACI_CheckInQty") 
    INTO v_CheckInQty 
    FROM "INV"."INV_Asset_CheckIn"  
    WHERE "MI_Id"=p_MI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVMST_Id"=p_INVMST_Id 
        AND "INVMI_Id"=p_INVMI_Id AND "INVACI_Id"=p_INVACI_Id;

    SELECT "INVACI_ActiveFlg" 
    INTO v_INVACI_ActiveFlg 
    FROM "INV"."INV_Asset_CheckIn"  
    WHERE "MI_Id"=p_MI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVMST_Id"=p_INVMST_Id 
        AND "INVMI_Id"=p_INVMI_Id AND "INVACI_Id"=p_INVACI_Id;

    IF(v_INVACI_ActiveFlg=1) THEN

        SELECT "INVC_LIFOFIFOFlg" 
        INTO v_lifo 
        FROM "INV"."INV_Configuration"  
        WHERE "MI_Id"=p_MI_Id AND "INVMST_Id"=p_INVMST_Id AND "INVC_ProcessApplFlg"=1;

        IF v_lifo = 'LIFO' THEN
            
            RAISE NOTICE 'LIFO=1';
            RAISE NOTICE 'LIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", 
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock",
                       SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0 
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id"  
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

                IF v_INVSTO_CheckedOutQty > 0 AND v_CheckInQty > 0 THEN
                    
                    IF(v_CheckInQty <= v_INVSTO_CheckedOutQty) THEN

                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=("INVSTO_AvaiableStock"+v_CheckInQty),
                            "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"-v_CheckInQty)
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_CheckInQty > v_INVSTO_CheckedOutQty) THEN
                    
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=0,
                            "INVSTO_AvaiableStock"=(COALESCE("INVSTO_AvaiableStock",0)+v_INVSTO_CheckedOutQty)
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                        
                        v_CheckInQty := v_CheckInQty - v_INVSTO_CheckedOutQty;
                    
                    END IF;

                END IF;

            END LOOP;

            UPDATE "INV"."INV_Asset_CheckOut" 
            SET "INVACO_CheckOutQty"="INVACO_CheckOutQty"-v_CheckInQty  
            WHERE "MI_Id"=p_MI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVMST_Id"=p_INVMST_Id 
                AND "INVMI_Id"=p_INVMI_Id AND "INVACO_ActiveFlg"=1;

        ELSE
            
            RAISE NOTICE 'FIFO START';

            FOR stock_rec IN
                SELECT "MI_Id", "INVSTO_Id", CAST("INVSTO_PurchaseDate" AS date) AS "INVSTO_PurchaseDate", 
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM(COALESCE("INVSTO_AvaiableStock",0)) AS "AvaiableStock",
                       SUM(COALESCE("INVSTO_CheckedOutQty",0)) AS "INVSTO_CheckedOutQty"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                    AND "INVSTO_SalesRate"=p_INVSTO_SalesRate AND "INVSTO_CheckedOutQty"<>0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         CAST("INVSTO_PurchaseDate" AS date), "INVSTO_Id" 
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
                
                IF v_INVSTO_CheckedOutQty > 0 AND v_CheckInQty > 0 THEN
                    
                    IF(v_CheckInQty <= v_INVSTO_CheckedOutQty) THEN

                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock"=("INVSTO_AvaiableStock"+v_CheckInQty),
                            "INVSTO_CheckedOutQty"=("INVSTO_CheckedOutQty"-v_CheckInQty)
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF (v_CheckInQty > v_INVSTO_CheckedOutQty) THEN
                    
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_CheckedOutQty"=0, 
                            "INVSTO_AvaiableStock"=(COALESCE("INVSTO_AvaiableStock",0)+v_INVSTO_CheckedOutQty)
                        WHERE "MI_Id"=p_MI_Id AND "INVMI_Id"=p_INVMI_Id AND "INVMST_Id"=p_INVMST_Id 
                            AND "INVSTO_SalesRate"=p_INVSTO_SalesRate 
                            AND CAST("INVSTO_PurchaseDate" AS date)=v_PurchaseDate 
                            AND "INVSTO_Id"=v_INVSTO_Id;
                        
                        v_CheckInQty := v_CheckInQty - v_INVSTO_CheckedOutQty;
                    
                    END IF;

                END IF;

            END LOOP;

            UPDATE "INV"."INV_Asset_CheckOut" 
            SET "INVACO_CheckOutQty"="INVACO_CheckOutQty"-v_CheckInQty  
            WHERE "MI_Id"=p_MI_Id AND "INVMLO_Id"=p_INVMLO_Id AND "INVMST_Id"=p_INVMST_Id 
                AND "INVMI_Id"=p_INVMI_Id AND "INVACO_ActiveFlg"=1;

        END IF;

    END IF;

END;
$$;