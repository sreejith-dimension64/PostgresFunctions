CREATE OR REPLACE FUNCTION "dbo"."Feeheads_dd_proc"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    "FMH_Id" bigint,
    "FMH_FeeName" VARCHAR,
    "ASMAY_Id" bigint,
    "MI_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "Fee_Student_Status"."FMH_Id",
        "Fee_Master_Head"."FMH_FeeName",
        "Fee_Student_Status"."ASMAY_Id",
        "Fee_Student_Status"."MI_Id"
    FROM "Fee_Student_Status"
    INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    WHERE "Fee_Student_Status"."MI_Id" = p_MI_Id 
        AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id;
END;
$$;