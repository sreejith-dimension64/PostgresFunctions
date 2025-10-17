CREATE OR REPLACE FUNCTION "dbo"."Exam_HallTicket_Generation_New"(
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
    v_DD VARCHAR(20);
    v_value VARCHAR(20);
    v_value1 VARCHAR(20);
    v_value2 VARCHAR(20);
    v_dynamic TEXT;
    v_sectionid BIGINT;
    v_dynamic1 TEXT;
    v_firstname TEXT;
    v_middlename TEXT;
    v_lastname TEXT;
    v_IMN_WidthNumeric TEXT;
    v_lengthofstart TEXT;
    v_substringwidth INT;
    v_lengthofzero TEXT;
    v_prefixno BIGINT;
    v_rowcont INT;
    v_classid BIGINT;
    v_intperfix VARCHAR(100);
    v_ExmConfig_HallTicketFlg BOOLEAN;
    v_SName TEXT;
    student_rec RECORD;
    section_rec RECORD;
    class_rec RECORD;
BEGIN

    v_rowcont := 0;
    v_substringwidth := 0;

    SELECT "ExmConfig_HallTicketFlg" INTO v_ExmConfig_HallTicketFlg 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_mi_id;

    IF (v_ExmConfig_HallTicketFlg = FALSE) THEN

        RAISE NOTICE 'varr1dd';

        FOR section_rec IN 
            EXECUTE 'SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = $1 AND "ASMS_Id" IN (' || p_asms_id || ')'
            USING p_mi_id
        LOOP
            v_sectionid := section_rec."ASMS_Id";

            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_HallTicket') THEN
                DELETE FROM "Exm"."Exm_HallTicket" 
                WHERE "MI_Id" = p_mi_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "ASMCL_Id" = p_asmcl_id 
                AND "ASMS_Id" = v_sectionid 
                AND "EME_Id" = p_eme_id;
            END IF;

            RAISE NOTICE '@@mi_id: %', p_mi_id;
            RAISE NOTICE '@@asmay_id: %', p_asmay_id;
            RAISE NOTICE '@@asmcl_id: %', p_asmcl_id;
            RAISE NOTICE '@sectionid: %', v_sectionid;

            FOR student_rec IN
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
                AND a."AMST_ActiveFlag" = TRUE 
                AND e."AMAY_ActiveFlag" = TRUE
                ORDER BY a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName"
            LOOP
                v_amst_id := student_rec."AMST_Id";
                v_firstname := student_rec."AMST_FirstName";
                v_middlename := student_rec."AMST_MiddleName";
                v_lastname := student_rec."AMST_LastName";

                RAISE NOTICE 'amst_id: %', v_amst_id;

                IF p_leadingzeros <> 0 THEN

                    RAISE NOTICE 'BBBBBBBBBBBB';

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
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::TEXT), p_leadingzeros, '0');
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
                        INSERT INTO "Exm"."Exm_HallTicket" 
                        ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                ELSIF (p_leadingzeros = 0) THEN

                    RAISE NOTICE 'CCCCCCCC';

                    v_HallNo := p_prefix || p_startno::TEXT;

                    RAISE NOTICE '@HallNo: %', v_HallNo;

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
                        INSERT INTO "Exm"."Exm_HallTicket" 
                        ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                END IF;

            END LOOP;

        END LOOP;

    ELSIF (v_ExmConfig_HallTicketFlg = TRUE) THEN

        FOR class_rec IN
            SELECT "ASMCL_Id" 
            FROM "Adm_School_M_Class" 
            WHERE "MI_Id" = p_mi_id 
            AND "ASMCL_Id" = p_asmcl_id
        LOOP
            v_classid := class_rec."ASMCL_Id";

            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_HallTicket') THEN
                DELETE FROM "Exm"."Exm_HallTicket" 
                WHERE "MI_Id" = p_mi_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "ASMCL_Id" = p_asmcl_id 
                AND "EME_Id" = p_eme_id;
            END IF;

            FOR student_rec IN
                SELECT DISTINCT a."AMST_Id", d."ASMS_Id",
                REPLACE((CASE WHEN RTRIM(LTRIM(COALESCE(a."AMST_FirstName", ''))) = '' THEN '' ELSE RTRIM(LTRIM(COALESCE(a."AMST_FirstName", ''))) END ||
                CASE WHEN RTRIM(LTRIM(COALESCE(a."AMST_MiddleName", ''))) = '' THEN '' ELSE ' ' || RTRIM(LTRIM(COALESCE(a."AMST_MiddleName", ''))) END ||
                CASE WHEN RTRIM(LTRIM(COALESCE(a."AMST_LastName", ''))) = '' THEN '' ELSE ' ' || RTRIM(LTRIM(COALESCE(a."AMST_LastName", ''))) END), '  ', ' ') AS "SName"
                FROM "Adm_M_Student" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."MI_Id" = p_mi_id 
                AND b."ASMAY_Id" = p_asmay_id 
                AND b."ASMCL_Id" = p_asmcl_id 
                AND b."ASMS_Id" NOT IN (68, 69) 
                AND a."AMST_SOL" = 'S' 
                AND a."AMST_ActiveFlag" = TRUE 
                AND e."AMAY_ActiveFlag" = TRUE
                ORDER BY "SName"
            LOOP
                v_amst_id := student_rec."AMST_Id";
                v_sectionid := student_rec."ASMS_Id";
                v_SName := student_rec."SName";

                IF p_leadingzeros != 0 THEN
                    RAISE NOTICE 'varr1';
                    v_IMN_WidthNumeric := LENGTH(p_startno::TEXT);
                    RAISE NOTICE 'varr2';
                    v_HallNo := p_prefix || LPAD(RTRIM(p_startno::TEXT), p_leadingzeros, '0');
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "Exm"."Exm_HallTicket" 
                    WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "ASMCL_Id" = p_asmcl_id 
                    AND "EME_Id" = p_eme_id 
                    AND "EHT_HallTicketNo" = v_HallNo;

                    WHILE v_rowcont > 0 LOOP
                        RAISE NOTICE 'varr11';
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        RAISE NOTICE 'varrww1';
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::BIGINT;
                        RAISE NOTICE 'varssr1';
                        v_prefixno := v_prefixno + p_increment;
                        v_intperfix := LENGTH(v_prefixno::TEXT);

                        IF p_leadingzeros >= 2 THEN
                            RAISE NOTICE 'varrssdd1';
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::TEXT), p_leadingzeros, '0');
                        ELSE
                            RAISE NOTICE 'vardddddsdr1';
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::TEXT), p_leadingzeros, '0');
                        END IF;

                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "Exm"."Exm_HallTicket" 
                        WHERE "MI_Id" = p_mi_id 
                        AND "ASMAY_Id" = p_asmay_id 
                        AND "ASMCL_Id" = p_asmcl_id 
                        AND "EME_Id" = p_eme_id 
                        AND "EHT_HallTicketNo" = v_HallNo;

                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "Exm"."Exm_HallTicket" 
                        ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                ELSE

                    RAISE NOTICE 'varddr1';
                    v_HallNo := p_prefix || p_startno::TEXT;
                    RAISE NOTICE 'vaddddrr1';
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "Exm"."Exm_HallTicket" 
                    WHERE "MI_Id" = p_mi_id 
                    AND "ASMAY_Id" = p_asmay_id 
                    AND "ASMCL_Id" = p_asmcl_id 
                    AND "EME_Id" = p_eme_id 
                    AND "EHT_HallTicketNo" = v_HallNo;

                    WHILE v_rowcont > 0 LOOP

                        RAISE NOTICE 'vaqqqrr1';
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        RAISE NOTICE 'vaqqqrrddd1';
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::BIGINT;
                        RAISE NOTICE 'vaqq11qrr1';
                        v_prefixno := v_prefixno + p_increment;
                        RAISE NOTICE 'vaqqqrwwr1';
                        v_HallNo := p_prefix || v_prefixno::TEXT;
                        RAISE NOTICE 'vaqqqrdddr1';
                        
                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "Exm"."Exm_HallTicket" 
                        WHERE "MI_Id" = p_mi_id 
                        AND "ASMAY_Id" = p_asmay_id 
                        AND "ASMCL_Id" = p_asmcl_id 
                        AND "EME_Id" = p_eme_id 
                        AND "EHT_HallTicketNo" = v_HallNo;

                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "Exm"."Exm_HallTicket" 
                        ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "AMST_Id", "EHT_HallTicketNo", "EHT_ActiveFlag", "CreatedDate", "UpdatedDate")
                        VALUES (p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                END IF;

            END LOOP;

        END LOOP;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;