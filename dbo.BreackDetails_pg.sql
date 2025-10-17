CREATE OR REPLACE FUNCTION "BreackDetails"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@HRME_Id" bigint
)
RETURNS TABLE(
    "ttmB_AfterPeriod" INTEGER,
    "ttmB_BreakName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  
        d."TTMB_AfterPeriod" as "ttmB_AfterPeriod",
        d."TTMB_BreakName" as "ttmB_BreakName"
    FROM "TT_Final_Generation_Detailed" a
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
    INNER JOIN "TT_Master_Break" d ON a."ASMCL_Id" = d."ASMCL_Id" 
        AND c."ASMCL_Id" = d."ASMCL_Id" 
        AND d."MI_Id" = c."MI_Id"
    INNER JOIN "Adm_School_M_Section" e ON a."ASMS_Id" = e."ASMS_Id"
    WHERE d."MI_Id" = "@MI_Id" 
        AND d."ASMAY_Id" = "@ASMAY_Id" 
        AND a."HRME_Id" = "@HRME_Id" 
        AND "ASMC_ActiveFlag" = 1;
END;
$$;