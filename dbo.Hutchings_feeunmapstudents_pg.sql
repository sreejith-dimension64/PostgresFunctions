CREATE OR REPLACE FUNCTION "Hutchings_feeunmapstudents"(
    p_FMG_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_MI_ID BIGINT,
    p_FMH_ID TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FTI_ID BIGINT;
    v_FMSG_Id BIGINT;
    v_AMST_ID BIGINT;
    v_dyna TEXT;
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT DISTINCT B."FTI_Id", A."AMST_Id"
        FROM "Fee_Student_Status" A
        INNER JOIN "Fee_Master_Amount" B 
            ON B."FMG_Id" = A."FMG_Id" 
            AND B."FMH_Id" = A."FMH_Id" 
            AND B."ASMAY_Id" = A."ASMAY_Id"
        WHERE A."MI_Id" = 10001 
            AND A."ASMAY_Id" = 10023 
            AND A."FMG_Id" = 16 
            AND A."FMH_ID" IN (29, 30)
            AND A."FSS_PaidAmount" = 0 
            AND B."FMCC_Id" IN (3, 4, 5)
    LOOP
        v_AMST_ID := rec."AMST_Id";
        v_FTI_ID := rec."FTI_Id";
        
        UPDATE "Fee_Student_Status" 
        SET "FSS_CurrentYrCharges" = 0,
            "FSS_TotalToBePaid" = 0,
            "FSS_ToBePaid" = 0,
            "FSS_NetAmount" = 0
        WHERE "MI_Id" = p_MI_ID 
            AND "ASMAY_Id" = p_ASMAY_ID 
            AND "FMG_Id" = p_FMG_ID 
            AND "FMH_ID" = ANY(STRING_TO_ARRAY(p_FMH_ID, ',')::BIGINT[])
            AND "FTI_ID" = v_FTI_ID 
            AND "AMST_ID" = v_AMST_ID 
            AND "FSS_PaidAmount" = 0;
    END LOOP;
    
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ErrorNumber: %, ErrorMessage: %', SQLSTATE, SQLERRM;
        RAISE;
END;
$$;