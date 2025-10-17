CREATE OR REPLACE FUNCTION "dbo"."AlumniCountriesWiseDistrict"(@IVRMMS_Ids TEXT)
RETURNS TABLE(
    "IVRMMS_Id" INTEGER,
    "IVRMMC_Id" INTEGER,
    "IVRMMS_Name" VARCHAR,
    "IVRMMS_Code" VARCHAR,
    "IVRMMS_ActiveFlag" BOOLEAN,
    "IVRMMS_CreatedBy" INTEGER,
    "IVRMMS_UpdatedBy" INTEGER,
    "IVRMMS_CreatedDate" TIMESTAMP,
    "IVRMMS_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery TEXT;
BEGIN
    v_sqlquery := 'SELECT * FROM "IVRM_Master_District" WHERE "IVRMMS_Id" IN (' || @IVRMMS_Ids || ')';
    
    RAISE NOTICE '%', v_sqlquery;
    
    RETURN QUERY EXECUTE v_sqlquery;
END;
$$;