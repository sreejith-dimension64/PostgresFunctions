CREATE OR REPLACE FUNCTION "dbo"."Exam_Staff_SubjectList"(
    p_LoginId TEXT,
    p_ASMAY_ID TEXT,
    p_MI_Id TEXT
)
RETURNS TABLE (
    "ISMS_SubjectName" VARCHAR,
    "ISMS_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
BEGIN
    v_SqlDynamic := 'SELECT DISTINCT a."ISMS_SubjectName", a."ISMS_Id" 
                     FROM "IVRM_Master_Subjects" a
                     INNER JOIN "EXM"."Exm_Login_Privilege_Subjects" b ON a."ISMS_Id" = b."ISMS_Id"
                     INNER JOIN "EXM"."Exm_Login_Privilege" c ON c."ELP_Id" = b."ELP_Id" AND c."ASMAY_Id" = ' || p_ASMAY_ID || '
                     WHERE c."Login_Id" IN (' || p_LoginId || ') 
                     AND a."MI_Id" = ' || p_MI_Id || ' 
                     AND c."MI_Id" = ' || p_MI_Id || ' 
                     AND a."ISMS_ActiveFlag" = 1';
    
    RAISE NOTICE '%', v_SqlDynamic;
    
    RETURN QUERY EXECUTE v_SqlDynamic;
END;
$$;