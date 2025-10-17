CREATE OR REPLACE FUNCTION "dbo"."CLG_Insert_Fee_Amount_Entry"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FMH_Id" bigint,
    "FTI_Id" bigint,
    "AMB_Id" bigint,
    "AMCO_Id" bigint,
    "FMG_Id" bigint,
    "FCMA_Id" bigint,
    "FCMAS_Id" bigint,
    "FCMA_Flag" varchar(10),
    "FCMA_ActiveFlg" varchar(10),
    "AMSE_Id" bigint,
    "FCMAS_Amount" varchar(50),
    "FCMAS_Currency" varchar(50),
    "FCMAS_ActiveFlg" varchar(50),
    "FCTDD_Month" varchar(50),
    "FCTDD_Day" varchar(50),
    "FCTDD_Year" varchar(100),
    "FCMAS_DueDate" TIMESTAMP
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "FCMAS" bigint;
    "maxid" bigint;
    "rowcount_check" integer;
BEGIN
    RAISE NOTICE 'sucess';
    
    IF ("FCMA_Id" = 0) THEN
        
        RAISE NOTICE 'a';
        
        PERFORM * FROM "clg"."Fee_College_Master_Amount" 
        WHERE "ASMAY_Id" = "CLG_Insert_Fee_Amount_Entry"."ASMAY_Id" 
            AND "FMG_Id" = "CLG_Insert_Fee_Amount_Entry"."FMG_Id" 
            AND "FMH_Id" = "CLG_Insert_Fee_Amount_Entry"."FMH_Id" 
            AND "AMCO_Id" = "CLG_Insert_Fee_Amount_Entry"."AMCO_Id" 
            AND "AMB_Id" = "CLG_Insert_Fee_Amount_Entry"."AMB_Id" 
            AND "MI_Id" = "CLG_Insert_Fee_Amount_Entry"."MI_Id" 
            AND "FTI_Id" = "CLG_Insert_Fee_Amount_Entry"."FTI_Id";
        
        PERFORM * FROM "clg"."Fee_College_Master_Amount_Semesterwise" 
        WHERE "MI_Id" = "CLG_Insert_Fee_Amount_Entry"."MI_Id" 
            AND "FCMA_Id" = "CLG_Insert_Fee_Amount_Entry"."FCMA_Id" 
            AND "AMSE_Id" = "CLG_Insert_Fee_Amount_Entry"."AMSE_Id" 
            AND "FCMAS_Amount" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_Amount" 
            AND "FCMAS_Currency" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_Currency" 
            AND "FCMAS_ActiveFlg" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_ActiveFlg";
        
        GET DIAGNOSTICS "rowcount_check" = ROW_COUNT;
        
        IF ("rowcount_check" = 0) THEN
            
            RAISE NOTICE 'b';
            
            INSERT INTO "clg"."Fee_College_Master_Amount" (
                "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "FMG_Id", "FMH_Id", "FTI_Id", 
                "FCMA_Flag", "FCMA_ActiveFlg", "CreatedDate", "UpdatedDate"
            ) 
            VALUES (
                "CLG_Insert_Fee_Amount_Entry"."MI_Id", 
                "CLG_Insert_Fee_Amount_Entry"."ASMAY_Id", 
                "CLG_Insert_Fee_Amount_Entry"."AMCO_Id", 
                "CLG_Insert_Fee_Amount_Entry"."AMB_Id", 
                "CLG_Insert_Fee_Amount_Entry"."FMG_Id", 
                "CLG_Insert_Fee_Amount_Entry"."FMH_Id", 
                "CLG_Insert_Fee_Amount_Entry"."FTI_Id", 
                "CLG_Insert_Fee_Amount_Entry"."FCMA_Flag", 
                "CLG_Insert_Fee_Amount_Entry"."FCMA_ActiveFlg", 
                CURRENT_TIMESTAMP, 
                CURRENT_TIMESTAMP
            );
            
            SELECT MAX("FCMA_Id") INTO "maxid" FROM "clg"."Fee_College_Master_Amount";
            
            INSERT INTO "clg"."Fee_College_Master_Amount_Semesterwise" (
                "MI_Id", "FCMA_Id", "AMSE_Id", "FCMAS_Amount", "FCMAS_Currency", 
                "FCMAS_ActiveFlg", "CreatedDate", "UpdatedDate", "FCMAS_DueDate"
            ) 
            VALUES (
                "CLG_Insert_Fee_Amount_Entry"."MI_Id", 
                "maxid", 
                "CLG_Insert_Fee_Amount_Entry"."AMSE_Id", 
                "CLG_Insert_Fee_Amount_Entry"."FCMAS_Amount", 
                "CLG_Insert_Fee_Amount_Entry"."FCMAS_Currency", 
                "CLG_Insert_Fee_Amount_Entry"."FCMAS_ActiveFlg", 
                CURRENT_TIMESTAMP, 
                CURRENT_TIMESTAMP, 
                "CLG_Insert_Fee_Amount_Entry"."FCMAS_DueDate"
            );
            
            SELECT MAX("FCMAS_Id") INTO "FCMAS" FROM "clg"."Fee_College_Master_Amount_Semesterwise";
            
            INSERT INTO "Clg"."Fee_College_T_Due_Date" (
                "FCMAS_Id", "FCTDD_Day", "FCTDD_Month", "FCTDD_Year"
            ) 
            VALUES (
                "FCMAS", 
                "CLG_Insert_Fee_Amount_Entry"."FCTDD_Day", 
                "CLG_Insert_Fee_Amount_Entry"."FCTDD_Month", 
                "CLG_Insert_Fee_Amount_Entry"."FCTDD_Year"
            );
            
        END IF;
        
    ELSIF ("FCMA_Id" > 0) THEN
        
        RAISE NOTICE 'c';
        
        UPDATE "Clg"."Fee_College_Master_Amount" 
        SET "FMG_Id" = "CLG_Insert_Fee_Amount_Entry"."FMG_Id", 
            "FMH_Id" = "CLG_Insert_Fee_Amount_Entry"."FMH_Id", 
            "FTI_Id" = "CLG_Insert_Fee_Amount_Entry"."FTI_Id" 
        WHERE "FCMA_Id" = "CLG_Insert_Fee_Amount_Entry"."FCMA_Id" 
            AND "MI_Id" = "CLG_Insert_Fee_Amount_Entry"."MI_Id" 
            AND "ASMAY_Id" = "CLG_Insert_Fee_Amount_Entry"."ASMAY_Id";
        
        UPDATE "Clg"."Fee_College_Master_Amount_Semesterwise" 
        SET "FCMAS_Amount" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_Amount", 
            "FCMAS_Currency" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_Currency", 
            "FCMAS_DueDate" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_DueDate" 
        WHERE "FCMAS_Id" = "CLG_Insert_Fee_Amount_Entry"."FCMAS_Id" 
            AND "MI_Id" = "CLG_Insert_Fee_Amount_Entry"."MI_Id";
        
        UPDATE "Clg"."Fee_College_T_Due_Date" 
        SET "FCTDD_Day" = "CLG_Insert_Fee_Amount_Entry"."FCTDD_Day", 
            "FCTDD_Month" = "CLG_Insert_Fee_Amount_Entry"."FCTDD_Month" 
        WHERE "FCMAS_Id" = "FCMAS";
        
    END IF;
    
    RETURN;
    
END;
$$;