CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_MP_Details_proc"(
    p_MI_Id bigint,
    p_ISMCLTPRMP_Id bigint
)
RETURNS TABLE (
    "ISMCLTPRMP_Id" bigint,
    "client_project_name" text,
    "ISMCLTPRMP_ResourceName" text,
    "ISMCLTPRMP_Qty" numeric,
    "ISMCLTPRMP_Remarks" text,
    "ISMCLTPRMP_ActiveFlag" boolean,
    "ISMMCLTPR_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRMP_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName") as client_project_name,
        a."ISMCLTPRMP_ResourceName",
        a."ISMCLTPRMP_Qty",
        a."ISMCLTPRMP_Remarks",
        a."ISMCLTPRMP_ActiveFlag",
        a."ISMMCLTPR_Id"
    FROM "ISM_Client_Project_ManPower" a
    INNER JOIN "ISM_Master_Client_Project" c ON a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id"
    INNER JOIN "ISM_Master_Client" d ON d."ISMMCLT_Id" = c."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" e ON e."ISMMPR_Id" = c."ISMMPR_Id"
    WHERE a."ISMCLTPRMP_Id" = p_ISMCLTPRMP_Id;
END;
$$;