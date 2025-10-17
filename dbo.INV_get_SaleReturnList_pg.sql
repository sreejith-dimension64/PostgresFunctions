CREATE OR REPLACE FUNCTION "inv"."INV_get_SaleReturnList"(
    p_MI_Id bigint,
    p_Flag VARCHAR(50),
    p_User_Id bigint
)
RETURNS TABLE(
    "INVMSLRET_Id" bigint,
    "INVMSLRET_SalesReturnNo" VARCHAR,
    "INVMSLRET_SalesReturnDate" TIMESTAMP,
    "INVMSLRET_TotalReturnAmount" NUMERIC,
    "INVMSLRET_ActiveFlg" BOOLEAN,
    "INVMSLRET_ReturnRemarks" TEXT,
    "INVMSLRET_CreditNoteNo" VARCHAR,
    "INVMSLRET_EWayRefNo" VARCHAR,
    "INVMSLRET_CreditNoteDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (p_Flag = 'Staff' OR p_Flag = 'Student') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSLRET_Id", 
            a."INVMSLRET_SalesReturnNo", 
            a."INVMSLRET_SalesReturnDate", 
            a."INVMSLRET_TotalReturnAmount", 
            a."INVMSLRET_ActiveFlg", 
            a."INVMSLRET_ReturnRemarks",
            a."INVMSLRET_CreditNoteNo",
            a."INVMSLRET_EWayRefNo",
            a."INVMSLRET_CreditNoteDate"
        FROM "inv"."INV_M_Sales_Return" a
        INNER JOIN "inv"."INV_T_Sales_Return" b ON a."INVMSLRET_Id" = b."INVMSLRET_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."INVMSLRET_ActiveFlg" = true 
            AND a."INVMSLRET_CreatedBy" = p_User_Id 
        ORDER BY a."INVMSLRET_Id" DESC;
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSLRET_Id", 
            a."INVMSLRET_SalesReturnNo", 
            a."INVMSLRET_SalesReturnDate", 
            a."INVMSLRET_TotalReturnAmount", 
            a."INVMSLRET_ActiveFlg", 
            a."INVMSLRET_ReturnRemarks",
            a."INVMSLRET_CreditNoteNo",
            a."INVMSLRET_EWayRefNo",
            a."INVMSLRET_CreditNoteDate"
        FROM "inv"."INV_M_Sales_Return" a
        INNER JOIN "inv"."INV_T_Sales_Return" b ON a."INVMSLRET_Id" = b."INVMSLRET_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."INVMSLRET_ActiveFlg" = true 
        ORDER BY a."INVMSLRET_Id" DESC;
    END IF;
END;
$$;