CREATE OR REPLACE FUNCTION "dbo"."FMS_Search_RefernceNo_Details"(
    "@MI_Id" TEXT,
    "@FMSCOR_ClientSupplierFlg" TEXT,
    "@FromDate" TEXT,
    "@ToDate" TEXT,
    "@FMSMFC_Id" TEXT,
    "@ISMMCLT_Id" TEXT,
    "@INVMS_Id" TEXT,
    "@ISMSLE_Id" TEXT
)
RETURNS TABLE(
    "FMSCOR_Id" INTEGER,
    "FMSCOR_RefernceNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@FMSCOR_ClientSupplierFlg" = 'Client' THEN
    
        RETURN QUERY
        SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo" 
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
        WHERE A."MI_Id" = "@MI_Id" 
        AND A."FMSCOR_ClientSupplierFlg" = "@FMSCOR_ClientSupplierFlg" 
        AND B."ISMMCLT_Id" = "@ISMMCLT_Id"
        AND A."FMSCOR_ActiveFlg" = 1 
        AND B."FMSCORCL_ActiveFlg" = 1;
    
    ELSIF "@FMSCOR_ClientSupplierFlg" = 'Supplier' THEN
    
        RETURN QUERY
        SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo" 
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Supplier" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "INV"."INV_Master_Supplier" C ON C."INVMS_Id" = B."INVMS_Id"
        WHERE A."MI_Id" = "@MI_Id" 
        AND A."FMSCOR_ClientSupplierFlg" = "@FMSCOR_ClientSupplierFlg" 
        AND B."INVMS_Id" = "@INVMS_Id"
        AND A."FMSCOR_ActiveFlg" = 1 
        AND B."FMSCORSUP_ActiveFlg" = 1;
    
    ELSIF "@FMSCOR_ClientSupplierFlg" = 'Sales Lead' THEN
    
        RETURN QUERY
        SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo" 
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_SalesLead" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "ISM_Sales_Lead" C ON C."ISMSLE_Id" = B."ISMSLE_Id"
        WHERE A."MI_Id" = "@MI_Id" 
        AND A."FMSCOR_ClientSupplierFlg" = "@FMSCOR_ClientSupplierFlg" 
        AND B."ISMSLE_Id" = "@ISMSLE_Id"
        AND A."FMSCOR_ActiveFlg" = 1 
        AND B."FMSCORSL_ActiveFlg" = 1;
    
    END IF;

    RETURN;

END;
$$;