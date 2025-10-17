CREATE OR REPLACE FUNCTION "dbo"."INV_ConfigurationDetails"(p_MI_Id BIGINT)
RETURNS TABLE (
    "INVC_Id" BIGINT,
    "INVC_LIFOFIFOFlg" VARCHAR,
    "INVC_ProcessApplFlg" VARCHAR,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" VARCHAR,
    "INVC_PRApplicableFlg" VARCHAR,
    "INVC_AlertsBeforeDays" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "IC"."INVC_Id",
        "IC"."INVC_LIFOFIFOFlg",
        "IC"."INVC_ProcessApplFlg",
        "IC"."INVMST_Id",
        "IMS"."INVMS_StoreName",
        "IC"."INVC_PRApplicableFlg",
        "IC"."INVC_AlertsBeforeDays"
    FROM "INV"."INV_Configuration" "IC"
    INNER JOIN "INV"."INV_Master_Store" "IMS" 
        ON "IC"."INVMST_Id" = "IMS"."INVMST_Id" 
        AND "IMS"."INVMS_ActiveFlg" = 1
    WHERE "IC"."MI_Id" = "IMS"."MI_Id" 
        AND "IC"."MI_Id" = p_MI_Id;
END;
$$;