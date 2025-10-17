CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Amount_Entry_StaffCollege"(
    "MI_Id" bigint,
    "FMG_Id" bigint,
    "ASMAY_Id" bigint,
    "FMH_Id" bigint,
    "FTI_Id" bigint,
    "FMAOST_Amount" decimal,
    "FMAOST_OthStaffFlag" varchar(10),
    "FTDD_Month" varchar(50),
    "FTDD_Day" varchar(50),
    "FTDD_Year" integer,
    "FMAOST_Id" bigint,
    "USER_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "maxid" bigint;
    "v_rowcount" integer;
BEGIN
    RAISE NOTICE 'sucess';
    
    IF ("FMAOST_Id" = 0) THEN
        RAISE NOTICE 'a';
        
        SELECT * FROM "CLG"."Fee_Master_College_Amount_OthStaffs" 
        WHERE "ASMAY_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."ASMAY_Id" 
        AND "FMG_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMG_Id" 
        AND "FMH_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMH_Id" 
        AND "MI_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."MI_Id" 
        AND "FTI_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FTI_Id" 
        AND "FMCAOST_OthStaffFlag" = "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_OthStaffFlag";
        
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        
        IF "v_rowcount" = 0 THEN
            RAISE NOTICE 'b';
            
            INSERT INTO "CLG"."Fee_Master_College_Amount_OthStaffs" (
                "MI_Id", "FMG_Id", "ASMAY_Id", "FMH_Id", "FTI_Id", 
                "FMCAOST_Amount", "FMCAOST_OthStaffFlag", "FMCAOST_ActiveFlag", 
                "FMCAOST_CreatedDate", "FMCAOST_UpdatedDate", 
                "FMCAOST_UpdatedBy", "FMCAOST_CreatedBy"
            ) 
            VALUES (
                "Insert_Fee_Amount_Entry_StaffCollege"."MI_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FMG_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."ASMAY_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FMH_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FTI_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_Amount", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_OthStaffFlag", 
                true, 
                CURRENT_TIMESTAMP, 
                CURRENT_TIMESTAMP, 
                "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id"
            );
            
            SELECT MAX("FMCAOST_Id") INTO "maxid" 
            FROM "CLG"."Fee_Master_College_Amount_OthStaffs";
            
            INSERT INTO "CLG"."Fee_College_T_Due_Date_OthStaffs" (
                "FMCAOST_Id", "FCTDDOST_Day", "FCTDDOST_Month", "FCTDDOST_Year", 
                "FCTDDOST_CreatedDate", "FCTDDOST_UpdatedDate", 
                "FCTDDOST_CreatedBy", "FCTDDOST_UpdatedBy"
            ) 
            VALUES (
                "maxid", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Day", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Month", 
                "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Year", 
                CURRENT_TIMESTAMP, 
                CURRENT_TIMESTAMP, 
                "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id", 
                "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id"
            );
        END IF;
        
    ELSIF ("FMAOST_Id" > 0) THEN
        RAISE NOTICE 'c';
        
        UPDATE "CLG"."Fee_Master_College_Amount_OthStaffs" 
        SET "FMG_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMG_Id", 
            "FMH_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMH_Id", 
            "FMCAOST_Amount" = "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_Amount", 
            "FTI_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FTI_Id", 
            "FMCAOST_UpdatedDate" = CURRENT_TIMESTAMP, 
            "FMCAOST_UpdatedBy" = "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id" 
        WHERE "FMCAOST_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_Id" 
        AND "MI_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."MI_Id" 
        AND "ASMAY_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."ASMAY_Id";
        
        UPDATE "CLG"."Fee_College_T_Due_Date_OthStaffs" 
        SET "FCTDDOST_Day" = "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Day", 
            "FCTDDOST_Month" = "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Month", 
            "FCTDDOST_Year" = "Insert_Fee_Amount_Entry_StaffCollege"."FTDD_Year", 
            "FCTDDOST_UpdatedDate" = CURRENT_TIMESTAMP, 
            "FCTDDOST_UpdatedBy" = "Insert_Fee_Amount_Entry_StaffCollege"."USER_Id" 
        WHERE "FMCAOST_Id" = "Insert_Fee_Amount_Entry_StaffCollege"."FMAOST_Id";
    END IF;
    
    RETURN;
END;
$$;