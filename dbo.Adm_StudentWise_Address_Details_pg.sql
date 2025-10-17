CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentWise_Address_Details"(
    p_MI_Id bigint,
    p_AMST_Id bigint
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
                COALESCE(',' || NULLIF("AMST_PerStreet", ''), '')  || 
                COALESCE(',' || NULLIF("AMST_PerArea", ''), '') ||
                COALESCE(',' || NULLIF("AMST_PerCity", ''), '') ||
                COALESCE(',' || NULLIF("AMST_PerState", ''), '') ||
                COALESCE(',' || NULLIF("AMST_PerCountry", ''), '') ||
                COALESCE('-' || NULLIF(CAST("AMST_PerPincode" AS TEXT), ''), '')
            FROM 2),
        ',,', ',') AS "PermanentAddress",
        
        REPLACE(
            SUBSTRING(
                COALESCE(',' || NULLIF("AMST_ConStreet", ''), '')  || 
                COALESCE(',' || NULLIF("AMST_ConArea", ''), '') ||
                COALESCE(',' || NULLIF("AMST_ConCity", ''), '') ||
                COALESCE(',' || NULLIF("AMST_ConState", ''), '') ||
                COALESCE(',' || NULLIF("AMST_ConCountry", ''), '') ||
                COALESCE('-' || NULLIF(CAST("AMST_ConPincode" AS TEXT), ''), '')
            FROM 2),
        ',,', ',') AS "ContactAddress"
    FROM (
        SELECT 
            "AMST_PerStreet",
            "AMST_PerArea",
            "AMST_PerCity",
            "AMST_PerAdd3",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE "IVRMMS_Id" = "AMST_PerState") AS "AMST_PerState",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE "IVRMMC_Id" = "AMST_PerCountry") AS "AMST_PerCountry",
            "AMST_PerPincode",
            "AMST_ConStreet",
            "AMST_ConArea",
            "AMST_ConCity",
            (SELECT "IVRMMS_Name" FROM "IVRM_Master_State" WHERE "IVRMMS_Id" = "AMST_ConState") AS "AMST_ConState",
            (SELECT "IVRMMC_CountryName" FROM "IVRM_Master_Country" WHERE "IVRMMC_Id" = "AMST_ConCountry") AS "AMST_ConCountry",
            "AMST_ConPincode"
        FROM "Adm_M_Student" "AMS" 
        WHERE "AMS"."MI_Id" = p_MI_Id AND "AMST_Id" = p_AMST_Id
    ) AS "New";
END;
$$;