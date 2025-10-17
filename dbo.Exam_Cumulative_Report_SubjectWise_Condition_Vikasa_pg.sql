CREATE OR REPLACE FUNCTION "dbo"."Exam_Cumulative_Report_SubjectWise_Condition_Vikasa"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT, 
    p_ASMCL_Id TEXT, 
    p_ASMS_Id TEXT, 
    p_ISMS_Id TEXT, 
    p_EMGR_Id TEXT
)
RETURNS TABLE(
    "MI_id" TEXT,
    "Amst_id" TEXT,
    "Admno" TEXT,
    "Studentname" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_eyc_id TEXT;
    v_EMCA_Id TEXT;
    v_EMPSG_DisplayName TEXT;
    v_EMPSG_Id TEXT;
    v_EMPSG_PercentValue TEXT;
    v_EMPSG_GroupName TEXT;
    v_eme_id TEXT;
    v_eme_name TEXT;
    v_eme_order TEXT;
    v_EMPSG_DisplayName1 TEXT;
    v_EMPSG_Id1 TEXT;
    v_EMPSG_PercentValue1 TEXT;
    v_EMPSG_DisplayName_per TEXT;
    v_EMPSG_Id_per TEXT;
    v_EMPSG_PercentValue_per TEXT;
    v_eme_id1 TEXT;
    v_eme_name1 TEXT;
    v_eme_order1 TEXT;
    v_amst_admno TEXT;
    v_studentname TEXT;
    v_amst_id TEXT;
    v_obtainedmarks TEXT;
    v_flag TEXT;
    v_obtainedmarksper TEXT;
    v_multipleexam TEXT;
    v_gradename TEXT;
    v_overalltotal DECIMAL(10,2);
    v_script TEXT;
    v_script1 TEXT;
    v_scripttotal TEXT;
    v_scriptgrade TEXT;
    v_total TEXT;
    v_scriptupdate TEXT;
    v_scriptupdate1 TEXT;
    v_seyquery TEXT;
    v_vsql TEXT;
    v_Newvalue TEXT;
    v_scriptupdateper1 TEXT;
    v_scriptupdateper TEXT;
    v_scriptupdateper_total TEXT;
    rec_display_name RECORD;
    rec_exam_name RECORD;
    rec_student_details RECORD;
    rec_display_name1 RECORD;
    rec_exam_name1 RECORD;
    v_rowcount INTEGER;
BEGIN
    v_overalltotal := 0.00;

    DROP TABLE IF EXISTS temp_vikasa_exam;
    
    CREATE TEMP TABLE temp_vikasa_exam (
        "MI_id" TEXT,
        "Amst_id" TEXT,
        "Admno" TEXT,
        "Studentname" TEXT
    );

    SELECT DISTINCT a."EMCA_Id" INTO v_EMCA_Id
    FROM "exm"."Exm_Master_Category" a 
    INNER JOIN "exm"."Exm_Category_Class" b ON a."EMCA_Id" = b."EMCA_Id" 
    WHERE b."ASMAY_Id" = p_ASMAY_Id::INTEGER 
        AND b."ASMCL_Id" = p_ASMCL_Id::INTEGER 
        AND b."ASMS_Id" = p_ASMS_Id::INTEGER 
        AND "ECAC_ActiveFlag" = 1 
        AND a."MI_Id" = p_MI_Id::INTEGER 
        AND b."MI_Id" = p_MI_Id::INTEGER;

    SELECT "EYC_Id" INTO v_eyc_id
    FROM "exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = p_ASMAY_Id::INTEGER 
        AND "EMCA_Id" = v_EMCA_Id::INTEGER 
        AND "EYC_ActiveFlg" = 1 
        AND "MI_Id" = p_MI_Id::INTEGER;

    FOR rec_display_name IN 
        SELECT DISTINCT "EMPSG_DisplayName", c."EMPSG_Id", c."EMPSG_PercentValue", c."EMPSG_GroupName" 
        FROM "exm"."Exm_M_Promotion" a 
        INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
        INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
        WHERE a."EYC_Id" = v_eyc_id::INTEGER 
            AND "EMP_ActiveFlag" = 1 
            AND "ISMS_Id" = p_ISMS_Id::INTEGER
        ORDER BY c."EMPSG_GroupName"
    LOOP
        v_EMPSG_DisplayName := rec_display_name."EMPSG_DisplayName";
        v_EMPSG_Id := rec_display_name."EMPSG_Id"::TEXT;
        v_EMPSG_PercentValue := rec_display_name."EMPSG_PercentValue"::TEXT;
        v_EMPSG_GroupName := rec_display_name."EMPSG_GroupName";

        FOR rec_exam_name IN 
            SELECT DISTINCT d."EME_Id", "EME_ExamName", "EME_ExamOrder" 
            FROM "exm"."Exm_M_Promotion" a 
            INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = d."EME_Id"
            INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
            WHERE a."EYC_Id" = v_eyc_id::INTEGER 
                AND "EMP_ActiveFlag" = 1 
                AND "ISMS_Id" = p_ISMS_Id::INTEGER 
                AND c."EMPSG_Id" = v_EMPSG_Id::INTEGER 
            ORDER BY "EME_ExamOrder"
        LOOP
            v_eme_id := rec_exam_name."EME_Id"::TEXT;
            v_eme_name := rec_exam_name."EME_ExamName";
            v_eme_order := rec_exam_name."EME_ExamOrder"::TEXT;
            
            v_script := 'ALTER TABLE temp_vikasa_exam ADD COLUMN "' || v_eme_name || '" TEXT';
            EXECUTE v_script;
        END LOOP;

        v_script1 := 'ALTER TABLE temp_vikasa_exam ADD COLUMN "' || v_EMPSG_DisplayName || '(' || v_EMPSG_PercentValue || '%)" TEXT';
        EXECUTE v_script1;
    END LOOP;

    v_total := 'Total(100%)';
    v_scripttotal := 'ALTER TABLE temp_vikasa_exam ADD COLUMN "' || v_total || '" TEXT';
    EXECUTE v_scripttotal;

    v_scriptgrade := 'ALTER TABLE temp_vikasa_exam ADD COLUMN "Grade" TEXT';
    EXECUTE v_scriptgrade;

    FOR rec_student_details IN 
        SELECT a."AMST_AdmNo" AS "Admno", 
               (COALESCE(a."amst_firstname", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."amst_lastname", '')) AS "Student Name",
               a."amst_id"
        FROM "Adm_M_Student" a 
        INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id"
        INNER JOIN "adm_school_M_class" c ON c."asmcl_id" = b."asmcl_id" 
        INNER JOIN "adm_school_M_section" d ON d."asms_id" = b."asms_id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."asmay_id" = b."asmay_id"
        INNER JOIN "Exm"."Exm_Studentwise_Subjects" f ON f."AMST_Id" = b."AMST_Id" 
            AND f."ASMAY_Id" = e."ASMAY_Id" 
            AND f."ASMCL_Id" = c."ASMCL_Id" 
            AND f."ASMS_Id" = d."ASMS_Id" 
            AND f."ESTSU_ActiveFlg" = 1
        INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = f."ISMS_Id" AND g."ISMS_ActiveFlag" = 1
        WHERE a."mi_id" = p_mi_id::INTEGER 
            AND b."asmay_id" = p_asmay_id::INTEGER 
            AND b."asmcl_id" = p_asmcl_id::INTEGER 
            AND b."asms_id" = p_asms_id::INTEGER 
            AND f."asmay_id" = p_asmay_id::INTEGER 
            AND f."asmcl_id" = p_asmcl_id::INTEGER 
            AND f."asms_id" = p_asms_id::INTEGER 
            AND "amst_sol" = 'S' 
            AND "amst_activeflag" = 1 
            AND "AMAY_ActiveFlag" = 1 
            AND f."ISMS_Id" = p_ISMS_Id::INTEGER
        ORDER BY "Student Name"
    LOOP
        v_amst_admno := rec_student_details."Admno";
        v_studentname := rec_student_details."Student Name";
        v_amst_id := rec_student_details."amst_id"::TEXT;
        
        v_overalltotal := 0.00;

        INSERT INTO temp_vikasa_exam ("MI_id", "Amst_id", "Admno", "Studentname")
        VALUES (p_MI_Id, v_amst_id, v_amst_admno, v_studentname);

        FOR rec_display_name1 IN 
            SELECT DISTINCT "EMPSG_DisplayName", c."EMPSG_Id", c."EMPSG_PercentValue"
            FROM "exm"."Exm_M_Promotion" a 
            INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
            INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
            WHERE a."EYC_Id" = v_eyc_id::INTEGER 
                AND "EMP_ActiveFlag" = 1 
                AND "ISMS_Id" = p_ISMS_Id::INTEGER
        LOOP
            v_EMPSG_DisplayName1 := rec_display_name1."EMPSG_DisplayName";
            v_EMPSG_Id1 := rec_display_name1."EMPSG_Id"::TEXT;
            v_EMPSG_PercentValue1 := rec_display_name1."EMPSG_PercentValue"::TEXT;

            v_multipleexam := '';

            FOR rec_exam_name1 IN 
                SELECT DISTINCT d."EME_Id", "EME_ExamName", "EME_ExamOrder" 
                FROM "exm"."Exm_M_Promotion" a 
                INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
                INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
                INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
                INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
                INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = d."EME_Id"
                INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
                WHERE a."EYC_Id" = v_eyc_id::INTEGER 
                    AND "EMP_ActiveFlag" = 1 
                    AND "ISMS_Id" = p_ISMS_Id::INTEGER 
                    AND c."EMPSG_Id" = v_EMPSG_Id1::INTEGER 
                ORDER BY "EME_ExamOrder"
            LOOP
                v_eme_id1 := rec_exam_name1."EME_Id"::TEXT;
                v_eme_name1 := rec_exam_name1."EME_ExamName";
                v_eme_order1 := rec_exam_name1."EME_ExamOrder"::TEXT;

                v_multipleexam := COALESCE(v_multipleexam, '') || COALESCE(v_eme_id1 || ', ', '');

                SELECT "ESTMPS_PassFailFlg", "ESTMPS_ObtainedMarks"::TEXT 
                INTO v_flag, v_obtainedmarks
                FROM "exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "mi_id" = p_mi_id::INTEGER 
                    AND "asmay_id" = p_asmay_id::INTEGER 
                    AND "asmcl_id" = p_asmcl_id::INTEGER 
                    AND "Asms_id" = p_asms_id::INTEGER 
                    AND "amst_id" = v_amst_id::INTEGER 
                    AND "isms_id" = p_isms_id::INTEGER 
                    AND "eme_id" = v_eme_id1::INTEGER;

                GET DIAGNOSTICS v_rowcount = ROW_COUNT;

                IF v_rowcount > 0 THEN
                    IF v_flag = 'OD' THEN
                        v_obtainedmarks := 'OD';
                    ELSIF v_flag = 'AB' THEN
                        v_obtainedmarks := 'AB';
                    END IF;

                    v_scriptupdate := 'UPDATE temp_vikasa_exam SET "' || v_eme_name1 || '" = ' || quote_literal(v_obtainedmarks) || 
                                      ' WHERE "Amst_id" = ' || quote_literal(v_amst_id) || ' AND "MI_id" = ' || quote_literal(p_MI_Id);
                    EXECUTE v_scriptupdate;
                ELSE
                    v_obtainedmarks := '';
                    v_scriptupdate1 := 'UPDATE temp_vikasa_exam SET "' || v_eme_name1 || '" = ' || quote_literal(v_obtainedmarks) || 
                                       ' WHERE "Amst_id" = ' || quote_literal(v_amst_id) || ' AND "MI_id" = ' || quote_literal(p_MI_Id);
                    EXECUTE v_scriptupdate1;
                END IF;
            END LOOP;

            v_multipleexam := LEFT(v_multipleexam, LENGTH(v_multipleexam) - 2);

            v_seyquery := 'SELECT (SUM("ESTMPS_ObtainedMarks"::DECIMAL)/SUM("ESTMPS_MaxMarks"::DECIMAL) * ' || v_EMPSG_PercentValue1 || 
                          ') FROM "exm"."Exm_Student_Marks_Process_Subjectwise" WHERE "mi_id" = ' || p_mi_id || 
                          ' AND "asmay_id" = ' || p_asmay_id || ' AND "asmcl_id" = ' || p_asmcl_id || 
                          ' AND "Asms_id" = ' || p_asms_id || ' AND "amst_id" = ' || v_amst_id || 
                          ' AND "isms_id" = ' || p_isms_id || ' AND "eme_id" IN (' || v_multipleexam || 
                          ') AND "ESTMPS_PassFailFlg" != ''OD''';

            BEGIN
                EXECUTE v_seyquery INTO v_Newvalue;
                
                IF v_Newvalue IS NULL OR v_Newvalue = '' THEN
                    v_Newvalue := '';
                    v_overalltotal := v_overalltotal + 0.00;
                    
                    v_scriptupdateper1 := 'UPDATE temp_vikasa_exam SET "' || v_EMPSG_DisplayName1 || '(' || v_EMPSG_PercentValue1 || '%)" = ' || 
                                          quote_literal(v_Newvalue) || ' WHERE "Amst_id" = ' || quote_literal(v_amst_id) || 
                                          ' AND "MI_id" = ' || quote_literal(p_MI_Id);
                    EXECUTE v_scriptupdateper1;
                ELSE
                    v_Newvalue := CAST(ROUND(v_Newvalue::DECIMAL, 2) AS TEXT);
                    v_overalltotal := v_overalltotal + v_Newvalue::DECIMAL(10,2);
                    
                    v_scriptupdateper := 'UPDATE temp_vikasa_exam SET "' || v_EMPSG_DisplayName1 || '(' || v_EMPSG_PercentValue1 || '%)" = ' || 
                                         v_Newvalue || ' WHERE "Amst_id" = ' || quote_literal(v_amst_id) || 
                                         ' AND "MI_id" = ' || quote_literal(p_MI_Id);
                    EXECUTE v_scriptupdateper;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    v_Newvalue := '';
            END;
        END LOOP;

        SELECT b."EMGD_Name" INTO v_gradename
        FROM "exm"."Exm_Master_Grade" a 
        INNER JOIN "exm"."Exm_Master_Grade_Details" b ON a."EMGR_Id" = b."EMGR_Id" 
        WHERE "MI_Id" = p_MI_Id::INTEGER 
            AND b."EMGR_Id" = p_EMGR_Id::INTEGER 
            AND v_overalltotal BETWEEN b."EMGD_From" AND b."EMGD_To";

        v_scriptupdateper_total := 'UPDATE temp_vikasa_exam SET "' || v_total || '" = ' || quote_literal(v_overalltotal::TEXT) || 
                                    ', "Grade" = ' || quote_literal(v_gradename) || ' WHERE "Amst_id" = ' || quote_literal(v_amst_id) || 
                                    ' AND "MI_id" = ' || quote_literal(p_MI_Id);
        EXECUTE v_scriptupdateper_total;
    END LOOP;

    RETURN QUERY SELECT * FROM temp_vikasa_exam;
END;
$$;