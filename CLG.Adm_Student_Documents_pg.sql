CREATE OR REPLACE FUNCTION "CLG"."Adm_Student_Documents"(
    p_MI_Id bigint,
    p_AMCST_Id bigint
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
        INNER JOIN "CLG"."Adm_College_Student_Documents" mas ON docs."AMSMD_Id" = mas."ACSMD_Id"
        WHERE mas."AMCST_Id" = p_AMCST_Id
    );

END;
$$;