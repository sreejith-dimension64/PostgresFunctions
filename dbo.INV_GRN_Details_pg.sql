CREATE OR REPLACE FUNCTION "dbo"."INV_GRN_Details"(
    p_MI_Id BIGINT,
    p_IMPO_Id BIGINT
)
RETURNS TABLE(
    impO_Id BIGINT,
    impO_Number VARCHAR,
    impO_Date TIMESTAMP,
    itpO_Id BIGINT,
    itpO_Qty NUMERIC,
    imiT_Item_Code VARCHAR,
    imiT_Id BIGINT,
    imiT_Name VARCHAR,
    imU_Id BIGINT,
    imU_Name VARCHAR,
    imS_Id BIGINT,
    imS_Name VARCHAR,
    imsT_Id BIGINT,
    imsT_Name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "a"."IMPO_Id" AS impO_Id,
        "a"."IMPO_Number" AS impO_Number,
        "a"."IMPO_Date" AS impO_Date,
        "b"."ITPO_Id" AS itpO_Id,
        "b"."ITPO_Qty" AS itpO_Qty,
        "c"."IMIT_Item_Code" AS imiT_Item_Code,
        "c"."IMIT_Id" AS imiT_Id,
        "c"."IMIT_Name" AS imiT_Name,
        "d"."IMU_Id" AS imU_Id,
        "d"."IMU_Name" AS imU_Name,
        "e"."IMS_Id" AS imS_Id,
        "e"."IMS_Name" AS imS_Name,
        "f"."IMST_Id" AS imsT_Id,
        "f"."IMST_Name" AS imsT_Name
    FROM "INV"."INV_M_Pur_Order" AS "a"
    CROSS JOIN "INV"."INV_T_Pur_Order" AS "b"
    CROSS JOIN "INV"."INV_M_Item" AS "c"
    CROSS JOIN "INV"."INV_M_Uom" AS "d"
    CROSS JOIN "INV"."INV_M_Supplier" AS "e"
    CROSS JOIN "INV"."INV_M_Store" AS "f"
    WHERE "a"."MI_Id" = "c"."MI_Id" 
        AND "a"."IMPO_Id" = "b"."IMPO_Id" 
        AND "d"."IMU_Id" = "b"."IMU_Id" 
        AND "c"."IMIT_Id" = "b"."IMIT_Id" 
        AND "e"."IMS_Id" = "a"."IMS_Id" 
        AND "f"."IMST_Id" = "a"."IMST_Id" 
        AND "a"."MI_Id" = p_MI_Id 
        AND "a"."IMPO_Id" = p_IMPO_Id;
END;
$$;