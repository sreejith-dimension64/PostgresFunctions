CREATE OR REPLACE FUNCTION "dbo"."ISm_client_project_DD_proc"(
    p_MI_Id bigint
)
RETURNS TABLE(
    client_project_name text,
    "ISMMCLTPR_Id" bigint
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        ("b"."ISMMCLT_ClientName" || ':' || "c"."ISMMPR_ProjectName")::text AS client_project_name, 
        "a"."ISMMCLTPR_Id"
    FROM "ISM_Master_Client_Project" "a"
    INNER JOIN "ISM_Master_Client" "b" ON "a"."ISMMCLT_Id" = "b"."ISMMCLT_Id"
    INNER JOIN "ISM_Master_Project" "c" ON "a"."ISMMPR_Id" = "c"."ISMMPR_Id"
    WHERE "b"."MI_Id" = "c"."MI_Id" 
        AND "c"."MI_Id" = p_MI_Id
    ORDER BY client_project_name;
END;
$$;