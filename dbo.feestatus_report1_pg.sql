CREATE OR REPLACE FUNCTION "dbo"."feestatus_report1"()
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_mi BIGINT;
BEGIN
    SELECT "MI_Id" INTO v_mi 
    FROM "dbo"."Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = 10;

    RETURN QUERY
    SELECT 
        SUM("dbo"."Fee_T_Stud_FeeStatus"."Net_amount") AS "TotalToBePaid", 
        "dbo"."Fee_Master_Group"."FMG_GroupName", 
        SUM("dbo"."Fee_Y_Payment"."FYP_Tot_Amount") AS "CollectedAmount" 
    FROM "dbo"."Fee_Yearly_Group" 
    INNER JOIN "dbo"."Fee_Master_Group" 
        ON "dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" 
    INNER JOIN "dbo"."Fee_Master_Head" 
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" 
        ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
        ON "dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" 
    INNER JOIN "dbo"."Fee_T_Payment" 
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
    INNER JOIN "dbo"."Fee_Y_Payment" 
        ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
    INNER JOIN "dbo"."Adm_M_Student" 
    INNER JOIN "dbo"."Adm_School_Y_Student" 
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "dbo"."Fee_T_Stud_FeeStatus" 
        ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_T_Stud_FeeStatus"."Amst_Id" 
        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
        ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" 
    INNER JOIN "dbo"."Fee_Master_Amount" 
        ON "dbo"."Fee_T_Stud_FeeStatus"."fma_id" = "dbo"."Fee_Master_Amount"."FMA_Id" 
        ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_T_Stud_FeeStatus"."fmg_id" 
    WHERE "dbo"."Fee_T_Stud_FeeStatus"."asmay_id" = 10
    GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName";

    RETURN QUERY
    SELECT 
        SUM("dbo"."Fee_T_Stud_FeeStatus"."Net_amount") AS "TotalToBePaid", 
        SUM("dbo"."Fee_Y_Payment"."FYP_Tot_Amount") AS "CollectedAmount",
        "dbo"."Fee_Master_Head"."FMH_FeeName" 
    FROM "dbo"."Fee_Yearly_Group" 
    INNER JOIN "dbo"."Fee_Master_Group" 
        ON "dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" 
    INNER JOIN "dbo"."Fee_Master_Head" 
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" 
        ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
        ON "dbo"."Fee_Yearly_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" 
    INNER JOIN "dbo"."Fee_T_Payment" 
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
    INNER JOIN "dbo"."Fee_Y_Payment" 
        ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
    INNER JOIN "dbo"."Adm_M_Student" 
    INNER JOIN "dbo"."Adm_School_Y_Student" 
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "dbo"."Fee_T_Stud_FeeStatus" 
        ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_T_Stud_FeeStatus"."Amst_Id" 
        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
        ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" 
    INNER JOIN "dbo"."Fee_Master_Amount" 
        ON "dbo"."Fee_T_Stud_FeeStatus"."fma_id" = "dbo"."Fee_Master_Amount"."FMA_Id" 
        ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_T_Stud_FeeStatus"."fmg_id"
    WHERE "dbo"."Fee_T_Stud_FeeStatus"."asmay_id" = 10 
    GROUP BY "dbo"."Fee_Master_Head"."FMH_FeeName";

    RETURN;
END;
$$;