CREATE OR REPLACE FUNCTION "dbo"."edit_relieving_proc"(
    p_HRME_Id INT
)
RETURNS TABLE(
    "ismresgcL_Id" TEXT,
    "ismresgmcL_Id" BIGINT,
    "ismresgmcL_CheckListName" TEXT,
    "document_Path" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRMD_Id BIGINT;
BEGIN
    SELECT "HRMD_Id" INTO v_HRMD_Id 
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = p_HRME_Id;

    RETURN QUERY
    SELECT 
        "rc"."ISMRESGCL_Id"::TEXT AS "ismresgcL_Id",
        "rc"."ISMRESGMCL_Id" AS "ismresgmcL_Id",
        "rc"."ISMRESGCL_FileName" AS "ismresgmcL_CheckListName",
        "rc"."ISMRESGCL_FilePath" AS "document_Path"
    FROM "ISM_Resignation_Master_CheckLists" "mc"
    INNER JOIN "ISM_Resignation_ChecKLists" "rc" ON "mc"."ISMRESGMCL_Id" = "rc"."ISMRESGMCL_Id"
    WHERE "mc"."HRMD_Id" = v_HRMD_Id
    
    UNION ALL
    
    SELECT 
        '' AS "ismresgcL_Id",
        "ISMRESGMCL_Id" AS "ismresgmcL_Id",
        "ISMRESGMCL_CheckListName" AS "ismresgmcL_CheckListName",
        '' AS "document_Path"
    FROM "ISM_Resignation_Master_CheckLists"
    WHERE "ISMRESGMCL_Id" NOT IN (
        SELECT "ISMRESGMCL_Id" 
        FROM "ISM_Resignation_ChecKLists"
    ) 
    AND "HRMD_Id" = v_HRMD_Id;
END;
$$;