CREATE OR REPLACE FUNCTION "dbo"."adm_sectionallotment_change_promotion_yearloss"(
    "asmay_id" TEXT,
    "asmcl_id" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" TEXT,
    "amsT_MiddleName" TEXT,
    "amsT_LastName" TEXT,
    "amsT_AdmNo" TEXT,
    "AMST_Id" BIGINT,
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "AMST_SOL" TEXT,
    "AMST_ActiveFlag" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."amsT_FirstName", 
        a."amsT_MiddleName",
        a."amsT_LastName",
        a."amsT_AdmNo",
        a."AMST_Id",
        a."MI_Id",
        a."ASMAY_Id",
        a."ASMCL_Id",
        a."AMST_SOL",
        a."AMST_ActiveFlag"
    FROM 
        "Adm_M_Student" a 
        LEFT JOIN "Adm_School_Y_Student" dict ON dict."AMST_Id" = a."AMST_Id" 
    WHERE 
        a."AMST_ActiveFlag" = 1 
        AND a."AMST_SOL" = 'S' 
        AND dict."amst_id" IS NULL 
        AND a."ASMAY_Id"::TEXT = "asmay_id" 
        AND a."ASMCL_Id"::TEXT = "asmcl_id" 
        AND a."MI_Id"::TEXT = "mi_id";
END;
$$;