CREATE OR REPLACE FUNCTION "dbo"."CLIENT_INVOICEREPORT"(
    p_MI_Id TEXT,
    p_FromDate VARCHAR(30),
    p_ToDate VARCHAR(30)
)
RETURNS TABLE (
    "ISMMCLT_Id" INTEGER,
    "ISMMPR_Id" INTEGER,
    "ISMINC_Id" INTEGER,
    "ISMINC_WorkOrder" VARCHAR,
    "ISMINC_PrInviceNo" VARCHAR,
    "ISMINC_Date" TIMESTAMP,
    "ISMINC_TotalTaxAmount" NUMERIC,
    "ISMINC_TotalAmount" NUMERIC,
    "ISMINC_Remarks" TEXT,
    "ISMINC_ActiveFlag" BOOLEAN,
    "ISMMCLT_ClientName" VARCHAR,
    "ISMMCLT_Desc" TEXT,
    "ISMMCLT_Address" TEXT,
    "ISMMPR_ProjectName" VARCHAR,
    "ISMMPR_Desc" TEXT,
    "MI_Id" INTEGER,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
    v_Content TEXT;
BEGIN

    IF (p_FromDate != '' AND p_ToDate != '') THEN
        v_Content := ' AND A."ISMINC_Date" BETWEEN ''' || p_FromDate || ''' AND ''' || p_ToDate || ''' ';
    ELSE
        v_Content := '';
    END IF;

    v_SqlDynamic := '
    SELECT DISTINCT
        A."ISMMCLT_Id",
        A."ISMMPR_Id",
        A."ISMINC_Id",
        A."ISMINC_WorkOrder",
        A."ISMINC_PrInviceNo",
        A."ISMINC_Date",
        A."ISMINC_TotalTaxAmount",
        A."ISMINC_TotalAmount",
        A."ISMINC_Remarks",
        A."ISMINC_ActiveFlag",
        B."ISMMCLT_ClientName",
        B."ISMMCLT_Desc",
        B."ISMMCLT_Address",
        C."ISMMPR_ProjectName",
        C."ISMMPR_Desc",
        D."MI_Id",
        D."MI_Name"
    FROM "ISM_Invoice" AS A 
    INNER JOIN "ISM_Master_Client" AS B ON B."ISMMCLT_Id" = A."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" AS C ON C."ISMMPR_Id" = A."ISMMPR_Id"
    INNER JOIN "Master_Institution" AS D ON D."MI_Id" = A."MI_Id"
    WHERE A."ISMINC_ActiveFlag" = true AND A."MI_Id" IN (' || p_MI_Id || ') ' || v_Content;

    RETURN QUERY EXECUTE v_SqlDynamic;

END;
$$;