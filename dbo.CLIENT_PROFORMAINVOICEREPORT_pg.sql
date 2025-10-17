CREATE OR REPLACE FUNCTION "dbo"."CLIENT_PROFORMAINVOICEREPORT"(
    "MI_Id" TEXT,
    "FromDate" VARCHAR(30),
    "ToDate" VARCHAR(30)
)
RETURNS TABLE(
    "ISMPRINC_Id" INTEGER,
    "ISMMCLT_Id" INTEGER,
    "ISMMPR_Id" INTEGER,
    "ISMPRINC_WorkOrder" TEXT,
    "ISMPRINC_PrInviceNo" TEXT,
    "ISMPRINC_Date" TIMESTAMP,
    "ISMPRINC_TotalTaxAmount" NUMERIC,
    "ISMPRINC_TotalAmount" NUMERIC,
    "ISMPRINC_Remarks" TEXT,
    "ISMPRINC_ActiveFlag" BOOLEAN,
    "ISMMCLT_ClientName" TEXT,
    "ISMMCLT_Desc" TEXT,
    "ISMMCLT_Address" TEXT,
    "ISMMPR_ProjectName" TEXT,
    "ISMMPR_Desc" TEXT,
    "ISMPRINC_AdvPer" NUMERIC,
    "ISMPRINC_AdvanceAmount" NUMERIC,
    "MI_Id" INTEGER,
    "MI_Name" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
    "Content" TEXT;
BEGIN

    IF ("FromDate" != '' AND "ToDate" != '') THEN
        "Content" := ' and A."ISMPRINC_Date" between ''' || "FromDate" || ''' and ''' || "ToDate" || ''' ';
    ELSE
        "Content" := '';
    END IF;

    "SqlDynamic" := '
    SELECT A."ISMPRINC_Id",
    A."ISMMCLT_Id",
    A."ISMMPR_Id",
    A."ISMPRINC_WorkOrder",
    A."ISMPRINC_PrInviceNo",
    A."ISMPRINC_Date",
    A."ISMPRINC_TotalTaxAmount",
    A."ISMPRINC_TotalAmount",
    A."ISMPRINC_Remarks",
    A."ISMPRINC_ActiveFlag",
    B."ISMMCLT_ClientName",
    B."ISMMCLT_Desc",
    B."ISMMCLT_Address",
    C."ISMMPR_ProjectName",
    C."ISMMPR_Desc",
    A."ISMPRINC_AdvPer",
    A."ISMPRINC_AdvanceAmount",
    D."MI_Id",
    D."MI_Name" 
    FROM "ISM_Proforma_Invoice" AS A 
    INNER JOIN "ISM_Master_Client" AS B ON B."ISMMCLT_Id" = A."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" AS C ON C."ISMMPR_Id" = A."ISMMPR_Id"
    INNER JOIN "Master_Institution" AS D ON D."MI_Id" = A."MI_Id"
    WHERE A."ISMPRINC_ActiveFlag" = true AND A."MI_Id" IN (' || "MI_Id" || ') ' || "Content";

    RETURN QUERY EXECUTE "SqlDynamic";

END;
$$;