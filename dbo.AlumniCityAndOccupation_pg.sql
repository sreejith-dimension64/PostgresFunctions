CREATE OR REPLACE FUNCTION "dbo"."AlumniCityAndOccupation"(
    "MI_Id" bigint,
    "Type" varchar(30)
)
RETURNS TABLE(
    "almsT_ConCity" varchar,
    "designation" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "Type" = 'City' THEN
        RETURN QUERY
        SELECT DISTINCT "ALMST_ConCity" as "almsT_ConCity", NULL::varchar as "designation"
        FROM "ALU"."Alumni_Master_Student"
        WHERE "MI_Id" = "AlumniCityAndOccupation"."MI_Id" 
            AND ("ALMST_ConCity" IS NOT NULL OR "ALMST_ConCity" = '');
    ELSIF "Type" = 'Occupation' THEN
        RETURN QUERY
        SELECT NULL::varchar as "almsT_ConCity", "ALSPR_Designation" as "designation"
        FROM "ALU"."Alumni_Student_Profession"
        WHERE "ALSPR_ActiveFlg" = true 
            AND "MI_Id" = "AlumniCityAndOccupation"."MI_Id";
    END IF;
END;
$$;