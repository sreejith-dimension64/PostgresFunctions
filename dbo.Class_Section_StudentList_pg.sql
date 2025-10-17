CREATE OR REPLACE FUNCTION "Class_Section_StudentList"(
    "@MI_ID" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@ASMCL_Id" TEXT,
    "@AMSC_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        a."AMST_Id",
        a."AMST_FirstName",
        a."AMST_MiddleName",
        a."AMST_LastName"
    FROM
        "Adm_M_Student" AS a 
        INNER JOIN "Adm_School_Y_Student" AS b ON a."AMST_Id" = b."AMST_Id"
    WHERE 
        a."AMST_ActiveFlag" = 1
        AND a."MI_Id" = "@MI_ID"
        AND b."ASMAY_Id" = "@ASMAY_Id"
        AND b."ASMCL_Id" IN (
            SELECT CAST(TRIM(unnest(string_to_array("@ASMCL_Id", ','))) AS BIGINT)
        )
        AND b."ASMS_Id" IN (
            SELECT CAST(TRIM(unnest(string_to_array("@AMSC_Id", ','))) AS BIGINT)
        )
    ORDER BY
        a."AMST_FirstName";
END;
$$;