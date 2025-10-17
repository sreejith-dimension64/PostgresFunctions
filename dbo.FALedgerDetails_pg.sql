CREATE OR REPLACE FUNCTION "dbo"."FALedgerDetails"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "FAMLED_Id" bigint,
    "FAMLED_ActiveFlg" boolean,
    "FAMCOMP_Id" bigint,
    "IMFY_Id" bigint,
    "FAMGRP_Id" bigint,
    "FAUGRP_Id" bigint,
    "FAMLED_LedgerName" varchar,
    "FAMLED_LedgerAliasName" varchar,
    "FAMLED_LedgerCreatedDate" timestamp,
    "FAMCOMP_CompanyName" varchar,
    "FAUGRP_UserGroupName" varchar,
    "IMFY_FinancialYear" varchar,
    "FAMGRP_GroupName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "FL"."FAMLED_Id",
        "FL"."FAMLED_ActiveFlg",
        "FL"."FAMCOMP_Id",
        "FL"."IMFY_Id",
        "FL"."FAMGRP_Id",
        "FL"."FAUGRP_Id",
        "FL"."FAMLED_LedgerName",
        "FL"."FAMLED_LedgerAliasName",
        "FL"."FAMLED_LedgerCreatedDate",
        "FC"."FAMCOMP_CompanyName",
        "FU"."FAUGRP_UserGroupName",
        "IMF"."IMFY_FinancialYear",
        "FM"."FAMGRP_GroupName"
    FROM "FA_M_Ledger" "FL"
    INNER JOIN "FA_Master_Company" "FC" ON "FL"."FAMCOMP_Id" = "FC"."FAMCOMP_Id"
    INNER JOIN "FA_Master_Group" "FM" ON "FL"."FAMGRP_Id" = "FM"."FAMGRP_Id"
    INNER JOIN "FA_User_Group" "FU" ON "FL"."FAUGRP_Id" = "FU"."FAUGRP_Id"
    INNER JOIN "IVRM_Master_FinancialYear" "IMF" ON "FL"."IMFY_Id" = "IMF"."IMFY_Id"
    WHERE "FL"."MI_Id" = p_MI_Id AND "FC"."FAMCOMP_ActiveFlg" = true;
END;
$$;