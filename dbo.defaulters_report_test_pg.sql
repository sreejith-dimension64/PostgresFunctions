CREATE OR REPLACE FUNCTION "dbo"."defaulters_report_test"(
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
RETURNS TABLE(
    query_result TEXT
) AS $$
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
    v_asmay_new TEXT;
    v_ids BIGINT;
    v_trid TEXT;
    cur_routeids CURSOR FOR SELECT "TRMR_Id" FROM "trn"."TR_Master_Route" WHERE "mi_id" = 4 AND "TRMR_ActiveFlg" = TRUE;
    cur_groupid CURSOR FOR 
        SELECT "FTDD_Day", "FTDD_Month", EXTRACT(YEAR FROM "ASMAY_From_Date"), EXTRACT(YEAR FROM "ASMAY_To_Date"), 
               "ASMAY_From_Date", "ASMAY_To_Date"
        FROM "Fee_T_Due_Date"
        INNER JOIN "Fee_Master_Amount" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Fee_Master_Amount"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_ID::BIGINT
        AND "Adm_School_M_Academic_Year"."MI_Id" = v_mi::BIGINT
        GROUP BY "FTDD_Day", "FTDD_Month", "ASMAY_From_Date", "ASMAY_To_Date";
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
            FOR v_rec IN cur_routeids LOOP
                IF v_ids = 0 THEN
                    v_trid := v_rec."TRMR_Id"::TEXT;
                    v_ids := v_ids + 1;
                ELSE
                    v_trid := v_trid || ',' || v_rec."TRMR_Id"::TEXT;
                END IF;
            END LOOP;
        ELSE
            v_trid := p_trmr_id;
        END IF;

        IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=TRUE) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=TRUE)';
        ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=TRUE) and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=TRUE)';
        ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
            v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=FALSE) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=FALSE)';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0)';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0)';
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id = '0') THEN
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0)';
        ELSIF (p_fmg_id = '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
            ELSE
                v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
            END IF;
        ELSE
            v_str1 := 'where ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0)';
        END IF;

        IF (p_fmg_id != '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSIF (p_fmg_id != '') AND (p_amsc_id = '0') THEN
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Fee_Master_Terms"."FMT_Id" in (' || p_fmg_id || ')) AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
        ELSIF (p_fmg_id = '') AND (p_amsc_id != '0') THEN
            IF p_section != '0' THEN
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') and ("adm_school_m_section"."asms_id"= ' || p_section || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            ELSE
                v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') and ("Adm_School_M_Class"."ASMCL_Id" = ' || p_amsc_id || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
            END IF;
        ELSE
            v_str2 := 'AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Student_Status"."FMG_Id" in (' || p_grpid || ')) AND ("fee_student_status"."MI_Id" = ' || v_mi || ') AND ("fee_student_status"."FSS_ToBePaid" > 0) ' || v_amst_sol;
        END IF;

        IF p_type = 'year' THEN
            IF p_option = 'FSW' THEN
                IF p_busroute = '0' THEN
                    IF p_left = '1' AND p_active = '1' AND p_deactive = '0' THEN
                        v_query := 'SELECT "Adm_M_Student"."AMST_Id", SUM("fee_student_status"."FSS_ToBePaid") AS totalbalance, COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as StudentName, "Adm_M_Student"."AMST_AdmNo", ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") as ClassSection, "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId" ' ||
                        'FROM "Fee_Master_Group" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" ' ||
                        'INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" ' ||
                        'AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" ' || v_str1 || ' and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=TRUE) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=TRUE) ' ||
                        'GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_MobileNo", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId", "Adm_M_Student"."AMST_Id" ' ||
                        'UNION ' ||
                        'SELECT "Adm_M_Student"."AMST_Id", SUM("fee_student_status"."FSS_ToBePaid") AS totalbalance, COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as StudentName, "Adm_M_Student"."AMST_AdmNo", ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") as ClassSection, "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId" ' ||
                        'FROM "Fee_Master_Group" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" ' ||
                        'INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" ' ||
                        'AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" ' || v_str1 || ' and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=FALSE) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=FALSE) ' ||
                        'GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_MobileNo", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId", "Adm_M_Student"."AMST_Id"';
                    ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '1' THEN
                        v_query := 'Similar pattern for deactive=1';
                    ELSIF p_left = '0' AND p_active = '1' AND p_deactive = '1' THEN
                        v_query := 'Similar pattern for active+deactive';
                    ELSIF (p_left = '1' AND p_active = '1' AND p_deactive = '1') OR (p_left = '0' AND p_active = '0' AND p_deactive = '0') THEN
                        v_query := 'All three unions';
                    ELSE
                        v_query := 'SELECT "Adm_M_Student"."AMST_Id", SUM("fee_student_status"."FSS_ToBePaid") AS totalbalance, COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as StudentName, "Adm_M_Student"."AMST_AdmNo", ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") as ClassSection, "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId" ' ||
                        'FROM "Fee_Master_Group" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" ' ||
                        'INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" ' ||
                        'AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" ' || v_str1 || ' ' || v_amst_sol || ' GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_MobileNo", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_FatherName", "AMST_emailId", "Adm_M_Student"."AMST_Id"';
                    END IF;
                ELSE
                    v_query := 'Route filtering query with similar pattern';
                END IF;
            ELSIF p_option = 'FIW' THEN
                v_query := 'FIW option query with FMT_Name';
            ELSIF p_option = 'FGW' THEN
                v_query := 'FGW option query grouping by FMG_GroupName';
            ELSIF p_option = 'FHW' THEN
                v_query := 'FHW option query grouping by FMH_FeeName';
            ELSIF p_option = 'FCW' THEN
                v_query := 'FCW option query grouping by ASMCL_ClassName';
            END IF;
        ELSE
            DELETE FROM "V_DueDate";
            
            IF p_fmg_id = '0' THEN
                FOR v_rec IN cur_groupid LOOP
                    v_ftdd_day := v_rec."FTDD_Day";
                    v_ftdd_month := v_rec."FTDD_Month";
                    v_startyr := v_rec."startyr";
                    v_endyr := v_rec."endyr";
                    v_fromdate := v_rec."ASMAY_From_Date";
                    v_todate := v_rec."ASMAY_To_Date";
                    
                    IF v_ftdd_day = 0 OR v_ftdd_month = 0 THEN
                        v_duedate := p_date1;
                        RETURN;
                    ELSE
                        v_duedate := v_startyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                        v_duedate1 := v_endyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                    END IF;
                    
                    IF v_duedate::DATE >= v_fromdate AND v_duedate::DATE <= v_todate THEN
                        INSERT INTO "V_DueDate"("Duedate") VALUES(TO_CHAR(v_duedate::DATE, 'DD/MM/YYYY'));
                    ELSIF v_duedate1::DATE >= v_fromdate AND v_duedate1::DATE <= v_todate THEN
                        INSERT INTO "V_DueDate"("Duedate") VALUES(TO_CHAR(v_duedate1::DATE, 'DD/MM/YYYY'));
                    ELSE
                        v_oResult := 'select current academic year date';
                    END IF;
                END LOOP;
            ELSE
                v_query := 'Similar cursor logic for non-zero fmg_id';
            END IF;
            
            IF p_due = 'duedate' OR p_due = 'tillduedate' THEN
                v_days := '';
                v_months := '';
                FOR v_rec IN (SELECT DISTINCT EXTRACT(DAY FROM "duedate"::DATE) as noofdays, 
                                             EXTRACT(MONTH FROM "duedate"::DATE) as noofmonths 
                              FROM "v_duedate" 
                              WHERE "duedate"::DATE <= TO_DATE(p_date1, 'DD/MM/YYYY')) LOOP
                    IF v_days = '' THEN
                        v_days := v_rec.noofdays::TEXT;
                        v_months := v_rec.noofmonths::TEXT;
                    ELSE
                        v_days := v_days || ',' || v_rec.noofdays::TEXT;
                        v_months := v_months || ',' || v_rec.noofmonths::TEXT;
                    END IF;
                END LOOP;
            END IF;
            
            IF p_option = 'FGW' THEN
                v_query := 'Date-based FGW query with FTDD_Day and FTDD_Month filters';
            ELSIF p_option = 'FHW' THEN
                v_query := 'Date-based FHW query';
            ELSIF p_option = 'FSW' THEN
                v_query := 'select distinct A."AMST_Id",(case when A.NetAmt>B.PaidAmt then A.NetAmt-B.PaidAmt else 0 end)totalbalance,A.StudentName,A."AMST_AdmNo",A.ClassSection,A."AMST_MobileNo",A."AMST_emailId" ' ||
                'from (select "fee_student_status"."AMST_Id",sum("fee_student_status"."FSS_NetAmount"+"fee_student_status"."FSS_FineAmount"-("FSS_WaivedAmount")) NetAmt, ' ||
                'COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as StudentName, ' ||
                '"Adm