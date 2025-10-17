CREATE OR REPLACE FUNCTION "Exam_Staffexamentry_studentcount_BKP"(
    p_MI_ID TEXT, 
    p_ASMAY_ID TEXT, 
    p_Userid TEXT
)
RETURNS TABLE(
    "Id" TEXT,
    "ASMAY_ID" BIGINT,
    "ASMCL_ID" BIGINT,
    "ASMS_ID" BIGINT,
    "UserName" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT := '';
    v_PivotSelectColumnNames TEXT := '';
    v_column_record RECORD;
BEGIN
    
    -- Build pivot column names
    FOR v_column_record IN (
        SELECT DISTINCT E."ISMS_SubjectName"
        FROM "Exm"."Exm_Student_Marks" A
        INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
        INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
        WHERE A."MI_ID" = p_MI_ID::BIGINT AND A."asmay_id" = p_ASMAY_ID::BIGINT
        GROUP BY D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName"
    ) LOOP
        IF v_PivotColumnNames = '' THEN
            v_PivotColumnNames := quote_ident(v_column_record."ISMS_SubjectName");
        ELSE
            v_PivotColumnNames := v_PivotColumnNames || ',' || quote_ident(v_column_record."ISMS_SubjectName");
        END IF;
    END LOOP;
    
    -- Build pivot select column names
    FOR v_column_record IN (
        SELECT DISTINCT E."ISMS_SubjectName"
        FROM "Exm"."Exm_Student_Marks" A
        INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
        INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
        WHERE A."MI_ID" = p_MI_ID::BIGINT AND A."asmay_id" = p_ASMAY_ID::BIGINT
        GROUP BY D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName"
    ) LOOP
        IF v_PivotSelectColumnNames = '' THEN
            v_PivotSelectColumnNames := 'SUM(COALESCE(' || quote_ident(v_column_record."ISMS_SubjectName") || ', 0)) AS ' || quote_ident(v_column_record."ISMS_SubjectName");
        ELSE
            v_PivotSelectColumnNames := v_PivotSelectColumnNames || ',SUM(COALESCE(' || quote_ident(v_column_record."ISMS_SubjectName") || ', 0)) AS ' || quote_ident(v_column_record."ISMS_SubjectName");
        END IF;
    END LOOP;
    
    v_sqldynamic := '
    SELECT "Id", "ASMAY_ID", "ASMCL_ID", "ASMS_ID", "UserName", "ASMCL_ClassName", "ASMC_SectionName", ' || v_PivotSelectColumnNames || ' 
    FROM crosstab(
        ''SELECT D."Id"::TEXT || ''-'' || A."ASMAY_ID"::TEXT || ''-'' || B."ASMCL_ID"::TEXT || ''-'' || C."ASMS_ID"::TEXT || ''-'' || D."UserName" || ''-'' || B."ASMCL_ClassName" || ''-'' || C."ASMC_SectionName" AS row_key,
               D."Id", A."ASMAY_ID", B."ASMCL_ID", C."ASMS_ID", D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName",
               E."ISMS_SubjectName", 
               COUNT(DISTINCT A."AMST_ID") AS Studentcount
        FROM "Exm"."Exm_Student_Marks" A
        INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
        INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
        WHERE A."MI_ID" = ' || p_MI_ID || ' AND A."asmay_id" = ' || p_ASMAY_ID || ' AND A."Id" IN (' || p_Userid || ')
        GROUP BY D."Id", A."ASMAY_ID", B."ASMCL_ID", C."ASMS_ID", D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName"
        ORDER BY 1, 8''
    ) AS ct(row_key TEXT, "Id" TEXT, "ASMAY_ID" BIGINT, "ASMCL_ID" BIGINT, "ASMS_ID" BIGINT, "UserName" TEXT, "ASMCL_ClassName" TEXT, "ASMC_SectionName" TEXT, ' || v_PivotColumnNames || ')
    GROUP BY "Id", "ASMAY_ID", "ASMCL_ID", "ASMS_ID", "UserName", "ASMCL_ClassName", "ASMC_SectionName"';
    
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;