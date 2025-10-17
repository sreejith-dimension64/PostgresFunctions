CREATE OR REPLACE FUNCTION "Fee_RouteHousewise_Report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "TRMR_RouteNo" VARCHAR,
    "SPCCMH_HouseName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        d."TRMR_RouteNo",
        f."SPCCMH_HouseName"
    FROM "Adm_School_Y_Student" a 
    INNER JOIN "Adm_M_Student" b
        ON a."amst_id" = b."amst_id" AND b."AMST_ActiveFlag" = 1
    LEFT JOIN "trn"."TR_Student_Route" c 
        ON a."amst_id" = c."amst_id" AND c."ASMAY_Id" = a."ASMAY_Id"
    LEFT JOIN "trn"."TR_Master_Route" d 
        ON d."TRMR_Id" = c."TRMR_Id"
    LEFT JOIN "spc"."SPCC_Student_House" e 
        ON e."AMST_Id" = a."AMST_Id" AND e."ASMAY_Id" = a."ASMAY_Id"
    LEFT JOIN "spc"."SPCC_Master_House" f 
        ON f."SPCCMH_Id" = e."SPCCMH_Id"
    WHERE b."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."AMST_Id" = p_AMST_Id;

END;
$$;