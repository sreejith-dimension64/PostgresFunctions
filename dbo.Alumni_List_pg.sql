CREATE OR REPLACE FUNCTION "Alumni_List"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentName" text,
    "amsT_emailId" character varying,
    "amsT_MobileNo" character varying
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "AMST_Id",
        (COALESCE("ALMST_FirstName", '') || ' ' || COALESCE("ALMST_MiddleName", '') || ' ' || COALESCE("ALMST_LastName", '')) AS "studentName",
        "ALMST_emailId" AS "amsT_emailId",
        "ALMST_MobileNo" AS "amsT_MobileNo"
    FROM "alu"."Alumni_Master_Student"
    WHERE "ASMAY_Id_Left" = "@ASMAY_Id" 
        AND "ASMCL_Id_Left" = "@ASMCL_Id";
END;
$$;