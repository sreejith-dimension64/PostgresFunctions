CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_yearly_class_categorytemp"(
    "mi_id" BIGINT,
    "asmay_id" BIGINT,
    "fmcc_id" BIGINT,
    "amcl_id" BIGINT,
    "activeflag" BOOLEAN,
    "FYCC_Id" BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    "maxid" BIGINT;
    "return" BIGINT;
    "row_count" INTEGER;
BEGIN
    "return" := 0;
    
    IF ("FYCC_Id" = 0) THEN
        -- insert --
        SELECT COUNT(*) INTO "row_count" 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "MI_Id" = "mi_id" 
            AND "ASMAY_Id" = "asmay_id" 
            AND "FMCC_Id" = "fmcc_id";
        
        IF ("row_count" = 0) THEN
            INSERT INTO "Fee_Yearly_Class_Category" 
                ("MI_Id", "FMCC_Id", "ASMAY_Id", "FYCC_ActiveFlag", "CreatedDate", "UpdatedDate") 
            VALUES 
                ("mi_id", "fmcc_id", "asmay_id", "activeflag", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        END IF;
        
        SELECT "fycc_id" INTO "maxid" 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "MI_Id" = "mi_id" 
            AND "ASMAY_Id" = "asmay_id";
        
        SELECT COUNT(*) INTO "row_count" 
        FROM "Fee_Yearly_Class_Category_Classes" 
        WHERE "FYCCC_Id" = "maxid" 
            AND "ASMCL_Id" = "amcl_id";
        
        IF ("row_count" = 0) THEN
            INSERT INTO "Fee_Yearly_Class_Category_Classes" 
                ("FYCC_Id", "ASMCL_Id", "CreatedDate", "UpdatedDate") 
            VALUES 
                ("maxid", "amcl_id", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
            "return" := 1;
            RAISE NOTICE 'sucess';
        ELSE
            "return" := 0;
            RAISE NOTICE 'fail';
        END IF;
    ELSE
        -- updating ---
        SELECT COUNT(*) INTO "row_count" 
        FROM "Fee_Yearly_Class_Category_Classes" 
        WHERE "FYCC_Id" = "FYCC_Id";
        
        IF ("row_count" <> 0) THEN
            UPDATE "Fee_Yearly_Class_Category_Classes" 
            SET "ASMCL_Id" = "amcl_id", 
                "UpdatedDate" = CURRENT_TIMESTAMP 
            WHERE "FYCC_Id" = "FYCC_Id";
            
            UPDATE "Fee_Yearly_Class_Category" 
            SET "MI_Id" = "mi_id",
                "ASMAY_Id" = "asmay_id",
                "FMCC_Id" = "fmcc_id",
                "FYCC_ActiveFlag" = "activeflag",
                "UpdatedDate" = CURRENT_TIMESTAMP 
            WHERE "FYCC_Id" = "FYCC_Id";
            
            "return" := 1;
            RAISE NOTICE 'sucess';
        END IF;
    END IF;
    
    RETURN "return";
END;
$$;