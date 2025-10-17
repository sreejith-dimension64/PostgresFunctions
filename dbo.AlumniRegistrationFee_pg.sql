CREATE OR REPLACE FUNCTION "dbo"."AlumniRegistrationFee"(p_MI_Id bigint)
RETURNS TABLE("FMA_Amount" numeric)
LANGUAGE plpgsql
AS $$
DECLARE
    v_asmay_id bigint;
BEGIN
    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = 4 
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    RETURN QUERY
    SELECT "Fee_Master_Amount"."FMA_Amount" 
    FROM "Fee_Master_Amount" 
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
    WHERE "Fee_Master_Amount"."MI_Id" = p_MI_Id 
    AND "Fee_Master_Amount"."ASMAY_Id" = v_asmay_id 
    AND "Fee_Master_Head"."FMH_Flag" = 'A';
END;
$$;