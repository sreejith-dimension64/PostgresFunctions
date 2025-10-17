CREATE OR REPLACE FUNCTION "dbo"."Adm_School_FeedbackCount"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMTY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_optionflag text
)
RETURNS TABLE(
    "FMTY_FeedbackTypeName" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "FBGivenCount" bigint,
    "FBNotGivenCount" bigint,
    "MI_Id" bigint,
    "FMTY_Id" bigint,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_optionflag = 'COUNT' THEN
        RETURN QUERY
        SELECT 
            "FMT"."FMTY_FeedbackTypeName",
            "ASMC"."ASMCL_ClassName",
            "ASMS"."ASMC_SectionName",
            count("FSST"."AMST_Id") AS "FBGivenCount",
            count("ASYS"."AMST_Id") AS "FBNotGivenCount",
            "ASMS"."MI_Id",
            "FMT"."FMTY_Id",
            "ASYS"."ASMAY_Id",
            "ASMC"."ASMCL_Id",
            "ASMS"."ASMS_Id"
        FROM "Adm_M_Student" "AMS"
        LEFT JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        LEFT JOIN "Feedback_School_Student_Transaction" "FSST" ON "FSST"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "FSST"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASYS"."ASMCL_Id" = "FSST"."ASMCL_Id" 
            AND "ASYS"."ASMS_Id" = "FSST"."ASMS_Id"
        LEFT JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "FSST"."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "FSST"."ASMS_Id"
        LEFT JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FSST"."FMTY_Id"
        WHERE "AMS"."MI_Id" = p_MI_Id 
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "FMT"."FMTY_ActiveFlag" = 1
        GROUP BY "FMT"."FMTY_FeedbackTypeName", "ASMC"."ASMCL_ClassName", "ASMS"."ASMC_SectionName", 
            "ASMS"."MI_Id", "FMT"."FMTY_Id", "ASYS"."ASMAY_Id", "ASMC"."ASMCL_Id", "ASMS"."ASMS_Id";
    
    ELSIF p_optionflag = 'DETAILS' THEN
        RETURN QUERY
        SELECT 
            "FMT"."FMTY_FeedbackTypeName",
            "ASMC"."ASMCL_ClassName",
            "ASMS"."ASMC_SectionName",
            count("FSST"."AMST_Id") AS "FBGivenCount",
            count("ASYS"."AMST_Id") AS "FBNotGivenCount",
            "ASMS"."MI_Id",
            "FMT"."FMTY_Id",
            "ASYS"."ASMAY_Id",
            "ASMC"."ASMCL_Id",
            "ASMS"."ASMS_Id"
        FROM "Adm_M_Student" "AMS"
        LEFT JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        LEFT JOIN "Feedback_School_Student_Transaction" "FSST" ON "FSST"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "FSST"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASYS"."ASMCL_Id" = "FSST"."ASMCL_Id" 
            AND "ASYS"."ASMS_Id" = "FSST"."ASMS_Id"
        LEFT JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "FSST"."ASMCL_Id"
        LEFT JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "FSST"."ASMS_Id"
        LEFT JOIN "Feedback_Master_Type" "FMT" ON "FMT"."FMTY_Id" = "FSST"."FMTY_Id"
        WHERE "FMT"."FMTY_ActiveFlag" = 1 
            AND "FMT"."FMTY_Id" = p_FMTY_Id 
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "AMS"."MI_Id" = p_MI_Id 
            AND "ASMC"."ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS"."ASMS_Id" = p_ASMS_Id
        GROUP BY "FMT"."FMTY_FeedbackTypeName", "ASMC"."ASMCL_ClassName", "ASMS"."ASMC_SectionName", 
            "ASMS"."MI_Id", "FMT"."FMTY_Id", "ASYS"."ASMAY_Id", "ASMC"."ASMCL_Id", "ASMS"."ASMS_Id";
    
    END IF;
    
    RETURN;
END;
$$;