CREATE OR REPLACE FUNCTION "INV"."INV_BalanceStock"(
    p_MI_Id BIGINT,
    p_INVMI_Id BIGINT
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "PurOBQty" NUMERIC,
    "INVSTO_AvaiableStock" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "INS"."INVMI_Id", 
        (SUM("INS"."INVSTO_PurOBQty") + SUM("INS"."INVSTO_PurRetQty")) AS "PurOBQty",
        SUM("INS"."INVSTO_AvaiableStock") AS "INVSTO_AvaiableStock"
    FROM "INV"."INV_Stock" "INS"
    WHERE "INS"."MI_Id" = p_MI_Id 
        AND "INS"."INVMI_Id" = p_INVMI_Id
    GROUP BY "INS"."INVMI_Id";
END;
$$;