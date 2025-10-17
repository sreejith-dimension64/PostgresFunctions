CREATE OR REPLACE FUNCTION "CategorywiseFooditeamDeatils"(
    p_CMMCA_Id bigint
)
RETURNS TABLE(
    "cmmfI_FoodItemName" VARCHAR,
    "cmmfI_FoodItemDescription" VARCHAR,
    "cmmfI_UnitRate" NUMERIC,
    "cmmfI_OutofStockFlg" VARCHAR,
    "cmmfI_PathURL" VARCHAR,
    "cmmfI_Id" BIGINT,
    "cmmcA_CategoryName" VARCHAR,
    "cmmcA_Id" BIGINT,
    "cmmfI_ActiveFlg" VARCHAR,
    "cmmfI_FoodItemFlag" VARCHAR,
    "cmmmCO_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."CMMFI_FoodItemName" AS "cmmfI_FoodItemName",
        c."CMMFI_FoodItemDescription" AS "cmmfI_FoodItemDescription",
        c."CMMFI_UnitRate" AS "cmmfI_UnitRate",
        c."CMMFI_OutofStockFlg" AS "cmmfI_OutofStockFlg",
        c."CMMFI_PathURL" AS "cmmfI_PathURL",
        c."CMMFI_Id" AS "cmmfI_Id",
        b."CMMCA_CategoryName" AS "cmmcA_CategoryName",
        b."CMMCA_Id" AS "cmmcA_Id",
        c."CMMFI_ActiveFlg" AS "cmmfI_ActiveFlg",
        c."CMMFI_FoodItemFlag" AS "cmmfI_FoodItemFlag",
        c."CMMCO_Id" AS "cmmmCO_Id"
    FROM "CM_Master_Counter" a
    INNER JOIN "CM_Master_Category" b ON b."CMMCO_Id" = a."CMMCO_Id"
    INNER JOIN "CM_Master_FoodItem" c ON c."CMMCA_Id" = b."CMMCA_Id"
    WHERE b."CMMCA_Id" = p_CMMCA_Id;
END;
$$;