CREATE OR REPLACE FUNCTION "dbo"."ASN"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst bigint;
    v_amst_dob bigint;
    v_amst_tpin_cnt varchar(100);
    v_amst_tpin_a bigint;
    v_dob_ varchar(100);
    v_dob_compare varchar(100);
    v_dob_1 varchar(100);
    v_mi_id bigint;
    v_NewEmpID varchar(25);
    v_Id integer;
    v_PreFix varchar(10);
BEGIN
    FOR v_mi_id IN 
        SELECT "MI_Id" FROM "Master_Institution"
    LOOP
        v_amst_tpin_a := NULL;
        
        FOR v_amst IN 
            SELECT DISTINCT "AMST_Id" FROM "Adm_M_Student" WHERE "MI_Id" = v_mi_id
        LOOP
            IF v_amst_tpin_a = 1 THEN
                SELECT COALESCE(MAX(SUBSTRING("AMST_Tpin", 4, 7)::integer), 0) + 1 
                INTO v_Id
                FROM "Adm_M_Student" 
                WHERE "MI_Id" = v_mi_id;
            ELSE
                v_Id := 1;
                v_amst_tpin_a := 1;
            END IF;
            
            v_PreFix := '0';
            v_NewEmpID := v_PreFix || RIGHT('000000' || v_Id::varchar, 6);
            
            UPDATE "Adm_M_Student" 
            SET "AMST_Tpin" = v_NewEmpID 
            WHERE "MI_Id" = v_mi_id 
            AND "AMST_Id" = v_amst;
            
        END LOOP;
        
    END LOOP;
    
    RETURN;
END;
$$;