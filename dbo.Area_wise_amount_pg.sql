```sql
CREATE OR REPLACE FUNCTION "dbo"."Area_wise_amount" (
    p_MI_Id bigint
)
RETURNS TABLE (
    "TRMAAMT_OneWayAmount" numeric,
    "TRMAAMT_TwoWayAmount" numeric,
    "TRMAAMT_Id" bigint,
    "TRMA_AreaName" varchar,
    "ASMAY_Year" varchar,
    "TRMAAMT_ActiveFlg" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."TRMAAMT_OneWayAmount",
        a."TRMAAMT_TwoWayAmount",
        a."TRMAAMT_Id",
        b."TRMA_AreaName",
        c."ASMAY_Year",
        a."TRMAAMT_ActiveFlg"
    FROM "TRN"."TR_Area_Amount" a
    INNER JOIN "TRN"."TR_Master_Area" b ON b."TRMA_Id" = a."TRMA_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE b."MI_Id" = p_MI_Id;
END;
$$;
```