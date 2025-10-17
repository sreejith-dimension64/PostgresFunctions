CREATE OR REPLACE FUNCTION "dbo"."FEE_TERMS_STUDENTS_list"(
    "p_MI_Id" VARCHAR(100),
    "p_ASMCL_Id" TEXT,
    "p_ASMAY_Id" VARCHAR(100),
    "p_ASMS_Id" TEXT,
    "p_FMT_Id" TEXT,
    "p_TRMR_Id" TEXT,
    "p_fmg_id" TEXT,
    "p_flag" VARCHAR(10)
)
RETURNS TABLE(
    "amsT_Id" INTEGER,
    "studentname" TEXT,
    "AMST_AppDownloadedDeviceId" TEXT,
    "AMST_AdmNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_dynamicsql" TEXT;
BEGIN
    IF "p_flag" = 'F' THEN
        "v_dynamicsql" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id" as "amsT_Id",
            COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "studentname",
            "Adm_M_Student"."AMST_AppDownloadedDeviceId",
            "Adm_M_Student"."AMST_AdmNo"
        FROM "Fee_Student_Status"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
            AND "Fee_Student_Status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
            AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status"."fti_id"
        WHERE "Fee_Student_Status"."MI_Id" = ' || "p_MI_Id" || ' 
            AND "Fee_Student_Status"."ASMAY_Id" = ' || "p_ASMAY_Id" || '
            AND "FMG_Id" IN (' || "p_fmg_id" || ')
            AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "p_ASMCL_Id" || ')
            AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "p_ASMS_Id" || ')
            AND "FMT_Id" IN (' || "p_FMT_Id" || ')
            AND "AMST_SOL" = ''S''
            AND "AMST_ActiveFlag" = 1
            AND "AMAY_ActiveFlag" = 1
            AND "FSS_ToBePaid" > 0';
    END IF;

    IF "p_flag" = 'R' THEN
        "v_dynamicsql" := 'SELECT "AMS"."AMST_Id" as "amsT_Id",
            (COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''')) AS "studentname",
            NULL::TEXT AS "AMST_AppDownloadedDeviceId",
            "AMS"."AMST_AdmNo"
        FROM "Adm_School_Y_Student" "ASYS"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        INNER JOIN "TRN"."TR_Student_Route" "trn" ON "ASYS"."AMST_Id" = "trn"."AMST_Id"
        WHERE "AMS"."MI_Id" = ' || "p_MI_Id" || '
            AND "ASYS"."ASMAY_Id" = ' || "p_ASMAY_Id" || '
            AND "ASYS"."ASMCL_Id" IN (' || "p_ASMCL_Id" || ')
            AND "ASYS"."ASMS_Id" IN (' || "p_ASMS_Id" || ')
            AND "AMS"."AMST_ActiveFlag" = 1
            AND "ASYS"."AMAY_ActiveFlag" = 1
            AND "AMS"."AMST_SOL" = ''S''
            AND "trn"."TRMR_Id" IN (' || "p_TRMR_Id" || ')';
    ELSIF "p_flag" = 'S' THEN
        "v_dynamicsql" := 'SELECT "AMS"."AMST_Id" as "amsT_Id",
            (COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''')) AS "studentname",
            NULL::TEXT AS "AMST_AppDownloadedDeviceId",
            "AMS"."AMST_AdmNo"
        FROM "Adm_School_Y_Student" "ASYS"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        WHERE "AMS"."MI_Id" = ' || "p_MI_Id" || '
            AND "ASYS"."ASMAY_Id" = ' || "p_ASMAY_Id" || '
            AND "ASYS"."ASMCL_Id" IN (' || "p_ASMCL_Id" || ')
            AND "ASYS"."ASMS_Id" IN (' || "p_ASMS_Id" || ')
            AND "AMS"."AMST_ActiveFlag" = 1
            AND "ASYS"."AMAY_ActiveFlag" = 1
            AND "AMS"."AMST_SOL" = ''S''';
    END IF;

    RETURN QUERY EXECUTE "v_dynamicsql";
END;
$$;