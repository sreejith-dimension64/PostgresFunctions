CREATE OR REPLACE FUNCTION "dbo"."defaulters_report_old"(
    p_fmg_id TEXT,
    p_ASMAY_ID TEXT,
    p_amsc_id TEXT,
    p_type TEXT,
    p_option TEXT,
    p_date1 TEXT,
    p_due TEXT,
    p_section TEXT,
    p_userid TEXT,
    p_grpid TEXT,
    p_trmr_id TEXT,
    p_active TEXT,
    p_deactive TEXT,
    p_left TEXT,
    p_StdType TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    totalbalance NUMERIC,
    "StudentName" TEXT,
    "AMST_AdmNo" TEXT,
    "ClassSection" TEXT,
    "AMST_MobileNo" TEXT,
    "AMST_FatherName" TEXT,
    "AMST_emailId" TEXT,
    "FMT_Name" TEXT,
    "FMG_GroupName" TEXT,
    "FMH_FeeName" TEXT,
    "ASMCL_ClassName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_temp1 TEXT;
    v_temp2 TEXT;
    v_fmg_id_new BIGINT;
    v_amst_sol TEXT;
    v_mi TEXT;
    v_dt BIGINT;
    v_mt BIGINT;
    v_ftdd_day BIGINT;
    v_ftdd_month BIGINT;
    v_endyr BIGINT;
    v_startyr BIGINT;
    v_duedate TEXT;
    v_duedate1 TEXT;
    v_fromdate DATE;
    v_todate DATE;
    v_oResult TEXT;
    v_days TEXT;
    v_months TEXT;
    v_query TEXT;
    v_str1 TEXT;
    v_str2 TEXT;
    v_mi_new TEXT;
    v_asmay_new TEXT;
    rec RECORD;
BEGIN
    v_amst_sol := '';
    v_mi := '0';
    v_ftdd_day := 0;
    v_ftdd_month := 0;
    v_endyr := 0;
    v_startyr := 0;
    v_days := '0';
    v_months := '0';
    v_dt := 0;
    v_mt := 0;

    IF p_StdType = 'Student' THEN
        SELECT "MI_Id" INTO v_mi FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=true) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=true)';
        ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=true) and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=true)';
        ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=false) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=false)';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id::BIGINT != 0) THEN
            IF p_section::BIGINT != 0 THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0)';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0)';
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id::BIGINT = 0) THEN
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0)';
        ELSIF (p_fmg_id = '') AND (p_amsc_id::BIGINT != 0) THEN
            IF p_section::BIGINT != 0 THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
            END IF;
        ELSE
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id::BIGINT != 0) THEN
            IF p_section::BIGINT != 0 THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id::BIGINT = 0) THEN
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
        ELSIF (p_fmg_id = '') AND (p_amsc_id::BIGINT != 0) THEN
            IF p_section::BIGINT != 0 THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSE
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
        END IF;

        IF p_type = 'year' THEN
            IF p_option = 'FSW' THEN
                IF p_trmr_id = '0' THEN
                    v_query := 'SELECT "Adm_M_Student"."AMST_Id", SUM("fee_student_status"."FSS_ToBePaid") AS totalbalance, COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "StudentName", "Adm_M_Student"."AMST_AdmNo", ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") as "ClassSection", "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId", NULL::TEXT as "FMT_Name", NULL::TEXT as "FMG_GroupName", NULL::TEXT as "FMH_FeeName", NULL::TEXT as "ASMCL_ClassName" FROM "Fee_Master_Group" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" ' || v_str1 || ' ' || v_amst_sol || ' GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_MobileNo", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId", "Adm_M_Student"."AMST_Id"';
                END IF;
            END IF;
        END IF;

        RETURN QUERY EXECUTE v_query;

    ELSIF p_StdType = 'Staff' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    ELSIF p_StdType = 'others' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    END IF;

END;
$$;