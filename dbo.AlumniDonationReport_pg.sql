CREATE OR REPLACE FUNCTION "dbo"."AlumniDonationReport"(
    p_MI_Id bigint,
    p_Fromdate timestamp,
    p_Todate timestamp
)
RETURNS TABLE (
    "ALDON_DonorName" VARCHAR,
    "ALMDON_DonationName" VARCHAR,
    "ALDON_Amount" NUMERIC,
    "ALDON_Date" TIMESTAMP,
    "ALDON_ReceiptNo" VARCHAR,
    "ALDON_ModeOfPayment" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."ALDON_DonorName", 
        b."ALMDON_DonationName", 
        a."ALDON_Amount", 
        a."ALDON_Date", 
        a."ALDON_ReceiptNo", 
        a."ALDON_ModeOfPayment"
    FROM "ALU"."Alumni_Donation" a 
    INNER JOIN "alu"."Alumni_Master_Donation" b ON b."ALMDON_Id" = a."ALMDON_Id"
    WHERE CAST(a."ALDON_Date" AS date) BETWEEN CAST(p_Fromdate AS date) AND CAST(p_Todate AS date)
        AND b."MI_Id" = p_MI_Id;
END;
$$;