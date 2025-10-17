CREATE OR REPLACE FUNCTION "dbo"."INV_MutlipleStuSalesQtyUpdate"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMSL_Id bigint;
    v_Mastersalescount bigint;
    v_INVMI_Id bigint;
    v_INVTSL_SalesQty decimal(18,2);
    v_INVTSL_SalesPrice decimal(18,2);
    v_INVTSL_SalesQty_New decimal(18,2);
    v_INVMST_Id bigint;
    v_CMI_Id bigint;
    v_INVSTO_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_SalesPrice decimal(18,2);
    v_soldqty decimal(18,2);
    
    rec_mastersalescount RECORD;
    rec_tsales RECORD;
    rec_stock RECORD;
BEGIN
    /*
    FOR rec_mastersalescount IN 
        SELECT "INVMSL_Id", "Mastersalescount" 
        FROM (
            SELECT "INVMSL_Id", COUNT(*) AS "Mastersalescount" 
            FROM "INV"."INV_M_Sales_Student" 
            WHERE "INVMSLS_ActiveFlg" = 1 AND "ASMAY_Id" = 38 
            GROUP BY "INVMSL_Id" 
            HAVING COUNT(*) > 1
        ) AS new 
        ORDER BY "Mastersalescount"
    LOOP
        v_INVMSL_Id := rec_mastersalescount."INVMSL_Id";
        v_Mastersalescount := rec_mastersalescount."Mastersalescount";
        
        FOR rec_tsales IN 
            SELECT "INVMI_Id", "INVTSL_SalesQty", "INVTSL_SalesPrice" 
            FROM "INV"."INV_T_Sales" 
            WHERE "INVMSL_Id" = v_INVMSL_Id
        LOOP
            v_INVMI_Id := rec_tsales."INVMI_Id";
            v_INVTSL_SalesQty := rec_tsales."INVTSL_SalesQty";
            v_INVTSL_SalesPrice := rec_tsales."INVTSL_SalesPrice";
            
            v_INVTSL_SalesQty_New := (v_INVTSL_SalesQty * v_Mastersalescount) - v_INVTSL_SalesQty;
            
            UPDATE "INV"."INV_T_Sales" 
            SET "INVTSL_SalesQty" = v_INVTSL_SalesQty * v_Mastersalescount,
                "INVTSL_Amount" = v_INVTSL_SalesPrice * v_Mastersalescount  
            WHERE "INVMSL_Id" = v_INVMSL_Id 
                AND "INVMI_Id" = v_INVMI_Id 
                AND "INVTSL_SalesQty" = v_INVTSL_SalesQty 
                AND "INVTSL_SalesPrice" = v_INVTSL_SalesPrice;
            
            UPDATE "INV"."INV_T_Sales" 
            SET "INVTSL_Amount" = v_INVTSL_SalesPrice * (v_INVTSL_SalesQty * v_Mastersalescount)  
            WHERE "INVMSL_Id" = v_INVMSL_Id 
                AND "INVMI_Id" = v_INVMI_Id 
                AND "INVTSL_SalesQty" = v_INVTSL_SalesQty 
                AND "INVTSL_SalesPrice" = v_INVTSL_SalesPrice;
            
            SELECT "INVMST_Id" INTO v_INVMST_Id 
            FROM "INV"."INV_M_Sales" 
            WHERE "INVMSL_Id" = v_INVMSL_Id AND "MI_Id" = 10;
            
            FOR rec_stock IN 
                SELECT "MI_Id", "INVSTO_Id", "INVSTO_PurchaseDate"::date AS "INVSTO_PurchaseDate", 
                       "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                       SUM("INVSTO_AvaiableStock") AS "AvaiableStock"
                FROM "INV"."INV_Stock" 
                WHERE "MI_Id" = 10 
                    AND "INVMI_Id" = v_INVMI_Id 
                    AND "INVMST_Id" = v_INVMST_Id 
                    AND "INVSTO_SalesRate" = v_INVTSL_SalesPrice 
                    AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_SalesRate", 
                         "INVSTO_PurchaseDate"::date, "INVSTO_Id"
            LOOP
                v_CMI_Id := rec_stock."MI_Id";
                v_INVSTO_Id := rec_stock."INVSTO_Id";
                v_PurchaseDate := rec_stock."INVSTO_PurchaseDate";
                v_citem := rec_stock."INVMI_Id";
                v_Cstoreid := rec_stock."INVMST_Id";
                v_SalesPrice := rec_stock."INVSTO_SalesRate";
                v_soldqty := rec_stock."AvaiableStock";
                
                IF v_soldqty > 0 THEN
                    IF v_INVTSL_SalesQty_New <= v_soldqty THEN
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock" = (v_soldqty - v_INVTSL_SalesQty_New),
                            "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_INVTSL_SalesQty_New  
                        WHERE "MI_Id" = v_CMI_Id 
                            AND "INVMI_Id" = v_citem 
                            AND "INVMST_Id" = v_INVMST_Id 
                            AND "INVSTO_SalesRate" = v_SalesPrice 
                            AND "INVSTO_PurchaseDate"::date = v_PurchaseDate 
                            AND "INVSTO_Id" = v_INVSTO_Id;
                        
                        EXIT;
                    ELSIF v_INVTSL_SalesQty_New > v_soldqty THEN
                        v_INVTSL_SalesQty_New := v_INVTSL_SalesQty_New - v_soldqty;
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock" = 0
                        WHERE "MI_Id" = v_CMI_Id 
                            AND "INVMI_Id" = v_citem 
                            AND "INVMST_Id" = v_INVMST_Id 
                            AND "INVSTO_SalesRate" = v_SalesPrice 
                            AND "INVSTO_PurchaseDate"::date = v_PurchaseDate 
                            AND "INVSTO_Id" = v_INVSTO_Id;
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;
    */
    
    RAISE NOTICE '***************************** Dont Execute*****************************';
    
    RETURN;
END;
$$;