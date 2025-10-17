CREATE OR REPLACE FUNCTION "dbo"."INV_GRNNumbers" (@MI_Id bigint)
RETURNS TABLE (
    "INVMGRN_Id" bigint,
    "INVMGRN_GRNNo" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "INVMGRN_Id", "INVMGRN_GRNNo" 
    FROM "INV"."INV_M_GRN" 
    WHERE "MI_Id" = @MI_Id;
END;
$$;