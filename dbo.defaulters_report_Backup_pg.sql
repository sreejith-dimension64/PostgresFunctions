CREATE OR REPLACE FUNCTION "dbo"."defaulters_report_Backup"(
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
    p_StdType TEXT,
    p_busroute TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "totalbalance" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" TEXT,
    "ClassSection" TEXT,
    "AMST_MobileNo" BIGINT,
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
    v_routeids TEXT;
    v_Dynamic1 TEXT;
    v_Dynamic2 TEXT;
    v_Dynamic3 TEXT;
    v_Fineamt FLOAT;
    v_flgarr1 INT;
    v_FMA_Id_F BIGINT;
    v_Duedate_fine DATE;
    v_flgarr INT;
    v_amt FLOAT;
    v_AMST_Id_F BIGINT;
    v_Fcount BIGINT;
    v_DueDate_N DATE;
    v_FAMST_Id BIGINT;
    v_Ftotalbalance BIGINT;
    v_FStudentName TEXT;
    v_FAMST_AdmNo TEXT;
    v_FClassSection TEXT;
    v_FAMST_MobileNo BIGINT;
    v_FAMST_FatherName TEXT;
    v_FASMCL_Order INT;
    v_FAMST_emailId TEXT;
    v_FFineAmount DECIMAL(18,2);
    v_sqldynamic TEXT;
    v_asmay_new TEXT;
    v_ids BIGINT;
    v_trid TEXT;
    v_ondate DATE;
    v_Frncount INT;
    v_Frncount1 INT;
    v_Fmtids TEXT;
    v_Sqldynamic_Terms TEXT;
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
    v_routeids := '0';
    v_ids := 0;

    IF p_StdType = 'Student' THEN

        SELECT "MI_Id" INTO v_mi FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = p_ASMAY_ID::BIGINT;

        IF p_trmr_id = '0' THEN
            FOR rec IN 
                SELECT "TRMR_Id" FROM "trn"."TR_Master_Route" 
                WHERE "mi_id" = v_mi::BIGINT AND "TRMR_ActiveFlg" = TRUE
            LOOP
                IF v_ids = 0 THEN
                    v_trid := rec."TRMR_Id"::TEXT;
                    v_ids := v_ids + 1;
                ELSE
                    v_trid := v_trid || ',' || rec."TRMR_Id"::TEXT;
                END IF;
            END LOOP;
        ELSE
            v_trid := p_trmr_id;
        END IF;

        IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
        ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
        ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0)and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
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
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id::BIGINT = 0) THEN
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
        ELSIF (p_fmg_id = '') AND (p_amsc_id::BIGINT != 0) THEN
            IF p_section::BIGINT != 0 THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
            END IF;
        ELSE
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || '';
        END IF;

        IF p_type = 'year' THEN
            IF p_option = 'FSW' THEN
                RETURN QUERY EXECUTE 'SELECT * FROM final_result_temp';
            ELSIF p_option = 'FIW' THEN
                RETURN QUERY EXECUTE 'SELECT * FROM final_result_temp';
            ELSIF p_option = 'FGW' THEN
                RETURN QUERY EXECUTE 'SELECT * FROM final_result_temp';
            ELSIF p_option = 'FHW' THEN
                RETURN QUERY EXECUTE 'SELECT * FROM final_result_temp';
            ELSIF p_option = 'FCW' THEN
                RETURN QUERY EXECUTE 'SELECT * FROM final_result_temp';
            END IF;
        END IF;

    ELSIF p_StdType = 'Staff' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    ELSIF p_StdType = 'others' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    END IF;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN;
END;
$$;