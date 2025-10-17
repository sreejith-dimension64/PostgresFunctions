CREATE OR REPLACE FUNCTION "dbo"."Inv_Product_report"(
    "@MI_Id" VARCHAR(100),
    "@INVMP_Id" VARCHAR(100),
    "@type" VARCHAR(10)
)
RETURNS TABLE(
    "INVMP_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMPI_ItemQty" NUMERIC,
    "INVMP_ProductName" VARCHAR,
    "INVMPS_Id" BIGINT,
    "INVMPSS_Status" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@str1" TEXT;
    "@Dynamic" TEXT;
BEGIN

    IF "@type" = '1' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            "inv"."INV_Master_Product_Item"."INVMP_Id",
            "inv"."INV_Master_Product_Item"."INVMI_Id",
            "inv"."INV_Master_Product_Item"."INVMPI_ItemQty",
            "inv"."INV_Master_Product"."INVMP_ProductName",
            NULL::BIGINT AS "INVMPS_Id",
            NULL::VARCHAR AS "INVMPSS_Status"
        FROM "inv"."INV_Master_Product_Item" 
        INNER JOIN "inv"."INV_Master_Product" 
            ON "inv"."INV_Master_Product_Item"."INVMP_Id" = "inv"."INV_Master_Product"."INVMP_Id"
        WHERE "inv"."INV_Master_Product_Item"."INVMP_Id" = "@INVMP_Id"::BIGINT 
            AND "inv"."INV_Master_Product"."MI_Id" = "@MI_Id"::BIGINT
        ORDER BY "inv"."INV_Master_Product_Item"."INVMP_Id", 
                 "inv"."INV_Master_Product_Item"."INVMI_Id";
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            "dcs"."INV_Master_Product_Stages_Status"."INVMP_Id",
            NULL::BIGINT AS "INVMI_Id",
            NULL::NUMERIC AS "INVMPI_ItemQty",
            NULL::VARCHAR AS "INVMP_ProductName",
            "dcs"."INV_Master_Product_Stages_Status"."INVMPS_Id",
            "dcs"."INV_Master_Product_Stages_Status"."INVMPSS_Status"
        FROM "dcs"."INV_Master_Product_Stages_Status" 
        INNER JOIN "inv"."INV_Master_Product" 
            ON "dcs"."INV_Master_Product_Stages_Status"."INVMP_Id" = "inv"."INV_Master_Product"."INVMP_Id"
        WHERE "dcs"."INV_Master_Product_Stages_Status"."INVMP_Id" = "@INVMP_Id"::BIGINT 
            AND "dcs"."INV_Master_Product_Stages_Status"."MI_Id" = "@MI_Id"::BIGINT
        ORDER BY "dcs"."INV_Master_Product_Stages_Status"."INVMP_Id", 
                 "dcs"."INV_Master_Product_Stages_Status"."INVMPS_Id";
    
    END IF;

    RETURN;

END;
$$;