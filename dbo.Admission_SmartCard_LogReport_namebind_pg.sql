CREATE OR REPLACE FUNCTION "dbo"."Admission_SmartCard_LogReport_namebind"(
    @admnoname TEXT
)
RETURNS TABLE (
    "Amst_id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "name" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlText" TEXT;
BEGIN
    IF @admnoname = 'regno' THEN
        "sqlText" := 'SELECT DISTINCT "dbo"."Adm_M_Student"."Amst_id", "dbo"."Adm_m_Student"."AMST_AdmNo", 
        "AMST_AdmNo" || '':'' || "AMST_FirstName" || '''' || "AMST_MiddleName" || '''' || "AMST_LastName" AS name 
        FROM "dbo"."Adm_M_Student" WHERE "dbo"."Adm_M_Student"."amst_sol" = ''S''';
    ELSE
        "sqlText" := 'SELECT DISTINCT "dbo"."Adm_M_Student"."Amst_id", "dbo"."Adm_m_Student"."AMST_AdmNo", 
        "AMST_FirstName" || '''' || "AMST_MiddleName" || '''' || "AMST_LastName" || '':'' || "AMST_AdmNo" AS name 
        FROM "dbo"."Adm_M_Student" WHERE "dbo"."Adm_M_Student"."amst_sol" = ''S''';
    END IF;
    
    RETURN QUERY EXECUTE "sqlText";
END;
$$;