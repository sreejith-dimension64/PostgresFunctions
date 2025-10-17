CREATE OR REPLACE FUNCTION "dbo"."Delete_Auto_Receipt_Group"(
    p_FGAR_Id bigint,
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount integer;
BEGIN

    SELECT * FROM "Fee_Groupwise_AutoReceipt" WHERE "FGAR_Id" = p_FGAR_Id;
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        
        SELECT * FROM "Fee_Groupwise_AutoReceipt_Groups" WHERE "FGAR_Id" = p_FGAR_Id;
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            DELETE FROM "Fee_Groupwise_AutoReceipt_Groups" WHERE "FGAR_Id" = p_FGAR_Id;
            DELETE FROM "Fee_Groupwise_AutoReceipt" WHERE "FGAR_Id" = p_FGAR_Id;
        END IF;
        
    END IF;

END;
$$;