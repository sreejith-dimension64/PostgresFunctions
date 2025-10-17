CREATE OR REPLACE FUNCTION "dbo"."INV_Student_leave_report_proc"(
    p_MI_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_stu_id text
)
RETURNS TABLE(
    "AMST_FirstName" character varying,
    "AMST_AdmNo" character varying,
    "ASMCL_ClassName" character varying,
    "ASMC_SectionName" character varying,
    "ASLA_ApplyDate" timestamp,
    "ASLA_FromDate" timestamp,
    "ASLA_ToDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Dynamic text;
BEGIN
    v_Dynamic := '
    SELECT DISTINCT 
        e."AMST_FirstName",
        e."AMST_AdmNo", 
        b."ASMCL_ClassName", 
        c."ASMC_SectionName",
        a."ASLA_ApplyDate", 
        a."ASLA_FromDate", 
        a."ASLA_ToDate" 
    FROM "Adm_Students_Leave_Apply" a
    INNER JOIN "Adm_School_M_Class" b ON a."MI_Id" = b."MI_Id" AND b."ASMCL_Id" IN (SELECT "ASMCL_Id" FROM "Adm_School_Y_Student" WHERE "AMST_Id" = a."AMST_Id")
    INNER JOIN "Adm_School_M_Section" c ON c."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_Y_Student" WHERE "AMST_Id" = a."AMST_Id")
    INNER JOIN "Adm_School_Y_Student" d ON a."AMST_Id" = d."AMST_Id" AND b."ASMCL_Id" = d."ASMCL_Id" AND c."ASMS_Id" = d."ASMS_Id"
    INNER JOIN "Adm_M_Student" e ON a."AMST_Id" = e."AMST_Id" AND e."ASMCL_Id" = b."ASMCL_Id" AND e."MI_Id" = a."MI_Id"
    WHERE a."MI_Id" = ' || p_MI_Id || ' 
    AND e."AMST_Id" IN (' || p_stu_id || ')';

    RETURN QUERY EXECUTE v_Dynamic;
END;
$$;