CREATE OR REPLACE FUNCTION "dbo"."FEE_Balance_Amount_Show_in_portalnotificationupdated"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMAY_ID bigint
)
RETURNS TABLE (
    due TEXT,
    "FMT_Name" VARCHAR,
    fmtis TEXT,
    "On_Date" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TODAY_DATE TIMESTAMP;
    v_Dynamic1 TEXT;
    v_Dynamic2 TEXT;
    v_Dynamic3 TEXT;
    v_Fineamt FLOAT;
    v_flgarr1 INTEGER;
    v_FMA_Id_F BIGINT;
    v_Duedate_fine DATE;
    v_flgarr INTEGER;
    v_amt FLOAT;
    v_AMST_Id_F BIGINT;
    v_Fcount BIGINT;
    v_DueDate_N DATE;
BEGIN
    v_TODAY_DATE := (CURRENT_DATE + INTERVAL '15 days')::TIMESTAMP;
    
    RAISE NOTICE '%', v_TODAY_DATE;
    
    PERFORM "dbo"."Fees_TermsDuedates"(p_MI_Id, p_ASMAY_ID, v_TODAY_DATE);
    
    RETURN QUERY
    SELECT 
        NEW.due,
        NEW."FMT_Name",
        NEW.fmtis,
        NEW."On_Date"
    FROM (
        SELECT  
            'DueDate For '::TEXT as due,
            "Fee_Master_Terms"."FMT_Name",
            ' Is '::TEXT as fmtis,
            "FeeTermsDueDates"."On_Date"
        FROM "dbo"."fee_student_status"
        INNER JOIN "dbo"."Fee_Master_Group" ON "fee_student_status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id
        INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Master_Head"."MI_Id" = p_MI_Id
        INNER JOIN "dbo"."Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
            AND "Fee_Master_Terms"."FMT_ActiveFlag" = 1 
            AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_School_Y_Student"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
            AND "Adm_School_Y_Student"."AMST_Id" = "fee_student_status"."AMST_Id"
        INNER JOIN "dbo"."Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id"
        INNER JOIN "dbo"."FeeTermsDueDates" ON "FeeTermsDueDates"."FMT_Id" = "Fee_Master_Terms"."FMT_Id" 
            AND "FeeTermsDueDates"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
            AND "FeeTermsDueDates"."FMA_Id" = "fee_student_status"."FMA_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_ID 
            AND "fee_student_status"."ASMAY_Id" = p_ASMAY_ID 
            AND "fee_student_status"."MI_Id" = p_MI_Id
            AND "Adm_School_M_Class"."ASMCL_Id" = p_ASMCL_Id 
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_ID
            AND "fee_student_status"."FSS_ToBePaid" != 0 
            AND "fee_student_status"."AMST_Id" = p_AMST_Id
            AND ("FeeTermsDueDates"."DueDate"::DATE - CURRENT_DATE) <= 15
        GROUP BY "fee_student_status"."AMST_Id",
            "AMST_FirstName",
            "AMST_MiddleName",
            "AMST_LastName",
            "AMST_AdmNo",
            "ASMCL_ClassName",
            "ASMC_SectionName",
            "AMST_MobileNo",
            "AMST_emailId",
            "Fee_Master_Head"."FMH_FeeName",
            "Fee_Master_Terms"."FMT_Name",
            "Adm_School_M_Academic_Year"."ASMAY_Year",
            "FeeTermsDueDates"."DueDate",
            "FeeTermsDueDates"."On_Date"
        HAVING SUM("fee_student_status"."FSS_ToBePaid") > 0
    ) AS NEW;
    
    RETURN;
END;
$$;