CREATE OR REPLACE FUNCTION "dbo"."FA_FindFyr" (
    "p_Cdate" date,
    "p_MI_Id" bigint,
    OUT "p_IMFY_Id" bigint
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    "v_FYR_Id" bigint;
BEGIN

    SELECT "IMF"."IMFY_Id" INTO "v_FYR_Id"
    FROM "FA_Master_Company" "FMC"
    INNER JOIN "FA_Company_FY_Mapping" "FYM" ON "FMC"."FAMCOMP_Id" = "FYM"."FAMCOMP_Id"
    INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "IMF"."IMFY_Id" = "FYM"."IMFY_Id"
    WHERE "p_Cdate" BETWEEN CAST("IMF"."IMFY_FromDate" AS date) AND CAST("IMF"."IMFY_ToDate" AS date) 
    AND "FMC"."MI_Id" = "p_MI_Id";

    "p_IMFY_Id" := "v_FYR_Id";

    RETURN;

END;
$$;