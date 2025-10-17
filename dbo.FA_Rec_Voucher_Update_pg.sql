CREATE OR REPLACE FUNCTION "dbo"."FA_Rec_Voucher_Update"(
    p_MI_Id bigint,
    p_IMFY_Id bigint,
    p_FAMCOMP_Id bigint,
    p_r_no varchar(100),
    p_date timestamp,
    p_amount numeric(9,2),
    p_remarks varchar(250),
    p_DFAMLED_Id varchar(50),
    p_BoolBank boolean,
    p_BankName varchar(50),
    p_ChequeNo varchar(20),
    p_ChequeDate timestamp,
    p_CFAMLED_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Tno bigint;
    v_Fyr_id bigint;
    v_Lcode bigint;
    v_rec RECORD;
BEGIN
    v_Tno := 0;
    
    UPDATE "dbo"."FA_M_Voucher" 
    SET "FAMVOU_VoucherDate" = p_date::date,
        "FAMVOU_Narration" = p_remarks 
    WHERE "FAMVOU_Description" = p_r_no 
        AND "MI_Id" = p_MI_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND "IMFY_Id" = p_IMFY_Id;
    
    SELECT "FAMVOU_Id", "IMFY_Id" 
    INTO v_Tno, v_Fyr_id
    FROM "dbo"."FA_M_Voucher" 
    WHERE "FAMVOU_Description" = p_r_no 
        AND "MI_Id" = p_MI_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id 
        AND "IMFY_Id" = p_IMFY_Id
    LIMIT 1;
    
    v_Lcode := 0;
    FOR v_rec IN 
        SELECT "FAMLED_Id" 
        FROM "dbo"."FA_T_Voucher"  
        WHERE "FAMVOU_Id" = v_Tno
        LIMIT 1
    LOOP
        v_Lcode := v_rec."FAMLED_Id";
    END LOOP;
    
    UPDATE "dbo"."FA_T_Voucher" 
    SET "FAMLED_Id" = p_CFAMLED_Id, 
        "FATVOU_Amount" = p_amount 
    WHERE "FAMVOU_Id" = v_Tno 
        AND "FATVOU_CRDRFlg" = 'Cr';
    
    PERFORM "dbo"."FA_autoUpdation"(v_Lcode, v_Fyr_id);
    
    v_Lcode := 0;
    FOR v_rec IN 
        SELECT "FAMLED_Id" 
        FROM "dbo"."FA_T_Voucher"  
        WHERE "FAMVOU_Id" = v_Tno
        LIMIT 1
    LOOP
        v_Lcode := v_rec."FAMLED_Id";
    END LOOP;
    
    UPDATE "dbo"."FA_T_Voucher" 
    SET "FAMLED_Id" = p_DFAMLED_Id::bigint, 
        "FATVOU_Amount" = p_amount 
    WHERE "FAMVOU_Id" = v_Tno 
        AND "FATVOU_CRDRFlg" = 'Dr';
    
    PERFORM "dbo"."FA_autoUpdation"(v_Lcode, v_Fyr_id);
    
    IF p_BoolBank = true THEN
        UPDATE "dbo"."FA_T_Voucher" 
        SET "FATVOU_ChequNo" = p_ChequeNo, 
            "FATVOU_ChequeDate" = p_ChequeDate,
            "FATVOU_BankName" = p_BankName  
        WHERE "FAMVOU_Id" = v_Tno 
            AND "FATVOU_CRDRFlg" = 'Dr';
    END IF;
    
    PERFORM "dbo"."FA_autoUpdation"(p_DFAMLED_Id::bigint, v_Fyr_id);
    PERFORM "dbo"."FA_autoUpdation"(p_CFAMLED_Id, v_Fyr_id);
    
    RETURN;
END;
$$;