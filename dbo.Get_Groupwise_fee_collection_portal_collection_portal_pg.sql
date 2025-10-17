CREATE OR REPLACE FUNCTION "dbo"."Get_Groupwise_fee_collection_portal_collection_portal"(
    p_MI_Id integer,
    p_ASMAY_Id integer
)
RETURNS TABLE(
    groupid integer,
    groupname character varying,
    receivable numeric,
    callected numeric,
    ballance numeric,
    concession numeric,
    waived numeric,
    rebate numeric,
    fine numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "dbo"."Fee_Master_Group"."FMG_Id" as groupid,
        "dbo"."Fee_Master_Group"."FMG_GroupName" as groupname,
        SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS receivable,
        SUM("dbo"."fee_student_status"."FSS_PaidAmount") AS callected,
        SUM("dbo"."fee_student_status"."FSS_ToBePaid") as ballance,
        SUM("dbo"."fee_student_status"."FSS_ConcessionAmount") AS concession,
        SUM("dbo"."fee_student_status"."FSS_WaivedAmount") AS waived,
        SUM("dbo"."fee_student_status"."FSS_RebateAmount") AS rebate,
        SUM("dbo"."fee_student_status"."FSS_FineAmount") AS fine
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."fee_student_status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."fee_student_status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id"
    WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id) 
        AND ("dbo"."fee_student_status"."MI_Id" = p_MI_Id) 
        AND ("dbo"."Fee_Master_Group"."FMG_ActiceFlag" = 1) 
        AND ("dbo"."fee_student_status"."FSS_PaidAmount" > 0) 
        AND ("dbo"."Adm_M_Student"."AMST_SOL" = 'S')
    GROUP BY "dbo"."Fee_Master_Group"."FMG_Id", "dbo"."Fee_Master_Group"."FMG_GroupName"
    ORDER BY "dbo"."Fee_Master_Group"."FMG_Id";
END;
$$;