CREATE OR REPLACE FUNCTION "dbo"."Get_Groupwise_fee_collection_portal" (
    p_MI_Id INT,
    p_ASMAY_Id INT
)
RETURNS TABLE (
    groupid INT,
    groupname VARCHAR,
    callected NUMERIC,
    ballance NUMERIC,
    concession NUMERIC,
    receivable NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    
    RETURN QUERY
    SELECT DISTINCT
        "Fee_Master_Group"."FMG_Id" AS groupid,
        "Fee_Master_Group"."FMG_GroupName" AS groupname,
        (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) AS callected,
        SUM("fee_student_status"."FSS_ToBePaid") AS ballance,
        SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS concession,
        SUM("fee_student_status"."FSS_CurrentYrCharges") AS receivable
    FROM "dbo"."Fee_Student_Status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
    WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id
        AND "Fee_Student_Status"."MI_Id" = p_MI_Id
        AND "fee_student_status"."ASMAY_Id" = p_ASMAY_Id
    GROUP BY "Fee_Master_Group"."FMG_Id", "Fee_Master_Group"."FMG_GroupName";
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    RETURN;
END;
$$;