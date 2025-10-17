CREATE OR REPLACE FUNCTION "dbo"."INV_SMS_Sales"(
    "@MI_Id" bigint,
    "@SalePrice" VARCHAR(100),
    "@SaleDate" VARCHAR(100),
    "@template" VARCHAR(200)
)
RETURNS TABLE(
    "SalesPrice" VARCHAR(100),
    "SaleDate" VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@template" = 'INVSales' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "@SalePrice" AS "SalesPrice",
            "@SaleDate" AS "SaleDate";
    END IF;

    RETURN;

END;
$$;