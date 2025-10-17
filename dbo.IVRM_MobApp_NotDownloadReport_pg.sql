CREATE OR REPLACE FUNCTION "dbo"."IVRM_MobApp_NotDownloadReport"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_FromDate VARCHAR(30),
    p_ToDate VARCHAR(30),
    p_Active VARCHAR(10),
    p_DeActive VARCHAR(10),
    p_Left VARCHAR(10),
    p_Flg VARCHAR(20)
)
RETURNS TABLE(
    studentname TEXT,
    "AMST_AdmNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "AMST_SOL" TEXT,
    "AMST_MobileNo" TEXT,
    "AMST_emailId" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_amstsol VARCHAR(50);
    v_sqlexc TEXT;
BEGIN

    IF p_Active='1' AND p_DeActive='0' AND p_Left='0' THEN
        v_amstsol := 'S';
    ELSIF p_Active='0' AND p_DeActive='1' AND p_Left='0' THEN
        v_amstsol := 'D';
    ELSIF p_Active='0' AND p_DeActive='0' AND p_Left='1' THEN
        v_amstsol := 'L';
    ELSIF p_Active='1' AND p_DeActive='1' AND p_Left='0' THEN
        v_amstsol := 'S,D';
    ELSIF p_Active='1' AND p_DeActive='0' AND p_Left='1' THEN
        v_amstsol := 'S,L';
    ELSIF p_Active='0' AND p_DeActive='1' AND p_Left='1' THEN
        v_amstsol := 'D,L';
    ELSIF (p_Active='1' AND p_DeActive='1' AND p_Left='1') OR (p_Active='0' AND p_DeActive='0' AND p_Left='0') THEN
        v_amstsol := 'S,D,L';
    END IF;

    v_sqlexc := '
    SELECT (COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) as studentname, 
    "AMST_AdmNo", "ASMCL_ClassName", "ASMC_SectionName", "AMST_SOL",
    "AMST_MobileNo", "AMST_emailId"
    FROM "Adm_M_Student"
    INNER JOIN "adm_school_Y_student" ON "Adm_M_Student"."amst_id" = "adm_school_Y_student"."amst_id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."asmcl_id" = "adm_school_Y_student"."asmcl_id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."asms_id" = "adm_school_Y_student"."asms_id"
    WHERE "Adm_M_Student"."mi_id" = ' || p_MI_Id::TEXT || ' 
    AND "adm_school_Y_student"."asmay_id" = ' || p_ASMAY_Id::TEXT || ' 
    AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || v_amstsol || ''' || '','') > 0 
    AND "Adm_M_Student"."AMST_Id" NOT IN (
        SELECT DISTINCT b."AMST_ID" 
        FROM "Adm_M_Student" a 
        INNER JOIN "Ivrm_User_StudentApp_login" b ON a."AMST_Id" = b."AMST_ID"
        INNER JOIN "IVRM_MobileApp_LoginDetails" c ON c."IVRMUL_Id" = b."STD_APP_ID"
        WHERE a."MI_Id" = ' || p_MI_Id::TEXT || ' 
        AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || v_amstsol || ''' || '','') > 0 
        AND "AMST_ActiveFlag" = 1 
        AND "IVRMMALD_logintype" = ''Mobile''
    )';

    RETURN QUERY EXECUTE v_sqlexc;

END;
$$;