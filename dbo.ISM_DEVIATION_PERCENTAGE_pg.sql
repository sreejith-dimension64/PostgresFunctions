CREATE OR REPLACE FUNCTION "dbo"."ISM_DEVIATION_PERCENTAGE"(
    "@MI_Id" bigint
)
RETURNS TABLE (
    -- Add column definitions based on ISM_Master_Deviation table structure
    -- Example columns (adjust according to actual table schema):
    -- "column1" type,
    -- "column2" type,
    -- etc.
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" text;
BEGIN
    RETURN QUERY
    SELECT * FROM "ISM_Master_Deviation";
END;
$$;