CREATE OR REPLACE FUNCTION Fee_concession_name(p_MI_Id bigint)
RETURNS TABLE(FMCC_ConcessionName character varying, FMCC_Id bigint)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "Fee_Master_Concession"."FMCC_ConcessionName", "Fee_Master_Concession"."FMCC_Id" 
    FROM "Fee_Master_Concession" 
    WHERE "Fee_Master_Concession"."MI_Id" = p_MI_Id;
END;
$$;