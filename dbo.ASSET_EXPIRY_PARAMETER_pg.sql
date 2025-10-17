
CREATE OR REPLACE FUNCTION "dbo"."ASSET_EXPIRY_PARAMETER"(
    "MI_Id" bigint,
    "ItemName" varchar(30),
    "WarantyExpiryDate" timestamp,
    "count_date" bigint
)
RETURNS TABLE(
    "DATE" timestamp,
    "NAME" varchar(30),
    "COUNT" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "WarantyExpiryDate" AS "DATE",
        "ItemName" AS "NAME",
        "count_date" AS "COUNT";
END;
$$;