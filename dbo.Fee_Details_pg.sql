CREATE OR REPLACE FUNCTION "Fee_Details"(@MI_ID bigint)
RETURNS TABLE (
    "FMG_GroupName" VARCHAR,
    "CreatedDate" TIMESTAMP,
    "FYGHM_ActiveFlag" BOOLEAN,
    "FYGHM_RVRegLedgerUnder" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        A."FMG_GroupName",
        B."CreatedDate",
        C."FYGHM_ActiveFlag",
        D."FYGHM_RVRegLedgerUnder"
    FROM "dbo"."Fee_Master_Group" AS A 
    INNER JOIN "dbo"."Fee_Yearly_Group" B ON A."FMG_Id" = B."FMG_Id"
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" AS C ON C."FMG_Id" = A."FMG_Id"
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_LedgerMapping" AS D ON D."FYGHM_Id" = C."FYGHM_Id"
    WHERE A."MI_Id" = 6;
END;
$$;