CREATE OR REPLACE FUNCTION "dbo"."doc_list_proc"(
    "@MI_Id" bigint,
    "@HRME_Id" bigint,
    "@qq" bigint
)
RETURNS TABLE(
    "employeename" text,
    "HRME_Id" bigint,
    "ismresgmcL_Id" bigint,
    "ismresgmcL_CheckListName" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@HRMDID" bigint;
    "@ISMRESGID1" bigint;
BEGIN

    IF("@qq" > 0) THEN
        
        SELECT "ISMRESG_Id" INTO "@ISMRESGID1" 
        FROM "ISM_Resignation" 
        WHERE "HRME_Id" = "@HRME_Id";

        RETURN QUERY
        SELECT 
            NULL::text AS "employeename",
            NULL::bigint AS "HRME_Id",
            mc."ISMRESGMCL_Id" AS "ismresgmcL_Id", 
            mc."ISMRESGMCL_CheckListName" AS "ismresgmcL_CheckListName"
        FROM "ISM_Resignation_Master_CheckLists" mc 
        WHERE mc."HRMD_Id" IN (
            SELECT "HRMD_Id" 
            FROM "HR_Master_Employee" 
            WHERE "HRME_Id" = "@HRME_Id"
        ) 
        AND mc."ISMRESGMCL_Id" NOT IN (
            SELECT "ISMRESGMCL_Id" 
            FROM "ISM_Resignation_ChecKLists" 
            WHERE "ISMRESG_Id" = "@ISMRESGID1"
        );

    ELSE
        
        RETURN QUERY
        SELECT DISTINCT 
            (COALESCE("HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME_EmployeeLastName", '')) AS "employeename",
            r."HRME_Id" AS "HRME_Id",
            NULL::bigint AS "ismresgmcL_Id",
            NULL::text AS "ismresgmcL_CheckListName"
        FROM "ISM_Resignation" r
        INNER JOIN "HR_Master_Employee" me ON r."MI_Id" = me."MI_Id" AND r."HRME_Id" = me."HRME_Id"
        INNER JOIN "ISM_Resignation_ChecKLists" rc ON r."ISMRESG_Id" = rc."ISMRESG_Id"
        WHERE r."MI_Id" = "@MI_Id" 
        AND r."ISMRESG_Print_Flg" = 1 
        AND r."ISMRESG_Status_Flg" = 1;

    END IF;

    RETURN;

END;
$$;