CREATE OR REPLACE FUNCTION "dbo"."INV_GroupwiseAssets_Details"(
    "MI_Id" TEXT,
    "FYear" VARCHAR(20)
)
RETURNS TABLE(
    "MGroupName" VARCHAR,
    "UserGroupName" VARCHAR,
    "W.D.V As On Opening Date" NUMERIC,
    "INVMI_ItemMoreThan180" NUMERIC,
    "INVMI_ItemLessThan180" NUMERIC,
    "INVMI_DeletedItemAmount" NUMERIC,
    "INVDEP_ClosingValue" NUMERIC,
    "Total As On Current Date" NUMERIC,
    "W.D.V As On Closing Date" NUMERIC,
    "Rate" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
    'SELECT (SELECT DISTINCT "MG"."INVMG_GroupName" 
        FROM "INV"."INV_Master_Group" "MG" 
        WHERE "MG"."MI_Id" = ANY(STRING_TO_ARRAY($1, '','')::INT[]) 
        AND "MG"."INVMG_ActiveFlg" = 1 
        AND "MG"."INVMG_MGUGIGFlg" = ''MG'' 
        AND "INVMG_ParentId" = "MG"."INVMG_ParentId"
        LIMIT 1) AS "MGroupName",
    "INVMG_GroupName" AS "UserGroupName",
    SUM("INVDEP_OpeningValue") AS "W.D.V As On Opening Date",
    SUM("INVMI_ItemMoreThan180") AS "INVMI_ItemMoreThan180",
    SUM("INVMI_ItemLessThan180") AS "INVMI_ItemLessThan180",
    SUM("INVMI_DeletedItemAmount") AS "INVMI_DeletedItemAmount",
    SUM("INVDEP_ClosingValue") AS "INVDEP_ClosingValue",
    (SUM("INVDEP_ClosingValue") * (SUM("INVDEP_DepreciationPer") / COUNT("MI"."INVMI_Id")) / 100) AS "Total As On Current Date",
    SUM("INVDEP_ClosingValue") - (SUM("INVDEP_ClosingValue") * (SUM("INVDEP_DepreciationPer") / COUNT("MI"."INVMI_Id")) / 100) AS "W.D.V As On Closing Date",
    (SUM("INVDEP_DepreciationPer") / COUNT("MI"."INVMI_Id")) AS "Rate"
    FROM "INV"."INV_Master_Item" "MI"
    INNER JOIN "INV"."INV_Depreciation" "ID" ON "ID"."INVMI_Id" = "MI"."INVMI_Id" AND "ID"."MI_Id" = "MI"."MI_Id"
    INNER JOIN "IVRM_Master_FinancialYear" "MFY" ON "MFY"."IMFY_Id" = "ID"."IMFY_Id"
    INNER JOIN "INV"."INV_OpeningBalance" "IOB" ON "IOB"."INVMI_Id" = "ID"."INVMI_Id" AND "ID"."MI_Id" = "IOB"."MI_Id"
    INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id" = "MI"."INVMG_Id" AND "MG"."MI_Id" = "IOB"."MI_Id"
    WHERE "MG"."INVMG_MGUGIGFlg" = ''UG'' 
    AND "MFY"."IMFY_FinancialYear" = $2
    AND "ID"."MI_Id" = ANY(STRING_TO_ARRAY($1, '','')::INT[])
    AND "MI"."INVMI_ActiveFlg" = 1 
    AND "MG"."INVMG_ActiveFlg" = 1 
    AND "IOB"."INVOB_ActiveFlg" = 1
    GROUP BY "MG"."INVMG_GroupName"'
    USING "MI_Id", "FYear";
END;
$$;