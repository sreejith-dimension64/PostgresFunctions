CREATE OR REPLACE FUNCTION "dbo"."Get_feegroupwise_groupbyclass_collaction_portal"(
    p_MI_Id integer,
    p_ASMAY_Id integer,
    p_FMG_Id integer
)
RETURNS TABLE(
    "FMG_Id" integer,
    "GroupName" text,
    "classid" integer,
    "classname" text,
    "callected" numeric,
    "ballance" numeric,
    "concession" numeric,
    "receivable" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "dbo"."Fee_Master_Group"."FMG_Id" as "FMG_Id",
        "dbo"."Fee_Master_Group"."FMG_GroupName" as "GroupName",
        "dbo"."Adm_School_M_Class"."ASMCL_Id" as "classid",
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName" as "classname",
        (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::numeric AS "callected",
        SUM("dbo"."fee_student_status"."FSS_ToBePaid")::numeric AS "ballance",
        SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::numeric AS "concession",
        SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::numeric AS "receivable"
    FROM "dbo"."Fee_Student_Status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
    WHERE "dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id
        AND "dbo"."Fee_Student_Status"."MI_Id" = p_MI_Id
        AND "dbo"."fee_student_status"."ASMAY_Id" = p_ASMAY_Id
        AND "dbo"."fee_student_status"."FMG_Id" = p_FMG_Id
    GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_Id",
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
        "dbo"."Fee_Master_Group"."FMG_Id",
        "dbo"."Fee_Master_Group"."FMG_GroupName"
    ORDER BY "dbo"."Adm_School_M_Class"."ASMCL_Id";
    
    RETURN;
END;
$$;