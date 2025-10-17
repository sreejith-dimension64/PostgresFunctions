CREATE OR REPLACE FUNCTION "dbo"."Exam_Staffexamentry_studentcount"(
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
    v_subject_record RECORD;
BEGIN

    -- Build pivot column names
    FOR v_subject_record IN (
        SELECT DISTINCT E."ISMS_SubjectName"
        FROM "Exm"."Exm_Student_Marks" A
        INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
        INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
        WHERE A."MI_ID" = p_MI_ID::BIGINT AND A."asmay_id" = p_ASMAY_ID::BIGINT
        GROUP BY D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName"
    )
    LOOP
        v_PivotColumnNames := v_PivotColumnNames || 
            CASE WHEN v_PivotColumnNames = '' THEN '' ELSE ',' END ||
            quote_ident(v_subject_record."ISMS_SubjectName");
        
        v_PivotSelectColumnNames := v_PivotSelectColumnNames ||
            CASE WHEN v_PivotSelectColumnNames = '' THEN '' ELSE ',' END ||
            'SUM(COALESCE(' || quote_ident(v_subject_record."ISMS_SubjectName") || ', 0)) AS ' ||
            quote_ident(v_subject_record."ISMS_SubjectName");
    END LOOP;

    -- Build and execute dynamic SQL
    v_sqldynamic := '
    SELECT "Id", "ASMAY_ID", "ASMCL_ID", "ASMS_ID", "UserName", "ASMCL_ClassName", "ASMC_SectionName", ' || v_PivotSelectColumnNames || ' 
    FROM crosstab(
        ''SELECT D."Id"::TEXT, A."ASMAY_ID", B."ASMCL_ID", C."ASMS_ID", D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", 
                 E."ISMS_SubjectName", COUNT(DISTINCT A."AMST_ID") AS Studentcount
          FROM "Exm"."Exm_Student_Marks" A
          INNER JOIN "Adm_School_M_class" B ON B."ASMCL_Id" = A."ASMCL_Id"
          INNER JOIN "Adm_School_M_section" C ON C."ASMS_Id" = A."ASMS_Id"
          INNER JOIN "ApplicationUser" D ON D."Id" = A."Id"
          INNER JOIN "IVRM_Master_Subjects" E ON E."ISMS_ID" = A."ISMS_ID"
          WHERE A."MI_ID" = ' || p_MI_ID || ' 
            AND A."asmay_id" = ' || p_ASMAY_ID || ' 
            AND A."Id" IN (' || p_Userid || ')
          GROUP BY D."Id", A."ASMAY_ID", B."ASMCL_ID", C."ASMS_ID", D."UserName", B."ASMCL_ClassName", C."ASMC_SectionName", E."ISMS_SubjectName"
          ORDER BY 1, 2, 3, 4'',
        ''SELECT DISTINCT "ISMS_SubjectName" 
          FROM "IVRM_Master_Subjects" 
          WHERE "ISMS_ID" IN (
              SELECT DISTINCT "ISMS_ID" 
              FROM "Exm"."Exm_Student_Marks" 
              WHERE "MI_ID" = ' || p_MI_ID || ' AND "asmay_id" = ' || p_ASMAY_ID || '
          )
          ORDER BY 1''
    ) AS ct("Id" TEXT, "ASMAY_ID" BIGINT, "ASMCL_ID" BIGINT, "ASMS_ID" BIGINT, "UserName" TEXT, 
            "ASMCL_ClassName" TEXT, "ASMC_SectionName" TEXT, ' || v_PivotColumnNames || ' BIGINT)
    GROUP BY "Id", "ASMAY_ID", "ASMCL_ID", "ASMS_ID", "UserName", "ASMCL_ClassName", "ASMC_SectionName"';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;