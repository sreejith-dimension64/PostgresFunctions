CREATE OR REPLACE FUNCTION "dbo"."AlumniProfile"(
    @MI_Id bigint,
    @ALMST_Id bigint,
    @Type varchar(50)
)
RETURNS TABLE (
    alumniname text,
    "ASMAY_Year" varchar,
    "ALMST_MobileNo" varchar,
    "ALMST_emailId" varchar,
    "ALMST_StudentPhoto" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF @Type = 'Profile' THEN
        RETURN QUERY
        SELECT 
            (COALESCE("a"."ALMST_FirstName", '') || COALESCE("a"."ALMST_MiddleName", '') || COALESCE("a"."ALMST_LastName", '')) as alumniname,
            "b"."ASMAY_Year",
            "a"."ALMST_MobileNo",
            "a"."ALMST_emailId",
            "a"."ALMST_StudentPhoto"
        FROM "alu"."Alumni_Master_Student" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "b" ON "a"."ASMAY_Id_Left" = "b"."ASMAY_Id";
    END IF;
END;
$$;