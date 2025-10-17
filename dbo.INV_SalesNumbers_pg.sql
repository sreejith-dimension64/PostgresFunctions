CREATE OR REPLACE FUNCTION "dbo"."INV_SalesNumbers" (p_MI_Id bigint)
RETURNS TABLE (
    "INVMSL_Id" bigint,
    "INVMSL_SalesNo" varchar
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "INVMSL_Id", "INVMSL_SalesNo" 
    FROM "INV"."INV_M_Sales"
    WHERE "MI_Id" = p_MI_Id;
END;
$$;