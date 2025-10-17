CREATE OR REPLACE FUNCTION "dbo"."FEE_Balance_Amount_Show_in_portalnotification"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMAY_ID bigint
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "FMH_FeeName" character varying,
    "FMT_Name" character varying,
    "TobePaid" numeric,
    "StudentName" text,
    "AMST_AdmNo" character varying,
    "ASMCL_ClassName" character varying,
    "ASMC_SectionName" character varying,
    "AMST_MobileNo" character varying,
    "AMST_EmailId" character varying,
    "DueDate" date
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TODAY_DATE timestamp;
    v_Dynamic1 text;
    v_Dynamic2 text;
    v_Dynamic3 text;
    v_Fineamt double precision;
    v_flgarr1 integer;
    v_FMA_Id_F bigint;
    v_Duedate_fine date;
    v_flgarr integer;
    v_amt double precision;
    v_AMST_Id_F bigint;
    v_Fcount bigint;
    v_DueDate_N date;
BEGIN
    v_TODAY_DATE := CURRENT_DATE;
    
    PERFORM "dbo"."Fees_TermsDuedates"(p_MI_Id, p_ASMAY_ID, v_TODAY_DATE);
    
    RETURN QUERY
    SELECT * FROM (
        SELECT DISTINCT 
            "fee_student_status"."AMST_Id" AS "AMST_Id",
            "Fee_Master_Head"."FMH_FeeName" AS "FMH_FeeName",
            "Fee_Master_Terms"."FMT_Name" AS "FMT_Name",
            SUM("fee_student_status"."FSS_ToBePaid") AS "TobePaid",
            COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
            COALESCE("Adm_M_Student"."AMST_MiddleName", '') || ' ' || 
            COALESCE("Adm_M_Student"."AMST_LastName", '') AS "StudentName",
            "Adm_M_Student"."AMST_AdmNo" AS "AMST_AdmNo",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "ASMCL_ClassName",
            "Adm_School_M_Section"."ASMC_SectionName" AS "ASMC_SectionName",
            "Adm_M_Student"."AMST_MobileNo" AS "AMST_MobileNo",
            "Adm_M_Student"."AMST_emailId" AS "AMST_EmailId",
            MAX("FeeTermsDueDates"."DueDate") AS "DueDate"
        FROM "fee_student_status"
        INNER JOIN "dbo"."Fee_Master_Group" 
            ON "fee_student_status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" 
            ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = p_MI_Id
        INNER JOIN "Fee_Master_Head" 
            ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
            AND "Fee_Master_Head"."MI_Id" = p_MI_Id
        INNER JOIN "Fee_Master_Terms" 
            ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
            AND "Fee_Master_Terms"."FMT_ActiveFlag" = 1 
            AND "Fee_Master_Terms"."MI_Id" = p_MI_Id
        INNER JOIN "Adm_School_Y_Student" 
            ON "Adm_School_Y_Student"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
            AND "Adm_School_Y_Student"."AMST_Id" = "fee_student_status"."AMST_Id"
        INNER JOIN "Adm_M_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" 
            ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" 
            ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" 
            ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id"
        INNER JOIN "FeeTermsDueDates" 
            ON "FeeTermsDueDates"."FMT_Id" = "Fee_Master_Terms"."FMT_Id" 
            AND CURRENT_DATE > "FeeTermsDueDates"."DueDate"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_ID
            AND "fee_student_status"."ASMAY_Id" = p_ASMAY_ID
            AND "fee_student_status"."MI_Id" = p_MI_Id
            AND "Adm_School_M_Class"."ASMCL_Id" = p_ASMCL_Id
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_ID
            AND "fee_student_status"."FSS_ToBePaid" != 0
            AND "fee_student_status"."AMST_Id" = p_AMST_Id
        GROUP BY 
            "fee_student_status"."AMST_Id",
            "Adm_M_Student"."AMST_FirstName",
            "Adm_M_Student"."AMST_MiddleName",
            "Adm_M_Student"."AMST_LastName",
            "Adm_M_Student"."AMST_AdmNo",
            "Adm_School_M_Class"."ASMCL_ClassName",
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_M_Student"."AMST_MobileNo",
            "Adm_M_Student"."AMST_emailId",
            "Fee_Master_Head"."FMH_FeeName",
            "Fee_Master_Terms"."FMT_Name"
        HAVING SUM("fee_student_status"."FSS_ToBePaid") > 0
        ORDER BY "ASMCL_ClassName"
        LIMIT 100
    ) AS "NEW";
    
    RETURN;
END;
$$;