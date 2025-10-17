CREATE OR REPLACE FUNCTION "dbo"."Adm_M_Student_AdmNoRegNo_Update"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_SchNo TEXT;
    v_StuCount int;
    v_StudentAdmno TEXT;
    v_AdmPrefix varchar(50);
    v_AMST_Id bigint;
    v_ASMAY_Year varchar(200);
    v_SchNo_Int int;
    student_rec RECORD;
BEGIN
    v_AdmPrefix := 'SCH';

    FOR student_rec IN 
        SELECT DISTINCT "AMS"."AMST_Id", "ASMAY"."ASMAY_Year"
        FROM "Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "AMS"."ASMAY_Id"
        WHERE "AMS"."MI_Id" = p_MI_Id 
            AND "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASMAY"."MI_Id" = p_MI_Id 
            AND ("AMS"."AMST_RegistrationNo" IS NULL OR "AMS"."AMST_AdmNo" IS NULL)
    LOOP
        v_AMST_Id := student_rec."AMST_Id";
        v_ASMAY_Year := student_rec."ASMAY_Year";

        SELECT count(*)
        INTO v_StuCount
        FROM "Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "AMS"."ASMAY_Id"
        WHERE "AMS"."MI_Id" = p_MI_Id 
            AND "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASMAY"."MI_Id" = p_MI_Id 
            AND ("AMS"."AMST_RegistrationNo" IS NULL OR "AMS"."AMST_AdmNo" IS NULL);

        IF (v_StuCount <> 0) THEN
            SELECT MAX(CAST(split_part("AMS"."AMST_RegistrationNo", '/', 3) AS INTEGER))
            INTO v_SchNo_Int
            FROM "Adm_M_Student" "AMS"
            INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "AMS"."ASMAY_Id"
            WHERE "AMS"."MI_Id" = p_MI_Id 
                AND "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
                AND "ASMAY"."MI_Id" = p_MI_Id 
                AND ("AMS"."AMST_RegistrationNo" IS NOT NULL OR "AMS"."AMST_AdmNo" IS NOT NULL);
            
            v_SchNo := COALESCE(v_SchNo_Int::TEXT, '1');
        ELSE
            v_SchNo := '1';
        END IF;

        v_StudentAdmno := v_AdmPrefix || '/' || v_ASMAY_Year || '/' || 
                          lpad(v_SchNo, 5, '0');

        UPDATE "Adm_M_Student" 
        SET "AMST_RegistrationNo" = v_StudentAdmno,
            "AMST_AdmNo" = v_StudentAdmno 
        WHERE "AMST_Id" = v_AMST_Id 
            AND ("AMST_RegistrationNo" IS NULL OR "AMST_AdmNo" IS NULL);

    END LOOP;

    RETURN;
END;
$$;