CREATE OR REPLACE FUNCTION "dbo"."getvmsbaseurl"(
    p_INST_CODE VARCHAR(50)
)
RETURNS TABLE (
    "IIVRSCURL_APIURL" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b."IIVRSCURL_APIURL"
    FROM "IVRM_IVRS_Configuration" a
    INNER JOIN "IVRM_Configuration_URL" b ON a."IIVRSC_Id" = b."IIVRSC_Id"
    WHERE a."IIVRSC_SchoolCode" = p_INST_CODE 
        AND b."IIVRSCURL_APIName" = 'Issuemanager' 
        AND a."IIVRSC_ActiveFlg" = 1;
END;
$$;