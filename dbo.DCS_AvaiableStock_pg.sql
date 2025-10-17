CREATE OR REPLACE FUNCTION "dbo"."DCS_AvaiableStock"(
    p_MI_Id BIGINT,
    p_INVMP_Id BIGINT,
    p_INVMP_ProductPrice DECIMAL(18,2),
    p_INVMST_Id BIGINT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "INVSTO_PurchaseDate" TIMESTAMP,
    "INVMP_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVSTO_BatchNo" VARCHAR,
    "AvaiableStock" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "DCS_Stock"."MI_Id",
        MAX("DCS_Stock"."INVSTO_PurchaseDate") AS "INVSTO_PurchaseDate",
        "DCS_Stock"."INVMP_Id",
        "DCS_Stock"."INVMST_Id",
        "DCS_Stock"."INVSTO_BatchNo",
        SUM("DCS_Stock"."INVSTO_AvaiableStock") AS "AvaiableStock"
    FROM "DCS"."DCS_Stock"
    WHERE "DCS_Stock"."MI_Id" = p_MI_Id 
        AND "DCS_Stock"."INVMP_Id" = p_INVMP_Id 
        AND "DCS_Stock"."INVMST_Id" = p_INVMST_Id
    GROUP BY 
        "DCS_Stock"."MI_Id",
        "DCS_Stock"."INVMP_Id",
        "DCS_Stock"."INVMST_Id",
        "DCS_Stock"."INVSTO_BatchNo";
END;
$$;