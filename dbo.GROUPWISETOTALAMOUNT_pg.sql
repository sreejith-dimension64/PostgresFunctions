CREATE OR REPLACE FUNCTION "GROUPWISETOTALAMOUNT"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_USERID bigint,
    p_AMST_Id bigint
)
RETURNS TABLE(
    "MI_Id" bigint,
    "AMST_Id" bigint,
    "FMG_Id" bigint,
    "FTI_Id" bigint,
    total numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Fee_Student_Status"."MI_Id",
        "Fee_Student_Status"."AMST_Id",
        "Fee_Student_Status"."FMG_Id",
        "Fee_Student_Status"."FTI_Id",
        SUM("Fee_Student_Status"."FSS_TotalToBePaid") as total 
    FROM "Fee_Student_Status"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
    INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."fmg_id" = "Fee_Student_Status"."FMG_Id"
        AND "Fee_Group_Login_Previledge"."fmh_id" = "Fee_Student_Status"."fmh_id"
    WHERE "FSS_ActiveFlag" = 1 
        AND "Fee_Student_Status"."MI_Id" = p_MI_Id 
        AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id
        AND "Fee_Group_Login_Previledge"."user_id" = p_USERID 
        AND "Fee_Student_Status"."AMST_Id" = p_AMST_Id
    GROUP BY "Fee_Student_Status"."AMST_Id", "Fee_Student_Status"."MI_Id", "Fee_Student_Status"."FMG_Id", "Fee_Student_Status"."FTI_Id"
    LIMIT 1000;
END;
$$;