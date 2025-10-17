CREATE OR REPLACE FUNCTION "dbo"."Autoreceiptnogeneration"(
    "mi_id" bigint,
    "asmay_id" bigint,
    "automanualgenerationflag" varchar(50)
)
RETURNS varchar(50)
LANGUAGE plpgsql
AS $$
DECLARE
    "IMN_PrefixAcadYearCodetemp" varchar(50);
    "IMN_PrefixFinYearCodetemp" varchar(50);
    "IMN_PrefixCalYearCodetemp" varchar(50);
    "IMN_PrefixParticulartemp" varchar(50);
    
    "IMN_SuffixAcadYearCodetemp" varchar(50);
    "IMN_SuffixFinYearCodetemp" varchar(50);
    "IMN_SuffixCalYearCodetemp" varchar(50);
    "IMN_SuffixParticulartemp" varchar(50);
    
    "IMN_WidthNumerictemp" varchar(50);
    "IMN_ZeroPrefixFlagtemp" varchar(50);
    "IMN_StartingNotemp" varchar(50);
    "IMN_RestartNumFlagtemp" varchar(50);
    
    "receiptnofeeypayment" text;
    
    "receiptnogen" varchar(50);
BEGIN
    "receiptnogen" := '';
    
    SELECT "IMN_PrefixAcadYearCode", "IMN_PrefixFinYearCode", "IMN_PrefixCalYearCode", "IMN_PrefixParticular",
           "IMN_SuffixAcadYearCode", "IMN_SuffixFinYearCode", "IMN_SuffixCalYearCode", "IMN_SuffixParticular",
           "IMN_WidthNumeric", "IMN_ZeroPrefixFlag", "IMN_StartingNo", "IMN_RestartNumFlag"
    INTO "IMN_PrefixAcadYearCodetemp", "IMN_PrefixFinYearCodetemp", "IMN_PrefixCalYearCodetemp", "IMN_PrefixParticulartemp",
         "IMN_SuffixAcadYearCodetemp", "IMN_SuffixFinYearCodetemp", "IMN_SuffixCalYearCodetemp", "IMN_SuffixParticulartemp",
         "IMN_WidthNumerictemp", "IMN_ZeroPrefixFlagtemp", "IMN_StartingNotemp", "IMN_RestartNumFlagtemp"
    FROM "IVRM_Master_Numbering" 
    WHERE "mi_id" = 4 AND "IMN_Flag" = 'Transaction';
    
    IF "IMN_WidthNumerictemp" != '' AND "IMN_RestartNumFlagtemp" = 'Yearly' THEN
        "IMN_WidthNumerictemp" := "IMN_WidthNumerictemp";
        "IMN_StartingNotemp" := "IMN_StartingNotemp";
        
        SELECT CAST("FYP_Receipt_No" AS bigint)::text
        INTO "receiptnofeeypayment"
        FROM "Fee_Y_Payment" 
        WHERE "mi_id" = 5 AND "ASMAY_ID" = 3;
        
        IF "IMN_WidthNumerictemp" != LENGTH("IMN_StartingNotemp")::text THEN
            IF COALESCE("receiptnofeeypayment", '') != '' THEN
                "IMN_WidthNumerictemp" := (CAST("IMN_WidthNumerictemp" AS bigint) - CAST("IMN_StartingNotemp" AS bigint))::text;
                SELECT REPEAT('0', CAST("IMN_WidthNumerictemp" AS integer)) INTO "receiptnogen";
                "receiptnogen" := "receiptnofeeypayment" || "IMN_StartingNotemp";
            ELSE
                "IMN_WidthNumerictemp" := (CAST("IMN_WidthNumerictemp" AS bigint) - CAST("IMN_StartingNotemp" AS bigint))::text;
                SELECT REPEAT('0', CAST("IMN_WidthNumerictemp" AS integer)) INTO "receiptnogen";
                "IMN_StartingNotemp" := (CAST("IMN_StartingNotemp" AS bigint) + 1)::text;
                "receiptnofeeypayment" := '0';
                "receiptnogen" := (CAST("receiptnofeeypayment" AS bigint) + CAST("IMN_StartingNotemp" AS bigint))::text;
            END IF;
        ELSE
            IF COALESCE("receiptnofeeypayment", '') = '' THEN
                "receiptnofeeypayment" := '0';
                "receiptnofeeypayment" := (CAST("receiptnofeeypayment" AS bigint) + 1)::text;
            ELSE
                "receiptnofeeypayment" := (CAST("receiptnofeeypayment" AS bigint) + 1)::text;
            END IF;
        END IF;
    END IF;
    
    IF "IMN_PrefixAcadYearCodetemp" = '1' THEN
        SELECT "ASMAY_Year" INTO "receiptnogen"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "mi_id" = 4 AND "asmay_id" = 2;
    END IF;
    
    IF COALESCE("IMN_PrefixParticulartemp", '') != '' THEN
        "receiptnogen" := "receiptnogen" || "IMN_PrefixParticulartemp";
    END IF;
    
    IF COALESCE("IMN_WidthNumerictemp", '') != '' THEN
        IF "IMN_ZeroPrefixFlagtemp" = '1' THEN
            SELECT REPEAT('0', CAST("IMN_WidthNumerictemp" AS integer)) INTO "receiptnogen";
        END IF;
    END IF;
    
    IF COALESCE("IMN_StartingNotemp", '') = '' THEN
        "receiptnogen" := "IMN_StartingNotemp";
    END IF;
    
    IF "IMN_SuffixAcadYearCodetemp" = '1' THEN
        SELECT "ASMAY_Year" INTO "receiptnogen"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "mi_id" = 4 AND "asmay_id" = 2;
    END IF;
    
    IF COALESCE("IMN_SuffixParticulartemp", '') != '' THEN
        "receiptnogen" := "IMN_SuffixParticulartemp";
    END IF;
    
    IF COALESCE("IMN_RestartNumFlagtemp", '') = '' THEN
        "receiptnogen" := "IMN_RestartNumFlagtemp";
    END IF;
    
    RETURN "receiptnogen";
END;
$$;