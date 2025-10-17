CREATE OR REPLACE FUNCTION "dbo"."INV_GRNReturn_Approval"(
    "@MI_Id" bigint,
    "@User_Id" bigint
)
RETURNS TABLE(
    "INVMGRNRET_Id" bigint,
    "INVMGRNRET_GRNRETNo" text,
    "INVMGRNRET_ReturnDate" timestamp,
    "INVMGRNRET_TotalAmount" numeric,
    "INVMGRNRET_Remarks" text,
    "INVMGRNRETAPP_Id" bigint,
    "INVMGRN_Id" bigint,
    "INVMS_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "INV_M_GRN_Return"."INVMGRNRET_Id",
        "INV_M_GRN_Return"."INVMGRNRET_GRNRETNo",
        "INV_M_GRN_Return"."INVMGRNRET_ReturnDate",
        "INV_M_GRN_Return"."INVMGRNRET_TotalAmount",
        "INV_M_GRN_Return"."INVMGRNRET_Remarks",
        "INV_M_GRN_Return"."INVMGRNRETAPP_Id",
        "INV_M_GRN_Return"."INVMGRN_Id",
        "INV_M_GRN_Return"."INVMS_Id"
    FROM "INV"."INV_M_GRN_Return"
    WHERE "INV_M_GRN_Return"."MI_Id" = "@MI_Id" 
      AND "INV_M_GRN_Return"."INVMGRNRETAPP_Id" = 0;
END;
$$;