CREATE OR REPLACE FUNCTION "dbo"."INV_DeleteGrn"(
    p_MI_Id BIGINT,
    p_INVMGRN_Id BIGINT,
    p_INVMST_Id BIGINT,
    p_INVMI_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_tssid BIGINT;
    v_oldqty FLOAT;
    v_oldfqty FLOAT;
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
    v_tgid BIGINT;
    v_newtgid BIGINT;
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
    v_tmgid BIGINT;
    v_newtmgid BIGINT;
    v_newMI_Id BIGINT;
    v_sMI_Id BIGINT;
    v_sPurchaseDate TIMESTAMP;
    v_PurchaseDate TIMESTAMP;
    v_sSalesQty DECIMAL(18,2);
    rec RECORD;
BEGIN

    FOR rec IN 
        SELECT "TGR"."INVTGRN_Id", "TGR"."INVMST_Id", "TGR"."INVMI_Id", 
               CAST("MGR"."INVMGRN_PurchaseDate" AS DATE) AS "INVMGRN_PurchaseDate",
               "TGR"."INVTGRN_Qty", "TGR"."INVTGRN_ReturnQty", "TGR"."INVTGRN_BatchNo",
               "TGR"."INVTGRN_PurchaseRate", "TGR"."INVTGRN_SalesPrice"
        FROM "INV"."INV_T_GRN" "TGR"
        INNER JOIN "INV"."INV_M_GRN" "MGR" ON "TGR"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        INNER JOIN "INV"."INV_M_GRN_Store" "MGRT" ON "MGRT"."INVMGRN_Id" = "MGR"."INVMGRN_Id"
        WHERE "MGR"."INVMGRN_Id" = p_INVMGRN_Id 
          AND "MGR"."MI_Id" = p_MI_Id 
          AND "TGR"."INVMI_Id" = p_INVMI_Id 
          AND "MGRT"."INVMST_Id" = p_INVMST_Id
    LOOP
        v_newtgid := rec."INVTGRN_Id";
        v_newstoreid := rec."INVMST_Id";
        v_newitem := rec."INVMI_Id";
        v_PurchaseDate := rec."INVMGRN_PurchaseDate";
        v_oldqty := rec."INVTGRN_Qty";
        v_newfqty := rec."INVTGRN_ReturnQty";
        v_newbatch := rec."INVTGRN_BatchNo";
        v_newphyprice := rec."INVTGRN_PurchaseRate";
        v_newsellprice := rec."INVTGRN_SalesPrice";

        RAISE NOTICE '%', v_oldqty;

        SELECT COALESCE("INVSTO_Id", 0),
               COALESCE("INVMI_Id", 0),
               COALESCE("INVMST_Id", 0),
               COALESCE("INVSTO_AvaiableStock", 0),
               COALESCE("INVSTO_SalesRate", 0),
               COALESCE("INVSTO_PurchaseRate", 0),
               CAST("INVSTO_PurchaseDate" AS DATE),
               "MI_Id",
               COALESCE("INVSTO_SalesQty", 0)
        INTO v_tssid, v_sitem, v_sstoreid, v_soldqty, v_ssellprice, 
             v_sphyprice, v_sPurchaseDate, v_sMI_Id, v_sSalesQty
        FROM "INV"."INV_Stock"
        WHERE "MI_Id" = p_MI_Id
          AND "INVMST_Id" = v_newstoreid
          AND "INVMI_Id" = v_newitem
          AND "INVSTO_SalesRate" = v_newsellprice
          AND "INVSTO_PurchaseRate" = v_newphyprice
          AND CAST("INVSTO_PurchaseDate" AS DATE) = v_PurchaseDate;

        IF (v_newitem = v_sitem)
           AND (v_newsellprice = v_ssellprice)
           AND (v_newphyprice = v_sphyprice)
           AND (v_PurchaseDate = v_sPurchaseDate)
           AND (v_newstoreid = v_sstoreid)
           AND v_sSalesQty = 0
        THEN
            RAISE NOTICE 'DELETE';

            DELETE FROM "INV"."INV_Stock" WHERE "INVSTO_Id" = v_tssid;
            DELETE FROM "INV"."INV_T_GRN" WHERE "INVTGRN_Id" = v_newtgid;

        END IF;

    END LOOP;

END;
$$;