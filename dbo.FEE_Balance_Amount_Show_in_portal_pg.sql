CREATE OR REPLACE FUNCTION "dbo"."FEE_Balance_Amount_Show_in_portal"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMAY_ID bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "FMH_FeeName" VARCHAR,
    "FMT_Name" VARCHAR,
    "TobePaid" NUMERIC,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "AMST_emailId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TODAY_DATE date;
BEGIN
    v_TODAY_DATE := CURRENT_DATE;
    
    RETURN QUERY
    SELECT DISTINCT 
        "fee_student_status"."AMST_Id",
        "Fee_Master_Head"."FMH_FeeName",
        "Fee_Master_Terms"."FMT_Name",
        SUM("fee_student_status"."FSS_ToBePaid") AS "TobePaid",
        COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
        COALESCE("Adm_M_Student"."AMST_MiddleName", '') || ' ' || 
        COALESCE("Adm_M_Student"."AMST_LastName", '') AS "StudentName",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Adm_M_Student"."AMST_MobileNo",
        "Adm_M_Student"."AMST_emailId"
    FROM "fee_student_status"
    INNER JOIN "dbo"."Fee_Master_Group" ON "fee_student_status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
        AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
        AND "Fee_Master_Head"."MI_Id" = p_MI_Id
    INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
        AND "Fee_Master_Terms"."FMT_ActiveFlag" = true 
        AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
    INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
        AND "Adm_School_Y_Student"."AMST_Id" = "fee_student_status"."AMST_Id"
    INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE "dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_ID 
        AND "dbo"."fee_student_status"."ASMAY_Id" = p_ASMAY_ID 
        AND "dbo"."fee_student_status"."MI_Id" = p_MI_Id
        AND "Adm_School_M_Class"."ASMCL_Id" = p_ASMCL_Id
        AND "fee_student_status"."AMST_Id" IN (
            SELECT DISTINCT "amst_id" 
            FROM "Fee_Y_Payment_School_Student" 
            WHERE "Fee_Y_Payment_School_Student"."FYP_Id" IN (
                SELECT DISTINCT "fyp_id" 
                FROM "fee_y_payment" 
                WHERE "mi_id" = p_MI_Id 
                    AND "ASMAY_ID" = p_ASMAY_ID 
                    AND CAST("FYP_Date" AS date) <= v_TODAY_DATE
            )
        ) 
        AND "fee_student_status"."FSS_ToBePaid" != 0 
        AND "fee_student_status"."AMST_Id" = p_AMST_Id
    GROUP BY 
        "fee_student_status"."AMST_Id",
        "AMST_FirstName",
        "AMST_MiddleName",
        "AMST_LastName",
        "AMST_AdmNo",
        "ASMCL_ClassName",
        "ASMC_SectionName",
        "AMST_MobileNo",
        "AMST_emailId",
        "Fee_Master_Head"."FMH_FeeName",
        "Fee_Master_Terms"."FMT_Name"
    LIMIT 100;
    
    RETURN;
END;
$$;