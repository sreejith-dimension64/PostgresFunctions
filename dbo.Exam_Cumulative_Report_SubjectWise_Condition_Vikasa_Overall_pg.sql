CREATE OR REPLACE FUNCTION "dbo"."Exam_Cumulative_Report_SubjectWise_Condition_Vikasa_Overall"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT, 
    p_ASMCL_Id TEXT, 
    p_ASMS_Id TEXT, 
    p_ISMS_Id TEXT, 
    p_EMGR_Id TEXT
)
RETURNS TABLE (
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
    v_EMPSG_GroupName1 TEXT;
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
    v_overalltotal NUMERIC(10,2);
    v_script1 TEXT;
    v_scripttotal TEXT;
    v_scriptgrade TEXT;
    v_scriptremarks TEXT;
    v_total TEXT;
    v_scriptupdate TEXT;
    v_seyquery TEXT;
    v_vsql TEXT;
    v_Newvalue TEXT;
    v_Newvalue1 TEXT;
    v_scriptupdateper1 TEXT;
    v_scriptupdateper TEXT;
    v_scriptupdateper_total TEXT;
    rec_display_name RECORD;
    rec_student RECORD;
    rec_display_name1 RECORD;
    rec_exam_name1 RECORD;
    rec_cursor RECORD;
BEGIN
    v_overalltotal := 0.00;

    DROP TABLE IF EXISTS "temp_vikasa_exam_overall";
    
    CREATE TEMP TABLE "temp_vikasa_exam_overall" (
        "MI_id" TEXT,
        "Amst_id" TEXT,
        "Admno" TEXT,
        "Studentname" TEXT
    );

    SELECT DISTINCT a."EMCA_Id" INTO v_EMCA_Id
    FROM "exm"."Exm_Master_Category" a 
    INNER JOIN "exm"."Exm_Category_Class" b ON a."EMCA_Id" = b."EMCA_Id" 
    WHERE b."ASMAY_Id" = p_ASMAY_Id 
        AND b."ASMCL_Id" = p_ASMCL_Id 
        AND b."ASMS_Id" = p_ASMS_Id 
        AND "ECAC_ActiveFlag" = 1 
        AND a."MI_Id" = p_MI_Id 
        AND b."MI_Id" = p_MI_Id;

    SELECT "EYC_Id" INTO v_eyc_id
    FROM "exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = p_ASMAY_Id 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1 
        AND "MI_Id" = p_MI_Id;

    FOR rec_display_name IN
        SELECT DISTINCT "EMPSG_DisplayName", c."EMPSG_Id", c."EMPSG_PercentValue", "EMPSG_GroupName"
        FROM "exm"."Exm_M_Promotion" a 
        INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
        INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
        WHERE a."EYC_Id" = v_eyc_id 
            AND "EMP_ActiveFlag" = 1 
            AND "ISMS_Id" = p_ISMS_Id
        ORDER BY "EMPSG_GroupName"
    LOOP
        v_EMPSG_DisplayName := rec_display_name."EMPSG_DisplayName";
        v_EMPSG_Id := rec_display_name."EMPSG_Id";
        v_EMPSG_PercentValue := rec_display_name."EMPSG_PercentValue";
        v_EMPSG_GroupName := rec_display_name."EMPSG_GroupName";
        
        v_script1 := 'ALTER TABLE "temp_vikasa_exam_overall" ADD COLUMN "' || v_EMPSG_DisplayName || '" TEXT, ADD COLUMN "' || v_EMPSG_DisplayName || '(' || v_EMPSG_PercentValue || '%)" TEXT';
        EXECUTE v_script1;
    END LOOP;

    v_total := 'Total(100%)';
    v_scripttotal := 'ALTER TABLE "temp_vikasa_exam_overall" ADD COLUMN "' || v_total || '" TEXT';
    EXECUTE v_scripttotal;

    v_scriptgrade := 'ALTER TABLE "temp_vikasa_exam_overall" ADD COLUMN "Grade" TEXT';
    EXECUTE v_scriptgrade;

    v_scriptremarks := 'ALTER TABLE "temp_vikasa_exam_overall" ADD COLUMN "Remarks" TEXT';
    EXECUTE v_scriptremarks;

    FOR rec_student IN
        SELECT a."AMST_AdmNo" AS "Admno", 
               (COALESCE(a."amst_firstname", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."amst_lastname", '')) AS "Student Name",
               a."amst_id"
        FROM "Adm_M_Student" a 
        INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id"
        INNER JOIN "adm_school_M_class" c ON c."asmcl_id" = b."asmcl_id"
        INNER JOIN "adm_school_M_section" d ON d."asms_id" = b."asms_id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."asmay_id" = b."asmay_id"
        WHERE a."mi_id" = p_mi_id 
            AND b."asmay_id" = p_asmay_id 
            AND b."asmcl_id" = p_asmcl_id 
            AND b."asms_id" = p_asms_id 
            AND "amst_sol" = 'S' 
            AND "amst_activeflag" = 1 
            AND "AMAY_ActiveFlag" = 1 
        ORDER BY "Student Name"
    LOOP
        v_amst_admno := rec_student."Admno";
        v_studentname := rec_student."Student Name";
        v_amst_id := rec_student."amst_id";
        
        v_overalltotal := 0.00;

        INSERT INTO "temp_vikasa_exam_overall" ("MI_id", "Amst_id", "Admno", "Studentname")
        VALUES (p_MI_Id, v_amst_id, v_amst_admno, v_studentname);

        FOR rec_display_name1 IN
            SELECT DISTINCT "EMPSG_DisplayName", c."EMPSG_Id", c."EMPSG_PercentValue", "EMPSG_GroupName"
            FROM "exm"."Exm_M_Promotion" a 
            INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
            INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
            WHERE a."EYC_Id" = v_eyc_id 
                AND "EMP_ActiveFlag" = 1 
                AND "ISMS_Id" = p_ISMS_Id
        LOOP
            v_EMPSG_DisplayName1 := rec_display_name1."EMPSG_DisplayName";
            v_EMPSG_Id1 := rec_display_name1."EMPSG_Id";
            v_EMPSG_PercentValue1 := rec_display_name1."EMPSG_PercentValue";
            v_EMPSG_GroupName1 := rec_display_name1."EMPSG_GroupName";
            
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
                WHERE a."EYC_Id" = v_eyc_id 
                    AND "EMP_ActiveFlag" = 1 
                    AND "ISMS_Id" = p_ISMS_Id 
                    AND c."EMPSG_Id" = v_EMPSG_Id1 
                ORDER BY "EME_ExamOrder"
            LOOP
                v_eme_id1 := rec_exam_name1."EME_Id";
                v_eme_name1 := rec_exam_name1."EME_ExamName";
                v_eme_order1 := rec_exam_name1."EME_ExamOrder";
                
                v_multipleexam := COALESCE(v_multipleexam, '') || COALESCE(v_eme_id1 || ', ', '');

                SELECT "ESTMPS_PassFailFlg", "ESTMPS_ObtainedMarks" INTO v_flag, v_obtainedmarks
                FROM "exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "mi_id" = p_mi_id 
                    AND "asmay_id" = p_asmay_id 
                    AND "asmcl_id" = p_asmcl_id 
                    AND "Asms_id" = p_asms_id 
                    AND "amst_id" = v_amst_id 
                    AND "isms_id" = p_isms_id 
                    AND "eme_id" = v_eme_id1;

                IF FOUND THEN
                    IF v_flag = 'OD' THEN
                        v_obtainedmarks := 'OD';
                    ELSIF v_flag = 'AB' THEN
                        v_obtainedmarks := 'AB';
                    END IF;
                ELSE
                    v_obtainedmarks := '';
                END IF;
            END LOOP;

            v_multipleexam := LEFT(v_multipleexam, LENGTH(v_multipleexam) - 1);

            v_seyquery := 'SELECT CAST(SUM("ESTMPS_ObtainedMarks") AS TEXT), CAST((SUM("ESTMPS_ObtainedMarks")/SUM("ESTMPS_MaxMarks") * ' || v_EMPSG_PercentValue1 || ') AS TEXT) FROM "exm"."Exm_Student_Marks_Process_Subjectwise" WHERE "mi_id" = ''' || p_mi_id || ''' AND "asmay_id" = ''' || p_asmay_id || ''' AND "asmcl_id" = ''' || p_asmcl_id || ''' AND "Asms_id" = ''' || p_asms_id || ''' AND "amst_id" = ''' || v_amst_id || ''' AND "isms_id" = ''' || p_isms_id || ''' AND "eme_id" IN (' || v_multipleexam || ') AND "ESTMPS_PassFailFlg" != ''OD''';

            FOR rec_cursor IN EXECUTE v_seyquery
            LOOP
                v_Newvalue1 := rec_cursor.sum;
                v_Newvalue := rec_cursor.numeric;

                IF v_Newvalue IS NULL OR v_Newvalue = '' THEN
                    v_Newvalue := '';
                    v_Newvalue1 := '';
                    v_overalltotal := v_overalltotal + 0.00;

                    v_scriptupdateper1 := 'UPDATE "temp_vikasa_exam_overall" SET "' || v_EMPSG_DisplayName1 || '" = ' || COALESCE('''' || v_Newvalue1 || '''', 'NULL') || ', "' || v_EMPSG_DisplayName1 || '(' || v_EMPSG_PercentValue1 || '%)" = ' || COALESCE('''' || v_Newvalue || '''', 'NULL') || ' WHERE "Amst_id" = ''' || v_amst_id || ''' AND "MI_id" = ''' || p_MI_Id || '''';
                    EXECUTE v_scriptupdateper1;
                ELSE
                    v_Newvalue := CAST(ROUND(CAST(v_Newvalue AS NUMERIC), 2) AS TEXT);
                    v_overalltotal := v_overalltotal + CAST(v_Newvalue AS NUMERIC(10,2));

                    v_scriptupdateper := 'UPDATE "temp_vikasa_exam_overall" SET "' || v_EMPSG_DisplayName1 || '" = ' || COALESCE('''' || v_Newvalue1 || '''', 'NULL') || ', "' || v_EMPSG_DisplayName1 || '(' || v_EMPSG_PercentValue1 || '%)" = ' || COALESCE('''' || v_Newvalue || '''', 'NULL') || ' WHERE "Amst_id" = ''' || v_amst_id || ''' AND "MI_id" = ''' || p_MI_Id || '''';
                    EXECUTE v_scriptupdateper;
                END IF;
            END LOOP;
        END LOOP;

        SELECT b."EMGD_Name" INTO v_gradename
        FROM "exm"."Exm_Master_Grade" a 
        INNER JOIN "exm"."Exm_Master_Grade_Details" b ON a."EMGR_Id" = b."EMGR_Id" 
        WHERE "MI_Id" = p_MI_Id 
            AND b."EMGR_Id" = p_EMGR_Id 
            AND v_overalltotal BETWEEN b."EMGD_From" AND b."EMGD_To";

        v_scriptupdateper_total := 'UPDATE "temp_vikasa_exam_overall" SET "' || v_total || '" = ''' || CAST(v_overalltotal AS TEXT) || ''', "Grade" = ''' || COALESCE(v_gradename, '') || ''', "Remarks" = '''' WHERE "Amst_id" = ''' || v_amst_id || ''' AND "MI_id" = ''' || p_MI_Id || '''';
        EXECUTE v_scriptupdateper_total;
    END LOOP;

    RETURN QUERY SELECT * FROM "temp_vikasa_exam_overall";
END;
$$;