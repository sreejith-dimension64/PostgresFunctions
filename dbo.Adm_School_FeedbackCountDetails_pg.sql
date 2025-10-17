CREATE OR REPLACE FUNCTION "dbo"."Adm_School_FeedbackCountDetails"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FMTY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "type" boolean
)
RETURNS TABLE(
    "StudName" text,
    "AMST_AdmNo" varchar
) 
LANGUAGE plpgsql
AS $$
BEGIN 

    "type" := false;

    IF ("type" = true) THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "StudName",
            "AMS"."AMST_AdmNo"
        FROM "Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        INNER JOIN "Feedback_School_Student_Transaction" "FSST" ON "FSST"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "FSST"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASYS"."ASMCL_Id" = "FSST"."ASMCL_Id" 
            AND "ASYS"."ASMS_Id" = "FSST"."ASMS_Id" 
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "FSST"."ASMCL_Id" 
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "FSST"."ASMS_Id"
        INNER JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FSST"."FMTY_Id"
        WHERE "FMT"."FMTY_ActiveFlag" = true 
            AND "FMT"."FMTY_Id" = "FMTY_Id" 
            AND "ASYS"."ASMAY_Id" = "ASMAY_Id" 
            AND "AMS"."MI_Id" = "MI_Id" 
            AND "ASMC"."ASMCL_Id" = "ASMCL_Id" 
            AND "ASMS"."ASMS_Id" = "ASMS_Id";
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "StudName",
            "AMS"."AMST_AdmNo"
        FROM "Adm_M_Student" "AMS"
        LEFT JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        LEFT JOIN "Feedback_School_Student_Transaction" "FSST" ON "FSST"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "FSST"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASYS"."ASMCL_Id" = "FSST"."ASMCL_Id" 
            AND "ASYS"."ASMS_Id" = "FSST"."ASMS_Id" 
        LEFT JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "FSST"."ASMCL_Id" 
        LEFT JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "FSST"."ASMS_Id"
        LEFT JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FSST"."FMTY_Id"
        WHERE "FMT"."FMTY_ActiveFlag" = true 
            AND "FMT"."FMTY_Id" = "FMTY_Id" 
            AND "ASYS"."ASMAY_Id" = "ASMAY_Id" 
            AND "AMS"."MI_Id" = "MI_Id" 
            AND "ASMC"."ASMCL_Id" = "ASMCL_Id" 
            AND "ASMS"."ASMS_Id" = "ASMS_Id" 
            AND "FSST"."AMST_Id" IS NULL;
    
    END IF;

END;
$$;