CREATE OR REPLACE FUNCTION "Adm_Students_DOBWords_Update"(
    "p_MI_ID" BIGINT,
    "p_ASMAY_Id" BIGINT,
    "p_Flag" VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN

    /***** FOR ALL ACADEMIC YEAR WISE *****/
    
    IF ("p_Flag" = '1') THEN
    
        UPDATE "Adm_M_Student" AS "S"
        SET "AMST_DOB_Words" = UPPER(CONCAT(
            "fnNumberToWords_day"(EXTRACT(DAY FROM "S"."AMST_DOB")::INTEGER, 'Day'),
            ' ',
            TO_CHAR("S"."AMST_DOB", 'Month'),
            ' ',
            "FnNumberToWords"(EXTRACT(YEAR FROM "S"."AMST_DOB")::INTEGER)
        ))
        WHERE "S"."MI_ID" = "p_MI_ID" 
          AND "S"."AMST_DOB_Words" IS NULL;
    
    /***** FOR ACADEMIC YEAR WISE *****/
    
    ELSIF ("p_Flag" = '2') THEN
    
        UPDATE "Adm_M_Student" AS "S"
        SET "AMST_DOB_Words" = UPPER(CONCAT(
            "fnNumberToWords_day"(EXTRACT(DAY FROM "S"."AMST_DOB")::INTEGER, 'Day'),
            ' ',
            TO_CHAR("S"."AMST_DOB", 'Month'),
            ' ',
            "FnNumberToWords"(EXTRACT(YEAR FROM "S"."AMST_DOB")::INTEGER)
        ))
        WHERE "S"."MI_ID" = "p_MI_ID" 
          AND "S"."ASMAY_Id" = "p_ASMAY_Id"  
          AND "S"."AMST_DOB_Words" IS NULL;
    
    END IF;

END;
$$;