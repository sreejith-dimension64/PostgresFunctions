CREATE OR REPLACE FUNCTION "INV"."INVENTORY_ALL_MAIL_PARAMETER"(
    "@MI_Id" bigint,
    "@UserID" bigint,
    "@INVMPR_Id" bigint,
    "@Template" TEXT
)
RETURNS TABLE(
    "REFNO" VARCHAR,
    "DATE" TIMESTAMP,
    "AMOUNT" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF "@Template" = 'PRTEMPLATE' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPR_PRNo"::VARCHAR AS "REFNO",
            "A"."INVMPR_PRDate" AS "DATE",
            "A"."INVMPR_ApproxTotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseRequisition" AS "A"
        WHERE "A"."INVMPR_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'PITEMPLATE' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPI_PINo"::VARCHAR AS "REFNO",
            "A"."INVMPI_PIDate" AS "DATE",
            "A"."INVMPI_ApproxTotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseIndent" AS "A"
        WHERE "A"."INVMPI_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'PITEMPLATEAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPI_PINo"::VARCHAR AS "REFNO",
            "A"."INVMPI_PIDate" AS "DATE",
            "A"."INVMPI_ApproxTotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseIndent" AS "A"
        WHERE "A"."INVMPI_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'POTEMPLATE' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPO_PONo"::VARCHAR AS "REFNO",
            "A"."INVMPO_PODate" AS "DATE",
            "A"."INVMPO_TotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseOrder" AS "A"
        WHERE "A"."INVMPO_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'POTEMPLATEAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPO_PONo"::VARCHAR AS "REFNO",
            "A"."INVMPO_PODate" AS "DATE",
            "A"."INVMPO_TotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseOrder" AS "A"
        WHERE "A"."INVMPO_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'STARTPIAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPIAPP_PINo"::VARCHAR AS "REFNO",
            "A"."INVMPIAPP_PIDate" AS "DATE",
            "A"."INVMPIAPP_ApproxTotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseIndent_Approval" AS "A"
        WHERE "A"."INVMPIAPP_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'ENDPIAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPIAPP_PINo"::VARCHAR AS "REFNO",
            "A"."INVMPIAPP_PIDate" AS "DATE",
            "A"."INVMPIAPP_ApproxTotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseIndent_Approval" AS "A"
        WHERE "A"."INVMPIAPP_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'STARTPOAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPOAPP_PONo"::VARCHAR AS "REFNO",
            "A"."INVMPOAPP_PODate" AS "DATE",
            "A"."INVMPOAPP_TotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseOrder_Approval" AS "A"
        WHERE "A"."INVMPOAPP_Id" = "@INVMPR_Id";
        
    ELSIF "@Template" = 'ENDPOAPPROVAL' THEN
        RETURN QUERY
        SELECT 
            "A"."INVMPOAPP_PONo"::VARCHAR AS "REFNO",
            "A"."INVMPOAPP_PODate" AS "DATE",
            "A"."INVMPOAPP_TotAmount" AS "AMOUNT"
        FROM "INV"."INV_M_PurchaseOrder_Approval" AS "A"
        WHERE "A"."INVMPOAPP_Id" = "@INVMPR_Id";
        
    END IF;
    
    RETURN;
    
END;
$$;