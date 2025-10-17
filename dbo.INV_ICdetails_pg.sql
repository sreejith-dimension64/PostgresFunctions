CREATE OR REPLACE FUNCTION "dbo"."INV_ICdetails"(
    "MI_Id" VARCHAR,
    "INVMIC_Id" VARCHAR
)
RETURNS TABLE(
    "invmiC_Id" BIGINT,
    "invmiC_StuOtherFlg" VARCHAR,
    "invtiC_Id" BIGINT,
    "invmI_Id" BIGINT,
    "invmuoM_Id" BIGINT,
    "invmP_Id" BIGINT,
    "invmI_ItemName" VARCHAR,
    "invtiC_ICPrice" NUMERIC,
    "invmuoM_UOMName" VARCHAR,
    "invtiC_BatchNo" VARCHAR,
    "invtiC_ICQty" NUMERIC,
    "invtiC_Naration" TEXT,
    "invtiC_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."INVMIC_Id" AS "invmiC_Id", 
        a."INVMIC_StuOtherFlg" AS "invmiC_StuOtherFlg", 
        b."INVTIC_Id" AS "invtiC_Id", 
        b."INVMI_Id" AS "invmI_Id", 
        b."INVMUOM_Id" AS "invmuoM_Id", 
        b."INVMP_Id" AS "invmP_Id",
        c."INVMI_ItemName" AS "invmI_ItemName",
        b."INVTIC_ICPrice" AS "invtiC_ICPrice", 
        d."INVMUOM_UOMName" AS "invmuoM_UOMName", 
        b."INVTIC_BatchNo" AS "invtiC_BatchNo", 
        b."INVTIC_ICQty" AS "invtiC_ICQty",
        b."INVTIC_Naration" AS "invtiC_Naration", 
        b."INVTIC_ActiveFlg" AS "invtiC_ActiveFlg"
    FROM "INV"."INV_M_ItemConsumption" a
    INNER JOIN "INV"."INV_T_ItemConsumption" b ON a."INVMIC_Id" = b."INVMIC_Id"
    INNER JOIN "INV"."INV_Master_Item" c ON b."INVMI_Id" = c."INVMI_Id"
    INNER JOIN "INV"."INV_Master_UOM" d ON b."INVMUOM_Id" = d."INVMUOM_Id"
    INNER JOIN "INV"."INV_Stock" e ON c."INVMI_Id" = e."INVMI_Id"
    WHERE a."MI_Id" = "INV_ICdetails"."MI_Id" AND a."INVMIC_Id" = "INV_ICdetails"."INVMIC_Id"
    ORDER BY a."INVMIC_Id";

END;
$$;