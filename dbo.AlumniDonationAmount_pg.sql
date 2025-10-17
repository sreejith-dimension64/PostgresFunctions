CREATE OR REPLACE FUNCTION "dbo"."AlumniDonationAmount"(
    p_MI_Id bigint,
    p_ALSREG_Id bigint
)
RETURNS TABLE("ALDON_Amount" numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT sum("ALDON_Amount") as "ALDON_Amount" 
    FROM "alu"."Alumni_Donation" 
    WHERE "ALSREG_Id" = p_ALSREG_Id;
END;
$$;