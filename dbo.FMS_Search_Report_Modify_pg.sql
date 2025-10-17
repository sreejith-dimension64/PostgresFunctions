CREATE OR REPLACE FUNCTION "dbo"."FMS_Search_Report_Modify"(
    p_MI_Id TEXT,
    p_SearchValue TEXT,
    p_ClientSupplierFlgflag TEXT,
    p_UserFlag TEXT
)
RETURNS TABLE(
    "FMSCOR_Id" INTEGER,
    "FMSCOR_RefernceNo" TEXT,
    "FMSCOR_ClientSupplierFlg" TEXT,
    "FMSCOR_Subject" TEXT,
    "FMSCOR_LetterHeadNo" TEXT,
    "FMSCOR_Date" TIMESTAMP,
    "FMSMFC_FileCategoryName" TEXT,
    "IMFY_FinancialYear" TEXT,
    "DETAILS" TEXT,
    "ProjectName" TEXT,
    "FMSCOR_Description" TEXT,
    "FMSCOR_ToName" TEXT,
    "CREATEDBY" TEXT,
    "FMSMPFN_PhysicalFileName" TEXT,
    "FMSMFCBT_FileCabinetName" TEXT,
    "FMSMFCR_CabinetRowName" TEXT,
    "FMSMFCC_CabinetColumnName" TEXT,
    "FMSMTMD_DispatchMode" TEXT,
    "FMSCORMD_SentDate" TIMESTAMP,
    "FMSCORMD_ReferenceNo" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "FMS_CLINET_REPORT";
    DROP TABLE IF EXISTS "FMS_SALES_REPORT";
    DROP TABLE IF EXISTS "FMS_SUPPLIER_REPORT";
    DROP TABLE IF EXISTS "FMS_OTHERS_REPORT";
    DROP TABLE IF EXISTS "FMS_INTERNAL_REPORT";

    /* CLIENT REPORT */
    CREATE TEMP TABLE "FMS_CLINET_REPORT" AS
    SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Subject",
        COALESCE(A."FMSCOR_LetterHeadNo",'') AS "FMSCOR_LetterHeadNo", A."FMSCOR_Date",
        D."FMSMFC_FileCategoryName", E."IMFY_FinancialYear",
        ('Client Name :' || C."ISMMCLT_ClientName") AS "DETAILS",
        'Project :' || (CASE WHEN F."ISMMPR_ProjectName" IS NULL THEN 'NA' ELSE F."ISMMPR_ProjectName" END) AS "ProjectName",
        A."FMSCOR_Description", A."FMSCOR_ToName",
        (SELECT "UserName" FROM "ApplicationUser" K WHERE A."FMSCOR_CreatedBy" = K."Id") AS "CREATEDBY",
        H."FMSMPFN_PhysicalFileName", J."FMSMFCBT_FileCabinetName", K."FMSMFCR_CabinetRowName",
        L."FMSMFCC_CabinetColumnName", N."FMSMTMD_DispatchMode",
        M."FMSCORMD_SentDate", M."FMSCORMD_ReferenceNo"
    FROM "FMS_Correspondence" A
    INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
    INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
    INNER JOIN "FMS_Master_FileCategory" D ON D."FMSMFC_Id" = A."FMSMFC_Id"
    INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
    LEFT JOIN "ISM_Master_Project" F ON F."ISMMPR_Id" = B."ISMMPR_Id"
    LEFT JOIN "FMS_Correspondence_Files" G ON G."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName" H ON H."FMSMPFN_Id" = G."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName_FileCabinet" I ON I."FMSMPFN_Id" = H."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_FileCabinet" J ON J."FMSMFCBT_Id" = I."FMSMFCBT_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Row" K ON K."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND K."FMSMFCR_Id" = I."FMSMFCR_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Column" L ON L."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND L."FMSMFCC_Id" = I."FMSMFCC_Id"
    LEFT JOIN "FMS_Correspondence_Mode" M ON M."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_DispatchMode" N ON N."FMSMDMD_Id" = M."FMSMDMD_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORCL_ActiveFlg" = 1 AND A."FMSCOR_ClientSupplierFlg" = 'Client'
    AND (REPLACE(C."ISMMCLT_ClientName",' ','') LIKE '%' || p_SearchValue || '%' OR D."FMSMFC_FileCategoryName" LIKE '%' || p_SearchValue || '%'
    OR A."FMSCOR_RefernceNo" LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_Subject",'') LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_Description",'') LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_ToName",'') LIKE '%' || p_SearchValue || '%'
    OR H."FMSMPFN_PhysicalFileName" LIKE '%' || p_SearchValue || '%' OR J."FMSMFCBT_FileCabinetName" LIKE '%' || p_SearchValue || '%'
    OR K."FMSMFCR_CabinetRowName" LIKE '%' || p_SearchValue || '%' OR L."FMSMFCC_CabinetColumnName" LIKE '%' || p_SearchValue || '%'
    OR N."FMSMTMD_DispatchMode" LIKE '%' || p_SearchValue || '%' OR E."IMFY_FinancialYear" LIKE '%' || p_SearchValue || '%');

    /* SALES REPORT */
    CREATE TEMP TABLE "FMS_SALES_REPORT" AS
    SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Subject",
        COALESCE(A."FMSCOR_LetterHeadNo",'') AS "FMSCOR_LetterHeadNo", A."FMSCOR_Date",
        B1."FMSMFC_FileCategoryName", E."IMFY_FinancialYear",
        ('Sales Lead :' || D."ISMSLE_LeadName") AS "DETAILS", '' AS "ProjectName",
        A."FMSCOR_Description", A."FMSCOR_ToName",
        (SELECT "UserName" FROM "ApplicationUser" K WHERE A."FMSCOR_CreatedBy" = K."Id") AS "CREATEDBY",
        H."FMSMPFN_PhysicalFileName", J."FMSMFCBT_FileCabinetName", K."FMSMFCR_CabinetRowName",
        L."FMSMFCC_CabinetColumnName", N."FMSMTMD_DispatchMode",
        M."FMSCORMD_SentDate", M."FMSCORMD_ReferenceNo"
    FROM "FMS_Correspondence" A
    INNER JOIN "FMS_Correspondence_SalesLead" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
    INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
    INNER JOIN "ISM_Sales_Lead" D ON D."ISMSLE_Id" = B."ISMSLE_Id"
    INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
    LEFT JOIN "FMS_Correspondence_Files" G ON G."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName" H ON H."FMSMPFN_Id" = G."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName_FileCabinet" I ON I."FMSMPFN_Id" = H."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_FileCabinet" J ON J."FMSMFCBT_Id" = I."FMSMFCBT_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Row" K ON K."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND K."FMSMFCR_Id" = I."FMSMFCR_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Column" L ON L."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND L."FMSMFCC_Id" = I."FMSMFCC_Id"
    LEFT JOIN "FMS_Correspondence_Mode" M ON M."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_DispatchMode" N ON N."FMSMDMD_Id" = M."FMSMDMD_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSL_ActiveFlg" = 1 AND A."FMSCOR_ClientSupplierFlg" = 'Sales Lead'
    AND (REPLACE(D."ISMSLE_LeadName",' ','') LIKE '%' || p_SearchValue || '%' OR B1."FMSMFC_FileCategoryName" LIKE '%' || p_SearchValue || '%'
    OR A."FMSCOR_RefernceNo" LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_Subject",'') LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_Description",'') LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_ToName",'') LIKE '%' || p_SearchValue || '%'
    OR H."FMSMPFN_PhysicalFileName" LIKE '%' || p_SearchValue || '%' OR J."FMSMFCBT_FileCabinetName" LIKE '%' || p_SearchValue || '%'
    OR K."FMSMFCR_CabinetRowName" LIKE '%' || p_SearchValue || '%' OR L."FMSMFCC_CabinetColumnName" LIKE '%' || p_SearchValue || '%'
    OR N."FMSMTMD_DispatchMode" LIKE '%' || p_SearchValue || '%' OR E."IMFY_FinancialYear" LIKE '%' || p_SearchValue || '%');

    /* SUPPLIER REPORT */
    CREATE TEMP TABLE "FMS_SUPPLIER_REPORT" AS
    SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Subject",
        COALESCE(A."FMSCOR_LetterHeadNo",'') AS "FMSCOR_LetterHeadNo", A."FMSCOR_Date",
        B1."FMSMFC_FileCategoryName", E."IMFY_FinancialYear",
        ('Supplier Name :' || D."INVMS_SupplierName") AS "DETAILS", '' AS "ProjectName",
        A."FMSCOR_Description", A."FMSCOR_ToName",
        (SELECT "UserName" FROM "ApplicationUser" K WHERE A."FMSCOR_CreatedBy" = K."Id") AS "CREATEDBY",
        H."FMSMPFN_PhysicalFileName", J."FMSMFCBT_FileCabinetName", K."FMSMFCR_CabinetRowName",
        L."FMSMFCC_CabinetColumnName", N."FMSMTMD_DispatchMode",
        M."FMSCORMD_SentDate", M."FMSCORMD_ReferenceNo"
    FROM "FMS_Correspondence" A
    INNER JOIN "FMS_Correspondence_Supplier" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
    INNER JOIN "FMS_Master_FileCategory" B1 ON B1."FMSMFC_Id" = A."FMSMFC_Id"
    INNER JOIN "INV"."INV_Master_Supplier" D ON D."INVMS_Id" = B."INVMS_Id"
    INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
    LEFT JOIN "ISM_Master_Project" F ON F."ISMMPR_Id" = B."ISMMPR_Id"
    LEFT JOIN "FMS_Correspondence_Files" G ON G."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName" H ON H."FMSMPFN_Id" = G."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName_FileCabinet" I ON I."FMSMPFN_Id" = H."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_FileCabinet" J ON J."FMSMFCBT_Id" = I."FMSMFCBT_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Row" K ON K."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND K."FMSMFCR_Id" = I."FMSMFCR_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Column" L ON L."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND L."FMSMFCC_Id" = I."FMSMFCC_Id"
    LEFT JOIN "FMS_Correspondence_Mode" M ON M."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_DispatchMode" N ON N."FMSMDMD_Id" = M."FMSMDMD_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."FMSCOR_ActiveFlg" = 1 AND B."FMSCORSUP_ActiveFlg" = 1 AND A."FMSCOR_ClientSupplierFlg" = 'Supplier'
    AND (REPLACE(D."INVMS_SupplierName",' ','') LIKE '%' || p_SearchValue || '%' OR B1."FMSMFC_FileCategoryName" LIKE '%' || p_SearchValue || '%'
    OR A."FMSCOR_RefernceNo" LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_Subject",'') LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_Description",'') LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_ToName",'') LIKE '%' || p_SearchValue || '%'
    OR H."FMSMPFN_PhysicalFileName" LIKE '%' || p_SearchValue || '%' OR J."FMSMFCBT_FileCabinetName" LIKE '%' || p_SearchValue || '%'
    OR K."FMSMFCR_CabinetRowName" LIKE '%' || p_SearchValue || '%' OR L."FMSMFCC_CabinetColumnName" LIKE '%' || p_SearchValue || '%'
    OR N."FMSMTMD_DispatchMode" LIKE '%' || p_SearchValue || '%' OR E."IMFY_FinancialYear" LIKE '%' || p_SearchValue || '%');

    /* OTHERS REPORT */
    CREATE TEMP TABLE "FMS_OTHERS_REPORT" AS
    SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Subject",
        COALESCE(A."FMSCOR_LetterHeadNo",'') AS "FMSCOR_LetterHeadNo",
        A."FMSCOR_Date", B."FMSMFC_FileCategoryName", C."IMFY_FinancialYear",
        'Others' AS "DETAILS", '' AS "ProjectName",
        A."FMSCOR_Description", A."FMSCOR_ToName",
        (SELECT "UserName" FROM "ApplicationUser" K WHERE A."FMSCOR_CreatedBy" = K."Id") AS "CREATEDBY",
        H."FMSMPFN_PhysicalFileName", J."FMSMFCBT_FileCabinetName", K."FMSMFCR_CabinetRowName",
        L."FMSMFCC_CabinetColumnName", N."FMSMTMD_DispatchMode",
        M."FMSCORMD_SentDate", M."FMSCORMD_ReferenceNo"
    FROM "FMS_Correspondence" A
    INNER JOIN "FMS_Master_FileCategory" B ON A."FMSMFC_Id" = B."FMSMFC_Id"
    INNER JOIN "IVRM_Master_FinancialYear" C ON C."IMFY_Id" = A."IMFY_Id"
    LEFT JOIN "FMS_Correspondence_Files" G ON G."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName" H ON H."FMSMPFN_Id" = G."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName_FileCabinet" I ON I."FMSMPFN_Id" = H."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_FileCabinet" J ON J."FMSMFCBT_Id" = I."FMSMFCBT_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Row" K ON K."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND K."FMSMFCR_Id" = I."FMSMFCR_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Column" L ON L."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND L."FMSMFCC_Id" = I."FMSMFCC_Id"
    LEFT JOIN "FMS_Correspondence_Mode" M ON M."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_DispatchMode" N ON N."FMSMDMD_Id" = M."FMSMDMD_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."FMSCOR_ActiveFlg" = 1 AND A."FMSCOR_ClientSupplierFlg" = 'Others'
    AND (B."FMSMFC_FileCategoryName" LIKE '%' || p_SearchValue || '%' OR A."FMSCOR_RefernceNo" LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_Subject",'') LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_Description",'') LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_ToName",'') LIKE '%' || p_SearchValue || '%' OR H."FMSMPFN_PhysicalFileName" LIKE '%' || p_SearchValue || '%'
    OR J."FMSMFCBT_FileCabinetName" LIKE '%' || p_SearchValue || '%' OR K."FMSMFCR_CabinetRowName" LIKE '%' || p_SearchValue || '%'
    OR L."FMSMFCC_CabinetColumnName" LIKE '%' || p_SearchValue || '%' OR N."FMSMTMD_DispatchMode" LIKE '%' || p_SearchValue || '%'
    OR C."IMFY_FinancialYear" LIKE '%' || p_SearchValue || '%');

    /* INTERNAL REPORT */
    CREATE TEMP TABLE "FMS_INTERNAL_REPORT" AS
    SELECT DISTINCT A."FMSCOR_Id", A."FMSCOR_RefernceNo", A."FMSCOR_ClientSupplierFlg", A."FMSCOR_Subject",
        COALESCE(A."FMSCOR_LetterHeadNo",'') AS "FMSCOR_LetterHeadNo",
        A."FMSCOR_Date", B."FMSMFC_FileCategoryName", C."IMFY_FinancialYear",
        'Internal' AS "DETAILS", '' AS "ProjectName",
        A."FMSCOR_Description", A."FMSCOR_ToName",
        (SELECT "UserName" FROM "ApplicationUser" K WHERE A."FMSCOR_CreatedBy" = K."Id") AS "CREATEDBY",
        H."FMSMPFN_PhysicalFileName", J."FMSMFCBT_FileCabinetName", K."FMSMFCR_CabinetRowName",
        L."FMSMFCC_CabinetColumnName", N."FMSMTMD_DispatchMode",
        M."FMSCORMD_SentDate", M."FMSCORMD_ReferenceNo"
    FROM "FMS_Correspondence" A
    INNER JOIN "FMS_Master_FileCategory" B ON A."FMSMFC_Id" = B."FMSMFC_Id"
    INNER JOIN "IVRM_Master_FinancialYear" C ON C."IMFY_Id" = A."IMFY_Id"
    LEFT JOIN "FMS_Correspondence_Files" G ON G."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName" H ON H."FMSMPFN_Id" = G."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_PhysicalFileName_FileCabinet" I ON I."FMSMPFN_Id" = H."FMSMPFN_Id"
    LEFT JOIN "FMS_Master_FileCabinet" J ON J."FMSMFCBT_Id" = I."FMSMFCBT_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Row" K ON K."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND K."FMSMFCR_Id" = I."FMSMFCR_Id"
    LEFT JOIN "FMS_Master_FileCabinet_Column" L ON L."FMSMFCBT_Id" = J."FMSMFCBT_Id" AND L."FMSMFCC_Id" = I."FMSMFCC_Id"
    LEFT JOIN "FMS_Correspondence_Mode" M ON M."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "FMS_Master_DispatchMode" N ON N."FMSMDMD_Id" = M."FMSMDMD_Id"
    LEFT JOIN "FMS_Correspondence_Employee" D1 ON D1."FMSCOR_Id" = A."FMSCOR_Id"
    LEFT JOIN "HR_Master_Employee" F1 ON F1."HRME_Id" = D1."HRME_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."FMSCOR_ActiveFlg" = 1 AND A."FMSCOR_ClientSupplierFlg" = 'Internal'
    AND (B."FMSMFC_FileCategoryName" LIKE '%' || p_SearchValue || '%' OR A."FMSCOR_RefernceNo" LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_Subject",'') LIKE '%' || p_SearchValue || '%' OR COALESCE(A."FMSCOR_Description",'') LIKE '%' || p_SearchValue || '%'
    OR COALESCE(A."FMSCOR_ToName",'') LIKE '%' || p_SearchValue || '%' OR H."FMSMPFN_PhysicalFileName" LIKE '%' || p_SearchValue || '%'
    OR J."FMSMFCBT_FileCabinetName" LIKE '%' || p_SearchValue || '%' OR K."FMSMFCR_CabinetRowName" LIKE '%' || p_SearchValue || '%'
    OR L."FMSMFCC_CabinetColumnName" LIKE '%' || p_SearchValue || '%' OR N."FMSMTMD_DispatchMode" LIKE '%' || p_SearchValue || '%'
    OR C."IMFY_FinancialYear" LIKE '%' || p_SearchValue || '%'
    OR (F1."HRME_EmployeeFirstName" || ' ' || COALESCE(COALESCE(F1."HRME_EmployeeMiddleName",'') || ' ','') || COALESCE(COALESCE(F1."HRME_EmployeeLastName",'') || ' ','')) LIKE '%' || p_SearchValue || '%');

    IF p_ClientSupplierFlgflag = 'All' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM (
            SELECT * FROM "FMS_CLINET_REPORT"
            UNION ALL
            SELECT * FROM "FMS_SALES_REPORT"
            UNION ALL
            SELECT * FROM "FMS_SUPPLIER_REPORT"
            UNION ALL
            SELECT * FROM "FMS_OTHERS_REPORT"
            UNION ALL
            SELECT * FROM "FMS_INTERNAL_REPORT"
        ) AS D
        ORDER BY "FMSCOR_Date" DESC;
    ELSIF p_ClientSupplierFlgflag = 'Client' THEN
        RETURN QUERY
        SELECT * FROM "FMS_CLINET_REPORT"
        ORDER BY "FMSCOR_Date" DESC;
    ELSIF p_ClientSupplierFlgflag = 'Supplier' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "FMS_SUPPLIER_REPORT"
        ORDER BY "FMSCOR_Date" DESC;
    ELSIF p_ClientSupplierFlgflag = 'Sales Lead' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "FMS_SALES_REPORT"
        ORDER BY "FMSCOR_Date" DESC;
    ELSIF p_ClientSupplierFlgflag = 'Others' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "FMS_OTHERS_REPORT"
        ORDER BY "FMSCOR_Date" DESC;
    ELSIF p_ClientSupplierFlgflag = 'Internal' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "FMS_INTERNAL_REPORT"
        ORDER BY "FMSCOR_Date" DESC;
    END IF;

    DROP TABLE IF EXISTS "FMS_CLINET_REPORT";
    DROP TABLE IF EXISTS "FMS_SALES_REPORT";
    DROP TABLE IF EXISTS "FMS_SUPPLIER_REPORT";
    DROP TABLE IF EXISTS "FMS_OTHERS_REPORT";
    DROP TABLE IF EXISTS "FMS_INTERNAL_REPORT";

END;
$$;