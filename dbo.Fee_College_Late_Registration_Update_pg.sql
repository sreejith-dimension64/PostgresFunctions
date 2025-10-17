CREATE OR REPLACE FUNCTION "Fee_College_Late_Registration_Update"(
    p_MI_Id BIGINT,
    p_Amcst_id TEXT,
    p_ASMAY_Id BIGINT,
    p_FMH_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Amcst_idTable BIGINT[];
BEGIN
    -- Split comma-separated string into array
    v_Amcst_idTable := string_to_array(p_Amcst_id, ',')::BIGINT[];
    
    -- Update statement
    UPDATE "clg"."Fee_College_Student_Status" 
    SET "FCSS_ToBePaid" = 0,
        "FCSS_NetAmount" = 0 
    WHERE "Amcst_id" = ANY(v_Amcst_idTable)
        AND "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "FMH_Id" = p_FMH_Id;
        
END;
$$;