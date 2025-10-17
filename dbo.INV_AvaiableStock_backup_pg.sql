CREATE OR REPLACE FUNCTION "INV"."INV_AvaiableStock_backup"(
    "p_MI_Id" BIGINT,
    "p_INVMI_Id" BIGINT,
    "p_INVSTO_SalesRate" DECIMAL(18,2),
    "p_INVMST_Id" BIGINT,
    "p_INVSTO_BatchNo" VARCHAR(20)
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "INVMI_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "AvaiableStock" NUMERIC,
    "INVSTO_BatchNo" VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_lifo" VARCHAR(30);
BEGIN
    SELECT "INVC_LIFOFIFOFlg" INTO "v_lifo"
    FROM "INV"."INV_Configuration"
    WHERE "MI_Id" = "p_MI_Id" 
        AND "INVMST_Id" = "p_INVMST_Id" 
        AND "INVC_ProcessApplFlg" = 1;

    IF "v_lifo" = 'LIFO' THEN
        RETURN QUERY
        SELECT 
            s."MI_Id",
            s."INVMI_Id",
            s."INVMST_Id",
            s."INVSTO_AvaiableStock" AS "AvaiableStock",
            s."INVSTO_BatchNo"
        FROM "INV"."INV_Stock" s
        WHERE s."MI_Id" = "p_MI_Id" 
            AND s."INVMI_Id" = "p_INVMI_Id" 
            AND s."INVMST_Id" = "p_INVMST_Id" 
            AND s."INVSTO_SalesRate" = "p_INVSTO_SalesRate" 
            AND s."INVSTO_BatchNo" = "p_INVSTO_BatchNo";
    ELSE
        RETURN QUERY
        SELECT 
            s."MI_Id",
            s."INVMI_Id",
            s."INVMST_Id",
            s."INVSTO_AvaiableStock" AS "AvaiableStock",
            s."INVSTO_BatchNo"
        FROM "INV"."INV_Stock" s
        WHERE s."MI_Id" = "p_MI_Id" 
            AND s."INVMI_Id" = "p_INVMI_Id" 
            AND s."INVMST_Id" = "p_INVMST_Id" 
            AND s."INVSTO_SalesRate" = "p_INVSTO_SalesRate" 
            AND s."INVSTO_BatchNo" = "p_INVSTO_BatchNo";
    END IF;

    RETURN;
END;
$$;