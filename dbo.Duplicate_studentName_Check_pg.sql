CREATE OR REPLACE FUNCTION "dbo"."Duplicate_studentName_Check"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@studentname" varchar(100)
)
RETURNS TABLE (
    "amst_firstname" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * 
    FROM (
        SELECT REPLACE(
            (CASE 
                WHEN "a"."AMST_FirstName" IS NULL OR "a"."AMST_FirstName" = '' THEN '' 
                ELSE "a"."AMST_FirstName" 
            END || 
            CASE 
                WHEN "a"."AMST_MiddleName" IS NULL OR "a"."AMST_MiddleName" = '' OR "a"."AMST_MiddleName" = '0' THEN '' 
                ELSE ' ' || "a"."AMST_MiddleName" 
            END || 
            CASE 
                WHEN "a"."AMST_LastName" IS NULL OR "a"."AMST_LastName" = '' OR "a"."AMST_LastName" = '0' THEN '' 
                ELSE ' ' || "a"."AMST_LastName" 
            END),
            ' ', ''
        ) AS "amst_firstname"
        FROM "Adm_M_Student" "a"
        INNER JOIN "Adm_School_Y_Student" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
        WHERE "a"."MI_Id" = "@MI_Id" 
            AND "b"."ASMAY_Id" = "@ASMAY_Id" 
            AND "b"."ASMCL_Id" = "@ASMCL_Id" 
            AND "b"."ASMS_Id" = "@ASMS_Id"
    ) AS "new"
    WHERE TRIM("new"."amst_firstname") = "@studentname";
END;
$$;