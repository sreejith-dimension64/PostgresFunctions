CREATE OR REPLACE FUNCTION "dbo"."Get_master_institution"()
RETURNS TABLE(
    "MI_Id" INTEGER,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "MI_Id", "MI_Name" 
    FROM "dbo"."Master_Institution" 
    WHERE "MI_ActiveFlag" = 1;
END;
$$;