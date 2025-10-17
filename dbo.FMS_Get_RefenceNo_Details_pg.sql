CREATE OR REPLACE FUNCTION "dbo"."FMS_Get_RefenceNo_Details"(
    "MI_Id" TEXT,
    "FMSCOR_ClientSupplierFlg" TEXT,
    "FMSCOR_Id" TEXT
)
RETURNS TABLE(
    "FMSCOR_Id" INTEGER,
    "FMSCOR_RefernceNo" VARCHAR,
    "FMSCOR_Date" VARCHAR,
    "Details" TEXT,
    "FMSCOR_Subject" TEXT,
    "FMSCOR_Description" TEXT,
    "FMSCOR_ToName" VARCHAR,
    "FMSCOR_LetterHeadNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "FMSCOR_ClientSupplierFlg" = 'Client' THEN
        RETURN QUERY
        SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", TO_CHAR(A."FMSCOR_Date", 'DD/MM/YYYY') AS "FMSCOR_Date",
            ('Client Name :' || C."ISMMCLT_ClientName" || ' : Project Name :' || COALESCE(F."ISMMPR_ProjectName", 'NA')) AS "Details",
            A."FMSCOR_Subject", A."FMSCOR_Description", A."FMSCOR_ToName", A."FMSCOR_LetterHeadNo"
        FROM "FMS_Correspondence" A
        INNER JOIN "FMS_Correspondence_Client" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "ISM_Master_Client" C ON C."ISMMCLT_Id" = B."ISMMCLT_Id"
        INNER JOIN "FMS_Master_FileCategory" D ON D."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        LEFT JOIN "ISM_Master_Project" F ON F."ISMMPR_Id" = B."ISMMPR_Id"
        WHERE A."FMSCOR_Id" = "FMSCOR_Id"::INTEGER AND B."FMSCOR_Id" = "FMSCOR_Id"::INTEGER;

    ELSIF "FMSCOR_ClientSupplierFlg" = 'Sales Lead' THEN
        RETURN QUERY
        SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", TO_CHAR(A."FMSCOR_Date", 'DD/MM/YYYY') AS "FMSCOR_Date",
            ('Sales Lead : ' || C."ISMSLE_LeadName") AS "Details",
            A."FMSCOR_Subject", A."FMSCOR_Description", A."FMSCOR_ToName", A."FMSCOR_LetterHeadNo"
        FROM "FMS_Correspondence" A
        INNER JOIN "FMS_Correspondence_SalesLead" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "ISM_Sales_Lead" C ON C."ISMSLE_Id" = B."ISMSLE_Id"
        INNER JOIN "FMS_Master_FileCategory" D ON D."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        WHERE A."FMSCOR_Id" = "FMSCOR_Id"::INTEGER AND B."FMSCOR_Id" = "FMSCOR_Id"::INTEGER;

    ELSIF "FMSCOR_ClientSupplierFlg" = 'Supplier' THEN
        RETURN QUERY
        SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", TO_CHAR(A."FMSCOR_Date", 'DD/MM/YYYY') AS "FMSCOR_Date",
            ('Supplier :' || C."INVMS_SupplierName" || ' : Project Name :' || COALESCE(F."ISMMPR_ProjectName", 'NA')) AS "Details",
            A."FMSCOR_Subject", A."FMSCOR_Description", A."FMSCOR_ToName", A."FMSCOR_LetterHeadNo"
        FROM "FMS_Correspondence" A
        INNER JOIN "FMS_Correspondence_Supplier" B ON A."FMSCOR_Id" = B."FMSCOR_Id"
        INNER JOIN "INV"."INV_Master_Supplier" C ON C."INVMS_Id" = B."INVMS_Id"
        INNER JOIN "FMS_Master_FileCategory" D ON D."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        LEFT JOIN "ISM_Master_Project" F ON F."ISMMPR_Id" = B."ISMMPR_Id"
        WHERE A."FMSCOR_Id" = "FMSCOR_Id"::INTEGER AND B."FMSCOR_Id" = "FMSCOR_Id"::INTEGER;

    ELSIF "FMSCOR_ClientSupplierFlg" = 'Others' OR "FMSCOR_ClientSupplierFlg" = 'Internal' THEN
        RETURN QUERY
        SELECT A."FMSCOR_Id", A."FMSCOR_RefernceNo", TO_CHAR(A."FMSCOR_Date", 'DD/MM/YYYY') AS "FMSCOR_Date",
            A."FMSCOR_ClientSupplierFlg" AS "Details",
            A."FMSCOR_Subject", A."FMSCOR_Description", A."FMSCOR_ToName", A."FMSCOR_LetterHeadNo"
        FROM "FMS_Correspondence" A
        INNER JOIN "FMS_Master_FileCategory" D ON D."FMSMFC_Id" = A."FMSMFC_Id"
        INNER JOIN "IVRM_Master_FinancialYear" E ON E."IMFY_Id" = A."IMFY_Id"
        WHERE A."FMSCOR_Id" = "FMSCOR_Id"::INTEGER;

    END IF;

    RETURN;

END;
$$;