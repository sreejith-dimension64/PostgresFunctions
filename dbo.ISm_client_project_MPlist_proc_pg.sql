CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_MPlist_proc"(@MI_Id bigint)
RETURNS TABLE (
    "ISMCLTPRMP_Id" bigint,
    "client_project_name" text,
    "ISMCLTPRMP_ResourceName" text,
    "ISMCLTPRMP_Qty" numeric,
    "ISMCLTPRMP_Remarks" text,
    "ISMCLTPRMP_ActiveFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRMP_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName") as "client_project_name",
        a."ISMCLTPRMP_ResourceName",
        a."ISMCLTPRMP_Qty",
        a."ISMCLTPRMP_Remarks",
        a."ISMCLTPRMP_ActiveFlag"
    FROM 
        "ISM_Client_Project_ManPower" a,
        "ISM_Master_Client_Project" c,
        "ISM_Master_Client" d,
        "ISM_Master_Project" e
    WHERE 
        a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id" 
        AND d."ISMMCLT_Id" = c."ISMMCLT_Id" 
        AND e."ISMMPR_Id" = c."ISMMPR_Id";
END;
$$;