CREATE OR REPLACE FUNCTION "dbo"."FindLastValues"()
RETURNS TABLE (
    "ALMST_MembershipId" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "alu"."Alumni_Master_Student"."ALMST_MembershipId" 
    FROM "alu"."Alumni_Master_Student" 
    WHERE "alu"."Alumni_Master_Student"."ALMST_MembershipId" = (
        SELECT MAX("alu"."Alumni_Master_Student"."ALMST_MembershipId") 
        FROM "alu"."Alumni_Master_Student"
    );
END;
$$;