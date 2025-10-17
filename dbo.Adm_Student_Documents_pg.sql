CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Documents"(
    p_MI_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "AMSMD_DocumentName" VARCHAR,
    "AMSMD_Id" bigint,
    "AMSMD_FLAG" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT smd."AMSMD_DocumentName", smd."AMSMD_Id", smd."AMSMD_FLAG"
    FROM "Adm_m_School_Master_Documents" smd
    WHERE smd."MI_Id" = p_MI_Id
    AND smd."AMSMD_Id" NOT IN (
        SELECT docs."AMSMD_Id" 
        FROM "Adm_m_School_Master_Documents" docs
        INNER JOIN "Adm_Master_Student_Documents" mas ON docs."AMSMD_Id" = mas."AMSMD_Id"
        WHERE mas."AMST_Id" = p_AMST_Id
    );
END;
$$;