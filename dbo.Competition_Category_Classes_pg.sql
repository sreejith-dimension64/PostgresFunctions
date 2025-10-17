CREATE OR REPLACE FUNCTION "dbo"."Competition_Category_Classes"(p_MT_Id BIGINT)
RETURNS TABLE (
    "VBSCMCCCL_Id" BIGINT,
    "VBSCMCC_Id" BIGINT,
    "ASMCL_ID" BIGINT,
    "MO_Name" VARCHAR,
    "MT_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "VBSCMCC_CompetitionCategory" VARCHAR,
    "VBSCMCC_ActiveFlag" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."VBSCMCCCL_Id",
        a."VBSCMCC_Id",
        a."ASMCL_ID",
        c."MO_Name",
        b."MT_Id",
        d."ASMCL_ClassName",
        b."VBSCMCC_CompetitionCategory",
        a."VBSCMCC_ActiveFlag"
    FROM "VBSC_Master_Competition_Category_Classes" a
    INNER JOIN "VBSC_Master_Competition_Category" b ON a."VBSCMCC_Id" = b."VBSCMCC_Id"
    INNER JOIN "Master_Organization" c ON c."MO_Id" = b."MT_Id"
    INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = a."ASMCL_ID";
END;
$$;