CREATE OR REPLACE FUNCTION "dbo"."FA_rec_voucher_delete_Trans"(
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
    v_tno_rec RECORD;
    v_lno_rec RECORD;
BEGIN
    v_Tno := 0;
    v_Fyr_id := 0;
    
    FOR v_tno_rec IN 
        SELECT "FAMVOU_Id", "IMFY_Id" 
        FROM "FA_M_Voucher" 
        WHERE "MI_Id" = p_MI_Id 
            AND "FAMCOMP_Id" = p_FAMCOMP_Id 
            AND "IMFY_Id" = p_IMFY_Id 
            AND "FAMVOU_Description" = p_r_no
    LOOP
        v_Tno := v_tno_rec."FAMVOU_Id";
        v_Fyr_id := v_tno_rec."IMFY_Id";
        
        FOR v_lno_rec IN 
            SELECT "FAMLED_Id" 
            FROM "FA_T_Voucher" 
            WHERE "FAMVOU_Id" = v_Tno
        LOOP
            v_lcode := v_lno_rec."FAMLED_Id";
            
            DELETE FROM "FA_T_Voucher" 
            WHERE "FAMLED_Id" = v_lcode 
                AND "FAMVOU_Id" = v_Tno;
            
            PERFORM "dbo"."FA_autoupdation"(v_lcode, v_Fyr_id);
            
        END LOOP;
        
    END LOOP;
    
    DELETE FROM "FA_M_Voucher" 
    WHERE "FAMVOU_Id" = v_Tno 
        AND "MI_Id" = p_MI_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND "IMFY_Id" = p_IMFY_Id;
    
    RETURN;
END;
$$;