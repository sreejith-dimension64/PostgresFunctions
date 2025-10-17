CREATE OR REPLACE FUNCTION "dbo"."feestatus_report"(
    p_asmay_id BIGINT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_type VARCHAR(10)
)
RETURNS TABLE (
    "TotalToBePaid" NUMERIC,
    "CollectedAmount" NUMERIC,
    "FMG_GroupName" VARCHAR,
    "FMH_FeeName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_mi BIGINT;
BEGIN
    SELECT "MI_Id" INTO v_mi 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_asmay_id;

    IF p_type = 'group' THEN
        RETURN QUERY
        SELECT 
            SUM("Fee_T_Stud_FeeStatus"."Net_amount") AS "TotalToBePaid",
            SUM("Fee_Y_Payment"."FYP_Tot_Amount") AS "CollectedAmount",
            "Fee_Master_Group"."FMG_GroupName",
            NULL::VARCHAR AS "FMH_FeeName"
        FROM "dbo"."Fee_Yearly_Group"
        INNER JOIN "dbo"."Fee_Master_Group" 
            ON "Fee_Yearly_Group"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "dbo"."Fee_Master_Head"
        INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" 
            ON "Fee_Master_Head"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            ON "Fee_Yearly_Group"."FMG_Id" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id"
        INNER JOIN "dbo"."Fee_T_Payment"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student"
        INNER JOIN "dbo"."Fee_Y_Payment" 
            ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_T_Stud_FeeStatus" 
            ON "Adm_School_Y_Student"."AMST_Id" = "Fee_T_Stud_FeeStatus"."Amst_Id"
            ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
        INNER JOIN "dbo"."Fee_Master_Amount" 
            ON "Fee_T_Stud_FeeStatus"."fma_id" = "Fee_Master_Amount"."FMA_Id"
            ON "Fee_Master_Group"."FMG_Id" = "Fee_T_Stud_FeeStatus"."fmg_id"
        WHERE "Fee_Y_Payment"."FYP_Date" BETWEEN TO_TIMESTAMP(p_fromdate, 'DD/MM/YYYY') AND TO_TIMESTAMP(p_todate, 'DD/MM/YYYY')
            AND "Fee_T_Stud_FeeStatus"."asmay_id" = p_asmay_id
        GROUP BY "Fee_Master_Group"."FMG_GroupName";

    ELSIF p_type = 'head' THEN
        RETURN QUERY
        SELECT 
            SUM("Fee_T_Stud_FeeStatus"."Net_amount") AS "TotalToBePaid",
            SUM("Fee_Y_Payment"."FYP_Tot_Amount") AS "CollectedAmount",
            NULL::VARCHAR AS "FMG_GroupName",
            "Fee_Master_Head"."FMH_FeeName"
        FROM "dbo"."Fee_Yearly_Group"
        INNER JOIN "dbo"."Fee_Master_Group" 
            ON "Fee_Yearly_Group"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "dbo"."Fee_Master_Head"
        INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" 
            ON "Fee_Master_Head"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            ON "Fee_Yearly_Group"."FMG_Id" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id"
        INNER JOIN "dbo"."Fee_T_Payment"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student"
        INNER JOIN "dbo"."Fee_Y_Payment" 
            ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_T_Stud_FeeStatus" 
            ON "Adm_School_Y_Student"."AMST_Id" = "Fee_T_Stud_FeeStatus"."Amst_Id"
            ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
        INNER JOIN "dbo"."Fee_Master_Amount" 
            ON "Fee_T_Stud_FeeStatus"."fma_id" = "Fee_Master_Amount"."FMA_Id"
            ON "Fee_Master_Group"."FMG_Id" = "Fee_T_Stud_FeeStatus"."fmg_id"
        WHERE "Fee_Y_Payment"."FYP_Date" BETWEEN TO_TIMESTAMP(p_fromdate, 'DD/MM/YYYY') AND TO_TIMESTAMP(p_todate, 'DD/MM/YYYY')
            AND "Fee_T_Stud_FeeStatus"."asmay_id" = p_asmay_id
        GROUP BY "Fee_Master_Head"."FMH_FeeName";

    END IF;

    RETURN;
END;
$$;