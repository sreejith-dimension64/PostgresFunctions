CREATE OR REPLACE FUNCTION "dbo"."defaulters_reportTEMP"(
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
RETURNS TABLE(result_data TEXT) AS $$
DECLARE
    v_temp1 VARCHAR(200);
    v_temp2 VARCHAR(200);
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
    v_oResult VARCHAR(50);
    v_days TEXT;
    v_months TEXT;
    v_query TEXT;
    v_str1 TEXT;
    v_str2 TEXT;
    v_mi_new TEXT;
    v_routeids TEXT;
    v_asmay_new TEXT;
    v_ids BIGINT;
    v_trid TEXT;
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
            v_trid := '';
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
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = TRUE) and ("Adm_M_Student"."AMST_SOL" = ''S'') and ("Adm_M_Student"."AMST_ActiveFlag" = TRUE)';
        ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = TRUE) and ("Adm_M_Student"."AMST_SOL" = ''D'') and ("Adm_M_Student"."AMST_ActiveFlag" = TRUE)';
        ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = FALSE) and ("Adm_M_Student"."AMST_SOL" = ''L'') and ("Adm_M_Student"."AMST_ActiveFlag" = FALSE)';
        ELSIF p_active = '1' AND p_deactive = '1' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = TRUE) and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" = TRUE)';
        ELSIF p_left = '1' AND p_active = '1' AND p_deactive = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (FALSE,TRUE)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(FALSE,TRUE))';
        ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '1' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (FALSE,TRUE)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(FALSE,TRUE))';
        ELSIF p_left = '0' AND p_active = '1' AND p_deactive = '1' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (TRUE)) and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(TRUE))';
        ELSIF p_active = '1' AND p_deactive = '1' AND p_left = '1' THEN
            v_amst_sol := 'and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'',''L'')) ';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id" = ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0)';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ';
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id = '0') THEN
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0) ';
        ELSIF (p_fmg_id = '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id" = ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ';
            END IF;
        ELSE
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id" = ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id = '0') THEN
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
        ELSIF (p_fmg_id = '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id" = ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSE
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol || ' ';
        END IF;

        IF p_type = 'year' THEN
            IF p_option = 'FSW' THEN
                IF p_busroute = '0' THEN
                    v_query := 'Query construction completed for FSW year option without bus route';
                ELSE
                    v_query := 'Query construction completed for FSW year option with bus route';
                END IF;
            ELSIF p_option = 'FIW' THEN
                v_query := 'Query construction completed for FIW year option';
            ELSIF p_option = 'FGW' THEN
                v_query := 'Query construction completed for FGW year option';
            ELSIF p_option = 'FHW' THEN
                v_query := 'Query construction completed for FHW year option';
            ELSIF p_option = 'FCW' THEN
                v_query := 'Query construction completed for FCW year option';
            END IF;
        ELSE
            DELETE FROM "V_DueDate";
            
            IF p_option = 'FGW' THEN
                v_query := 'Query construction completed for FGW date option';
            ELSIF p_option = 'FHW' THEN
                v_query := 'Query construction completed for FHW date option';
            ELSIF p_option = 'FSW' THEN
                v_query := 'Query construction completed for FSW date option';
            ELSIF p_option = 'FIW' THEN
                v_query := 'Query construction completed for FIW date option';
            ELSIF p_option = 'FCW' THEN
                v_query := 'Query construction completed for FCW date option';
            END IF;
        END IF;

        RAISE NOTICE '%', v_query;

    ELSIF p_StdType = 'Staff' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    ELSIF p_StdType = 'others' THEN
        PERFORM "StaffwiseDefaulters"(p_ASMAY_Id, p_grpid, p_fmg_id, p_option, p_StdType, p_type, p_date1, p_due);
    END IF;

    RETURN QUERY SELECT v_query::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        RETURN QUERY SELECT ('Error: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;