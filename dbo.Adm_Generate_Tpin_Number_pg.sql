CREATE OR REPLACE FUNCTION "dbo"."Adm_Generate_Tpin_Number"(
    p_mi_id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_month VARCHAR(10);
    v_day VARCHAR(10);
    v_year VARCHAR(10);
    v_tpin BIGINT;
    v_count BIGINT;
    v_amst_id TEXT;
    v_dobdate TEXT;
    student_rec RECORD;
BEGIN

    FOR student_rec IN 
        SELECT "AMST_Id", TO_CHAR("AMST_DOB", 'YYYYMMDD') AS dob 
        FROM "Adm_M_Student" 
        WHERE "mi_id" = p_mi_id 
        AND "AMST_Tpin" IS NULL
    LOOP
        v_amst_id := student_rec."AMST_Id";
        v_dobdate := student_rec.dob;
        
        v_tpin := v_dobdate::BIGINT;
        
        SELECT COUNT(*) INTO v_count 
        FROM "Adm_M_Student" 
        WHERE "mi_id" = p_mi_id 
        AND "AMST_Tpin" = v_tpin;
        
        WHILE v_count > 0 LOOP
            v_tpin := v_tpin + 1;
            
            SELECT COUNT(*) INTO v_count 
            FROM "Adm_M_Student" 
            WHERE "mi_id" = p_mi_id 
            AND "AMST_Tpin" = v_tpin;
        END LOOP;
        
        UPDATE "Adm_M_Student" 
        SET "AMST_Tpin" = v_tpin 
        WHERE "mi_id" = p_mi_id 
        AND "AMST_Id" = v_amst_id;
        
        v_tpin := NULL;
        
    END LOOP;

END;
$$;