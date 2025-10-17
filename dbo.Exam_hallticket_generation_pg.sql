CREATE OR REPLACE FUNCTION "dbo"."Exam_hallticket_generation" (
    "p_mi_id" bigint,
    "p_asmay_id" bigint,
    "p_asmcl_id" bigint,
    "p_asms_id" text,
    "p_eme_id" bigint,
    "p_prefix" varchar(20),
    "p_startno" int,
    "p_increment" int,
    "p_leadingzeros" int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_amst_id" bigint;
    "v_HallNo" varchar(20);
    "v_DD" varchar(20);
    "v_value" varchar(20);
    "v_value1" varchar(20);
    "v_value2" varchar(20);
    "v_sectionid" bigint;
    "v_firstname" text;
    "v_middlename" text;
    "v_lastname" text;
    "v_row_count" int;
    "section_rec" RECORD;
    "student_rec" RECORD;
BEGIN
    BEGIN
        FOR "section_rec" IN 
            EXECUTE format('SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = %s AND "ASMS_Id" IN (%s)', 
                          "p_mi_id", "p_asms_id")
        LOOP
            "v_sectionid" := "section_rec"."ASMS_Id";
            "v_HallNo" := '0';
            "v_DD" := '0000';

            FOR "student_rec" IN 
                SELECT DISTINCT a."AMST_Id", a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName"
                FROM "Adm_M_Student" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."MI_Id" = "p_mi_id" 
                  AND b."ASMAY_Id" = "p_asmay_id" 
                  AND b."ASMCL_Id" = "p_asmcl_id" 
                  AND b."ASMS_Id" = "v_sectionid" 
                  AND a."AMST_SOL" = 'S' 
                  AND a."AMST_ActiveFlag" = 1 
                  AND e."AMAY_ActiveFlag" = 1
                ORDER BY a."AMST_FirstName", a."AMST_MiddleName", a."AMST_LastName"
            LOOP
                "v_amst_id" := "student_rec"."AMST_Id";
                "v_firstname" := "student_rec"."AMST_FirstName";
                "v_middlename" := "student_rec"."AMST_MiddleName";
                "v_lastname" := "student_rec"."AMST_LastName";

                IF "v_HallNo" = '0' THEN
                    SELECT LEFT("v_DD", "p_leadingzeros" - 1) INTO "v_value1";
                    "v_HallNo" := "p_prefix" || "v_value1" || CAST("p_startno" AS VARCHAR);
                ELSE
                    SELECT CAST(RIGHT("v_HallNo", "p_leadingzeros")::int + "p_increment" AS VARCHAR) INTO "v_value";

                    IF "v_value"::int < 10 THEN
                        IF "p_leadingzeros" = 5 THEN
                            "v_DD" := '0000';
                        ELSIF "p_leadingzeros" = 4 THEN
                            "v_DD" := '000';
                        ELSIF "p_leadingzeros" = 3 THEN
                            "v_DD" := '00';
                        ELSIF "p_leadingzeros" = 2 THEN
                            "v_DD" := '0';
                        ELSIF "p_leadingzeros" = 1 THEN
                            "v_DD" := '';
                        END IF;
                    END IF;

                    IF "v_value"::int = 10 THEN
                        IF "p_leadingzeros" = 5 THEN
                            "v_DD" := '000';
                        ELSIF "p_leadingzeros" = 4 THEN
                            "v_DD" := '00';
                        ELSIF "p_leadingzeros" = 3 THEN
                            "v_DD" := '0';
                        ELSIF "p_leadingzeros" = 2 THEN
                            "v_DD" := '';
                        END IF;
                    ELSIF "v_value"::int = 100 THEN
                        IF "p_leadingzeros" = 5 THEN
                            "v_DD" := '00';
                        ELSIF "p_leadingzeros" = 4 THEN
                            "v_DD" := '0';
                        ELSIF "p_leadingzeros" = 3 THEN
                            "v_DD" := '';
                        END IF;
                    ELSIF "v_value"::int = 1000 THEN
                        IF "p_leadingzeros" = 5 THEN
                            "v_DD" := '0';
                        ELSIF "p_leadingzeros" = 4 THEN
                            "v_DD" := '';
                        END IF;
                    ELSIF "v_value"::int = 10000 THEN
                        IF "p_leadingzeros" = 5 THEN
                            "v_DD" := '';
                        END IF;
                    END IF;

                    "v_HallNo" := "p_prefix" || "v_DD" || CAST("v_value" AS VARCHAR);
                END IF;

                SELECT COUNT(*) INTO "v_row_count"
                FROM "Exm"."Exm_HallTicket"
                WHERE "MI_ID" = "p_mi_id" 
                  AND "ASMAY_ID" = "p_asmay_id" 
                  AND "ASMCL_ID" = "p_asmcl_id" 
                  AND "ASMS_ID" = "p_asms_id" 
                  AND "EME_ID" = "p_eme_id"
                  AND "AMST_ID" = "v_amst_id" 
                  AND "EHT_HallTicketNo" = "v_HallNo";

                IF "v_row_count" = 0 THEN
                    INSERT INTO "Exm"."Exm_HallTicket" 
                    VALUES("p_mi_id", "p_asmay_id", "p_asmcl_id", "p_asms_id", "p_eme_id", "v_amst_id", "v_HallNo", 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
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