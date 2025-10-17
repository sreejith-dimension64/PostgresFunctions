CREATE OR REPLACE FUNCTION "dbo"."DELETE_RFID_IN_OUT_DETAILS"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_DATE date
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "IVRM_RF_Punch" 
    WHERE "MI_Id" = p_MI_Id 
    AND CAST("IRFPU_DateTime" AS date) = p_DATE;
    
    RETURN;
END;
$$;