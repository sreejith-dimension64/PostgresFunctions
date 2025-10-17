CREATE OR REPLACE FUNCTION "CM_FoodIteamedit"(p_CMMFI_Id bigint)
RETURNS TABLE(
    "cmmcA_Id" bigint,
    "cmmcO_Id" bigint,
    "cmmfI_Id" bigint,
    "cmmfI_FoodItemName" varchar,
    "cmmfI_FoodItemDescription" text,
    "cmmfI_UnitRate" numeric,
    "cmmfI_FoodItemFlag" varchar,
    "cmmcA_CategoryName" varchar,
    "cmmcO_CounterName" varchar,
    "icaI_Attachment" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."CMMCA_Id" AS "cmmcA_Id",
        d."CMMCO_Id" AS "cmmcO_Id",
        a."CMMFI_Id" AS "cmmfI_Id",
        a."CMMFI_FoodItemName" AS "cmmfI_FoodItemName",
        a."CMMFI_FoodItemDescription" AS "cmmfI_FoodItemDescription",
        a."CMMFI_UnitRate" AS "cmmfI_UnitRate",
        a."CMMFI_FoodItemFlag" AS "cmmfI_FoodItemFlag",
        b."CMMCA_CategoryName" AS "cmmcA_CategoryName",
        d."CMMCO_CounterName" AS "cmmcO_CounterName",
        c."ICAI_Attachment" AS "icaI_Attachment"
    FROM "CM_Master_FoodItem" a
    INNER JOIN "CM_Master_Category" b ON a."CMMCA_Id" = b."CMMCA_Id"
    INNER JOIN "IVRM_Canteen_Attatchment_Item" c ON a."CMMFI_Id" = c."CMMFI_Id"
    LEFT JOIN "CM_Master_Counter" d ON a."CMMCO_Id" = d."CMMCO_Id"
    WHERE a."CMMFI_Id" = p_CMMFI_Id;
END;
$$;