CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_BOM_Details_proc"(
    p_MI_Id bigint,
    p_ISMCLTPRBOM_Id bigint
)
RETURNS TABLE(
    "ISMCLTPRBOM_Id" bigint,
    "client_project_name" text,
    "ISMCLTC_Name" varchar,
    "ISMCLTC_Id" bigint,
    "ISMCLTPRBOM_Qty" numeric,
    "ISMCLTPRBOM_Remarks" text,
    "ISMCLTPRBOM_ActiveFlag" boolean,
    "ISMMCLTPR_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."ISMCLTPRBOM_Id",
        (d."ISMMCLT_ClientName" || ' : ' || e."ISMMPR_ProjectName")::text AS "client_project_name",
        b."ISMCLTC_Name",
        b."ISMCLTC_Id",
        a."ISMCLTPRBOM_Qty",
        a."ISMCLTPRBOM_Remarks",
        a."ISMCLTPRBOM_ActiveFlag",
        a."ISMMCLTPR_Id"
    FROM "ISM_Client_Project_BOM" a
    INNER JOIN "ISM_Client_Master_Components" b ON a."ISMCLTC_Id" = b."ISMCLTC_Id"
    INNER JOIN "ISM_Master_Client_Project" c ON a."ISMMCLTPR_Id" = c."ISMMCLTPR_Id"
    INNER JOIN "ISM_Master_Client" d ON d."ISMMCLT_Id" = c."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" e ON e."ISMMPR_Id" = c."ISMMPR_Id"
    WHERE b."MI_Id" = p_MI_Id 
    AND a."ISMCLTPRBOM_Id" = p_ISMCLTPRBOM_Id;
END;
$$;