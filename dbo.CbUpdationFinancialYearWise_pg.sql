CREATE OR REPLACE FUNCTION "dbo"."CbUpdationFinancialYearWise"(p_MI_Id BIGINT, p_ASMAY_Id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_error_number TEXT;
    v_error_message TEXT;
    v_error_context TEXT;
BEGIN
    DROP TABLE IF EXISTS "Students_CYPaidAccAsOnDateFY_Temp1";
    
    CREATE TEMP TABLE "Students_CYPaidAccAsOnDateFY_Temp1" AS
    SELECT * 
    FROM "Fee_Student_status" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
        AND "MI_Id" = p_MI_Id 
        AND "FSS_ToBePaid" > 0 
        AND "FMG_Id" = 26 
        AND "FSS_OBTransferred" IS NULL
    ORDER BY 1
    LIMIT 100;
    
    UPDATE "Fee_Student_Status" "FSS"
    SET "FSS_CBAsPerFY" = "FSST"."FSS_ToBePaid"
    FROM "Students_CYPaidAccAsOnDateFY_Temp1" "FSST"
    WHERE "FSST"."AMST_Id" = "FSS"."AMST_Id" 
        AND "FSS"."FSS_Id" = "FSST"."FSS_Id"
        AND "FSS"."MI_Id" = p_MI_Id 
        AND "FSS"."ASMAY_Id" = p_ASMAY_Id 
        AND "FSST"."MI_Id" = p_MI_Id 
        AND "FSST"."ASMAY_Id" = p_ASMAY_Id 
        AND "FSS"."FSS_ToBePaid" > 0
        AND "FSS"."FMG_Id" = 26 
        AND "FSST"."FMG_Id" = 26 
        AND "FSS"."FSS_OBTransferred" IS NULL 
        AND "FSST"."FSS_OBTransferred" IS NULL;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_error_message = MESSAGE_TEXT,
            v_error_context = PG_EXCEPTION_CONTEXT;
        
        v_error_number := SQLSTATE;
        
        RAISE NOTICE 'ErrorNumber: %', v_error_number;
        RAISE NOTICE 'ErrorProcedure: %', 'CbUpdationFinancialYearWise';
        RAISE NOTICE 'ErrorMessage: %', v_error_message;
        RAISE NOTICE 'ErrorContext: %', v_error_context;
        
        ROLLBACK;
        RAISE;
END;
$$;