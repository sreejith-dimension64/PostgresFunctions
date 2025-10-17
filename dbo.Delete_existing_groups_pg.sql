CREATE OR REPLACE FUNCTION "dbo"."Delete_existing_groups"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FGAR_Id" bigint
)
RETURNS TABLE (
    "fgar_id" bigint,
    "fgarg_id" bigint,
    "fmg_id" bigint,
    "fgarg_createddate" timestamp,
    "fgarg_updateddate" timestamp,
    "fgarg_createdby" bigint,
    "fgarg_updatedby" bigint,
    "fgarg_activeflag" boolean
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount integer;
BEGIN
    RETURN QUERY
    SELECT * FROM "Fee_Groupwise_AutoReceipt_Groups" 
    WHERE "fgar_id" = "FGAR_Id";
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        DELETE FROM "Fee_Groupwise_AutoReceipt_Groups" 
        WHERE "fgar_id" = "FGAR_Id";
    END IF;
    
    RETURN;
END;
$$;