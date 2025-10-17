CREATE OR REPLACE FUNCTION "Interaction_message_readcount"(
    "p_ISMINT_Id" BIGINT,
    "p_ISTINT_ToId" BIGINT
)
RETURNS TABLE(
    "ISMINT_Id" BIGINT,
    "ISTINT_ReadFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_readcount" BIGINT;
    "v_totalcount" BIGINT;
    "v_ISTINT_ReadFlg" BOOLEAN;
BEGIN

    SELECT COUNT(*)
    INTO "v_readcount"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    WHERE a."ISMINT_Id" = "p_ISMINT_Id" AND b."ISTINT_ToId" = "p_ISTINT_ToId" AND COALESCE(b."ISTINT_ReadFlg", false) = true;

    SELECT COUNT(*)
    INTO "v_totalcount"
    FROM "IVRM_School_Master_Interactions" a
    INNER JOIN "IVRM_School_Transaction_Interactions" b ON a."ISMINT_Id" = b."ISMINT_Id" AND a."ISMINT_ActiveFlag" = true
    WHERE a."ISMINT_Id" = "p_ISMINT_Id" AND b."ISTINT_ToId" = "p_ISTINT_ToId";

    IF ("v_totalcount" = "v_readcount") THEN
        "v_ISTINT_ReadFlg" := true;
    ELSE
        "v_ISTINT_ReadFlg" := false;
    END IF;

    RETURN QUERY
    SELECT "p_ISMINT_Id" AS "ISMINT_Id", "v_ISTINT_ReadFlg" AS "ISTINT_ReadFlg";

END;
$$;