CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Amount_Entry_Staff"(
    "@MI_Id" bigint,
    "@FMG_Id" bigint,
    "@ASMAY_Id" bigint,
    "@FMH_Id" bigint,
    "@FTI_Id" bigint,
    "@FMAOST_Amount" decimal,
    "@FMAOST_OthStaffFlag" varchar(10),
    "@FTDD_Month" varchar(50),
    "@FTDD_Day" varchar(50),
    "@FTDD_Year" integer,
    "@FMAOST_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@maxid" bigint;
    "v_rowcount" integer;
BEGIN
    RAISE NOTICE 'sucess';
    
    IF "@FMAOST_Id" = 0 THEN
        RAISE NOTICE 'a';
        
        PERFORM * FROM "Fee_Master_Amount_OthStaffs" 
        WHERE "ASMAY_Id" = "@ASMAY_Id" 
        AND "FMG_Id" = "@FMG_Id" 
        AND "FMH_Id" = "@FMH_Id" 
        AND "MI_Id" = "@MI_Id" 
        AND "FTI_Id" = "@FTI_Id" 
        AND "FMAOST_OthStaffFlag" = "@FMAOST_OthStaffFlag";
        
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        
        IF "v_rowcount" = 0 THEN
            RAISE NOTICE 'b';
            
            INSERT INTO "Fee_Master_Amount_OthStaffs" (
                "MI_Id", "FMG_Id", "ASMAY_Id", "FMH_Id", "FTI_Id", 
                "FMAOST_Amount", "FMAOST_OthStaffFlag", "FMAOST_ActiveFlag", 
                "CreatedDate", "UpdatedDate"
            ) 
            VALUES (
                "@MI_Id", "@FMG_Id", "@ASMAY_Id", "@FMH_Id", "@FTI_Id", 
                "@FMAOST_Amount", "@FMAOST_OthStaffFlag", 1, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
            
            SELECT MAX("FMAOST_Id") INTO "@maxid" FROM "Fee_Master_Amount_OthStaffs";
            
            INSERT INTO "Fee_T_Due_Date_OthStaffs" (
                "FMAOST_Id", "FTDD_Day", "FTDD_Month", "FTDD_Year", 
                "CreatedDate", "UpdatedDate"
            ) 
            VALUES (
                "@maxid", "@FTDD_Day", "@FTDD_Month", "@FTDD_Year", 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );
            
        END IF;
        
    ELSIF "@FMAOST_Id" > 0 THEN
        RAISE NOTICE 'c';
        
        UPDATE "Fee_Master_Amount_OthStaffs" 
        SET "FMG_Id" = "@FMG_Id",
            "FMH_Id" = "@FMH_Id",
            "FMAOST_Amount" = "@FMAOST_Amount",
            "FTI_Id" = "@FTI_Id",
            "UpdatedDate" = CURRENT_TIMESTAMP
        WHERE "FMAOST_Id" = "@FMAOST_Id" 
        AND "MI_Id" = "@MI_Id" 
        AND "ASMAY_Id" = "@ASMAY_Id";
        
        UPDATE "Fee_T_Due_Date_OthStaffs" 
        SET "FTDD_Day" = "@FTDD_Day",
            "FTDD_Month" = "@FTDD_Month",
            "FTDD_Year" = "@FTDD_Year",
            "UpdatedDate" = CURRENT_TIMESTAMP
        WHERE "FMAOST_Id" = "@FMAOST_Id";
        
    END IF;
    
    RETURN;
END;
$$;