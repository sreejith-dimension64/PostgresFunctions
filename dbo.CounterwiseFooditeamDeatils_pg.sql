CREATE OR REPLACE FUNCTION "dbo"."CounterwiseFooditeamDeatils"(
    "p_CMMCO_Id" bigint,
    "p_CMMCA_Id" bigint
)
RETURNS TABLE(
    "cmmfI_FoodItemName" VARCHAR,
    "cmmfI_FoodItemDescription" VARCHAR,
    "cmmfI_UnitRate" NUMERIC,
    "cmmfI_OutofStockFlg" BOOLEAN,
    "cmmfI_PathURL" VARCHAR,
    "cmmfI_Id" BIGINT,
    "cmmcA_CategoryName" VARCHAR,
    "cmmcA_Id" BIGINT,
    "cmmfI_ActiveFlg" BOOLEAN,
    "cmmfI_FoodItemFlag" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF ("p_CMMCO_Id" > 0) AND "p_CMMCA_Id" = 0 THEN
        RETURN QUERY
        SELECT 
            "c"."CMMFI_FoodItemName" AS "cmmfI_FoodItemName",
            "c"."CMMFI_FoodItemDescription" AS "cmmfI_FoodItemDescription",
            "c"."CMMFI_UnitRate" AS "cmmfI_UnitRate",
            "c"."CMMFI_OutofStockFlg" AS "cmmfI_OutofStockFlg",
            "c"."CMMFI_PathURL" AS "cmmfI_PathURL",
            "c"."CMMFI_Id" AS "cmmfI_Id",
            "b"."CMMCA_CategoryName" AS "cmmcA_CategoryName",
            "b"."CMMCA_Id" AS "cmmcA_Id",
            "c"."CMMFI_ActiveFlg" AS "cmmfI_ActiveFlg",
            "c"."CMMFI_FoodItemFlag" AS "cmmfI_FoodItemFlag"
        FROM "CM_Master_Counter" "a"
        INNER JOIN "CM_Master_Category" "b" ON "b"."CMMCO_Id" = "a"."CMMCO_Id"
        INNER JOIN "CM_Master_FoodItem" "c" ON "c"."CMMCA_Id" = "b"."CMMCA_Id"
        WHERE "a"."CMMCO_Id" = "p_CMMCO_Id" AND "c"."CMMFI_ActiveFlg" = true;
    ELSE
        RETURN QUERY
        SELECT 
            "c"."CMMFI_FoodItemName" AS "cmmfI_FoodItemName",
            "c"."CMMFI_FoodItemDescription" AS "cmmfI_FoodItemDescription",
            "c"."CMMFI_UnitRate" AS "cmmfI_UnitRate",
            "c"."CMMFI_OutofStockFlg" AS "cmmfI_OutofStockFlg",
            "c"."CMMFI_PathURL" AS "cmmfI_PathURL",
            "c"."CMMFI_Id" AS "cmmfI_Id",
            "b"."CMMCA_CategoryName" AS "cmmcA_CategoryName",
            "b"."CMMCA_Id" AS "cmmcA_Id",
            "c"."CMMFI_ActiveFlg" AS "cmmfI_ActiveFlg",
            "c"."CMMFI_FoodItemFlag" AS "cmmfI_FoodItemFlag"
        FROM "CM_Master_Counter" "a"
        INNER JOIN "CM_Master_Category" "b" ON "b"."CMMCO_Id" = "a"."CMMCO_Id"
        INNER JOIN "CM_Master_FoodItem" "c" ON "c"."CMMCA_Id" = "b"."CMMCA_Id"
        WHERE "b"."CMMCA_Id" = "p_CMMCA_Id" AND "a"."CMMCO_Id" = "p_CMMCO_Id" AND "c"."CMMFI_ActiveFlg" = true;
    END IF;
    
    RETURN;
END;
$$;