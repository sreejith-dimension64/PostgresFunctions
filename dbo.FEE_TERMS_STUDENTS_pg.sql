CREATE OR REPLACE FUNCTION "dbo"."FEE_TERMS_STUDENTS"(
    "MI_Id" VARCHAR(100),
    "ASMCL_Id" TEXT,
    "ASMAY_Id" VARCHAR(100),
    "ASMS_Id" TEXT,
    "FMT_Id" TEXT,
    "fmg_id" TEXT,
    "AMST_Id" TEXT,
    "student_flag" BIGINT,
    "type" BIGINT
)
RETURNS TABLE(
    "AMST_MobileNo" VARCHAR,
    "amsT_Id" BIGINT,
    "studentname" TEXT,
    "AMST_AppDownloadedDeviceId" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    dynamicsql TEXT;
BEGIN
    IF "type" = 1 THEN
        IF "student_flag" = 1 THEN
            dynamicsql := 'SELECT DISTINCT "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_Id" as "amsT_Id", COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "studentname", "Adm_M_Student"."AMST_AppDownloadedDeviceId"
            FROM "Fee_Student_Status"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Fee_Student_Status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status"."fti_id"
            WHERE "Fee_Student_Status"."MI_Id" = ' || "MI_Id" || ' AND "Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "FMG_Id" IN (' || "fmg_id" || ') AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ') AND
            "FMT_Id" IN (' || "FMT_Id" || ') AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND "FSS_ToBePaid" > 0 AND "Fee_Student_Status"."AMST_Id" IN (' || "AMST_Id" || ')';
        ELSE
            dynamicsql := 'SELECT DISTINCT "Adm_M_Student"."AMST_MobileNo", "Adm_M_Student"."AMST_Id" as "amsT_Id", COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "studentname", "Adm_M_Student"."AMST_AppDownloadedDeviceId"
            FROM "Fee_Student_Status"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Fee_Student_Status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status"."fti_id"
            WHERE "Fee_Student_Status"."MI_Id" = ' || "MI_Id" || ' AND "Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "FMG_Id" IN (' || "fmg_id" || ') AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ') AND
            "FMT_Id" IN (' || "FMT_Id" || ') AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 AND "FSS_ToBePaid" > 0';
        END IF;
    ELSE
        IF "student_flag" = 0 THEN
            dynamicsql := 'SELECT DISTINCT a."AMST_MobileNo", a."AMST_Id" as "amsT_Id", NULL::TEXT as "studentname", a."AMST_AppDownloadedDeviceId"
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            WHERE a."MI_Id" = ' || "MI_Id" || ' AND a."AMST_ActiveFlag" = 1 AND b."ASMAY_Id" = ' || "ASMAY_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND b."ASMS_Id" IN (' || "ASMS_Id" || ')';
        ELSE
            dynamicsql := 'SELECT DISTINCT a."AMST_MobileNo", a."AMST_Id" as "amsT_Id", NULL::TEXT as "studentname", a."AMST_AppDownloadedDeviceId"
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            WHERE a."MI_Id" = ' || "MI_Id" || ' AND a."AMST_ActiveFlag" = 1 AND b."ASMAY_Id" = ' || "ASMAY_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND b."ASMS_Id" IN (' || "ASMS_Id" || ') AND b."AMST_Id" IN (' || "AMST_Id" || ')';
        END IF;
    END IF;

    RETURN QUERY EXECUTE dynamicsql;
END;
$$;