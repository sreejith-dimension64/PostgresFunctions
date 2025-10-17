CREATE OR REPLACE FUNCTION "dbo"."Get_Classwise_fee_collaction"(
    p_MI_Id INT,
    p_ASMAY_Id INT
)
RETURNS TABLE(
    callected NUMERIC,
    ballance NUMERIC,
    concession NUMERIC,
    waived NUMERIC,
    rebate NUMERIC,
    fine NUMERIC,
    class VARCHAR,
    classid INT,
    "ASMCL_Order" INT,
    receivable NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    RETURN QUERY
    SELECT DISTINCT
        SUM("dbo"."fee_student_status"."FSS_PaidAmount" - "dbo"."fee_student_status"."FSS_FineAmount") AS callected,
        SUM("dbo"."fee_student_status"."FSS_ToBePaid") AS ballance,
        SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS concession,
        SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS waived,
        SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS rebate,
        SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS fine,
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS class,
        "Adm_School_M_Class"."ASMCL_Id" AS classid,
        "Adm_School_M_Class"."ASMCL_Order",
        SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS receivable
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."fee_student_status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."fee_student_status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id) 
        AND ("dbo"."fee_student_status"."MI_Id" = p_MI_Id) 
        AND ("dbo"."fee_student_status"."ASMAY_Id" = p_ASMAY_Id)
    GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_ClassName", 
             "Adm_School_M_Class"."ASMCL_Id", 
             "Adm_School_M_Class"."ASMCL_Order"
    ORDER BY "Adm_School_M_Class"."ASMCL_Order";
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    RETURN;
END;
$$;