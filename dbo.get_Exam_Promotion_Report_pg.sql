CREATE OR REPLACE FUNCTION "dbo"."get_Exam_Promotion_Report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_examtype varchar(50),
    p_EME_Id text
)
RETURNS TABLE(
    "AMST_AdmNo" varchar,
    "AMST_Name" text,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "EPRD_Remarks" text,
    "EME_ExamName" varchar,
    "ASMAY_Year" varchar,
    "EPRD_PromotionName" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
BEGIN
    IF p_examtype = '0' THEN
        v_sqldynamic := ' SELECT DISTINCT e."AMST_AdmNo", COALESCE(e."AMST_FirstName",'''') ||'' '' || COALESCE(e."AMST_MiddleName",'''') ||''  '' || COALESCE(e."AMST_LastName",'''') as "AMST_Name",
        c."ASMCL_ClassName", d."ASMC_SectionName", a."EPRD_Remarks", f."EME_ExamName", g."ASMAY_Year", NULL::varchar as "EPRD_PromotionName"
        FROM "Exm"."Exm_Promotion_Remarks_Details" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."ASMCL_Id" = b."ASMCL_Id" AND a."ASMS_Id" = b."ASMS_Id"
        INNER JOIN "Adm_School_M_Class" c ON b."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" d ON b."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_M_Student" e ON b."AMST_Id" = e."AMST_Id" AND e."AMST_SOL" = ''S''
        INNER JOIN "Exm"."Exm_Master_Exam" f ON f."EME_Id" = a."EME_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."ASMCL_Id" = ' || p_ASMCL_Id || ' AND a."ASMS_Id" = ' || p_ASMS_Id || ' AND a."EME_Id" IN (' || p_EME_Id || ') AND a."EPRD_Promotionflag" = ''IE''';
        
        RETURN QUERY EXECUTE v_sqldynamic;
    ELSIF p_examtype = '1' THEN
        RETURN QUERY
        SELECT DISTINCT e."AMST_AdmNo", COALESCE(e."AMST_FirstName",'') ||' ' || COALESCE(e."AMST_MiddleName",'') ||' ' || COALESCE(e."AMST_LastName",'') as "AMST_Name",
        c."ASMCL_ClassName", d."ASMC_SectionName", a."EPRD_Remarks", NULL::varchar as "EME_ExamName", g."ASMAY_Year", a."EPRD_PromotionName"
        FROM "Exm"."Exm_Promotion_Remarks_Details" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Class" c ON b."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" d ON b."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_M_Student" e ON b."AMST_Id" = e."AMST_Id" AND e."AMST_SOL" = 'S' AND e."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id
        AND b."ASMAY_Id" = p_ASMAY_Id AND b."ASMCL_Id" = p_ASMCL_Id AND b."ASMS_Id" = p_ASMS_Id
        AND a."EPRD_Promotionflag" != 'IE';
    END IF;
END;
$$;