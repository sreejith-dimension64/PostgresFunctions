CREATE OR REPLACE FUNCTION "INV"."INV_get_SalesList"(
    p_MI_Id bigint,
    p_Flag VARCHAR(50),
    p_User_Id bigint
)
RETURNS TABLE(
    "invmsL_Id" bigint,
    "invmsL_SalesNo" VARCHAR,
    "invmsT_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_Flag = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSL_Id" AS "invmsL_Id",
            a."INVMSL_SalesNo" AS "invmsL_SalesNo",
            a."INVMST_Id" AS "invmsT_Id"
        FROM "INV"."INV_M_Sales" a
        INNER JOIN "INV"."INV_M_Sales_Staff" b ON a."INVMSL_Id" = b."INVMSL_Id"
        WHERE b."HRME_Id" = p_User_Id AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMSL_Id" DESC;
        
    ELSIF p_Flag = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSL_Id" AS "invmsL_Id",
            a."INVMSL_SalesNo" AS "invmsL_SalesNo",
            a."INVMST_Id" AS "invmsT_Id"
        FROM "INV"."INV_M_Sales" a
        INNER JOIN "INV"."INV_M_Sales_Student" b ON a."INVMSL_Id" = b."INVMSL_Id"
        WHERE b."AMST_Id" = p_User_Id AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMSL_Id" DESC;
        
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSL_Id" AS "invmsL_Id",
            a."INVMSL_SalesNo" AS "invmsL_SalesNo",
            a."INVMST_Id" AS "invmsT_Id"
        FROM "INV"."INV_M_Sales" a
        WHERE a."MI_Id" = p_MI_Id AND a."INVMSL_ActiveFlg" = 1
        ORDER BY a."INVMSL_Id" DESC;
        
    END IF;
END;
$$;