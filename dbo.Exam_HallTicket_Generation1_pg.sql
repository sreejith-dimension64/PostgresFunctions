CREATE OR REPLACE FUNCTION "dbo"."Exam_HallTicket_Generation1"(
    p_mi_id bigint,
    p_asmay_id bigint,
    p_asmcl_id bigint,
    p_asms_id text,
    p_eme_id bigint,
    p_prefix varchar(100),
    p_startno int,
    p_increment int,
    p_leadingzeros int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_id bigint;
    v_HallNo varchar(100);
    v_DD varchar(20);
    v_value varchar(20);
    v_value1 varchar(20);
    v_value2 varchar(20);
    v_dynamic text;
    v_sectionid bigint;
    v_dynamic1 text;
    v_firstname text;
    v_middlename text;
    v_lastname text;
    v_IMN_WidthNumeric text;
    v_lengthofstart text;
    v_substringwidth int;
    v_lengthofzero text;
    v_prefixno BIGINT;
    v_rowcont int;
    v_intperfix varchar(100);
    rec_section RECORD;
    rec_student RECORD;
BEGIN
    v_rowcont := 0;
    v_substringwidth := 0;

    BEGIN
        FOR rec_section IN 
            EXECUTE format('SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id"=%s AND "ASMS_Id" IN (%s)', p_mi_id, p_asms_id)
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
                    v_IMN_WidthNumeric := LENGTH(p_startno::text);
                    v_HallNo := p_prefix || LPAD(RTRIM(p_startno::text), p_leadingzeros, '0');

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
                        v_intperfix := LENGTH(v_prefixno::text);

                        IF p_leadingzeros >= 2 THEN
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::text), p_leadingzeros, '0');
                        ELSE
                            v_HallNo := p_prefix || LPAD(RTRIM(p_startno::text), p_leadingzeros, '0');
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
                        VALUES(p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;
                ELSE
                    v_HallNo := p_prefix || p_startno::text;

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
                        v_HallNo := p_prefix || v_prefixno::varchar(100);

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
                        VALUES(p_mi_id, p_asmay_id, p_asmcl_id, v_sectionid, p_eme_id, v_amst_id, v_HallNo, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
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