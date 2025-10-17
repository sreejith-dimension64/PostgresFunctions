CREATE OR REPLACE FUNCTION "INV"."INV_Sales_Details"(
    p_MI_Id VARCHAR(50),
    p_optionflag VARCHAR(50)
)
RETURNS TABLE (
    "Id" BIGINT,
    "Name" VARCHAR,
    "Code" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec TEXT;
BEGIN
    IF (p_optionflag = 'Item') THEN
        v_sqlexec := '
        SELECT DISTINCT a."INVMI_Id",
                        a."INVMI_ItemName",
                        a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a,
             "INV"."INV_M_Sales" b,
             "INV"."INV_T_Sales" c
        WHERE a."INVMI_Id" = c."INVMI_Id" 
          AND b."INVMSL_Id" = c."INVMSL_Id" 
          AND a."MI_Id" IN(' || p_MI_Id || ')
        ORDER BY a."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE v_sqlexec;
        
    ELSIF (p_optionflag = 'Customer') THEN
        v_sqlexec := '
        SELECT DISTINCT a."INVMC_Id",
                        a."INVMC_CustomerName",
                        NULL::VARCHAR
        FROM "INV"."INV_Master_Customer" a,
             "INV"."INV_M_Sales" b,
             "INV"."INV_M_Sales_Customer" c
        WHERE a."INVMC_Id" = c."INVMC_Id" 
          AND b."INVMSL_Id" = c."INVMSL_Id" 
          AND a."MI_Id" IN(' || p_MI_Id || ')
        ORDER BY a."INVMC_CustomerName"';
        
        RETURN QUERY EXECUTE v_sqlexec;
        
    END IF;
    
    RETURN;
END;
$$;