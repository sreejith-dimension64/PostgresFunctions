CREATE OR REPLACE FUNCTION "Exm"."Exam_HallTicket_Generation1_Old"(
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_asmcl_id BIGINT,
    p_asms_id TEXT,
    p_eme_id BIGINT,
    p_prefix VARCHAR(100),
    p_startno INT,
    p_increment INT,
    p_leadingzeros INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_id BIGINT;
    v_HallNo VARCHAR(100);
    v_sectionid BIGINT;
    v_firstname TEXT;
    v_middlename TEXT;
    v_lastname TEXT;
    v_IMN_WidthNumeric TEXT;
    v_substringwidth INT;
    v_prefixno BIGINT;
    v_rowcont INT;
    v_intperfix VARCHAR(100);
    rec_section RECORD;
    rec_student RECORD;
BEGIN
    v_rowcont := 0;
    v_substringwidth := 0;

    BEGIN
        FOR rec_section IN EXECUTE 
            'SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = ' || p_mi_id || ' AND "ASMS_Id" IN (' || p_asms_id || ')'
        LOOP
            v_sectionid := rec_section."ASMS_Id";

            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_HallTicket') THEN
                DELETE FROM "Exm"."Exm_HallTicket" 
                WHERE "MI_Id" = p_mi_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "ASMCL_Id" = p_asmcl_id 
                AND "ASMS_Id" = v_sectionid 
                AND "EME_Id" = p_eme_id;
            END IF;

            FOR rec_student IN 
                SELECT DISTINCT a."AMST_Id", a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName"
                FROM "Adm_M_Student" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."MI_Id" = p_mi_id 
                AND b."ASMAY_Id" = p_asmay_id 
                AND b."ASMCL_Id" = p_asmcl_id 
                AND b."ASMS_Id" = v_sectionid
                AND a."AMST_SOL" = 'S'
                AND a."AMST_ActiveFlag" = 1 
                AND e."AMAY_ActiveFlag" = 1
                ORDER BY a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName"
            LOOP
                v_amst_id := rec_student."AMST_Id";
                v_firstname := rec_student."AMST_FirstName";
                v_middlename := rec_student."AMST_MiddleName";
                v_lastname := rec_student."AMST_LastName";

                IF p_leadingzeros != 0 THEN
                    v_IMN_WidthNumeric := LENGTH(p_startno::TEXT);
                    v_HallNo := p_prefix || LPAD(RTRIM(p_startno::TEXT), p_leadingzeros, '0');
                    
                    SELECT COUNT(*) INTO v_rowcont
                    FROM "Exm"."Exm_HallTicket"
                    WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "ASMCL_Id" = p_asmcl_id 
                    AND "ASMS_Id" = v_sectionid 
                    AND "EME_Id" = p_eme_id 
                    AND "EHT_HallTicketNo" = v_HallNo;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::BIGINT;
                        v_prefixno := v_prefixno + p_increment;
                        v_intperfix := LENGTH(v_prefixno::TEXT);

                        IF p_leadingzeros >= 2 THEN
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::TEXT), p_leadingzeros, '0');
                        ELSE
                            v_HallNo := p_prefix || LPAD(RTRIM(p_startno::TEXT), p_leadingzeros, '0');
                        END IF;

                        SELECT COUNT(*) INTO v_rowcont
                        FROM "Exm"."Exm_HallTicket"
                        WHERE "MI_Id" = p_mi_id 
                        AND "ASMAY_Id" = p_asmay_id 
                        AND "ASMCL_Id" = p_asmcl_id 
                        AND "ASMS_Id" = v_sectionid 
                        AND "EME_Id" = p_eme_id 
                        AND "EHT_HallTicketNo" = v_HallNo;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "Exm"."Exm_HallTicket" ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;
                ELSE
                    v_HallNo := p_prefix || p_startno::TEXT;
                    
                    SELECT COUNT(*) INTO v_rowcont
                    FROM "Exm"."Exm_HallTicket"
                    WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "ASMCL_Id" = p_asmcl_id 
                    AND "ASMS_Id" = v_sectionid 
                    AND "EME_Id" = p_eme_id 
                    AND "EHT_HallTicketNo" = v_HallNo;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::BIGINT;
                        v_prefixno := v_prefixno + p_increment;
                        v_HallNo := p_prefix || v_prefixno::TEXT;
                        
                        SELECT COUNT(*) INTO v_rowcont
                        FROM "Exm"."Exm_HallTicket"
                        WHERE "MI_Id" = p_mi_id 
                        AND "ASMAY_Id" = p_asmay_id 
                        AND "ASMCL_Id" = p_asmcl_id 
                        AND "ASMS_Id" = v_sectionid 
                        AND "EME_Id" = p_eme_id 
                        AND "EHT_HallTicketNo" = v_HallNo;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "Exm"."Exm_HallTicket" ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;
                END IF;
            END LOOP;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;