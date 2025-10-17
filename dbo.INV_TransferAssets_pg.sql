CREATE OR REPLACE FUNCTION "dbo"."INV_TransferAssets"(
    "MI_Id" bigint,
    "INVMST_Id" bigint,
    "INVMLOFrom_Id" bigint,
    "INVMLOTo_Id" bigint,
    "INVMI_Id" bigint,
    "INVSTO_SalesRate" decimal(18,2),
    "INVATR_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "transferQty" decimal(18,2);
    "INVSTO_Id" bigint;
    "MastertransferQty" decimal(18,2);
    "fromlocationQty" decimal(18,2);
    "tolocationQty" decimal(18,2);
    "lifo" varchar(50);
    "soldqty" FLOAT;
    "CMI_Id" bigint;
    "PurchaseDate" timestamp;
    "citem" bigint;
    "Cstoreid" bigint;
    "SalesPrice" FLOAT;
BEGIN

    SELECT SUM("INVACO_CheckOutQty") INTO "fromlocationQty" 
    FROM "INV"."INV_Asset_CheckOut" 
    WHERE "MI_Id" = "INV_TransferAssets"."MI_Id" 
        AND "INVMST_Id" = "INV_TransferAssets"."INVMST_Id" 
        AND "INVMI_Id" = "INV_TransferAssets"."INVMI_Id" 
        AND "INVSTO_SalesRate" = "INV_TransferAssets"."INVSTO_SalesRate"  
        AND "INVMLO_Id" = "INV_TransferAssets"."INVMLOFrom_Id";

    SELECT SUM("INVACO_CheckOutQty") INTO "tolocationQty" 
    FROM "INV"."INV_Asset_CheckOut" 
    WHERE "MI_Id" = "INV_TransferAssets"."MI_Id" 
        AND "INVMST_Id" = "INV_TransferAssets"."INVMST_Id" 
        AND "INVMI_Id" = "INV_TransferAssets"."INVMI_Id" 
        AND "INVSTO_SalesRate" = "INV_TransferAssets"."INVSTO_SalesRate"  
        AND "INVMLO_Id" = "INV_TransferAssets"."INVMLOTo_Id";

    SELECT SUM("INVATR_CheckOutQty") INTO "transferQty" 
    FROM "INV"."INV_Asset_Transfer"  
    WHERE "MI_Id" = "INV_TransferAssets"."MI_Id" 
        AND "INVMI_Id" = "INV_TransferAssets"."INVMI_Id"  
        AND "INVSTO_SalesRate" = "INV_TransferAssets"."INVSTO_SalesRate" 
        AND "INVATR_Id" = "INV_TransferAssets"."INVATR_Id";

    IF (COALESCE("fromlocationQty", 0) != 0) THEN
    BEGIN

        UPDATE "INV"."INV_Asset_CheckOut" 
        SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" - "transferQty"  
        WHERE "MI_Id" = "INV_TransferAssets"."MI_Id" 
            AND "INVMLO_Id" = "INV_TransferAssets"."INVMLOFrom_Id" 
            AND "INVMST_Id" = "INV_TransferAssets"."INVMST_Id" 
            AND "INVMI_Id" = "INV_TransferAssets"."INVMI_Id" 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = "INV_TransferAssets"."INVSTO_SalesRate";

        UPDATE "INV"."INV_Asset_CheckOut" 
        SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" + "transferQty"  
        WHERE "MI_Id" = "INV_TransferAssets"."MI_Id" 
            AND "INVMLO_Id" = "INV_TransferAssets"."INVMLOTo_Id" 
            AND "INVMST_Id" = "INV_TransferAssets"."INVMST_Id" 
            AND "INVMI_Id" = "INV_TransferAssets"."INVMI_Id" 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = "INV_TransferAssets"."INVSTO_SalesRate";

    END;
    END IF;

    RETURN;

END;
$$;