
CREATE OR REPLACE FUNCTION "dbo"."ISm_Sales_Lead_DD"(
    "MI_Id" bigint
)
RETURNS TABLE(
    "ISMSLE_Id" bigint,
    "ISMSLE_LeadName" varchar
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."ISMSLE_Id", 
        b."ISMSLE_LeadName"
    FROM "ISM_Sales_Lead_Comments" a
    INNER JOIN "ISM_Sales_Lead" b 
        ON a."ISMSLE_Id" = b."ISMSLE_Id" 
        AND a."MI_Id" = b."MI_Id" 
        AND a."MI_Id" = "ISm_Sales_Lead_DD"."MI_Id";
END;
$$;