CREATE OR REPLACE FUNCTION "dbo"."ISM_CLIENTPROJECTPAYMENT_REPORT"(
    "p_MI_Id" bigint,
    "p_ISMMPR_Id" text
)
RETURNS TABLE(
    "ISMMPR_ProjectName" varchar,
    "ISMCLTPRP_Year" varchar,
    "ISMCLTPRP_InstallmentName" varchar,
    "ISMCLTPRP_InstallmentAmt" numeric,
    "ISMCLTPRP_PaymentDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqldynamic" text;
BEGIN
    "v_sqldynamic" := 'SELECT 
        a."ISMMPR_ProjectName",
        d."ASMAY_Year" as "ISMCLTPRP_Year",
        b."ISMCLTPRP_InstallmentName",
        b."ISMCLTPRP_InstallmentAmt",
        b."ISMCLTPRP_PaymentDate" 
    FROM "dbo"."ISM_Master_Client_Project" c 
    INNER JOIN "dbo"."ISM_Master_Project" a ON a."ISMMPR_Id" = c."ISMMPR_Id"
    INNER JOIN "dbo"."ISM_Client_Project_Payment" b ON b."ISMMCLTPR_Id" = c."ISMMCLTPR_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = b."ISMCLTPRP_Year"
    WHERE a."ISMMPR_Id" IN (' || "p_ISMMPR_Id" || ') 
    AND a."MI_Id" = ' || "p_MI_Id"::text;

    RETURN QUERY EXECUTE "v_sqldynamic";
END;
$$;