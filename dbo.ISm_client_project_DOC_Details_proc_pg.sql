CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_DOC_Details_proc"(
    "@MI_Id" bigint,
    "@ISMCLTPRDOC_Id" bigint
)
RETURNS TABLE(
    "ISMCLTPRDOC_Id" bigint,
    "ISMMCLTPR_Id" bigint,
    "client_project_name" text,
    "ISMCLTPRMDOC_Name" text,
    "ISMCLTPRDOC_FileName" text,
    "ISMCLTPRDOC_FilePath" text,
    "ISMCLTPRDOC_ActiveFlag" boolean,
    "ISMCLTPRDOC_Date" timestamp,
    "ISMCLTPRMDOC_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRDOC_Id",
        a."ISMMCLTPR_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName")::text as "client_project_name",
        b."ISMCLTPRMDOC_Name",
        a."ISMCLTPRDOC_FileName",
        a."ISMCLTPRDOC_FilePath",
        a."ISMCLTPRDOC_ActiveFlag",
        a."ISMCLTPRDOC_Date",
        a."ISMCLTPRMDOC_Id"
    FROM "ISM_Client_Project_Docs" a
    INNER JOIN "ISM_Client_Project_Master_Docs" b ON a."ISMCLTPRMDOC_Id" = b."ISMCLTPRMDOC_Id"
    INNER JOIN "ISM_Master_Client_Project" c ON a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id"
    INNER JOIN "ISM_Master_Client" d ON d."ISMMCLT_Id" = c."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" e ON e."ISMMPR_Id" = c."ISMMPR_Id"
    WHERE a."ISMCLTPRDOC_Id" = "@ISMCLTPRDOC_Id";
END;
$$;