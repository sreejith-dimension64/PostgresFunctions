CREATE OR REPLACE FUNCTION "INV"."INV_LIFO_FIFO_ITEMbkp"(
    "MI_Id" BIGINT,
    "INVC_LIFOFIFOFlg" VARCHAR(20),
    "INVMST_Id" BIGINT
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVSTO_PurchaseDate" TIMESTAMP,
    "INVSTO_PurchaseRate" NUMERIC,
    "INVSTO_SalesRate" NUMERIC,
    "INVSTO_AvaiableStock" NUMERIC,
    "INVMI_ItemCode" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
   
    IF "INVC_LIFOFIFOFlg" = 'LIFO' THEN
        RETURN QUERY
        SELECT DISTINCT a."INVMI_Id", 
               a."INVMI_ItemName",
               MAX(b."INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate",
               b."INVSTO_PurchaseRate",
               b."INVSTO_SalesRate",
               SUM(b."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
               a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a 
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" c ON c."INVMST_Id" = b."INVMST_Id"
        WHERE a."MI_Id" = "MI_Id" 
          AND b."INVSTO_PurchaseDate" IS NOT NULL 
          AND b."INVMST_Id" = "INVMST_Id"
          AND a."INVMI_ActiveFlg" = 1 
          AND b."INVSTO_AvaiableStock" <> 0
        GROUP BY a."INVMI_Id",
                 a."INVMI_ItemName",
                 a."INVMI_ItemCode",
                 b."INVSTO_PurchaseRate",
                 b."INVSTO_SalesRate"
        ORDER BY "INVSTO_PurchaseDate" ASC;
        
    ELSIF "INVC_LIFOFIFOFlg" = 'FIFO' THEN
        RETURN QUERY
        SELECT DISTINCT a."INVMI_Id", 
               a."INVMI_ItemName",
               MIN(b."INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate",
               b."INVSTO_PurchaseRate",
               b."INVSTO_SalesRate",
               SUM(b."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock",
               a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a 
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Store" c ON c."INVMST_Id" = b."INVMST_Id"
        WHERE a."MI_Id" = "MI_Id" 
          AND b."INVSTO_PurchaseDate" IS NOT NULL 
          AND b."INVMST_Id" = "INVMST_Id"
          AND a."INVMI_ActiveFlg" = 1 
          AND b."INVSTO_AvaiableStock" <> 0
        GROUP BY a."INVMI_Id",
                 a."INVMI_ItemName",
                 a."INVMI_ItemCode",
                 b."INVSTO_PurchaseRate",
                 b."INVSTO_SalesRate"
        ORDER BY "INVSTO_PurchaseDate" ASC;
        
    END IF;
    
    RETURN;
    
END;
$$;