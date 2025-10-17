CREATE OR REPLACE FUNCTION "INV"."INV_GRNSearch"(
    "@MI_Id" BIGINT,
    "@SearchColumn" VARCHAR(50),
    "@EnteredData" VARCHAR(50)
)
RETURNS TABLE(
    "INVMGRN_Id" BIGINT,
    "MI_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVMGRN_Date" TIMESTAMP,
    "INVMGRN_SupplierName" VARCHAR,
    "INVMGRN_InvoiceNo" VARCHAR,
    "INVMGRN_InvoiceDate" TIMESTAMP,
    "INVMGRN_ChallanNo" VARCHAR,
    "INVMGRN_ChallanDate" TIMESTAMP,
    "INVMGRN_ReceivedDate" TIMESTAMP,
    "INVMGRN_Remarks" TEXT,
    "INVMGRN_ActiveFlg" BOOLEAN,
    "INVMGRN_CreatedBy" BIGINT,
    "INVMGRN_CreatedDate" TIMESTAMP,
    "INVMGRN_UpdatedBy" BIGINT,
    "INVMGRN_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    "@EnteredData" := '%' || "@EnteredData" || '%';
    
    IF "@SearchColumn" = '0' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "INV"."INV_M_GRN" WHERE "MI_Id" = "@MI_Id"
        ORDER BY "INVMGRN_Id" ASC;
        RETURN;
    END IF;
    
    IF "@SearchColumn" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "INV"."INV_M_GRN" WHERE "MI_Id" = "@MI_Id" AND "INVMGRN_GRNNo" LIKE "@EnteredData"
        ORDER BY "INVMGRN_Id" ASC;
        RETURN;
    END IF;
    
    IF "@SearchColumn" = '2' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "INV"."INV_M_GRN" WHERE "MI_Id" = "@MI_Id" AND "INVMGRN_GRNNo" LIKE "@SearchColumn"
        ORDER BY "INVMGRN_Id" ASC;
        RETURN;
    END IF;
    
    IF "@SearchColumn" = '3' THEN
        RETURN QUERY
        SELECT DISTINCT * FROM "INV"."INV_M_GRN" WHERE "MI_Id" = "@MI_Id" AND "INVMGRN_GRNNo" LIKE "@SearchColumn"
        ORDER BY "INVMGRN_Id" ASC;
        RETURN;
    END IF;
    
END;
$$;