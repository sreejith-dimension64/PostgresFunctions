CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_Delete"(
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_IMFY_Id bigint,
    p_r_no varchar(100)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_lcode bigint;
    v_Fyr_id bigint;
    v_Tno bigint;
    v_rec RECORD;
BEGIN
    v_Tno := 0;
    v_Fyr_id := 0;
    
    SELECT "FAMVOU_Id", "IMFY_Id" 
    INTO v_Tno, v_Fyr_id
    FROM "FA_M_Voucher" 
    WHERE "FAMVOU_Description" = p_r_no 
        AND "MI_Id" = p_MI_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND "IMFY_Id" = p_IMFY_Id
    LIMIT 1;
    
    v_lcode := 0;
    
    FOR v_rec IN 
        SELECT "FAMLED_Id" 
        FROM "FA_T_Voucher" 
        WHERE "FAMVOU_Id" = v_Tno
    LOOP
        v_lcode := v_rec."FAMLED_Id";
        
        DELETE FROM "FA_T_Voucher" 
        WHERE "FAMLED_Id" = v_lcode 
            AND "FAMVOU_Id" = v_Tno;
        
        PERFORM "dbo"."FA_autoUpdation"(v_lcode, v_Fyr_id);
    END LOOP;
    
    DELETE FROM "FA_M_voucher" 
    WHERE "FAMVOU_Id" = v_Tno 
        AND "MI_Id" = p_MI_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND "IMFY_Id" = p_IMFY_Id;
        
END;
$$;