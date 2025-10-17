CREATE OR REPLACE FUNCTION "dbo"."Exm_Marks_Entry_Marks_Popup"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_EME_Id TEXT
)
RETURNS TABLE(
    "MI_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "SubjectOrder" INTEGER,
    "Employename" TEXT,
    "SourceMarksEntryFlag" INTEGER,
    "SourceMarksColorFlag" TEXT,
    "SourceMarksEntry" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMCA_Id TEXT;
    v_EYC_Id TEXT;
    v_ISMS_Id TEXT;
    v_ISMS_SubjectName TEXT;
    v_ISMS_order INTEGER;
    v_ASMCL_ClassName TEXT;
    v_ASMC_SectionName TEXT;
    v_ASMC_SectionOrder INTEGER;
    v_rowcount BIGINT;
    v_student_rowcount BIGINT;
    v_enteryflag INTEGER;
    v_employeename TEXT;
    v_SourceMarksEntry TEXT;
    v_enteryflag_color TEXT;
    v_ASMS_Id_New TEXT;
    rec_subject RECORD;
    rec_section RECORD;
BEGIN
    DROP TABLE IF EXISTS "Marks_Entry_Report";
    
    CREATE TEMP TABLE "Marks_Entry_Report" (
        "MI_Id" TEXT,
        "ASMCL_Id" TEXT,
        "ASMS_Id" TEXT,
        "ASMCL_ClassName" TEXT,
        "ASMC_SectionName" TEXT,
        "ISMS_Id" BIGINT,
        "ISMS_SubjectName" TEXT,
        "SubjectOrder" INTEGER,
        "Employename" TEXT,
        "SourceMarksEntryFlag" INTEGER,
        "SourceMarksColorFlag" TEXT,
        "SourceMarksEntry" TEXT
    );
    
    IF p_ASMS_Id > '0' THEN
        
        SELECT "ASMCL_ClassName" INTO v_ASMCL_ClassName 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = p_MI_Id AND "ASMCL_Id" = p_ASMCL_Id;
        
        SELECT "ASMC_SectionName" INTO v_ASMC_SectionName 
        FROM "Adm_School_M_Section" 
        WHERE "MI_Id" = p_MI_Id AND "ASMS_Id" = p_ASMS_Id;
        
        SELECT DISTINCT "EMCA_Id" INTO v_EMCA_Id 
        FROM "Exm"."Exm_Category_Class" a 
        WHERE a."mi_id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id 
            AND a."ECAC_ActiveFlag" = 1;
        
        SELECT DISTINCT "EYC_Id" INTO v_EYC_Id 
        FROM "Exm"."Exm_Yearly_Category" 
        WHERE "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = v_EMCA_Id AND "EYC_ActiveFlg" = 1;
        
        FOR rec_subject IN
            SELECT DISTINCT a."ISMS_Id", d."ISMS_SubjectName", f."EYCES_SubjectOrder"
            FROM "Exm"."Exm_Yearly_Category_Group_Subjects" a
            INNER JOIN "Exm"."Exm_Yearly_Category_Group" b ON a."EYCG_Id" = b."EYCG_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category" c ON c."EYC_Id" = b."EYC_Id"
            INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" e ON e."EYC_Id" = c."EYC_Id"
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" f ON f."EYCE_Id" = e."EYCE_Id" AND f."ISMS_Id" = d."ISMS_Id"
            INNER JOIN "Exm"."Exm_Studentwise_Subjects" g ON g."ISMS_Id" = d."ISMS_Id" 
                AND g."ASMAY_Id" = p_ASMAY_Id AND g."ESTSU_ActiveFlg" = 1 
                AND g."ASMCL_Id" = p_ASMCL_Id AND g."ASMS_Id" = p_ASMS_Id
            WHERE c."EMCA_Id" = v_EMCA_Id AND c."ASMAY_Id" = p_ASMAY_Id 
                AND e."EME_Id" = p_EME_Id AND a."EYCGS_ActiveFlg" = 1 
                AND b."EYCG_ActiveFlg" = 1 AND c."EYC_ActiveFlg" = 1
                AND d."ISMS_ActiveFlag" = 1 AND e."EYCE_ActiveFlg" = 1 
            ORDER BY f."EYCES_SubjectOrder"
        LOOP
            v_ISMS_Id := rec_subject."ISMS_Id";
            v_ISMS_SubjectName := rec_subject."ISMS_SubjectName";
            v_ISMS_order := rec_subject."EYCES_SubjectOrder";
            
            v_student_rowcount := 0;
            
            SELECT COUNT(*) INTO v_student_rowcount
            FROM "adm_M_student" a 
            INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id"
            INNER JOIN "Exm"."Exm_Studentwise_Subjects" c ON c."AMST_Id" = b."AMST_Id" AND c."ESTSU_ActiveFlg" = 1
            WHERE b."ASMAY_Id" = p_ASMAY_Id AND b."ASMCL_Id" = p_ASMCL_Id 
                AND b."ASMS_Id" = p_ASMS_Id AND b."AMAY_ActiveFlag" IN (0, 1) 
                AND a."AMST_ActiveFlag" IN (0, 1) AND a."amst_sol" = 'S'
                AND c."ASMAY_Id" = p_ASMAY_Id AND c."ASMCL_Id" = p_ASMCL_Id 
                AND c."ASMS_Id" = p_ASMS_Id AND c."ISMS_Id" = v_ISMS_Id::BIGINT;
            
            v_rowcount := 0;
            
            SELECT COUNT(*) INTO v_rowcount
            FROM "Exm"."Exm_Student_Marks" a 
            WHERE a."mi_id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id 
                AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id 
                AND a."EME_Id" = p_EME_Id AND a."ISMS_Id" = v_ISMS_Id::BIGINT;
            
            IF v_rowcount > 0 THEN
                IF v_student_rowcount = v_rowcount THEN
                    v_SourceMarksEntry := 'Full Entered';
                    v_enteryflag := 1;
                    v_enteryflag_color := 'Green';
                ELSE
                    v_SourceMarksEntry := 'Partially Entered';
                    v_enteryflag := 2;
                    v_enteryflag_color := 'Brown';
                END IF;
            ELSE
                v_enteryflag := 0;
                v_SourceMarksEntry := 'Not Entered';
                v_enteryflag_color := 'Red';
            END IF;
            
            INSERT INTO "Marks_Entry_Report" VALUES(
                p_MI_Id, p_ASMCL_Id, p_ASMS_Id, v_ASMCL_ClassName, v_ASMC_SectionName,
                v_ISMS_Id::BIGINT, v_ISMS_SubjectName, v_ISMS_order,
                v_employeename, v_enteryflag, v_enteryflag_color, v_SourceMarksEntry
            );
        END LOOP;
        
    ELSE
        
        SELECT "ASMCL_ClassName" INTO v_ASMCL_ClassName 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = p_MI_Id AND "ASMCL_Id" = p_ASMCL_Id;
        
        FOR rec_section IN
            SELECT DISTINCT a."ASMS_Id", b."ASMC_SectionName", b."ASMC_Order"
            FROM "Exm"."Exm_Category_Class" a 
            INNER JOIN "Adm_School_M_Section" b ON a."ASMS_Id" = b."ASMS_Id"
            WHERE a."MI_Id" = p_MI_Id AND "ASMCL_Id" = p_ASMCL_Id AND "ECAC_ActiveFlag" = 1
        LOOP
            v_ASMS_Id_New := rec_section."ASMS_Id";
            v_ASMC_SectionName := rec_section."ASMC_SectionName";
            v_ASMC_SectionOrder := rec_section."ASMC_Order";
            
            SELECT DISTINCT "EMCA_Id" INTO v_EMCA_Id 
            FROM "Exm"."Exm_Category_Class" a 
            WHERE a."mi_id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id 
                AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = v_ASMS_Id_New 
                AND a."ECAC_ActiveFlag" = 1;
            
            SELECT DISTINCT "EYC_Id" INTO v_EYC_Id 
            FROM "Exm"."Exm_Yearly_Category" 
            WHERE "ASMAY_Id" = p_ASMAY_Id AND "EMCA_Id" = v_EMCA_Id AND "EYC_ActiveFlg" = 1;
            
            FOR rec_subject IN
                SELECT DISTINCT a."ISMS_Id", d."ISMS_SubjectName", f."EYCES_SubjectOrder"
                FROM "Exm"."Exm_Yearly_Category_Group_Subjects" a
                INNER JOIN "Exm"."Exm_Yearly_Category_Group" b ON a."EYCG_Id" = b."EYCG_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category" c ON c."EYC_Id" = b."EYC_Id"
                INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = a."ISMS_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" e ON e."EYC_Id" = c."EYC_Id"
                INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" f ON f."EYCE_Id" = e."EYCE_Id" AND f."ISMS_Id" = d."ISMS_Id"
                INNER JOIN "Exm"."Exm_Studentwise_Subjects" g ON g."ISMS_Id" = d."ISMS_Id" 
                    AND g."ASMAY_Id" = p_ASMAY_Id AND g."ESTSU_ActiveFlg" = 1 
                    AND g."ASMCL_Id" = p_ASMCL_Id AND g."ASMS_Id" = v_ASMS_Id_New
                WHERE c."EMCA_Id" = v_EMCA_Id AND c."ASMAY_Id" = p_ASMAY_Id 
                    AND e."EME_Id" = p_EME_Id AND a."EYCGS_ActiveFlg" = 1 
                    AND b."EYCG_ActiveFlg" = 1 AND c."EYC_ActiveFlg" = 1
                    AND d."ISMS_ActiveFlag" = 1 AND e."EYCE_ActiveFlg" = 1 
                ORDER BY f."EYCES_SubjectOrder"
            LOOP
                v_ISMS_Id := rec_subject."ISMS_Id";
                v_ISMS_SubjectName := rec_subject."ISMS_SubjectName";
                v_ISMS_order := rec_subject."EYCES_SubjectOrder";
                
                v_student_rowcount := 0;
                
                SELECT COUNT(*) INTO v_student_rowcount
                FROM "adm_M_student" a 
                INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id"
                INNER JOIN "Exm"."Exm_Studentwise_Subjects" c ON c."AMST_Id" = b."AMST_Id" AND c."ESTSU_ActiveFlg" = 1
                WHERE b."ASMAY_Id" = p_ASMAY_Id AND b."ASMCL_Id" = p_ASMCL_Id 
                    AND b."ASMS_Id" = v_ASMS_Id_New AND b."AMAY_ActiveFlag" IN (0, 1) 
                    AND a."AMST_ActiveFlag" IN (0, 1) AND a."amst_sol" = 'S'
                    AND c."ASMAY_Id" = p_ASMAY_Id AND c."ASMCL_Id" = p_ASMCL_Id 
                    AND c."ASMS_Id" = v_ASMS_Id_New AND c."ISMS_Id" = v_ISMS_Id::BIGINT;
                
                v_rowcount := 0;
                v_employeename := '';
                
                SELECT COUNT(*) INTO v_rowcount
                FROM "Exm"."Exm_Student_Marks" a 
                WHERE a."mi_id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id 
                    AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = v_ASMS_Id_New 
                    AND a."EME_Id" = p_EME_Id AND a."ISMS_Id" = v_ISMS_Id::BIGINT;
                
                IF v_rowcount > 0 THEN
                    IF v_student_rowcount = v_rowcount THEN
                        v_SourceMarksEntry := 'Full Entered';
                        v_enteryflag := 1;
                        v_enteryflag_color := 'Green';
                    ELSE
                        v_SourceMarksEntry := 'Partially Entered';
                        v_enteryflag := 2;
                        v_enteryflag_color := 'Brown';
                    END IF;
                ELSE
                    v_enteryflag := 0;
                    v_SourceMarksEntry := 'Not Entered';
                    v_enteryflag_color := 'Red';
                END IF;
                
                INSERT INTO "Marks_Entry_Report" VALUES(
                    p_MI_Id, p_ASMCL_Id, v_ASMS_Id_New, v_ASMCL_ClassName, v_ASMC_SectionName,
                    v_ISMS_Id::BIGINT, v_ISMS_SubjectName, v_ISMS_order,
                    v_employeename, v_enteryflag, v_enteryflag_color, v_SourceMarksEntry
                );
            END LOOP;
        END LOOP;
        
    END IF;
    
    RETURN QUERY 
    SELECT * FROM "Marks_Entry_Report" 
    ORDER BY "SubjectOrder";
    
END;
$$;