CREATE OR REPLACE FUNCTION "INV"."INV_MonthEndReport"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_month TEXT,
    p_year TEXT
)
RETURNS TABLE(
    "grnCount" TEXT,
    "salesCount" TEXT,
    "itemCount" TEXT,
    "sms" TEXT,
    "email" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_grncount TEXT;
    v_salescount TEXT;
    v_itemcount TEXT;
    v_smscount TEXT;
    v_emailcount TEXT;
BEGIN

    -- Total GRN
    SELECT COUNT(*)::TEXT INTO v_grncount 
    FROM "INV"."INV_T_GRN" 
    WHERE "INVMGRN_Id" IN (
        SELECT "INVMGRN_Id" 
        FROM "INV"."INV_M_GRN" 
        WHERE "MI_Id" = p_MI_Id
    )
    AND EXTRACT(MONTH FROM "CreatedDate") = p_month::INTEGER
    AND EXTRACT(YEAR FROM "CreatedDate") = p_year::INTEGER
    AND "INVTGRN_ActiveFlg" = 1;

    -- Total Sales
    SELECT COUNT(*)::TEXT INTO v_salescount 
    FROM "INV"."INV_T_Sales" 
    WHERE "INVMSL_Id" IN (
        SELECT "INVMSL_Id" 
        FROM "INV"."INV_M_Sales" 
        WHERE "MI_Id" = p_MI_Id
    )
    AND EXTRACT(MONTH FROM "CreatedDate") = p_month::INTEGER
    AND EXTRACT(YEAR FROM "CreatedDate") = p_year::INTEGER
    AND "INVTSL_ActiveFlg" = 1;

    -- Total Item
    SELECT COUNT(*)::TEXT INTO v_itemcount 
    FROM "INV"."INV_Master_Item" 
    WHERE "MI_Id" = p_MI_Id
    AND EXTRACT(MONTH FROM "CreatedDate") = p_month::INTEGER
    AND EXTRACT(YEAR FROM "CreatedDate") = p_year::INTEGER
    AND "INVMI_ActiveFlg" = 1;

    -- Total SMS COUNT
    SELECT COUNT(*)::TEXT INTO v_smscount 
    FROM "IVRM_sms_sentBox" 
    WHERE "MI_Id" = p_MI_Id
    AND EXTRACT(MONTH FROM "CreatedDate") = p_month::INTEGER
    AND EXTRACT(YEAR FROM "CreatedDate") = p_year::INTEGER
    AND "Module_Name" = 'Inventory';

    -- Total EMAIL COUNT
    SELECT COUNT(*)::TEXT INTO v_emailcount 
    FROM "IVRM_Email_sentBox" 
    WHERE "MI_Id" = p_MI_Id
    AND EXTRACT(MONTH FROM "Datetime") = p_month::INTEGER
    AND EXTRACT(YEAR FROM "Datetime") = p_year::INTEGER
    AND "Module_Name" = 'Inventory';

    -- Return result set
    RETURN QUERY 
    SELECT v_grncount, v_salescount, v_itemcount, v_smscount, v_emailcount;

END;
$$;