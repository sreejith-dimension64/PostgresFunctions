CREATE OR REPLACE FUNCTION "IVRM_Interaction_Inboxnew1"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "roleflg" VARCHAR(50)
)
RETURNS TABLE(
    "ISTINT_ComposedById" BIGINT,
    "ISTINT_ToId" BIGINT,
    "ISTINT_ToFlg" VARCHAR,
    "ISMINT_Subject" VARCHAR,
    "ISTINT_Interaction" TEXT,
    "ISTINT_ComposedByFlg" VARCHAR,
    "ISMINT_GroupOrIndFlg" VARCHAR,
    "ISMINT_DateTime" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."ISTINT_ComposedById", 
        b."ISTINT_ToId", 
        b."ISTINT_ToFlg", 
        a."ISMINT_Subject", 
        b."ISTINT_Interaction", 
        b."ISTINT_ComposedByFlg",
        a."ISMINT_GroupOrIndFlg", 
        a."ISMINT_DateTime"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" 
    WHERE b."ISTINT_ComposedById" = "HRME_Id"
    
    UNION ALL
    
    SELECT 
        b."ISTINT_ComposedById", 
        b."ISTINT_ToId", 
        b."ISTINT_ToFlg", 
        a."ISMINT_Subject", 
        b."ISTINT_Interaction", 
        b."ISTINT_ComposedByFlg",
        a."ISMINT_GroupOrIndFlg", 
        a."ISMINT_DateTime"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" 
    WHERE b."ISTINT_ComposedById" != "HRME_Id" AND b."ISTINT_ToId" = "HRME_Id";
END;
$$;