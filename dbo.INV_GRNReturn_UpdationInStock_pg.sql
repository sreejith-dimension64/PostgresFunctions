CREATE OR REPLACE FUNCTION "dbo"."INV_GRNReturn_UpdationInStock"(
    p_INVMGRNRETAPP_Id bigint,
    p_MI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_GINVMI_Id bigint;
    v_GPurchaseDate date;
    v_GPurchaseRate FLOAT;
    v_GReturnQty FLOAT;
    v_tssid bigint;
    v_sitem bigint;
    v_sstoreid bigint;
    v_soldqty FLOAT;
    v_PurchaseRate FLOAT;
    v_sbatch text;
    v_sMI_Id bigint;
    v_INVSTO_PurchaseDate date;
    v_lifo varchar(100);
    v_CMI_Id bigint;
    v_INVSTO_Id bigint;
    v_PurchaseDate date;
    v_citem bigint;
    v_Cstoreid bigint;
    v_PurchagePrice FLOAT;
    v_BatchNo text;
    rec_stock RECORD;
BEGIN

    FOR v_GINVMI_Id, v_GPurchaseDate, v_GPurchaseRate, v_GReturnQty, v_BatchNo IN
        SELECT DISTINCT "TGRN"."INVMI_Id",
               "INVMGRN_PurchaseDate"::date AS "PurchaseDate",
               "TGRN"."INVTGRN_PurchaseRate",
               "TGRA"."INVTGRNRETAPP_ReturnQty",
               "TGRN"."INVTGRN_BatchNo"
        FROM "INV"."INV_M_GRN_Return_Apply" "MGRA"
        INNER JOIN "INV"."INV_T_GRN_Return_Apply" "TGRA" ON "MGRA"."INVMGRNRETAPP_Id" = "TGRA"."INVMGRNRETAPP_Id"
        INNER JOIN "INV"."INV_M_GRN" "MGRN" ON "MGRN"."INVMGRN_Id" = "MGRA"."INVMGRN_Id"
        INNER JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id" 
            AND "TGRN"."INVMI_Id" = "TGRA"."INVMI_Id" 
            AND "TGRN"."INVMUOM_Id" = "TGRA"."INVMUOM_Id"
        WHERE "MGRA"."INVMGRNRETAPP_Id" = p_INVMGRNRETAPP_Id 
            AND "MGRA"."MI_Id" = p_MI_Id 
            AND "INVMGRNRETAPP_StatusFlg" = 'APPROVED' 
            AND "TGRA"."INVTGRNRETAPP_ActiveFlg" = 1
    LOOP

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               COALESCE("INVSTO_BatchNo", '0'),
               "MI_Id",
               "INVSTO_PurchaseDate"::date
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_PurchaseRate, v_sbatch, v_sMI_Id, v_INVSTO_PurchaseDate
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_MI_Id
            AND "INVMI_Id" = v_GINVMI_Id
            AND "INVSTO_PurchaseDate"::date = v_GPurchaseDate
            AND "INVSTO_PurchaseRate" = v_GPurchaseRate;

        IF v_sitem = v_GINVMI_Id
            AND v_PurchaseRate = v_GPurchaseRate
            AND v_INVSTO_PurchaseDate = v_GPurchaseDate
            AND v_sMI_Id = p_MI_Id
        THEN

            FOR rec_stock IN
                SELECT "MI_Id",
                       "INVSTO_Id",
                       "INVSTO_PurchaseDate"::date AS "INVSTO_PurchaseDate",
                       "INVMI_Id",
                       "INVMST_Id",
                       "INVSTO_PurchaseRate",
                       SUM(COALESCE("INVSTO_AvaiableStock", 0)) AS "AvaiableStock"
                FROM "INV"."INV_Stock"
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMI_Id" = v_GINVMI_Id 
                    AND "INVMST_Id" = v_sstoreid 
                    AND "INVSTO_PurchaseRate" = v_GPurchaseRate 
                    AND "INVSTO_AvaiableStock" <> 0
                GROUP BY "MI_Id", "INVMI_Id", "INVMST_Id", "INVSTO_PurchaseRate", "INVSTO_PurchaseDate"::date, "INVSTO_Id"
            LOOP
                v_CMI_Id := rec_stock."MI_Id";
                v_INVSTO_Id := rec_stock."INVSTO_Id";
                v_PurchaseDate := rec_stock."INVSTO_PurchaseDate";
                v_citem := rec_stock."INVMI_Id";
                v_Cstoreid := rec_stock."INVMST_Id";
                v_PurchagePrice := rec_stock."INVSTO_PurchaseRate";
                v_soldqty := rec_stock."AvaiableStock";

                IF v_soldqty > 0 AND v_GReturnQty > 0 THEN
                    
                    IF v_GReturnQty <= v_soldqty THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock" = (v_soldqty - v_GReturnQty),
                            "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_GReturnQty,
                            "INVSTO_PurRetQty" = "INVSTO_PurRetQty" + v_GReturnQty
                        WHERE "MI_Id" = p_MI_Id 
                            AND "INVMI_Id" = v_GINVMI_Id 
                            AND "INVMST_Id" = v_sstoreid 
                            AND "INVSTO_PurchaseRate" = v_GPurchaseRate 
                            AND "INVSTO_PurchaseDate"::date = v_PurchaseDate 
                            AND "INVSTO_Id" = v_INVSTO_Id;

                        EXIT;
                        
                    ELSIF v_GReturnQty > v_soldqty THEN
                        
                        UPDATE "INV"."INV_Stock" 
                        SET "INVSTO_AvaiableStock" = 0,
                            "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_soldqty,
                            "INVSTO_PurRetQty" = "INVSTO_PurRetQty" + v_soldqty
                        WHERE "MI_Id" = p_MI_Id 
                            AND "INVMI_Id" = v_GINVMI_Id 
                            AND "INVMST_Id" = v_sstoreid 
                            AND "INVSTO_PurchaseRate" = v_GPurchaseRate 
                            AND "INVSTO_PurchaseDate"::date = v_PurchaseDate 
                            AND "INVSTO_Id" = v_INVSTO_Id;
                        
                        v_GReturnQty := v_GReturnQty - v_soldqty;
                        
                    END IF;

                END IF;

            END LOOP;

        END IF;

    END LOOP;

END;
$$;