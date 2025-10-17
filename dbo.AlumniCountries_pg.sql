CREATE OR REPLACE FUNCTION "dbo"."AlumniCountries"(
    p_IVRMMC_Ids TEXT
)
RETURNS TABLE (
    "IVRMMC_Id" INTEGER,
    "IVRMMS_Id" INTEGER,
    "IVRMMS_Name" VARCHAR,
    "IVRMMS_Code" VARCHAR,
    "IVRMMS_ActiveFlag" BOOLEAN,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery TEXT;
BEGIN
    v_sqlquery := 'SELECT * FROM "IVRM_Master_State" WHERE "IVRMMC_Id" IN (' || p_IVRMMC_Ids || ')';
    
    RETURN QUERY EXECUTE v_sqlquery;
END;
$$;