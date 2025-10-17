CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_DOClist_proc"(
    "@MI_Id" bigint
)
RETURNS TABLE (
    "ISMCLTPRDOC_Id" bigint,
    "ISMMCLTPR_Id" bigint,
    "client_project_name" text,
    "ISMCLTPRMDOC_Name" text,
    "ISMCLTPRDOC_FileName" text,
    "ISMCLTPRDOC_FilePath" text,
    "ISMCLTPRDOC_ActiveFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRDOC_Id",
        a."ISMMCLTPR_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName") as "client_project_name",
        b."ISMCLTPRMDOC_Name",
        a."ISMCLTPRDOC_FileName",
        a."ISMCLTPRDOC_FilePath",
        a."ISMCLTPRDOC_ActiveFlag"
    FROM 
        "dbo"."ISM_Client_Project_Docs" a,
        "dbo"."ISM_Client_Project_Master_Docs" b,
        "dbo"."ISM_Master_Client_Project" c,
        "dbo"."ISM_Master_Client" d,
        "dbo"."ISM_Master_Project" e
    WHERE 
        a."ISMCLTPRMDOC_Id" = b."ISMCLTPRMDOC_Id" 
        AND a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id" 
        AND d."ISMMCLT_Id" = c."ISMMCLT_Id" 
        AND e."ISMMPR_Id" = c."ISMMPR_Id";
END;
$$;