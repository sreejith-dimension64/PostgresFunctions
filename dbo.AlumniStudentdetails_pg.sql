CREATE OR REPLACE FUNCTION "dbo"."AlumniStudentdetails"(
    p_MI_Id bigint,
    p_ALMST_Id bigint
)
RETURNS TABLE(
    "ALMST_FirstName" text,
    "ALMST_PerStreet" text,
    "ALMST_PerArea" text,
    "ALMST_PerAdd3" text,
    "ALMST_PerCity" text,
    "ALMST_PerPincode" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE("ALMST_FirstName",'') || COALESCE("ALMST_MiddleName",'') || COALESCE("ALMST_LastName", ''))::text AS "ALMST_FirstName",
        "ALMST_PerStreet"::text,
        "ALMST_PerArea"::text,
        "ALMST_PerAdd3"::text,
        "ALMST_PerCity"::text,
        "ALMST_PerPincode"::text
    FROM "alu"."Alumni_Master_Student"
    WHERE "MI_Id" = p_MI_Id 
        AND "ALMST_Id" = p_ALMST_Id;
END;
$$;