CREATE OR REPLACE FUNCTION "dbo"."ADM_RF_CARDS_Studentdetails_Cancel"(
    p_MI_id bigint,
    p_AMST_Id text
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "dbo"."ADM_RF_CARDS" 
    SET "AMCTST_STATUS" = 'D' 
    WHERE "MI_Id" = p_MI_id 
    AND "AMST_Id" = p_AMST_Id;
END;
$$;