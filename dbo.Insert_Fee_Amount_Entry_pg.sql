CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Amount_Entry"(
    p_MI_Id bigint,
    p_FMG_Id bigint,
    p_ASMAY_Id bigint,
    p_FMCC_Id bigint,
    p_FTI_Id bigint,
    p_FMA_Amount decimal,
    p_FMA_Flag varchar(10),
    p_FMH_Id bigint,
    p_FTDD_Month varchar(50),
    p_FTDD_Day varchar(50),
    p_FTDDE_Month varchar(50),
    p_FTDDE_Day varchar(100),
    p_FMA_ID bigint,
    p_User_id bigint,
    p_DueDate timestamp,
    p_ECSDueDate timestamp,
    p_FMA_PartialRebateApplicableDate timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_maxid bigint;
    v_rowcount integer;
BEGIN
    RAISE NOTICE 'sucess';
    
    IF p_FMA_ID = 0 THEN
        RAISE NOTICE 'a';
        
        SELECT COUNT(*) INTO v_rowcount
        FROM "fee_master_amount"
        WHERE "ASMAY_Id" = p_ASMAY_Id
          AND "FMG_Id" = p_FMG_Id
          AND "FMH_Id" = p_FMH_Id
          AND "FMCC_Id" = p_FMCC_Id
          AND "MI_Id" = p_MI_Id
          AND "FTI_Id" = p_FTI_Id;
        
        IF v_rowcount = 0 THEN
            RAISE NOTICE 'b';
            
            INSERT INTO "fee_master_amount" (
                "MI_Id", "FMG_Id", "ASMAY_Id", "FMCC_Id", "FTI_Id", 
                "FMA_Amount", "FMA_Flag", "FMH_Id", "FMA_CreatedBy", 
                "FMA_UpdatedBy", "FMA_CreatedDate", "FMA_UpdatedDate", "FMA_DueDate"
            )
            VALUES (
                p_MI_Id, p_FMG_Id, p_ASMAY_Id, p_FMCC_Id, p_FTI_Id,
                p_FMA_Amount, p_FMA_Flag, p_FMH_Id, p_User_id,
                p_User_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_DueDate
            );
            
            SELECT MAX("fma_Id") INTO v_maxid FROM "Fee_Master_Amount";
            
            INSERT INTO "Fee_T_Due_Date" ("FMA_Id", "FTDD_Day", "FTDD_Month")
            VALUES (v_maxid, p_FTDD_Day, p_FTDD_Month);
            
            INSERT INTO "Fee_T_Due_Date_ECS" ("FMA_Id", "FTDDE_Day", "FTDDE_Month")
            VALUES (v_maxid, p_FTDDE_Day, p_FTDDE_Month);
        END IF;
        
    ELSIF p_FMA_ID > 0 THEN
        RAISE NOTICE 'c';
        
        UPDATE "Fee_Master_Amount"
        SET "FMG_Id" = p_FMG_Id,
            "FMH_Id" = p_FMH_Id,
            "FMA_Amount" = p_FMA_Amount,
            "FTI_Id" = p_FTI_Id,
            "FMCC_Id" = p_FMCC_Id,
            "FMA_UpdatedBy" = p_User_id,
            "FMA_DueDate" = p_DueDate
        WHERE "FMA_Id" = p_FMA_ID
          AND "MI_Id" = p_MI_Id
          AND "ASMAY_Id" = p_ASMAY_Id;
        
        UPDATE "Fee_T_Due_Date"
        SET "FTDD_Day" = p_FTDD_Day,
            "FTDD_Month" = p_FTDD_Month
        WHERE "FMA_Id" = p_FMA_ID;
        
        UPDATE "Fee_T_Due_Date_ECS"
        SET "FTDDE_Day" = p_FTDDE_Day,
            "FTDDE_Month" = p_FTDDE_Month
        WHERE "FMA_Id" = p_FMA_ID;
    END IF;
    
    RETURN;
END;
$$;