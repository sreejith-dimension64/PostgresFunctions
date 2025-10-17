CREATE OR REPLACE FUNCTION "dbo"."Class_SectionListNoticeBord"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id TEXT
)
RETURNS TABLE(
    "asmS_Id" BIGINT,
    "asmC_SectionName" VARCHAR,
    "asmcL_ClassName" VARCHAR,
    "asmC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        s."ASMS_Id" as "asmS_Id",
        sec."ASMC_SectionName" as "asmC_SectionName",
        cls."ASMCL_ClassName" as "asmcL_ClassName",
        sec."ASMC_Order" as "asmC_Order"
    FROM "dbo"."Adm_School_M_Section" AS sec
    INNER JOIN "dbo"."Adm_School_Y_Student" AS s ON sec."ASMS_Id" = s."ASMS_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" AS a ON sec."MI_Id" = a."MI_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" AS cls ON s."ASMCL_Id" = cls."ASMCL_Id"
    WHERE sec."MI_Id" = p_MI_Id
        AND s."ASMAY_Id" = p_ASMAY_Id
        AND sec."ASMC_ActiveFlag" = 1
        AND s."ASMCL_Id" IN (
            SELECT CAST(TRIM(split_value) AS BIGINT)
            FROM unnest(string_to_array(p_ASMCL_Id, ',')) AS split_value
            WHERE TRIM(split_value) <> ''
        )
    ORDER BY sec."ASMC_SectionName";
END;
$$;