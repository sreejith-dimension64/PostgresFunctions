CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentWise_Address_Details_clg"(
    "p_MI_Id" TEXT,
    "p_AMST_Id" TEXT
)
RETURNS TABLE(
    "PermanentAddress" TEXT,
    "ContactAddress" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        REPLACE(
            SUBSTRING(
                COALESCE(' ' || NULLIF("AMCST_PerStreet", ''), '')  ||   
                COALESCE(',' || NULLIF("AMCST_PerArea", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_PerCity", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_PerState", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_PerCountry" , ''), '') ||  
                COALESCE('-' || NULLIF(CAST("AMCST_PerPincode" AS TEXT), ''), '')
                FROM 2
            ), ',,', ','
        ) AS "PermanentAddress",
        
        REPLACE(
            SUBSTRING(
                COALESCE(' ' || NULLIF("AMCST_ConStreet", ''), '')  ||   
                COALESCE(',' || NULLIF("AMCST_ConArea", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_ConCity", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_ConState", ''), '') ||  
                COALESCE(',' || NULLIF("AMCST_ConCountry" , ''), '') ||  
                COALESCE('-' || NULLIF(CAST("AMCST_ConPincode" AS TEXT) , ''), '')
                FROM 2
            ), ',,', ','
        ) AS "ContactAddress"
    
    FROM (
        SELECT 
            "AMCST_PerStreet",
            "AMCST_PerArea",
            "AMCST_PerCity",
            "AMCST_PerAdd3",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE "IVRMMS_Id" = "AMS"."AMCST_PerState") AS "AMCST_PerState",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE "IVRMMC_Id" = "AMS"."IVRMMC_Id") AS "AMCST_PerCountry",
            "AMCST_PerPincode",
            "AMCST_ConStreet",
            "AMCST_ConArea",
            "AMCST_ConCity",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE "IVRMMS_Id" = "AMS"."AMCST_ConState") AS "AMCST_ConState",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE "IVRMMC_Id" = "AMS"."AMCST_ConCountryId") AS "AMCST_ConCountry",
            "AMCST_ConPincode"
        
        FROM "clg"."Adm_Master_College_Student" "AMS" 
        WHERE "AMS"."MI_Id" = "p_MI_Id" AND "AMCST_Id" = "p_AMST_Id"
    ) AS "New";
    
    RETURN;
END;
$$;