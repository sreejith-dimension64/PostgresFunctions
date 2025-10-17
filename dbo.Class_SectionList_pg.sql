CREATE OR REPLACE FUNCTION "dbo"."Class_SectionList"(
    p_MI_ID BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id TEXT
)
RETURNS TABLE(
    "ASMC_SectionName" VARCHAR,
    "ASMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        c."ASMC_SectionName",
        c."ASMS_Id"
    FROM
        "Adm_M_Student" AS a
        INNER JOIN "Adm_School_Y_Student" AS b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Section" AS c ON b."ASMS_Id" = c."ASMS_Id"
    WHERE 
        a."AMST_ActiveFlag" = 1
        AND a."MI_Id" = p_MI_ID
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND b."ASMCL_Id" IN (
            SELECT CAST(value AS BIGINT) AS SplitValue 
            FROM unnest(string_to_array(p_ASMCL_Id, ',')) AS value
            WHERE value ~ '^[0-9]+$'
        )
    ORDER BY
        c."ASMC_SectionName";
END;
$$;