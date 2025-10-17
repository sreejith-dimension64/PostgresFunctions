CREATE OR REPLACE FUNCTION "Fee_Not_Paid_Students"(
    p_mi_id BIGINT,
    p_Asmay_Id BIGINT,
    p_asmcl_id BIGINT,
    p_asms_id BIGINT,
    p_Amst_Id BIGINT
)
RETURNS TABLE(
    "amst_Id" BIGINT,
    "fsS_PaidAmount" INTEGER,
    "fsS_CurrentYrCharges" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (p_asmcl_id != 0 AND p_asms_id != 0 AND p_Amst_Id = 0) THEN
        RETURN QUERY
        SELECT 
            "Amst_Id" AS "amst_Id",
            0 AS "fsS_PaidAmount",
            0 AS "fsS_CurrentYrCharges"
        FROM "adm_school_Y_student"
        WHERE "asmay_id" = p_Asmay_Id 
            AND "asmcl_id" = p_asmcl_id 
            AND "asms_id" = p_asms_id
            AND "amst_id" NOT IN (
                SELECT "amst_id" 
                FROM "PDA_Status" 
                WHERE "ASMAY_Id" = p_Asmay_Id
            );
    ELSIF (p_asmcl_id != 0 AND p_asms_id != 0 AND p_Amst_Id != 0) THEN
        RETURN QUERY
        SELECT 
            "Amst_Id" AS "amst_Id",
            0 AS "fsS_PaidAmount",
            0 AS "fsS_CurrentYrCharges"
        FROM "adm_school_Y_student"
        WHERE "asmay_id" = p_Asmay_Id 
            AND "asmcl_id" = p_asmcl_id 
            AND "asms_id" = p_asms_id
            AND "amst_id" = p_Amst_Id
            AND "amst_id" NOT IN (
                SELECT "amst_id" 
                FROM "PDA_Status" 
                WHERE "ASMAY_Id" = p_Asmay_Id
            );
    END IF;

    RETURN;
END;
$$;