CREATE OR REPLACE FUNCTION "dbo"."FMS_Correspondance_Report"(
    "p_MI_Id" TEXT,
    "p_CLIENTSUPPLIERFLGFLAG" TEXT,
    "p_FLAG" TEXT,
    "p_FROMDATE" VARCHAR(10),
    "p_TODATE" TEXT,
    "p_CLIENTIDS" TEXT,
    "p_PROJECTIDS" TEXT,
    "p_SUPPLIERIDS" TEXT,
    "p_SALESID" TEXT
)
RETURNS TABLE(
    "FMSCOR_Id" INTEGER,
    "FMSCOR_RefernceNo" VARCHAR,
    "FMSCOR_Subject" TEXT,
    "FMSCOR_ClientSupplierFlg" VARCHAR,
    "FMSCOR_Date" TIMESTAMP,
    "IMFY_FinancialYear" VARCHAR,
    "DETAILS" TEXT,
    "FMSMFC_FileCategoryName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SQL" TEXT;
BEGIN

    IF "p_CLIENTSUPPLIERFLGFLAG" = 'All' THEN
    
        RETURN QUERY
        SELECT * FROM (
        
            SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            ('Client Name :' || C."ISMMCLT_ClientName" || 
            'Project :' || (CASE WHEN D."ISMMPR_ProjectName" IS NULL THEN 'NA' ELSE D."ISMMPR_ProjectName" END)) AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            LEFT JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = B."ISMMPR_Id"
            WHERE A."MI_Id" = "p_MI_Id"::INTEGER AND (A."FMSCOR_Date" BETWEEN "p_FROMDATE"::TIMESTAMP AND "p_TODATE"::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORCL_ActiveFlg" = 1
            
            UNION ALL
            
            SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            D."INVMS_SupplierName" AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_Supplier" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "INV"."INV_Master_Supplier" D ON D."INVMS_Id" = B."INVMS_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            WHERE A."MI_Id" = "p_MI_Id"::INTEGER AND (A."FMSCOR_Date" BETWEEN "p_FROMDATE"::TIMESTAMP AND "p_TODATE"::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSUP_ActiveFlg" = 1
            
            UNION ALL
            
            SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            D."ISMSLE_LeadName" AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_SalesLead" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "ISM_Sales_Lead" D ON D."ISMSLE_Id" = B."ISMSLE_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            WHERE A."MI_Id" = "p_MI_Id"::INTEGER AND (A."FMSCOR_Date" BETWEEN "p_FROMDATE"::TIMESTAMP AND "p_TODATE"::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSL_ActiveFlg" = 1
            
        ) AS D;
    
    ELSIF "p_CLIENTSUPPLIERFLGFLAG" = 'Supplier' THEN
    
        "v_SQL" := 'SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
        D."INVMS_SupplierName" AS "DETAILS",
        B1."FMSMFC_FileCategoryName"
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_Supplier" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "INV"."INV_Master_Supplier" D ON D."INVMS_Id" = B."INVMS_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."INVMS_Id" IN (' || "p_SUPPLIERIDS" || ') 
        AND (A."FMSCOR_Date" BETWEEN ''' || "p_FROMDATE" || '''::TIMESTAMP AND ''' || "p_TODATE" || '''::TIMESTAMP) 
        AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSUP_ActiveFlg" = 1';
        
        RETURN QUERY EXECUTE "v_SQL";
    
    ELSIF "p_CLIENTSUPPLIERFLGFLAG" = 'Sales Lead' THEN
    
        "v_SQL" := 'SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
        D."ISMSLE_LeadName" AS "DETAILS",
        B1."FMSMFC_FileCategoryName"
        FROM "FMS_Correspondence" A 
        INNER JOIN "FMS_Correspondence_SalesLead" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "ISM_Sales_Lead" D ON D."ISMSLE_Id" = B."ISMSLE_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."ISMSLE_Id" IN (' || "p_SALESID" || ') 
        AND (A."FMSCOR_Date" BETWEEN ''' || "p_FROMDATE" || '''::TIMESTAMP AND ''' || "p_TODATE" || '''::TIMESTAMP) 
        AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSL_ActiveFlg" = 1';
        
        RETURN QUERY EXECUTE "v_SQL";
    
    ELSIF "p_CLIENTSUPPLIERFLGFLAG" = 'Client' THEN
    
        IF "p_FLAG" = 'All' THEN
        
            "v_SQL" := 'SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            (''Client Name :'' || C."ISMMCLT_ClientName" || 
            ''Project :'' || (CASE WHEN D."ISMMPR_ProjectName" IS NULL THEN ''NA'' ELSE D."ISMMPR_ProjectName" END)) AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            LEFT JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = B."ISMMPR_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."ISMMCLT_Id" IN (' || "p_CLIENTIDS" || ') 
            AND (A."FMSCOR_Date" BETWEEN ''' || "p_FROMDATE" || '''::TIMESTAMP AND ''' || "p_TODATE" || '''::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORCL_ActiveFlg" = 1';
            
            RETURN QUERY EXECUTE "v_SQL";
        
        ELSIF "p_FLAG" = 'With Project' THEN
        
            "v_SQL" := 'SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            (''Client Name :'' || C."ISMMCLT_ClientName" || 
            ''Project :'' || (CASE WHEN D."ISMMPR_ProjectName" IS NULL THEN ''NA'' ELSE D."ISMMPR_ProjectName" END)) AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            INNER JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = B."ISMMPR_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."ISMMCLT_Id" IN (' || "p_CLIENTIDS" || ') 
            AND B."ISMMPR_Id" IN(' || "p_PROJECTIDS" || ') 
            AND (A."FMSCOR_Date" BETWEEN ''' || "p_FROMDATE" || '''::TIMESTAMP AND ''' || "p_TODATE" || '''::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORCL_ActiveFlg" = 1';
            
            RETURN QUERY EXECUTE "v_SQL";
        
        ELSIF "p_FLAG" = 'With Out Project' THEN
        
            "v_SQL" := 'SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_Subject", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Date", E."IMFY_FinancialYear",
            (''Client Name :'' || C."ISMMCLT_ClientName") AS "DETAILS",
            B1."FMSMFC_FileCategoryName"
            FROM "FMS_Correspondence" A 
            INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
            INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
            INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
            INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
            WHERE A."MI_Id" = ' || "p_MI_Id" || ' AND B."ISMMCLT_Id" IN (' || "p_CLIENTIDS" || ') 
            AND (A."FMSCOR_Date" BETWEEN ''' || "p_FROMDATE" || '''::TIMESTAMP AND ''' || "p_TODATE" || '''::TIMESTAMP) 
            AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORCL_ActiveFlg" = 1';
            
            RETURN QUERY EXECUTE "v_SQL";
        
        END IF;
    
    END IF;
    
    RETURN;

END;
$$;