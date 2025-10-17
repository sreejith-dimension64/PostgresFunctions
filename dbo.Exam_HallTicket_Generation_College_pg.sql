CREATE OR REPLACE FUNCTION "dbo"."Exam_HallTicket_Generation_College"(
    p_mi_id bigint,
    p_asmay_id bigint,
    p_AMCO_Id bigint,
    p_asms_id text,
    p_eme_id bigint,
    p_prefix varchar(100),
    p_startno int,
    p_increment int,
    p_leadingzeros int,
    p_AMB_Id bigint,
    p_AMSE_Id bigint
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
    v_classid bigint;
    v_intperfix varchar(100);
    v_ExmConfig_HallTicketFlg boolean;
    v_SName text;
    section_cursor CURSOR FOR SELECT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" 
        WHERE "MI_Id" = p_mi_id AND "ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[]);
    class_cursor CURSOR FOR SELECT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" 
        WHERE "MI_Id" = p_mi_id AND "ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[]);
    student_id refcursor;
BEGIN
    v_rowcont := 0;
    v_substringwidth := 0;

    SELECT "ExmConfig_HallTicketFlg" INTO v_ExmConfig_HallTicketFlg 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id;

    IF (v_ExmConfig_HallTicketFlg = false) THEN
        
        FOR v_sectionid IN 
            SELECT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" 
            WHERE "MI_Id" = p_mi_id AND "ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[])
        LOOP
            
            IF EXISTS (SELECT 1 FROM information_schema.tables 
                      WHERE table_schema = 'CLG' AND table_name = 'Exm_HallTicket_College') THEN
                DELETE FROM "CLG"."Exm_HallTicket_College" 
                WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id AND "AMCO_Id" = p_AMCO_Id 
                AND "AMB_Id" = p_AMB_Id AND "AMSE_Id" = p_AMSE_Id AND "EME_Id" = p_eme_id 
                AND "ACMS_Id" = v_sectionid;
            END IF;

            OPEN student_id FOR
            SELECT DISTINCT "ACYS"."AMCST_Id", "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName"
            FROM "CLG"."Adm_Master_College_Student" AS "AMCS"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
                ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
                AND "AMCS"."AMCST_ActiveFlag" = true
                AND "AMCS"."AMCST_SOL" = 'S' 
                AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
                AND "ACYS"."AMCO_Id" = p_AMCO_Id
                AND "ACYS"."AMB_Id" = p_AMB_Id 
                AND "ACYS"."AMSE_Id" = p_AMSE_Id
                AND "ACYS"."ACMS_Id" = v_sectionid 
                AND "AMCS"."MI_Id" = p_MI_Id
            WHERE "AMCS"."MI_Id" = p_MI_Id 
                AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
                AND "ACYS"."AMCO_Id" = p_AMCO_Id 
                AND "ACYS"."AMB_Id" = p_AMB_Id
                AND "ACYS"."AMSE_Id" = p_AMSE_Id 
                AND "ACYS"."ACMS_Id" = v_sectionid
            ORDER BY "ACYS"."AMCST_Id";

            LOOP
                FETCH student_id INTO v_amst_id, v_firstname, v_middlename, v_lastname;
                EXIT WHEN NOT FOUND;

                IF p_leadingzeros != 0 THEN
                    v_IMN_WidthNumeric := LENGTH(p_startno::text);
                    v_HallNo := p_prefix || LPAD(RTRIM(p_startno::text), p_leadingzeros, '0');
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "CLG"."Exm_HallTicket_College" 
                    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                    AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                    AND "EHTC_HallTicketNo" = v_HallNo
                    AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::bigint;
                        v_prefixno := v_prefixno + p_increment;
                        v_intperfix := LENGTH(v_prefixno::text);

                        IF p_leadingzeros >= 2 THEN
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::text), p_leadingzeros, '0');
                        ELSE
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::text), p_leadingzeros, '0');
                        END IF;

                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "CLG"."Exm_HallTicket_College" 
                        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                        AND "EHTC_HallTicketNo" = v_HallNo
                        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "CLG"."Exm_HallTicket_College" (
                            "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", 
                            "AMCST_Id", "EHTC_HallTicketNo", "EHTC_PublishFlg", "EHTC_ActiveFlag", 
                            "EHTC_CreatedDate", "EHTC_UpdatedDate", "EME_Id"
                        )
                        VALUES (
                            p_mi_id, p_asmay_id, p_AMCO_Id, p_AMB_Id, p_AMSE_Id, v_sectionid,
                            v_amst_id, v_HallNo, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_eme_id
                        );
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                ELSE
                    v_HallNo := p_prefix || p_startno::text;
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "CLG"."Exm_HallTicket_College" 
                    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                    AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                    AND "EHTC_HallTicketNo" = v_HallNo
                    AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::bigint;
                        v_prefixno := v_prefixno + p_increment;
                        v_HallNo := p_prefix || v_prefixno::varchar(100);

                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "CLG"."Exm_HallTicket_College" 
                        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                        AND "EHTC_HallTicketNo" = v_HallNo
                        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "CLG"."Exm_HallTicket_College" (
                            "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", 
                            "AMCST_Id", "EHTC_HallTicketNo", "EHTC_PublishFlg", "EHTC_ActiveFlag", 
                            "EHTC_CreatedDate", "EHTC_UpdatedDate", "EME_Id"
                        )
                        VALUES (
                            p_mi_id, p_asmay_id, p_AMCO_Id, p_AMB_Id, p_AMSE_Id, v_sectionid,
                            v_amst_id, v_HallNo, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_eme_id
                        );
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;
                END IF;

            END LOOP;
            CLOSE student_id;

        END LOOP;

    ELSIF (v_ExmConfig_HallTicketFlg = true) THEN
        
        FOR v_classid IN 
            SELECT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" 
            WHERE "MI_Id" = p_mi_id AND "ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[])
        LOOP
            
            IF EXISTS (SELECT 1 FROM information_schema.tables 
                      WHERE table_schema = 'Exm' AND table_name = 'Exm_HallTicket') THEN
                DELETE FROM "CLG"."Exm_HallTicket_College" 
                WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id AND "AMCO_Id" = p_AMCO_Id 
                AND "AMB_Id" = p_AMB_Id AND "AMSE_Id" = p_AMSE_Id AND "EME_Id" = p_eme_id;
            END IF;

            OPEN student_id FOR
            SELECT DISTINCT "ACYS"."AMCST_Id", "ACYS"."ACMS_Id", 
                   (COALESCE("AMCST_FirstName", '') || ' ' || COALESCE("AMCST_MiddleName", '') || ' ' || COALESCE("AMCST_LastName", '')) AS SName
            FROM "CLG"."Adm_Master_College_Student" AS "AMCS"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
                ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
                AND "AMCS"."AMCST_ActiveFlag" = true
                AND "AMCS"."AMCST_SOL" = 'S' 
                AND "ACYS"."ACYST_ActiveFlag" = true 
                AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
                AND "ACYS"."AMCO_Id" = p_AMCO_Id
                AND "ACYS"."AMB_Id" = p_AMB_Id 
                AND "ACYS"."AMSE_Id" = p_AMSE_Id
                AND "ACYS"."ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[])
                AND "AMCS"."MI_Id" = p_MI_Id
            WHERE "AMCS"."MI_Id" = p_MI_Id 
                AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
                AND "ACYS"."AMCO_Id" = p_AMCO_Id 
                AND "ACYS"."AMB_Id" = p_AMB_Id
                AND "ACYS"."AMSE_Id" = p_AMSE_Id 
                AND "ACYS"."ACMS_Id" = ANY(string_to_array(p_asms_id, ',')::bigint[])
            ORDER BY "ACYS"."AMCST_Id";

            LOOP
                FETCH student_id INTO v_amst_id, v_sectionid, v_SName;
                EXIT WHEN NOT FOUND;

                IF p_leadingzeros != 0 THEN
                    v_IMN_WidthNumeric := LENGTH(p_startno::text);
                    v_HallNo := p_prefix || LPAD(RTRIM(p_startno::text), p_leadingzeros, '0');
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "CLG"."Exm_HallTicket_College" 
                    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                    AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                    AND "EHTC_HallTicketNo" = v_HallNo
                    AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::bigint;
                        v_prefixno := v_prefixno + p_increment;
                        v_intperfix := LENGTH(v_prefixno::text);

                        IF p_leadingzeros >= 2 THEN
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::text), p_leadingzeros, '0');
                        ELSE
                            v_HallNo := p_prefix || LPAD(RTRIM(v_prefixno::text), p_leadingzeros, '0');
                        END IF;

                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "CLG"."Exm_HallTicket_College" 
                        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                        AND "EHTC_HallTicketNo" = v_HallNo
                        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "CLG"."Exm_HallTicket_College" (
                            "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", 
                            "AMCST_Id", "EHTC_HallTicketNo", "EHTC_PublishFlg", "EHTC_ActiveFlag", 
                            "EHTC_CreatedDate", "EHTC_UpdatedDate", "EME_Id"
                        )
                        VALUES (
                            p_mi_id, p_asmay_id, p_AMCO_Id, p_AMB_Id, p_AMSE_Id, v_sectionid,
                            v_amst_id, v_HallNo, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_eme_id
                        );
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;

                ELSE
                    v_HallNo := p_prefix || p_startno::text;
                    
                    SELECT COUNT(*) INTO v_rowcont 
                    FROM "CLG"."Exm_HallTicket_College" 
                    WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                    AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                    AND "EHTC_HallTicketNo" = v_HallNo
                    AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;

                    WHILE v_rowcont > 0 LOOP
                        v_substringwidth := LENGTH(p_prefix) + 1;
                        v_prefixno := SUBSTRING(v_HallNo, v_substringwidth, 100)::bigint;
                        v_prefixno := v_prefixno + p_increment;
                        v_HallNo := p_prefix || v_prefixno::varchar(100);

                        SELECT COUNT(*) INTO v_rowcont 
                        FROM "CLG"."Exm_HallTicket_College" 
                        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id
                        AND "AMCO_Id" = p_AMCO_Id AND "AMB_Id" = p_AMB_Id AND "EME_Id" = p_eme_id 
                        AND "EHTC_HallTicketNo" = v_HallNo
                        AND "AMSE_Id" = p_AMSE_Id AND "ACMS_Id" = v_sectionid;
                    END LOOP;

                    IF v_rowcont = 0 THEN
                        INSERT INTO "CLG"."Exm_HallTicket_College" (
                            "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_Id", 
                            "AMCST_Id", "EHTC_HallTicketNo", "EHTC_PublishFlg", "EHTC_ActiveFlag", 
                            "EHTC_CreatedDate", "EHTC_UpdatedDate", "EME_Id"
                        )
                        VALUES (
                            p_mi_id, p_asmay_id, p_AMCO_Id, p_AMB_Id, p_AMSE_Id, v_sectionid,
                            v_amst_id, v_HallNo, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_eme_id
                        );
                        
                        v_rowcont := 0;
                        v_HallNo := '';
                    END IF;
                END IF;

            END LOOP;
            CLOSE student_id;

        END LOOP;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;