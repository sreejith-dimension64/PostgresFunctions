CREATE OR REPLACE FUNCTION "dbo"."FeeReceipt_ImportDelete"(
    p_MI_ID BIGINT,
    p_ASMAY_Id BIGINT,
    p_FYP_Date VARCHAR(20)
)
RETURNS TABLE(
    "AMST_AdmNo" VARCHAR,
    "FYP_Id" BIGINT,
    "ASMAY_ID" BIGINT,
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "FYP_Date" TIMESTAMP,
    "FYP_Receipt_No" VARCHAR,
    "FYP_Tot_Amount" NUMERIC
) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- EXEC FeeReceipt_ImportDelete 4,209,'2022-06-01'
    
    RETURN QUERY
    SELECT 
        c."AMST_AdmNo",
        a."FYP_Id",
        a."ASMAY_ID",
        c."AMST_Id",
        COALESCE(c."AMST_FirstName", ' ') || ' ' || COALESCE(c."AMST_MiddleName", ' ') || ' ' || COALESCE(c."AMST_LastName", ' ') AS "StudentName",
        a."FYP_Date",
        a."FYP_Receipt_No",
        a."FYP_Tot_Amount"
    FROM "Fee_Y_Payment" a
    INNER JOIN "Fee_Y_Payment_School_Student" b ON a."ASMAY_ID" = b."ASMAY_Id" AND a."FYP_Id" = b."FYP_Id"
    INNER JOIN "Adm_M_Student" c ON a."MI_Id" = c."MI_Id" AND b."AMST_id" = c."AMST_id"
    INNER JOIN "Adm_School_Y_Student" d ON a."ASMAY_ID" = d."ASMAY_Id" AND c."AMST_Id" = d."AMST_Id" AND b."AMST_Id" = d."AMST_Id"
    WHERE a."MI_Id" = p_MI_ID 
        AND a."ASMAY_ID" = p_ASMAY_Id 
        AND a."FYP_Remarks" = 'Fee Receipt Imported' 
        AND a."FYP_Date" = p_FYP_Date::TIMESTAMP;
        
    RETURN;
END;
$$;