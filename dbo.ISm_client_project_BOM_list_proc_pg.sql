CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_BOM_list_proc"(
    "@MI_Id" bigint
)
RETURNS TABLE(
    "ISMCLTPRBOM_Id" bigint,
    "client_project_name" text,
    "ISMCLTC_Name" text,
    "ISMCLTPRBOM_Qty" numeric,
    "ISMCLTPRBOM_Remarks" text,
    "ISMCLTPRBOM_ActiveFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRBOM_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName") as "client_project_name",
        b."ISMCLTC_Name",
        a."ISMCLTPRBOM_Qty",
        a."ISMCLTPRBOM_Remarks",
        a."ISMCLTPRBOM_ActiveFlag"
    FROM 
        "ISM_Client_Project_BOM" a,
        "ISM_Client_Master_Components" b,
        "ISM_Master_Client_Project" c,
        "ISM_Master_Client" d,
        "ISM_Master_Project" e
    WHERE 
        a."ISMCLTC_Id" = b."ISMCLTC_Id" 
        AND a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id" 
        AND d."ISMMCLT_Id" = c."ISMMCLT_Id" 
        AND e."ISMMPR_Id" = c."ISMMPR_Id";
END;
$$;